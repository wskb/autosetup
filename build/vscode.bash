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
    echo "echo $file is currently missing" >> "$target"
    echo "fi" >> "$target"
}

apply_merge () {
    local target="$1"
    local slug="$2"
    local src="$3"
    local actualDir="$4"
    local actualFile="$5"

    echo "if [[ ! -e \"${actualDir}/${actualFile}\" ]]; then echo '{}' > \"${actualDir}/${actualFile}\"; fi" >> "$target"
    echo "cp \"${actualDir}/${actualFile}\" \"\$archiveDir\"" >> "$target"
    echo "echo \"Updating ${actualDir}/${actualFile}\"" >> "$target"
    echo "jq -s --sort-keys --indent 4 '.[0] * .[1]' \"\${archiveDir}/${actualFile}\" - <<'$slug' > \"${actualDir}/${actualFile}\"" >> "$target"
    cat "$src" >> "$target"
    echo "$slug" >> "$target"
}

apply_copy () {
    local target="$1"
    local slug="$2"
    local src="$3"
    local actual="$4"

    echo "if [[ -e \"$actual\" ]]; then cp \"$actual\" \"\$archiveDir\"; fi" >> "$target"
    echo "echo \"Replacing $actual\"" >> "$target"
    echo "cat <<'$slug' > \"$actual\"" >> "$target"
    cat "$src" >> "$target"
    echo "$slug" >> "$target"
}

#::# vscode diff

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

#::# vscode apply

cp "$SCRIPT_DIR/../content/install/vscode-lib.bash" "$DEST/vscode-apply"
echo >> "$DEST/vscode-apply"

echo 'checkForJq' >> "$DEST/vscode-apply"
echo >> "$DEST/vscode-apply"

cat >> "$DEST/vscode-apply" <<'END'
archiveDir="/tmp/wskb-vscode-apply-$$"
mkdir "$archiveDir"
echo "Archive dir is $archiveDir"

END
apply_copy "$DEST/vscode-apply" 'END_SNIPPET_POWERSHELL' "$SCRIPT_DIR/../content/vscode/snippets/powershell.json" '$(getSettingsPath)/snippets/powershell.json'
echo >> "$DEST/vscode-apply"
apply_copy "$DEST/vscode-apply" 'END_SNIPPET_R' "$SCRIPT_DIR/../content/vscode/snippets/r.json" '$(getSettingsPath)/snippets/r.json'
echo >> "$DEST/vscode-apply"
apply_copy "$DEST/vscode-apply" 'END_SNIPPET_SHELL' "$SCRIPT_DIR/../content/vscode/snippets/shellscript.json" '$(getSettingsPath)/snippets/shellscript.json'
echo >> "$DEST/vscode-apply"

apply_merge "$DEST/vscode-apply" 'END_SNIPPET_SETTINGS' "$SCRIPT_DIR/../content/vscode/settings.json" '$(getSettingsPath)' "settings.json"
echo >> "$DEST/vscode-apply"

echo "echo \"Installing missing extensions, if any\"" >> "$DEST/vscode-apply"
echo "jq --raw-output -s '.[1] - .[0] | .[]' <( jq '[. | .[].identifier.id] | sort' \"\$(getExtensionsPath)/extensions.json\" ) - <<'END_EXTENSIONS_ARRAY' | xargs --verbose -L 1 -- code --install-extension" >> "$DEST/vscode-apply"
cat "$SCRIPT_DIR/../content/vscode/extensions.txt" | jq --raw-input --null-input '[inputs] | sort' >> "$DEST/vscode-apply"
echo "END_EXTENSIONS_ARRAY" >> "$DEST/vscode-apply"
