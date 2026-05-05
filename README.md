# taller-kubernetes

Repositorio de apoyo para un taller de Kubernetes. Incluye scripts para preparar el entorno y una aplicación de ejemplo (`poke-app`) que puede ejecutarse en local, con `docker compose` o sobre Minikube.

## Contenido

- `scripts/install-k8s-tools.sh`: instala Docker Engine, `kubectl`, `minikube`, Argo CD CLI y dependencias relacionadas.
- `scripts/verify-k8s-tools.sh`: comprueba que las herramientas principales están disponibles en el `PATH`.
- `scripts/uninstall-k8s-tools.sh`: desinstala las herramientas instaladas por el script.
- `poke-app/`: aplicación de ejemplo con frontend, backend, servicio de autenticación y manifiestos de Kubernetes.

## Guía de instalación

### Windows

La instalación puede realizarse manualmente siguiendo la documentación oficial de cada herramienta:

1. Docker Desktop: https://docs.docker.com/desktop/setup/install/windows-install/
2. kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
3. Minikube: https://minikube.sigs.k8s.io/docs/start/
4. Argo CD CLI: https://argo-cd.readthedocs.io/en/stable/cli_installation/

### WSL2 y Linux

El script de instalación está orientado a distribuciones basadas en Debian o Ubuntu.

1. Dar permisos de ejecución a los scripts:

```bash
chmod +x scripts/install-k8s-tools.sh scripts/verify-k8s-tools.sh scripts/uninstall-k8s-tools.sh
```

2. Ejecutar la instalación:

```bash
./scripts/install-k8s-tools.sh
```

3. Verificar que las herramientas han quedado disponibles:

```bash
./scripts/verify-k8s-tools.sh
```

4. Si en algún momento es necesario eliminar las herramientas instaladas:

```bash
./scripts/uninstall-k8s-tools.sh
```

Aviso:

- La desinstalación elimina Docker y componentes asociados instalados para el taller.
- No se garantiza la conservación de imágenes, contenedores o datos de otros proyectos que también estén usando Docker en la misma máquina.
- Antes de desinstalar, conviene revisar si el entorno Docker se está utilizando para otros desarrollos.

Limpieza adicional de imágenes y caché de build:

```bash
docker builder prune -a
docker images | grep '^poke-app' | awk '{print $2}' | xargs docker rmi
```

#### Notas para WSL2

- Si un script falla al ejecutarse y se ha editado desde Windows, conviene comprobar que el archivo usa saltos de línea `LF` y no `CRLF`.
- En Visual Studio Code este ajuste puede revisarse y cambiarse desde la parte inferior derecha del editor.

## Guía de ejecución

La aplicación de ejemplo puede ejecutarse de tres formas distintas, según el objetivo de la práctica.

### Ejecución en local

Esta opción arranca los servicios del proyecto directamente en la máquina local. El script:

- instala dependencias del frontend si todavía no existen,
- compila los proyectos Java,
- levanta la base de datos PostgreSQL con `docker compose`,
- arranca `auth`, `back` y `front`.

Comando:

```bash
chmod +x poke-app/run-poke-app.sh
./poke-app/run-poke-app.sh
```

Puertos utilizados:

- frontend: `http://localhost:5173`
- backend: `http://localhost:5180`
- auth: `http://localhost:5190`
- base de datos: `localhost:55432`

Requisitos mínimos para esta modalidad:

- `java`
- `mvn`
- `npm`
- `docker` con `docker compose`

### Ejecución con Docker Compose

Esta opción construye y arranca la aplicación completa en contenedores.

```bash
cd poke-app
docker compose up -d --build
```

Servicios expuestos:

- frontend: `http://localhost:5173`
- backend: `http://localhost:5180`
- auth: `http://localhost:5190`

Para detener el entorno:

```bash
cd poke-app
docker compose down
```

### Ejecución con Minikube

La guía completa de despliegue con Minikube está en [`poke-app/k8s/README.md`](./poke-app/k8s/README.md).

Ese documento incluye:

- construcción de imágenes en el daemon Docker de Minikube,
- aplicación de manifiestos con Kustomize,
- comprobación del estado del despliegue,
- configuración del host `poke.local`,
- scripts de apoyo para redeploy y limpieza.

