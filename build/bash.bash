#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"

DEST="${DEST:-$SCRIPT_DIR/../dist}"

copy_folder_to_file () {
    local file="$1"
    local slug="$2"
    local src="$3"
    local target="$4"

    echo "echo \"Updating ${file}\"" >> "$target"
    echo "cat > \"${file}\" <<'$slug'" >> "$target"
    for A in `find "$src" -type f | sort`; do
        cat "$A" >> "$target"
    done
    echo "$slug" >> "$target"
}

mkdir -p "$DEST"

cp "$SCRIPT_DIR/../content/install/1-prefix.bash" "$DEST/bash-setup"

copy_folder_to_file '$HOME/.bashrc.wskb' 'END_BASHRC_WSKB' "$SCRIPT_DIR/../content/bash" "$DEST/bash-setup"
