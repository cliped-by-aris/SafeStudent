#!/bin/bash

echo "🔐 Instalando SafeStudent..."

# Crear directorio del programa
mkdir -p /opt/SafeStudent
cp safestudent.sh /opt/SafeStudent/
chmod +x /opt/SafeStudent/safestudent.sh
cp icon.png /opt/SafeStudent/

# Crear acceso directo
mkdir -p ~/.local/share/applications
cp config/safestudent.desktop ~/.local/share/applications/

# Añadir seguridad a .bashrc si no está
if ! grep -q "safe_guard" ~/.bashrc; then
    cat <<'EOF' >> ~/.bashrc

# SafeStudent protección
safe_guard() {
    local cmd="$BASH_COMMAND"
    local patterns=("rm -rf" "chmod 000" "mkfs" ":(){:|:&};:" "dd if=")
    for pattern in "${patterns[@]}"; do
        if [[ "$cmd" =~ $pattern ]]; then
            echo -e "\n\033[1;33m⚠ Comando peligroso: '$cmd'\033[0m"
            read -p "¿Backup antes de continuar? (s/N): " b
            if [[ "$b" =~ [sS] ]]; then
                mkdir -p "$HOME/SafeStudent_backups/emergency/$(date +%Y%m%d_%H%M%S)"
                rsync -a "$HOME/" "$_" --exclude=SafeStudent_backups --exclude=.cache
                echo -e "\033[1;32m✅ Backup hecho\033[0m"
            fi
            read -p "¿Ejecutar comando igualmente? (s/N): " c
            [[ "$c" =~ [sS] ]] || return 1
        fi
    done
}
trap 'safe_guard' DEBUG
EOF
fi

echo "✅ Instalación completa. Reinicia tu terminal o ejecuta:"
echo "source ~/.bashrc"