## Scripts de ayuda para Minikube

Además del despliegue manual, el repositorio incluye varios scripts para acelerar el trabajo durante el taller.

Se recomienda utilizar estos scripts solo después de haber realizado el proceso manual varias veces, para entender con claridad cada paso del despliegue y la actualización de la aplicación en Kubernetes.

### Despliegue completo

```bash
chmod +x scripts/deploy-minikube-e2e.sh
./scripts/deploy-minikube-e2e.sh
```

Este script:

- arranca Minikube,
- activa Ingress,
- construye las imágenes,
- aplica los manifiestos,
- espera a que los `Deployment` queden listos,
- muestra la IP del clúster y el host que debe añadirse localmente.

### Construcción de imágenes versionadas para Minikube

Si se quiere construir manualmente las imágenes con una versión concreta antes de desplegar, puede usarse:

```bash
./scripts/build-minikube-images.sh 1.1.0
```

Este script:

- arranca Minikube si todavía no está levantado,
- activa el addon de Ingress,
- conecta Docker al daemon interno de Minikube,
- construye las imágenes `poke-auth`, `poke-back` y `poke-front` con la versión indicada en el comando,
- actualiza los archivos `deployment.yaml` para que usen esa misma versión en los campos `image`.

Los `Deployment` que actualiza son:

- `poke-app/k8s/auth/deployment.yaml`
- `poke-app/k8s/back/deployment.yaml`
- `poke-app/k8s/front/deployment.yaml`

### Aplicar cambios en una app ya desplegada

Si se modifica `front`, `back` o `auth`, no es necesario rehacer todo el despliegue. Puede reconstruirse solo la imagen afectada y reiniciar el `Deployment` correspondiente:

```bash
./scripts/apply-pod-changes.sh front
./scripts/apply-pod-changes.sh back
./scripts/apply-pod-changes.sh auth
```

Si lo que cambia son los manifiestos de Kubernetes:

```bash
./scripts/apply-pod-changes.sh manifests
```

### Limpiar el despliegue de Kubernetes

```bash
./scripts/cleanup-deployment.sh
```

Si además se quiere eliminar el volumen persistente de la base de datos:

```bash
./scripts/cleanup-deployment.sh --delete-pvc
```

### Eliminar el clúster de Minikube

```bash
./scripts/cleanup-minikube.sh
```

Para hacer una limpieza más completa:

```bash
./scripts/cleanup-minikube.sh --purge
```

## Referencias adicionales

- Guía específica de Kubernetes: [`poke-app/k8s/README.md`](./poke-app/k8s/README.md)

## Carpeta `argocd`

La carpeta [`argocd/`](./argocd) contiene los manifiestos necesarios para registrar este repositorio en Argo CD y desplegar la aplicación desde Git.

### `argocd/upm.yaml`

Este archivo define una `Application` de Argo CD:

- crea la aplicación `upm`,
- apunta al repositorio `git@github.com:PedroPabloDomenech-next/taller-kubernetes.git`,
- indica que los manifiestos a desplegar están en `poke-app/k8s`,
- despliega contra el clúster interno (`https://kubernetes.default.svc`) en el namespace `default`,
- activa sincronización automática.

### `argocd/repo-upm-secret.yaml`

Este archivo define un `Secret` de tipo repositorio para Argo CD:

- registra el repositorio Git que Argo CD debe poder leer,
- usa autenticación SSH mediante `sshPrivateKey`,
- debe existir en el namespace `argocd`,
- incluye la etiqueta `argocd.argoproj.io/secret-type: repository`, que permite a Argo CD reconocerlo como credencial de repositorio.

Este secreto es necesario cuando Argo CD debe acceder a un repositorio privado por SSH.

### Orden recomendado de aplicación

Primero debe aplicarse el secreto del repositorio y después la aplicación:

```bash
kubectl apply -f argocd/repo-upm-secret.yaml
kubectl apply -f argocd/upm.yaml
```

### Nota de seguridad

La clave privada SSH del archivo `argocd/repo-upm-secret.yaml` da acceso al repositorio configurado. Conviene gestionarla como credencial sensible y evitar reutilizarla fuera del entorno del taller.
