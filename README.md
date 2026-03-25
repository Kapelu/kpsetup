<div align="center">
<h1 style='margin: 0 0 2rem; font-size: 2.5rem;'>🔧 setup-kapelu</h1 >
</div>
<div align="center">

[![npm version](https://img.shields.io/npm/v/setup-kapelu.svg)](https://www.npmjs.com/package/kpsetup)
![Bash](https://img.shields.io/badge/Bash-4%2B-blue)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%2B-orange)
![License](https://img.shields.io/badge/License-MIT-blue)
![Version](https://img.shields.io/badge/version-3.0-informational)

> 🐧 Ubuntu_OS | 🚀 One-command setup
</div>

<div align="center">

## Descripción general

`script-setup` es una colección de utilidades de terminal ***post-install*** orientadas al rendimiento, diseñadas para mejorar la productividad de los desarrolladores en sistemas Ubuntu. El proyecto prioriza la baja sobrecarga, la arquitectura modular de Bash y un comportamiento de ejecución predecible.

---
## ⚡ Instalación Rápida
</div>


```bash
# Instalar globalmente vía npm
```
```
setup-kapelu/
├── bin/
│   └── setup-kapelu          # Script principal ejecutable
├── lib/
│   ├── config/
│   │   ├── .bashrc           # Configuración bash personalizada
│   │   └── protect-main.json # Archivo de configuración de `main` en Github
│   └── scripts/
│       ├── btn-log.sh        # Script: cerrar sesión
│       ├── btn-shd.sh        # Script: apagar
│       ├── btn-sus.sh        # Script: suspender
│       └── node-clean.sh     # Script: limpieza node_modules
├── src/
│   └── setup-kapelu.sh       # Fuente con documentación completa
├── package.json
├── README.md
└── LICENSE
```
<div align="center">

## 📦 Modulos

</div>

⚠️ Requisito importante

Esto solo funciona en Bash 4+ (por declare -A).

En sistemas viejos (ej: macOS antiguo con Bash 3), rompe.

------------------------------------------------------------------------

------------------------------------------------------------------------

------------------------------------------------------------------------