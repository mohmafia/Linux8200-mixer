#!/bin/sh
echo -ne '\033c\033]0;mixer-project-linux\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/mixer.x86_64" "$@"
