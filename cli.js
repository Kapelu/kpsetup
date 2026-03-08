#!/usr/bin/env node

const { execSync } = require("child_process");
const pkg = require("./package.json");

function latestVersion() {
  try {
    return execSync("npm view Post-Install version").toString().trim();
  } catch {
    return null;
  }
}

function updateIfNeeded() {
  const current = pkg.version;
  const latest = latestVersion();

  if (!latest) return;

  if (current !== latest) {
    console.log(`⬆ Nueva versión disponible ${latest} (actual ${current})`);
    console.log("Actualizando Post-Install...\n");

    execSync("npm install -g Post-Install", { stdio: "inherit" });

    console.log("\n✔ Post-Install actualizado");
    process.exit(0);
  }
}

try {

  console.log("🔎 Verificando actualizaciones...\n");
  updateIfNeeded();

  console.log("🚀 Ejecutando install.sh\n");

  execSync("bash install.sh", { stdio: "inherit" });

} catch (err) {
  console.error("❌ Error ejecutando Post-Install");
  process.exit(1);
}


//const { execSync } = require("child_process");
//execSync("bash install.sh", { stdio: "inherit" });
