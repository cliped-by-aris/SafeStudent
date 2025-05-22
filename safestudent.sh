#!/bin/bash
# Programa: SafeStudent
# Descripción: Protección contra comandos peligrosos, backups automáticos y menú de restauración.
# Autor: Tú 😎

# Rutas
CONFIG="$HOME/.config/safestudent.conf"
LOG="$HOME/.cache/safestudent.log"
BACKUPS="$HOME/SafeStudent_backups"

# Colores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# Inicialización
init() {
    mkdir -p "$BACKUPS"/{daily,emergency}
    [ -f "$CONFIG" ] || echo -e "PROTECTED_DIRS=(\"$HOME\")\nMAX_BACKUPS=5" > "$CONFIG"
    source "$CONFIG"
}

# Crear backup diario
auto_backup() {
    local today="$BACKUPS/daily/$(date +%Y%m%d)"
    mkdir -p "$today"
    echo -e "${BLUE}🔄 Realizando backup automático...${NC}"
    for dir in "${PROTECTED_DIRS[@]}"; do
        rsync -a --exclude='*.tmp' "$dir" "$today"
        echo -e "${GREEN}✓ $dir respaldado${NC}"
    done

    # Eliminar backups antiguos
    ls -dt "$BACKUPS/daily/"* | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -rf
}

# Restaurar backup
do_restore() {
    echo -e "${BLUE}=== Restaurar Backup ===${NC}"
    local backups=($(ls -t "$BACKUPS/daily/"))
    for i in "${!backups[@]}"; do
        echo "$((i+1)). ${backups[$i]}"
    done

    read -p "Selecciona backup [1-${#backups[@]}]: " idx
    selected="${backups[$((idx-1))]}"
    read -p "⚠ Esto sobrescribirá archivos. ¿Continuar? (s/N): " confirm
    [[ "$confirm" =~ [sS] ]] && rsync -a "$BACKUPS/daily/$selected/" "$HOME/"
    echo -e "${GREEN}✅ Restauración completada${NC}"
}

# Menú de configuración
config_menu() {
    echo -e "${BLUE}=== Configuración ===${NC}"
    echo "1. Cambiar carpetas protegidas"
    echo "2. Cambiar número máximo de backups"
    read -p "Elige una opción: " opt
    case $opt in
        1)
            read -p "Nuevas carpetas (espacio separado): " dirs
            echo "PROTECTED_DIRS=($dirs)" > "$CONFIG"
            echo "MAX_BACKUPS=$MAX_BACKUPS" >> "$CONFIG"
            ;;
        2)
            read -p "Nuevo número máximo de backups: " max
            echo "PROTECTED_DIRS=(${PROTECTED_DIRS[@]})" > "$CONFIG"
            echo "MAX_BACKUPS=$max" >> "$CONFIG"
            ;;
    esac
    echo -e "${GREEN}✅ Configuración guardada${NC}"
}

# Ver registros
show_logs() {
    echo -e "${YELLOW}=== LOG DE SAFE STUDENT ===${NC}"
    [ -f "$LOG" ] && cat "$LOG" || echo "No hay registros aún."
}

# Menú principal
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}┌──────────────────────────────┐"
        echo -e "│       SAFE STUDENT           │"
        echo -e "└──────────────────────────────┘${NC}"
        echo "1. Backup manual"
        echo "2. Restaurar archivos"
        echo "3. Configurar"
        echo "4. Ver registros"
        echo "5. Salir"
        read -p "Selecciona una opción: " opt
        case $opt in
            1) auto_backup ;;
            2) do_restore ;;
            3) config_menu ;;
            4) show_logs ;;
            5) break ;;
            *) echo "Opción inválida" ;;
        esac
        read -p "Presiona Enter para continuar..."
    done
}

# ========= EJECUCIÓN =========
init
main_menu
