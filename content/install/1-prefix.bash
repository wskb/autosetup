#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -e "$HOME/.bashrc.wskb" ]]; then
    if [[ ! -w "$HOME/.bashrc.wskb" ]]; then
        echo "file is not writeable: $HOME/.bashrc.wskb" 1>&2
        exit 1
    fi
else
    if [[ -w "$HOME" ]]; then
        echo "folder is not writeable: $HOME" 1>&2
        exit 1
    fi
fi

edit_bashrc=0
if [[ -e "$HOME/.bashrc" ]]; then
    grep -q  ".bashrc.wskb" "$HOME/.bashrc" && rc=$? || rc=$?
    if [[ $rc -ne 0 ]]; then
        if [[ -w "$HOME/.bashrc" ]]; then
            edit_bashrc=1
        else
            echo "file is not writeable: $HOME/.bashrc" 1>&2
            exit 1
        fi
    fi
else
    if [[ -w "$HOME" ]]; then
        echo "folder is not writeable: $HOME" 1>&2
        exit 1
    fi
fi

edit_bash_profile=0
if [[ -e "$HOME/.bash_profile" ]]; then
    grep -q  ".bashrc" "$HOME/.bash_profile" && rc=$? || rc=$?
    if [[ $rc -ne 0 ]]; then
        if [[ -w "$HOME/.bash_profile" ]]; then
            edit_bash_profile=1
        else
            echo "file is not writeable: $HOME/.bash_profile" 1>&2
            exit 1
        fi
    fi
else
    if [[ -w "$HOME" ]]; then
        echo "folder is not writeable: $HOME" 1>&2
        exit 1
    fi
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

echo "Updating $HOME/.bashrc.wskb"
cat > "$HOME/.bashrc.wskb" <<'END_BASHRC_WSKB'
