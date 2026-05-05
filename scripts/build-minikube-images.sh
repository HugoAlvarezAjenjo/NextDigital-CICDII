#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
K8S_DIR="${REPO_ROOT}/poke-app/k8s"
NAMESPACE="poke-app"
HOSTNAME_VALUE="${HOSTNAME_VALUE:-poke.local}"
IMAGE_TAG="${1:-}"

log() {
  printf '\n==> %s\n' "$1"
}

usage() {
  echo "Uso: $0 <image-tag>" >&2
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Falta el comando requerido: $1" >&2
    exit 1
  fi
}

update_deployment_image() {
  local file="$1"
  local image_name="$2"

  perl -0pi -e "s|image: ${image_name}:[^\\s]+|image: ${image_name}:${IMAGE_TAG}|g" "${file}"
}

update_deployments() {
  log "Actualizando deployment yamls con la version ${IMAGE_TAG}"
  update_deployment_image "${K8S_DIR}/auth/deployment.yaml" "poke-auth"
  update_deployment_image "${K8S_DIR}/back/deployment.yaml" "poke-back"
  update_deployment_image "${K8S_DIR}/front/deployment.yaml" "poke-front"
}

build_images() {
  log "Construyendo imagen poke-auth:${IMAGE_TAG}"
  docker build -t "poke-auth:${IMAGE_TAG}" "${REPO_ROOT}/poke-app/auth"

  log "Construyendo imagen poke-back:${IMAGE_TAG}"
  docker build -t "poke-back:${IMAGE_TAG}" "${REPO_ROOT}/poke-app/back"

  log "Construyendo imagen poke-front:${IMAGE_TAG}"
  docker build \
    -t "poke-front:${IMAGE_TAG}" \
    "${REPO_ROOT}/poke-app/front" \
    --build-arg VITE_API_BASE_URL=/api/v2 \
    --build-arg VITE_AUTH_BASE_URL=/auth
}

main() {
  require_command minikube
  require_command kubectl
  require_command docker
  require_command perl

  if [[ -z "${IMAGE_TAG}" ]]; then
    usage
    exit 1
  fi

  log "Arrancando Minikube"
  minikube start

  log "Activando addon ingress"
  minikube addons enable ingress

  log "Conectando al daemon Docker de Minikube"
  eval "$(minikube -p minikube docker-env --shell bash)"

  update_deployments
  build_images
}

main "$@"
