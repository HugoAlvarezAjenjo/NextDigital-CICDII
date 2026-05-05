# Práctica: Hello World en Kubernetes con Minikube y Argo CD

Aplicación web estática desplegada en Kubernetes usando Minikube como clúster local y Argo CD como herramienta GitOps.

## Estructura del proyecto

```
practica/
├── app/
│   ├── index.html        # Página web Hello World
│   └── nginx.conf        # Configuración de nginx con endpoint /health
├── Dockerfile            # Imagen Docker basada en nginx:alpine
├── k8s/
│   ├── deployment.yaml   # Deployment con probes de salud
│   ├── service.yaml      # Service ClusterIP
│   └── ingress.yaml      # Ingress para acceso externo
├── argocd/
│   └── application.yaml  # Application de Argo CD
├── docs/                 # Capturas y evidencias
└── README.md
```

## Decisiones técnicas

### Aplicación: HTML estático con nginx

Se eligió servir un archivo HTML estático con nginx en lugar de un servidor de aplicación (Node.js, Python, etc.) porque:

- La práctica pide un "hello world"; no necesita lógica de backend.
- nginx es un servidor probado en producción, ligero y rápido.
- La imagen `nginx:1.27-alpine` pesa ~40MB, lo que acelera los despliegues.

### Endpoint /health

El endpoint `/health` se configura directamente en `nginx.conf` devolviendo `{"status":"ok"}` con código 200. Esto permite que Kubernetes verifique la salud del contenedor sin necesidad de código adicional.

### Dockerfile

```dockerfile
FROM nginx:1.27-alpine
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

- Se usa una sola etapa porque no hay compilación.
- El contexto de build es `practica/app/` (donde están los archivos fuente).

### Manifiestos de Kubernetes

| Recurso | Propósito |
|---------|-----------|
| **Deployment** | Define 2 réplicas del pod con la imagen `hello-world:1.0.0`. Incluye `livenessProbe` y `readinessProbe` contra `/health`. |
| **Service** | Expone los pods internamente en el puerto 80 mediante ClusterIP. |
| **Ingress** | Permite acceder a la app desde fuera del clúster usando el host `hello.local`. |

### Probes de salud

- **livenessProbe**: si `/health` deja de responder, Kubernetes reinicia el contenedor. `initialDelaySeconds: 5`, `periodSeconds: 10`.
- **readinessProbe**: mientras `/health` no responda, el pod no recibe tráfico del Service. `initialDelaySeconds: 3`, `periodSeconds: 5`.

### Argo CD

La `Application` de Argo CD:

- Apunta al path `practica/k8s` del repositorio.
- Usa sincronización automática con `prune: true` (elimina recursos huérfanos) y `selfHeal: true` (revierte cambios manuales en el clúster).
- Despliega en el namespace `default` del clúster local.

## Guía de despliegue en Minikube

### Requisitos previos

- Docker instalado y funcionando
- Minikube instalado
- kubectl configurado
- Argo CD CLI (opcional, para gestión desde terminal)

### 1. Arrancar Minikube y activar Ingress

```bash
minikube start
minikube addons enable ingress
```

### 2. Construir la imagen Docker dentro de Minikube

```bash
eval $(minikube docker-env)
docker build -t hello-world:1.0.0 -f practica/Dockerfile practica/app/
```

### 3. Aplicar los manifiestos

```bash
kubectl apply -f practica/k8s/
```

### 4. Verificar el despliegue

```bash
kubectl get pods
kubectl get svc hello-world
kubectl get ingress hello-world
```

### 5. Configurar acceso local

Obtener la IP de Minikube y añadirla a `/etc/hosts`:

```bash
echo "$(minikube ip) hello.local" | sudo tee -a /etc/hosts
```

Acceder a `http://hello.local` en el navegador.

### 6. Desplegar con Argo CD

```bash
# Instalar Argo CD en el clúster (si no está instalado)
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Esperar a que esté listo
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=120s

# Obtener contraseña inicial
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Aplicar la Application
kubectl apply -f practica/argocd/application.yaml
```

A partir de este momento, cualquier cambio en `practica/k8s/` que se suba a `main` se sincronizará automáticamente con el clúster.

## Versionado de imágenes

La imagen se versiona manualmente con tags semánticos (`1.0.0`, `1.1.0`, etc.). Para actualizar:

1. Modificar el código en `app/`.
2. Reconstruir con un nuevo tag: `docker build -t hello-world:1.1.0 ...`
3. Actualizar el campo `image` en `deployment.yaml`.
4. Hacer commit y push — Argo CD aplica el cambio automáticamente.

## Mejoras futuras

- **CI/CD con GitHub Actions**: construir y publicar la imagen automáticamente en un registry (Docker Hub o GitHub Container Registry) en cada push.
- **Helm chart**: parametrizar réplicas, imagen y host del Ingress para reutilizar en distintos entornos.
- **TLS**: añadir cert-manager para servir la app con HTTPS.
- **Namespace dedicado**: desplegar en un namespace propio en lugar de `default`.
- **HPA (Horizontal Pod Autoscaler)**: escalar automáticamente según carga de CPU.
- **NetworkPolicy**: restringir el tráfico entre pods.
