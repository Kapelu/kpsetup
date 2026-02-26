
# ============================================
# Kapeclean v3.0 – Limpieza de proyectos Node.js
# Autor: Kapelu
# Date: 2025-08
# Licencia: MIT
# ============================================

# Entrar en pantalla alternativa
tput smcup
clear
# limpia scrollback
printf '\033[3J'   
# Modo dry-run
DRY_RUN=false
[[ "$1" == "--dry-run" ]] && DRY_RUN=true
# Carpetas a buscar
TARGETS=("node_modules" ".next")

# ========================
# Funciones auxiliares
# ========================

# Detectar dimensiones de terminal
TERM_WIDTH=$(tput cols)
TERM_HEIGHT=$(tput lines)

# Calcular altura de diálogo según cantidad de items
# ========================
calc_height() {
    local items=$1
    local max_height=$((TERM_HEIGHT - 8))
    [[ $items -lt $max_height ]] && echo $((items + 8)) || echo $max_height
}

# Acortar rutas largas
# ========================
shorten_path() {
    local path="$1"
    local max_len=$2
    local path_len=${#path}
    if (( path_len <= max_len )); then
        echo "$path"
    else
        local part_len=$(( (max_len - 3) / 2 ))
        echo "${path:0:part_len}…${path: -part_len}"
    fi
}

# Función de salida centralizada
# ========================
salir() {
    tput rmcup
    clear
    echo ""
    echo "Gracias por usar node-clean by Kapelu."
    echo "https://github.com/Kapelu"
    echo "¡Hasta la próxima!"
    echo ""
    exit 0
}

# Selección de carpeta raíz
# ========================
while true; do
    ROOT_DIR_NAME=$(dialog --title "Seleccionar carpeta raíz" \
        --inputbox "Ingrese la carpeta donde buscar:" 10 $((TERM_WIDTH / 2)) 3>&1 1>&2 2>&3)
    
    STATUS=$?  # Capturamos el exit code de dialog

    # Cancel o Escape
    if [[ $STATUS -ne 0 ]]; then
        salir
    fi

    # Si no ingresó nada
    if [[ -z "$ROOT_DIR_NAME" ]]; then
        dialog --msgbox "No ingresó ningún nombre de carpeta. Intente nuevamente." 6 $((TERM_WIDTH / 2))
        clear
        continue  # vuelve al inicio del while
    fi

    BASE_DIR="$HOME/$ROOT_DIR_NAME"

    if [[ -d "$BASE_DIR" ]]; then
        break  # Carpeta válida, salimos del bucle
    else
        dialog --msgbox "La carpeta $BASE_DIR no existe. Intente nuevamente." 6 $((TERM_WIDTH / 2))
        clear
    fi
done
clear

# Buscar targets a eliminar
# ========================
NODE_DIRS=()
for TARGET in "${TARGETS[@]}"; do
    while IFS= read -r path; do
        NODE_DIRS+=("$path")
    done < <(/usr/bin/find "$BASE_DIR" -name "$TARGET" -prune 2>/dev/null)
done

[[ ${#NODE_DIRS[@]} -eq 0 ]] && {
    clear
    dialog --msgbox "No se encontraron targets: ${TARGETS[*]}" 8 $((TERM_WIDTH / 2))
    clear
    tput rmcup
    exit 0
}

# Mostrar targets encontrados
# ========================
mostrar_carpetas() {
    DIR_LIST=""
    TOTAL_MB=0
    for DIR in "${NODE_DIRS[@]}"; do
        SIZE_MB=$(/usr/bin/du -sm --max-depth=0 "$DIR" 2>/dev/null | awk '{print $1}')
        DIR_LIST+=$(shorten_path "$DIR" 80)
        DIR_LIST+=" → ${SIZE_MB} MB\n"
        TOTAL_MB=$((TOTAL_MB + SIZE_MB))
    done

    HEIGHT=$(calc_height ${#NODE_DIRS[@]})
    dialog  --title "Carpetas encontradas" \
            --msgbox "Se encontraron ${#NODE_DIRS[@]} carpetas:\n\n$DIR_LIST\nTamaño total combinado: ${TOTAL_MB} MB" $HEIGHT $TERM_WIDTH
    clear
}

# Confirmación de borrado
# ========================
confirmar_borrado() {
    local DIRS=("$@")
    local TOTAL_MB=0
    for DIR in "${DIRS[@]}"; do
        SIZE_MB=$(/usr/bin/du -sm --max-depth=0 "$DIR" 2>/dev/null | awk '{print $1}')
        TOTAL_MB=$((TOTAL_MB + SIZE_MB))
    done

    COUNT=${#DIRS[@]}
    HEIGHT=10
    WIDTH=$((TERM_WIDTH / 2))

    dialog --title "Confirmación de borrado" \
            --yes-label "Sí" --no-label "No" \
            --yesno "Se van a eliminar ${COUNT} carpetas.\nEspacio total a liberar: ${TOTAL_MB} MB\n\n¿Desea continuar?" $HEIGHT $WIDTH
    return $?  # 0 = Sí, 1 = No
}

# Funciones de borrado completo
# ========================
borrar_todas() {
    if $DRY_RUN; then
        DIR_LIST=""
        for DIR in "${NODE_DIRS[@]}"; do
            DIR_LIST+=$(shorten_path "$DIR" 80)
            DIR_LIST+="\n"
        done
        HEIGHT=$(calc_height ${#NODE_DIRS[@]})
        dialog --msgbox "== DRY-RUN: Se eliminarían todas las carpetas ==\n\n$DIR_LIST" $HEIGHT $TERM_WIDTH
        clear
        return
    fi

    confirmar_borrado "${NODE_DIRS[@]}"
    [[ $? -ne 0 ]] && { clear; echo "Operación cancelada."; return; }

    TOTAL_DELETED_MB=0
    for DIR in "${NODE_DIRS[@]}"; do
        SIZE_MB=$(/usr/bin/du -sm --max-depth=0 "$DIR" 2>/dev/null | awk '{print $1}')
        /bin/rm -rf "$DIR"
        TOTAL_DELETED_MB=$((TOTAL_DELETED_MB + SIZE_MB))
    done
    dialog --msgbox "Se eliminaron todas las carpetas.\nEspacio liberado: ${TOTAL_DELETED_MB} MB" 10 $((TERM_WIDTH / 2))
    clear
}

# Opción de borrado múltiple con checklist
# ========================
borrar_checklist() {
    TOTAL_DELETED_MB=0
    CHECKLIST_ARGS=()
    MAP_DIRS=()

    for DIR in "${NODE_DIRS[@]}"; do
        SIZE_MB=$(/usr/bin/du -sm --max-depth=0 "$DIR" 2>/dev/null | awk '{print $1}')
        SHORT=$(shorten_path "$DIR" 50)
        LABEL="item$(( ${#MAP_DIRS[@]} + 1 ))"
        MAP_DIRS+=("$DIR")
        CHECKLIST_ARGS+=("$LABEL" "$SHORT → ${SIZE_MB} MB" "off")
    done

    HEIGHT=$(calc_height ${#NODE_DIRS[@]})
    SELECTED=$(dialog --title "Seleccionar carpetas a borrar" \
        --checklist "Use la barra espaciadora para seleccionar:" $HEIGHT $TERM_WIDTH 20 \
        "${CHECKLIST_ARGS[@]}" 3>&1 1>&2 2>&3)
    [[ $? -ne 0 || -z "$SELECTED" ]] && { clear; echo "Operación cancelada."; return; }

    TO_DELETE=()
    for LABEL in $SELECTED; do
        LABEL=$(echo "$LABEL" | tr -d '"')
        INDEX=$(( ${LABEL//[!0-9]/} - 1 ))
        TO_DELETE+=("${MAP_DIRS[$INDEX]}")
    done

    confirmar_borrado "${TO_DELETE[@]}"
    [[ $? -ne 0 ]] && { clear; echo "Operación cancelada."; return; }

    for DIR in "${TO_DELETE[@]}"; do
        SIZE_MB=$(/usr/bin/du -sm --max-depth=0 "$DIR" 2>/dev/null | awk '{print $1}')
        /bin/rm -rf "$DIR"
        TOTAL_DELETED_MB=$((TOTAL_DELETED_MB + SIZE_MB))
        dialog --msgbox "Eliminado: $(shorten_path "$DIR" 80) → ${SIZE_MB} MB" 6 $((TERM_WIDTH / 2))
        clear
    done
}

# Meú principal
# ========================
mostrar_carpetas
while true; do
    OPCION=$(dialog --title "Opciones de borrado" \
                    --menu "Seleccione una opción:" 12 50 3 \
                    1 "Borrar todas" \
                    2 "Borrado múltiple (checklist)" \
                    3 "Salir" 3>&1 1>&2 2>&3)
    STATUS=$?   # Capturamos el exit code de dialog

    # Si presiona Cancel o Escape, llamamos a salir()
    if [[ $STATUS -ne 0 ]]; then
        salir
    fi

    clear

    case $OPCION in
        1) 
            borrar_todas
            ;;
        2) 
            borrar_checklist
            ;;
        3) 
            salir
            ;;
        *) 
            dialog --msgbox "Opción inválida" 5 30
            clear
            ;;
    esac
done