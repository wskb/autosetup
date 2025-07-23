#::# preferences

export PAGER=less
export VISUAL=vi
export EDITOR=vi

# turn off control flow (Ctrl-S Ctrl-Q)
stty -ixon

# turn off beep on extra tabbing
shopt -s no_empty_cmd_completion

#::# history

HISTFILESIZE=10000
HISTSIZE=$HISTFILESIZE

# append not overwrite
shopt -s histappend
# ignore repeats of last
HISTCONTROL=ignoredups
# flush history immediately
PROMPT_COMMAND="${PROMPT_COMMAND:+${PROMPT_COMMAND};}history -a"

#::# shorthand

alias md='mkdir'
alias rd='rmdir'

function mcd()
{
	mkdir -pv "$1" && cd "$1"
}

#::# default options

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ls='ls -F'
alias la='ls -alh'
alias ll='ls -Alh'
alias diff='diff -u'
alias df='df -h'
alias du='du -h'

#::# conveniences

function size()
{
	if [[ $# -gt 0 ]]; then
		du -sc "$@" 2>/dev/null | sort -rh
	else
		du -sc * 2>/dev/null | sort -rh
	fi
}

function explode()
{
	if [[ -z "$1" ]]; then
		echo "no file provided"
		return 1
	fi
	
	mkdir "$1.contents"
	case `file -b --mime "$1"` in
		application/zip*)
			unzip -d "$1.contents" "$1"
		;;
		application/x-tar*)
			tar -xvf "$1" -C "$1.contents"
		;;
		application/gzip* | application/x-gzip*)
			case "$1" in
				*.tar.gz|*.tgz)
					tar -xvzf "$1" -C "$1.contents"
				;;
				*)
					cp "$1" "$1.contents"
					cd "$1.contents"
					gunzip *
					cd -
				;;
			esac
		;;
		application/x-bzip2*)
			case "$1" in
				*.tar.bz2|*.tbz)
					tar -xvjf "$1" -C "$1.contents"
				;;
				*)
					cp "$1" "$1.contents"
					cd "$1.contents"
					bunzip2 *
					cd -
				;;
			esac
		;;
		*)
			echo "File format not understood"
			rmdir "$1.contents"
		;;
	esac

	if [[ -d "$1.contents" ]]; then
		cd "$1.contents"
	fi
}

