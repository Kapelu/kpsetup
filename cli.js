#!/usr/bin/env node

const { execSync } = require('child_process')
const path = require('path')
const fs = require('fs')

const SUPPORTED = ['ubuntu', 'linuxmint', 'pop', 'zorin', 'elementary', 'neon']

// Detectar distro (devuelve id + raw)
function detectDistro() {
  try {
    const osRelease = fs.readFileSync('/etc/os-release', 'utf8')

    const idMatch = osRelease.match(/^ID=(.*)$/m)
    if (!idMatch) throw new Error('No se pudo detectar ID')

    const id = idMatch[1].replace(/"/g, '').toLowerCase()

    return {
      id,
      raw: osRelease,
    }
  } catch (err) {
    console.error('❌ No se pudo detectar la distribución Linux')
    process.exit(1)
  }
}

// Detectar si es ubuntu-like usando ID_LIKE
function isUbuntuLike(osRelease) {
  const id = osRelease.match(/^ID=(.*)$/m)?.[1].replace(/"/g, '')
  const like = osRelease.match(/^ID_LIKE=(.*)$/m)?.[1].replace(/"/g, '')

  const values = `${id} ${like}`.toLowerCase()

  return values.includes('ubuntu')
}

const { id, raw } = detectDistro()

// Validación combinada
const isSupported = SUPPORTED.includes(id) || isUbuntuLike(raw)

if (!isSupported) {
  console.error(`
⚠️  ERROR

Este instalador solo soporta distribuciones basadas en Ubuntu.

Distro detectada: ${id}

Abortando...
`)
  process.exit(1)
}

// Ejecutar install.sh
const baseDir = __dirname
const script = path.join(baseDir, 'install.sh')

try {
  execSync(`BASE_DIR=${baseDir} bash ${script}`, {
    stdio: 'inherit',
  })
} catch (err) {
  console.error('❌ Error ejecutando instalación')
  process.exit(1)
}