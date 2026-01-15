#!/usr/bin/env bash
# ==============================================
# Linux8200 Mixer Installer Script
# Safe to run from inside the Mixer
# ==============================================

set -euo pipefail

# -------------------------
# Capture real user BEFORE privilege escalation
# -------------------------
if [ -n "${SUDO_USER-}" ]; then
  REAL_USER="$SUDO_USER"
elif [ -n "${PKEXEC_UID-}" ]; then
  REAL_USER=$(id -nu "$PKEXEC_UID")
else
  REAL_USER=$(logname 2>/dev/null || echo "$USER")
fi

# Save session environment variables (may be empty)
DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS-}"
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR-}"
DISPLAY="${DISPLAY-}"
WAYLAND_DISPLAY="${WAYLAND_DISPLAY-}"

TMP_ENV_FILE="$(mktemp /tmp/linux8200_installer_env.XXXXXX)"
trap 'rm -f "$TMP_ENV_FILE"' EXIT
printf 'DBUS_SESSION_BUS_ADDRESS=%q\nXDG_RUNTIME_DIR=%q\nDISPLAY=%q\nWAYLAND_DISPLAY=%q\n' \
  "$DBUS_SESSION_BUS_ADDRESS" "$XDG_RUNTIME_DIR" "$DISPLAY" "$WAYLAND_DISPLAY" > "$TMP_ENV_FILE"

# -------------------------
# Elevate privileges if not root
# -------------------------
if [ "$(id -u)" -ne 0 ]; then
  export REAL_USER
  if [ -n "${DISPLAY-}" ] || [ -n "${WAYLAND_DISPLAY-}" ]; then
	echo "🖥️ GUI detected — attempting pkexec..."
	if command -v pkexec >/dev/null 2>&1; then
	  exec pkexec env REAL_USER="$REAL_USER" bash "$0" "$@"
	else
	  echo "⚠️ pkexec not available — falling back to sudo..."
	  exec sudo -E env REAL_USER="$REAL_USER" bash "$0" "$@"
	fi
  else
	echo "🖥️ No GUI — using sudo..."
	exec sudo -E env REAL_USER="$REAL_USER" bash "$0" "$@"
  fi
fi

# From here on we run as root.
CONFIG_PATH="/home/$REAL_USER/.local/share/godot/app_userdata/mixer-project-linux/installed.flag"

if [ -f "$CONFIG_PATH" ]; then
  echo "✅ Mixer environment already installed. Skipping setup."
  exit 0
fi

echo "🎛️  Linux8200 Mixer Installer - Preparing environment..."
sleep 1

msg() { echo -e "\n🔹 $1"; sleep 0.4; }

# -------------------------
# Detect distro safely (fallbacks for missing keys)
# -------------------------
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  DISTRO="${ID:-unknown}"
  DISTRO_LIKE="${ID_LIKE:-unknown}"
else
  DISTRO="unknown"
  DISTRO_LIKE="unknown"
fi

DISTRO_ALL="$DISTRO $DISTRO_LIKE"

msg "Detected distro: $DISTRO_ALL"

# -------------------------
# Install helper
# -------------------------
install_cmd_if_missing() {
  local cmd="$1"; shift
  local install_cmd="$*"
  if command -v "$cmd" >/dev/null 2>&1; then
	echo "✅ $cmd already present"
  else
	echo "📦 Installing for $cmd..."
	eval "$install_cmd"
  fi
}

# -------------------------
# Per-distro installation
# -------------------------
case "$DISTRO_ALL" in
  *ubuntu*|*debian*)
	msg "Updating APT..."
	apt-get update -y

	if ! command -v lsb_release >/dev/null 2>&1; then
	  apt-get install -y lsb-release
	fi

	UBUNTU_VER="$(lsb_release -rs | cut -d'.' -f1 || echo 0)"
	if [ "$UBUNTU_VER" -lt 23 ]; then
	  msg "Adding PipeWire backport PPA (if available)..."
	  add-apt-repository -y ppa:pipewire-debian/pipewire-upstream 2>/dev/null || true
	  apt-get update -y || true
	fi

	msg "Installing PipeWire components..."
	apt-get install -y --no-install-recommends \
	  pipewire pipewire-audio pipewire-pulse pipewire-alsa wireplumber pavucontrol \
	  libspa-0.2-bluetooth pipewire-jack || true
	;;

  *arch*|*manjaro*|*cachy*)
	msg "Installing PipeWire (pacman)..."
	pacman -Sy --needed --noconfirm pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol || true
	;;

  *fedora*)
	msg "Installing PipeWire (dnf)..."
	dnf install -y pipewire pipewire-pulseaudio pipewire-alsa wireplumber pavucontrol || true
	;;

  *opensuse*)
	msg "Installing PipeWire (zypper)..."
	zypper refresh || true
	zypper install -y pipewire pipewire-pulseaudio pipewire-alsa wireplumber pavucontrol || true
	;;

  *)
	echo "⚠️ Unsupported distro: $DISTRO — please install PipeWire and WirePlumber manually."
	;;
esac

# -------------------------
# Add REAL_USER to audio group
# -------------------------
if id "$REAL_USER" >/dev/null 2>&1; then
  usermod -aG audio "$REAL_USER" || true
  msg "Added $REAL_USER to 'audio' group (you may need to re-login)."
else
  echo "⚠️ User $REAL_USER not found; skipping group modification."
fi

# -------------------------
# Post-install verification as real user
# -------------------------
DBUS_SESSION_BUS_ADDRESS_SAVED="$(sed -n '1p' "$TMP_ENV_FILE" | cut -d'=' -f2- || true)"
XDG_RUNTIME_DIR_SAVED="$(sed -n '2p' "$TMP_ENV_FILE" | cut -d'=' -f2- || true)"
DISPLAY_SAVED="$(sed -n '3p' "$TMP_ENV_FILE" | cut -d'=' -f2- || true)"
WAYLAND_DISPLAY_SAVED="$(sed -n '4p' "$TMP_ENV_FILE" | cut -d'=' -f2- || true)"

msg "Running post-install verification as $REAL_USER..."

# Forceer de juiste XDG_RUNTIME_DIR als deze leeg is
if [ -z "$XDG_RUNTIME_DIR_SAVED" ]; then
	USER_ID=$(id -u "$REAL_USER")
	XDG_RUNTIME_DIR_SAVED="/run/user/$USER_ID"
fi

# Gebruik 'machinectl' of 'systemd-run' als ze beschikbaar zijn, 
# anders vallen we terug op een verbeterde sudo-aanroep.
sudo -u "$REAL_USER" bash << EOF
	export XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR_SAVED"
	export DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS_SAVED"
	
	echo "🔍 Verifying for user: \$USER (UID: \$UID)"

	# Check of de socket daadwerkelijk bestaat
	if [ -S "\$XDG_RUNTIME_DIR/pipewire-0" ]; then
		echo "✅ PipeWire Socket gevonden in runtime dir."
	else
		echo "⚠️ PipeWire Socket niet gevonden. Service start mogelijk pas na herstart."
	fi

	# Probeer de status op te vragen via de user-bus
	if systemctl --user --machine="$REAL_USER@.host" is-active pipewire >/dev/null 2>&1; then
		echo "✅ PipeWire user service is actief."
	else
		echo "⚠️ PipeWire user service nog niet actief."
	fi
EOF
