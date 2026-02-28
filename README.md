<div align="center">
<p style='margin: 0 0 2rem; font-size: 2.5rem;'>script-setup</p >
</div>
<p align="center">
Pequeños Script post-install de Ubuntu, Entre ellos de configuración y personalización de procesos.
</p>
</br>

<div align="center">
<p style='margin: 0 0 2rem; font-size: 1.5rem;'>✅ node-clean</p >
</div>

### Descripción:
  Herramienta interactiva para localizar y eliminar carpetas 
  comunes en proyectos Node.js (node_modules, .next) dentro 
  de un directorio base. En `TARGETS=("node_modules" ".next")`()

### Características:
- Interfaz TUI basada en dialog
- Cálculo previo de espacio a liberar
- Borrado total o selectivo
- Soporte modo --dry-run
- Restauración segura del estado de la terminal

### Uso:
```bash
  node-clean [--dry-run]
```

<div align="center">
<p style='margin: 0 0 2rem; font-size: 1.5rem;'>✅ .bashrc</p >
</div>

### Descripción:
Esta script implementa un prompt dinámico optimizado con cacheo inteligente, orientado a entornos de desarrollo Node/Next.js.

### Características:

> ### Cache Global
```bash
__LAST_PWD=""
__PKG_MANAGER=""
__GIT_BRANCH=""
```
Esto evita recomputar información si no cambió el directorio.

**Ventaja**: reduce llamadas a disco y procesos externos → prompt más rápido.

> ### Búsqueda ascendente de package.json
```bash
find_package_json_upwards()
```

Recorre desde `$PWD` hacia `/` buscando `package.json`.

**Ventaja**:
El `.bashrc` estándar no detecta contexto de proyecto, en cambio esta versión detecta automáticamente si estás dentro de un proyecto Node aunque estés en subcarpetas profundas.

> ### Detección inteligente del package manager

```bash
detect_package_manager()
```

Busca el campo `packageManager` en `package.json`

Lockfiles:

- `pnpm-lock.yaml`
- `yarn.lock`
- `package-lock.json`

**Ventaja**: El .bashrc por defecto no:

- inspecciona archivos
- detecta lockfiles
- analiza JSON
- usa grep + sed + cut

Esta versión sí lo hace. Se ejecuta solo si cambia el directorio evitando parsear siempre, lo que deriva en una optimización real de rendimiento.


> ### Uso correcto de secuencias ANSI 

`\[\033[01;34m\]`

El uso de \[ y \] es correcto para que Bash:

- Calcule bien el ancho del prompt

- No rompa el cursor

- No desalineé el input


**Ventaja**: El prompt final muestra:
```bash
[pnpm] hostname:[main] ~/proyecto $
```
Mostrando colores diferenciados por contexto.

<div align="center">
<p style='margin: 0 0 2rem; font-size: 1.5rem;'>📈 Comparación con <strong>.bashrc</strong> estándar de Ubuntu vs Prompt v2.0</p >
</div>

<div align="center">

| Característica              | Ubuntu default | Tu versión |
|----------------------------|---------------|------------|
| Prompt estático            | ✔             | ❌         |
| Rama Git                   | ❌            | ✔          |
| Detectar Node project      | ❌            | ✔          |
| Detectar package manager   | ❌            | ✔          |
| Cache de estado            | ❌            | ✔          |
| Optimización por PWD       | ❌            | ✔          |
| Parsing JSON               | ❌            | ✔          |

</div>
</br >
<div align="center">
<p style='margin: 0 0 2rem; font-size: 1.5rem;'>🧠 Nivel Técnico del Script</p>
</div>


Esto ya no es un simple PS1. Es:

- Prompt contextual

- Con heurística de proyecto

- Con micro-optimización

- Con separación por responsabilidades

- Con reducción de overhead

Está más cerca de un mini framework de prompt que de un .bashrc común.
