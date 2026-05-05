# Práctica: despliegue de una aplicación web en Kubernetes con Minikube y Argo CD

## Objetivo

Desarrolla y despliega una aplicación web sencilla (frontal base con hello world) sobre Kubernetes usando Minikube, y GitOps con Argo CD.

La práctica debe demostrar que eres capaz de:

- versionar una aplicación y su infraestructura en GitHub;
- dockerizar una aplicación web;
- definir manifiestos de Kubernetes;
- configurar probes de salud de readiness y liveness;
- desplegar la aplicación en Minikube;
- creación de la application con Argo CD.

## Idea principal de la práctica

Lo más importante de esta práctica es que el repositorio tenga una estructura clara y coherente, y que los archivos entregados tengan sentido entre sí.

Se valorará especialmente:

- una organización lógica de carpetas y archivos;
- nombres claros y consistentes;
- manifiestos de Kubernetes bien separados por responsabilidad;
- documentación suficiente para entender cómo está montada la solución;
- coherencia entre imágenes Docker, `Deployment`, `Service`, `Ingress`, secretos y configuración de Argo CD.

Si el ejemplo no llega a funcionar completamente, la práctica se considera válida siempre que la estructura del proyecto, los manifiestos y los archivos entregados sean lógicos, consistentes y estén bien organizados.

## Requisitos de la práctica

Debes construir una solución completa que incluya, como mínimo, los siguientes elementos:

### 1. Aplicación y control de versiones

- Mantén el código fuente y la configuración de infraestructura versionados en GitHub.
- Organiza el repositorio de forma clara para separar, si procede, la aplicación, los manifiestos y la documentación.

### 2. Contenerización

- Crea la imagen Docker de la aplicación.
- Define un `Dockerfile` coherente con el tipo de aplicación elegida.

### 3. Despliegue declarativo en Kubernetes

- Define los manifiestos necesarios para desplegar la aplicación en Kubernetes.
- Incluye, según corresponda, recursos como `Deployment`, `Service`, `Ingress` o cualquier otro que aporte valor a la solución.

### 4. Salud y operabilidad

- Configura probes de salud adecuadas para la aplicación:
  - `livenessProbe`
  - `readinessProbe`

### 5. Ejecución en Minikube

- Despliega la solución en un clúster local con Minikube.
- Verifica que la aplicación queda accesible y funcionando correctamente.

### 6. Gestión GitOps con Argo CD

- Configura Argo CD para gestionar el despliegue desde el repositorio Git.
- Define el estado deseado de la aplicación en Git y sincronízalo con el clúster.

## Entregables

La entrega debe incluir, como mínimo:

- enlace al repositorio de GitHub;
- capturas o evidencias del funcionamiento en Minikube y Argo CD, o los hitos que se hayan conseguido. Capturas de pantalla en una carpeta docs/, por ejemplo;
- un `README` detallado que explique las decisiones técnicas tomadas durante el proyecto, incluyendo el razonamiento detrás de ellas y cualquier aspecto que aporte valor o contexto a la entrega.

## Contenido mínimo esperado en el README

Como referencia, debería hacer una descripción del proyecto y responder preguntas como:

- ¿Qué hace cada carpeta principal?
- ¿Qué recursos de Kubernetes se han definido y con qué propósito?
- ¿Cómo se construyen las imágenes y cómo se versionan?
- ¿Qué mejoras futuras serían razonables si el proyecto evolucionara?

## Resultado esperado

Al finalizar la práctica, debe existir una aplicación web funcional, desplegada en Minikube, gestionada de forma declarativa mediante manifiestos de Kubernetes y sincronizada desde Git mediante Argo CD.

Si el ejemplo no llega a funcionar completamente, la práctica se considera válida siempre que la estructura del proyecto, los manifiestos y los archivos entregados sean lógicos, consistentes y estén bien organizados.