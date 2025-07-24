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

showPromptColors () {
	echo "index - fgbg"
 
    local offset=$(( $RANDOM % 49 ))
    local colorIndex
    local loopIndex
	for (( loopIndex = 0; loopIndex < 49; loopIndex++ )); do
        local colorIndex=$(( ($loopIndex + $offset) % 49 ))
        local fgColor=$((colorIndex % 7))
        local bgColor=$((colorIndex / 7))
        if [[ $fgColor -ge $bgColor ]]; then
            fgColor=$((fgColor + 1))
        fi
        if [[ $colorIndex -lt 10 ]]; then
            echo -n " $colorIndex "
        else
            echo -n "$colorIndex "
        fi
        echo -e "\\033[3${fgColor};4${bgColor}m\\c"
        echo -n " fc ${fgColor} - bc ${bgColor} |"
        echo -e "\\033[1m\\c"
        echo -n " fc ${fgColor} - bc ${bgColor} "
        echo -e "\\033[0m\\c"
        echo
    done
}

choosePromptColors () {
    local target="$1"

    showPromptColors

    local selectedIndex=-1
    until [[ selectedIndex -ge 0 && selectedIndex -le 49 ]]; do
        read -p "Pick by number: " selectedIndex
    done
    
    local fgColor=$((selectedIndex % 7))
    local bgColor=$((selectedIndex / 7))
    if [[ $fgColor -ge $bgColor ]]; then
        fgColor=$((fgColor + 1))
    fi
    echo -n $fgColor$bgColor > "$target"
}

check_writeable "$HOME/.bashrc.wskb"
check_writeable "$HOME/.inputrc"

edit_bashrc=0
if [[ ! -e "$HOME/.bashrc" ]] || ! grep -q  ".bashrc.wskb" "$HOME/.bashrc"; then
    edit_bashrc=1
    check_writeable "$HOME/.bashrc"
fi

edit_bash_profile=0
if [[ ! -e "$HOME/.bash_profile" ]] || ! grep -q  ".bashrc" "$HOME/.bash_profile"; then
    edit_bash_profile=1
    edit_bashrc
    check_writeable "$HOME/.bash_profile"
fi

if [[ -e "$HOME/.promptColor" ]]; then
    echo "skipping prompt color selection as file exists: $HOME/.promptColor"
else
    check_writeable "$HOME/.promptColor"
    choosePromptColors "$HOME/.promptColor"
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
