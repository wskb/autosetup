#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"

DEST="${DEST:-$SCRIPT_DIR/../dist6}"

mkdir -p "$DEST"

cp "$SCRIPT_DIR/../content/install/1-prefix.bash" "$DEST/bash-setup"
for A in `find "$SCRIPT_DIR/../content/bash" -type f | sort`; do
    cat "$A" >> "$DEST/bash-setup"
done
echo "END_BASHRC_WSKB" >> "$DEST/bash-setup"
