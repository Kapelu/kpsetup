############################################
# ⚡ CACHE GLOBAL
############################################

__LAST_PWD=""
__PKG_MANAGER=""
__GIT_BRANCH=""

############################################
# 🔍 Buscar package.json hacia arriba
############################################

find_package_json_upwards() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    [ -f "$dir/package.json" ] && { echo "$dir/package.json"; return; }
    dir=$(dirname "$dir")
  done
}

############################################
# 📦 Detectar gestor (optimizado)
############################################

detect_package_manager() {
  local pkg_json
  pkg_json=$(find_package_json_upwards)

  if [ -n "$pkg_json" ]; then
    local manager
    manager=$(grep '"packageManager"' "$pkg_json" 2>/dev/null | \
      sed -E 's/.*"([^"]+)".*/\1/' | cut -d@ -f1)

    if [ -n "$manager" ]; then
      echo "$manager"
      return
    fi
  fi

  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    [ -f "$dir/pnpm-lock.yaml" ] && { echo "pnpm"; return; }
    [ -f "$dir/yarn.lock" ] && { echo "yarn"; return; }
    [ -f "$dir/package-lock.json" ] && { echo "npm"; return; }
    dir=$(dirname "$dir")
  done
}

############################################
# 🌿 Git branch rápido
############################################

get_git_branch() {
  git branch --show-current 2>/dev/null
}

############################################
# ⚡ Actualizar cache solo si cambia PWD
############################################

update_prompt_cache() {

  if [ "$PWD" != "$__LAST_PWD" ]; then
    __LAST_PWD="$PWD"

    # Package manager
    local manager
    manager=$(detect_package_manager)
    if [ -n "$manager" ]; then
      __PKG_MANAGER="[$manager]"
    else
      __PKG_MANAGER=""
    fi
  fi

  # Git (no depende tanto de PWD porque puede cambiar branch)
  local branch
  branch=$(get_git_branch)
  if [ -n "$branch" ]; then
    __GIT_BRANCH="[$branch]"
  else
    __GIT_BRANCH=""
  fi
}

PROMPT_COMMAND=update_prompt_cache

############################################
# 🎨 Prompt limpio y rápido
############################################

PS1='\[\033[01;34m\]${__PKG_MANAGER} \
\[\033[01;32m\]\h:\
\[\033[01;35m\]${__GIT_BRANCH} \
\[\033[00m\]\w \
\[\033[01;34m\]\$ \[\033[00m\]'