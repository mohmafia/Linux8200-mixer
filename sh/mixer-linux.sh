#!/bin/sh
echo -ne '\033c\033]0;mixer-project-linux\a'
base_path="$(dirname "$(realpath "$0")")"

# Forceer X11 backend zodat Godot niet native Wayland gebruikt
export SDL_VIDEODRIVER=x11
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
export CLUTTER_BACKEND=x11

"$base_path/mixer-linux.x86_64" "$@"

