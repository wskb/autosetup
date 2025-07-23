#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

check_writeable () {
    local target="$1"
    local targetParent="$(dirname "$target")"

    if [[ -e "$target" ]]; then
        if [[ ! -w "$target" ]]; then
            echo "file is not writeable: $target" 1>&2
            exit 1
        fi
    else
        if [[ ! -w "$targetParent" ]]; then
            echo "folder is not writeable: $targetParent" 1>&2
            exit 1
        fi
    fi
}

check_writeable "$HOME/.bashrc.wskb"
check_writeable "$HOME/.inputrc"

edit_bashrc=0
if [[ ( ! -e "$HOME/.bashrc" ) || ( ! grep -q  ".bashrc.wskb" "$HOME/.bashrc" ) ]]; then
    edit_bashrc=1
    check_writeable "$HOME/.bashrc"
fi

edit_bash_profile=0
if [[ ( ! -e "$HOME/.bash_profile" ) || ( ! grep -q  ".bashrc" "$HOME/.bash_profile" ) ]]; then
    edit_bash_profile=1
    edit_bashrc
    check_writeable "$HOME/.bash_profile"
fi

if [[ $edit_bash_profile -eq 1 ]]; then
    echo "Updating $HOME/.bash_profile"
    echo >> "$HOME/.bash_profile"
    echo 'source $HOME/.bashrc' >> "$HOME/.bash_profile"
fi

if [[ $edit_bashrc -eq 1 ]]; then
    echo "Updating $HOME/.bashrc"
    echo >> "$HOME/.bashrc"
    echo 'source $HOME/.bashrc.wskb' >> "$HOME/.bashrc"
fi
