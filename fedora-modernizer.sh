#!/bin/bash

# =============================================================================
# INSTALADOR RÁPIDO - MODERNIZACIÓN COMPLETA DE FEDORA
# Ejecuta: curl -sSL [URL] | bash
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║         🚀 FEDORA WORKSTATION 42 MODERNIZER 🚀            ║"
    echo "║                                                              ║"
    echo "║         Transforma tu Fedora en una experiencia moderna     ║"
    echo "║         Estilo Windows + macOS + Optimización total          ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}[PASO $1/7]${NC} $2"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_status() {
    echo -e "${BLUE}➤${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Verificaciones iniciales
print_header

if [ "$EUID" -eq 0 ]; then
    print_error "No ejecutes este script como root!"
    exit 1
fi

if ! command -v dnf &> /dev/null; then
    print_error "Este script es solo para Fedora"
    exit 1
fi

print_status "Verificando conexión a internet..."
if ! ping -c 1 google.com &> /dev/null; then
    print_error "Sin conexión a internet"
    exit 1
fi

print_success "Verificaciones completadas"
sleep 2

# =============================================================================
# PASO 1: ACTUALIZACIÓN DEL SISTEMA
# =============================================================================
print_header
print_step "1" "ACTUALIZANDO SISTEMA BASE"

print_status "Actualizando repositorios..."
sudo dnf update -y --refresh

print_status "Instalando herramientas esenciales..."
sudo dnf install -y curl wget git vim htop neofetch flatpak snapd dnf-plugins-core \
    util-linux-user dconf-editor gnome-tweaks chrome-gnome-shell

print_success "Sistema base actualizado"

# =============================================================================
# PASO 2: CONFIGURACIÓN DE REPOSITORIOS
# =============================================================================
print_header
print_step "2" "CONFIGURANDO REPOSITORIOS ADICIONALES"

print_status "Habilitando RPM Fusion..."
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || true

print_status "Configurando Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

print_status "Habilitando Snap..."
sudo systemctl enable --now snapd
sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true

print_success "Repositorios configurados"

# =============================================================================
# PASO 3: PRESERVAR Y OPTIMIZAR WIFI
# =============================================================================
print_header
print_step "3" "PRESERVANDO Y OPTIMIZANDO WIFI"

print_status "Verificando WiFi..."
if nmcli radio wifi | grep -q "enabled"; then
    print_success "WiFi funcionando correctamente"
else
    print_warning "Habilitando WiFi..."
    nmcli radio wifi on
fi

print_status "Instalando drivers WiFi..."
sudo dnf install -y NetworkManager-wifi wireless-tools wpa_supplicant iw

print_status "Optimizando NetworkManager..."
sudo tee /etc/NetworkManager/conf.d/wifi-optimization.conf > /dev/null << 'EOF'
[main]
plugins=ifupdown,keyfile

[device]
wifi.scan-rand-mac-address=no
wifi.powersave=2

[connection]
wifi.powersave=2
EOF

sudo systemctl restart NetworkManager

print_success "WiFi optimizado y protegido"

# =============================================================================
# PASO 4: INSTALACIÓN DE TEMAS MODERNOS
# =============================================================================
print_header
print_step "4" "INSTALANDO TEMAS MODERNOS (ESTILO WINDOWS + MACOS)"

print_status "Instalando temas base..."
sudo dnf install -y papirus-icon-theme breeze-gtk adwaita-gtk2-theme

print_status "Descargando tema WhiteSur (estilo macOS)..."
cd /tmp
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd WhiteSur-gtk-theme
./install.sh -c Dark -c Light -s standard -i fedora --silent 2>/dev/null || ./install.sh -c Dark
cd /tmp

print_status "Instalando iconos WhiteSur..."
git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
cd WhiteSur-icon-theme
./install.sh -a --silent 2>/dev/null || ./install.sh
cd ~

print_success "Temas modernos instalados"

# =============================================================================
# PASO 5: CONFIGURACIÓN DE INTERFAZ MODERNA
# =============================================================================
print_header
print_step "5" "CONFIGURANDO INTERFAZ MODERNA"

print_status "Instalando Extension Manager..."
flatpak install -y flathub com.mattjakeman.ExtensionManager 2>/dev/null || true

print_status "Aplicando configuraciones de GNOME..."

# Tema principal
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark' 2>/dev/null || gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark' 2>/dev/null || gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Configurar botones de ventana (estilo macOS)
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# Configuraciones visuales
gsettings set org.gnome.desktop.interface enable-animations true
gsettings set org.gnome.desktop.interface enable-hot-corners false

# Instalar extensiones esenciales
print_status "Configurando extensiones..."
sudo dnf install -y gnome-shell-extension-dash-to-dock gnome-shell-extension-appindicator 2>/dev/null || true

print_success "Interfaz moderna configurada"

# =============================================================================
# PASO 6: FONDOS DE PANTALLA Y OPTIMIZACIONES
# =============================================================================
print_header
print_step "6" "FONDOS MODERNOS Y OPTIMIZACIONES"

print_status "Creando directorio de fondos..."
mkdir -p ~/Pictures/Wallpapers

print_status "Configurando fondos modernos..."
# Crear un fondo SVG moderno
cat > ~/Pictures/Wallpapers/modern-gradient.svg << 'EOF'
<svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#764ba2;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#f093fb;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="100%" height="100%" fill="url(#grad1)" />
</svg>
EOF

gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/modern-gradient.svg"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/Wallpapers/modern-gradient.svg"

print_status "Aplicando optimizaciones de rendimiento..."
# Configurar swappiness
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Habilitar trim para SSD
sudo systemctl enable fstrim.timer

# Instalar y configurar tuned
sudo dnf install -y tuned
sudo systemctl enable --now tuned
sudo tuned-adm profile desktop

print_success "Optimizaciones aplicadas"

# =============================================================================
# PASO 7: ARREGLAR PANTALLA DE LOGIN
# =============================================================================
print_header
print_step "7" "MODERNIZANDO PANTALLA DE LOGIN"

print_status "Configurando GDM..."
sudo tee /etc/gdm/custom.conf > /dev/null << 'EOF'
[daemon]
AutomaticLoginEnable=False
WaylandEnable=true
DefaultSession=gnome.desktop

[security]
DisallowTCP=true

[debug]
Enable=false
EOF

print_status "Limpiando logs problemáticos..."
sudo rm -f /var/log/gdm/* 2>/dev/null || true
sudo journalctl --vacuum-time=1d

print_status "Aplicando tema moderno a login..."
# Copiar fondo para GDM
sudo mkdir -p /usr/share/backgrounds/gdm
sudo cp ~/Pictures/Wallpapers/modern-gradient.svg /usr/share/backgrounds/gdm/

print_success "Pantalla de login modernizada"

# =============================================================================
# APLICACIONES ESENCIALES
# =============================================================================
print_status "Instalando aplicaciones modernas..."
sudo dnf install -y firefox thunderbird libreoffice gimp vlc 2>/dev/null || true

# =============================================================================
# SCRIPTS DE MANTENIMIENTO
# =============================================================================
print_status "Creando scripts de mantenimiento..."

cat > ~/fedora-maintenance.sh << 'EOF'
#!/bin/bash
echo "🔄 Actualizando sistema..."
sudo dnf update -y
echo "🧹 Limpiando caché..."
sudo dnf clean all
flatpak uninstall --unused -y
echo "🔧 Optimizando..."
sudo fstrim -av
echo "✅ Mantenimiento completado!"
EOF

chmod +x ~/fedora-maintenance.sh

cat > ~/reset-theme.sh << 'EOF'
#!/bin/bash
echo "🎨 Reaplicando tema moderno..."
gsettings set org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'WhiteSur-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
echo "✅ Tema reaplicado!"
EOF

chmod +x ~/reset-theme.sh

# =============================================================================
# FINALIZACIÓN
# =============================================================================
print_header

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║                🎉 ¡MODERNIZACIÓN COMPLETADA! 🎉              ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
print_success "Tu Fedora ha sido transformado exitosamente"
echo ""
echo -e "${CYAN}CAMBIOS APLICADOS:${NC}"
echo "  ✅ Sistema actualizado y optimizado"
echo "  ✅ Tema moderno WhiteSur instalado"
echo "  ✅ Interfaz estilo Windows + macOS"
echo "  ✅ WiFi preservado y optimizado"
echo "  ✅ Pantalla de login modernizada"
echo "  ✅ Fondos de pantalla modernos"
echo "  ✅ Optimizaciones de rendimiento"
echo ""
echo -e "${YELLOW}SCRIPTS CREADOS:${NC}"
echo "  🔧 ~/fedora-maintenance.sh - Mantenimiento automático"
echo "  🎨 ~/reset-theme.sh - Reaplicar tema si se pierde"
echo ""
echo -e "${PURPLE}PRÓXIMOS PASOS:${NC}"
echo "  1. Reinicia tu sistema: sudo reboot"
echo "  2. Abre Extension Manager para más personalizaciones"
echo "  3. Ejecuta ~/fedora-maintenance.sh semanalmente"
echo ""

print_warning "⚠️  IMPORTANTE: Reinicia ahora para aplicar todos los cambios"

read -p "¿Quieres reiniciar ahora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_status "Reiniciando en 5 segundos..."
    sleep 5
    sudo reboot
else
    print_warning "Recuerda reiniciar manualmente con: sudo reboot"
fi