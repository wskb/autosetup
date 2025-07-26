#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"

DEST="${DEST:-$SCRIPT_DIR/../dist}"

mkdir -p "$DEST"

diff_process () {
    local target="$1"
    local slug="$2"
    local src="$3"
    local actual="$4"
    local actualLabel="${5:-actual}"

    echo "diff --unified --label reference --label \"$actualLabel\" - $actual <<'$slug'" >> "$target"
    cat "$src" >> "$target"
    echo "$slug" >> "$target"
}

diff_file () {
    local target="$1"
    local slug="$2"
    local src="$3"
    local file="$4"

    echo "if [[ -e \"$file\" ]]; then" >> "$target"
    diff_process "$target" "$slug" "$src" "\"$file\"" "$file"
    echo "else" >> "$target"
    echo "echo $file is current missing" >> "$target"
    echo "fi" >> "$target"
}

cp "$SCRIPT_DIR/../content/install/vscode-lib.bash" "$DEST/vscode-diff"
echo >> "$DEST/vscode-diff"

echo 'checkForJq' >> "$DEST/vscode-diff"
echo >> "$DEST/vscode-diff"

diff_file "$DEST/vscode-diff" 'END_SNIPPET_POWERSHELL' "$SCRIPT_DIR/../content/vscode/snippets/powershell.json" '$(getSettingsPath)/snippets/powershell.json'
echo >> "$DEST/vscode-diff"
diff_file "$DEST/vscode-diff" 'END_SNIPPET_R' "$SCRIPT_DIR/../content/vscode/snippets/r.json" '$(getSettingsPath)/snippets/r.json'
echo >> "$DEST/vscode-diff"
diff_file "$DEST/vscode-diff" 'END_SNIPPET_SHELL' "$SCRIPT_DIR/../content/vscode/snippets/shellscript.json" '$(getSettingsPath)/snippets/shellscript.json'
echo >> "$DEST/vscode-diff"

diff_process "$DEST/vscode-diff" 'END_SNIPPET_SETTINGS' "$SCRIPT_DIR/../content/vscode/settings.json" '<( jq --sort-keys --indent 4 '.' "$(getSettingsPath)/settings.json" )'
echo >> "$DEST/vscode-diff"
diff_process "$DEST/vscode-diff" 'END_EXTENSIONS_LIST' "$SCRIPT_DIR/../content/vscode/extensions.txt" '<( jq --raw-output ". | .[].identifier.id" "$(getExtensionsPath)/extensions.json" | sort )'
echo >> "$DEST/vscode-diff"
