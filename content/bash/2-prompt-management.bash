_setPrompt()
{
	if [ -n "$TERM" ] && [ 'dumb' != "$TERM" ]; then
		
		local PROMPT_FC="7"
		local PROMPT_BC="0"
		
		if [[ -f "$HOME/.promptColor" ]]; then
			local PROMPT_C=`cat "$HOME/.promptColor"`
			PROMPT_FC="${PROMPT_C:0:1}"
			PROMPT_BC="${PROMPT_C:1:1}"
		fi
		
		PS1="$WINDOW_TITLE"
		PS1="$PS1\[\e[1;3${PROMPT_FC};4${PROMPT_BC}m\]" # prompt color on
		PS1="$PS1\u@\h" # user@host
		PS1="$PS1\[\e[0m\]" # prompt color off
		PS1="$PS1:\w" # working directory
		PS1="$PS1\n" # newline
		PS1="$PS1\[\e[1;4\$([[ \$? = 0 ]] && printf 0 || printf 1)m\]" # bg red if last command errored
		PS1="$PS1>" # prompt
		PS1="$PS1\[\e[0m\]" # error color off
		export PS1
	fi
}

# xterm/mintty window title
# see http://www.davidpashley.com/articles/bash-prompts.html

case "$TERM" in
	xterm*)
		setWindowTitle ()
		{
			WINDOW_TITLE="\[\e]0;$1\007\]"
			echo -ne "\033]0;$1\007"
			_setPrompt
		}
		WINDOW_TITLE="\[\e]0;new\007\]"
		;;
	*)
		setWindowTitle ()
		{
			echo "not an xterm"
		}
		;;
esac

setWindowTitleFromPWD () {
	setWindowTitle "`basename "$PWD"`"
}

sssh () {
	setWindowTitle "$1"
	ssh "$@"
}

_setPrompt
