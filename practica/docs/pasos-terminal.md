# Pasos ejecutados en terminal

## 1. Arrancar Minikube y activar Ingress

```bash
minikube start
minikube addons enable ingress
```

## 2. Configurar Docker para usar el daemon de Minikube

```bash
eval $(minikube docker-env)
```

## 3. Construir la imagen Docker

Desde la raíz del repositorio:

```bash
docker build -t hello-world:1.0.0 -f practica/Dockerfile practica/app/
```

## 4. Aplicar los manifiestos de Kubernetes

```bash
kubectl apply -f practica/k8s/
```

Esto crea:
- `deployment.apps/hello-world`
- `service/hello-world`
- `ingress.networking.k8s.io/hello-world`

## 5. Verificar el despliegue

```bash
kubectl get pods
kubectl get svc hello-world
kubectl get ingress hello-world
```

## 6. Acceder a la aplicación (WSL + Windows)

Usar port-forward para exponer el servicio en localhost:

```bash
kubectl port-forward svc/hello-world 8080:80
```

Abrir en el navegador de Windows: `http://localhost:8080`

## 7. Desplegar con Argo CD (opcional)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s
kubectl apply -f practica/argocd/application.yaml
```
