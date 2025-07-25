
getSettingsPath () {
    if [[ $(uname) == *Darwin* ]]; then
        echo "$HOME/Library/Application Support/Code/User"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "$HOME/AppData/Roaming/Code/User"
    else
        echo "$HOME/.config/Code/User"
    fi
 ]]
}

getExtensionsPath () {
    if [[ $(uname) == *Darwin* ]]; then
        echo "$HOME/.vscode/extensions"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "$HOME/.vscode/extensions"
    else
        echo "$HOME/.vscode/extensions"
    fi
 ]]
}

checkForJq () {
    if ! which jq >/dev/null; then
        echo "jq is required for this script" 1>&2
        exit 1
    fi
}
