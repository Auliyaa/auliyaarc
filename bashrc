# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
# Ensure window size is checked for word wrapping
if [[ "$(get_shell 2> /dev/null)" = "bash" ]]; then
  shopt -s checkwinsize
fi

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
  # bash colors
  source ~/.bash_colors
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_dev ]; then
    . ~/.bash_dev
fi

if [ -f ~/.bash_video ]; then
    . ~/.bash_video
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# dynamically setup tilix
if [[ ! -e /etc/profile.d/vte.sh ]]; then
  echo -e "${fmt_bold}${col_red}/etc/profile.d/vte.sh does not exist${col_rst} ${fmt_dim}ln -s /etc/profile.d/vte-2.91.sh /etc/profile.d/vte.sh${col_rst}"
fi
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  source /etc/profile.d/vte.sh
fi

# ==========================================================================
# Add nice colors and command exec time into bash
# ==========================================================================
[ -e "/etc/DIR_COLORS" ] && DIR_COLORS="/etc/DIR_COLORS"
[ -e "$HOME/.dircolors" ] && DIR_COLORS="$HOME/.dircolors"
[ -e "$DIR_COLORS" ] || DIR_COLORS=""
eval "`dircolors -b $DIR_COLORS`"

export PROMPT_COMMAND=__prompt_command

__prompt_command() {
    local _last_exit_code="$?" # This needs to be first

    PS1='[\[\e[36m\]\u\[\e[0m\]@\[\e[37m\]\h\[\e[37m\]\[\e[2m\] \W\[\e[0m\]'
    if [[ -d ".git" ]]; then
      local _br="$(git rev-parse --abbrev-ref HEAD)"
      if [[ "${_br}" == "main" || "${_br}" == "master" ]]; then
        PS1+="(\[\e[35m\]${_br}\[\e[0m\])"
      else
        PS1+="(\[\e[36m\]${_br}\[\e[0m\])"
      fi
    fi
    PS1+="]"

    if [[ -d ".git" ]]; then
      local _mod=$(git ls-files -m | wc -l)
      local _del=$(git ls-files -d | wc -l)
      local _oth=$(git ls-files -o | wc -l)
      local _stg=$(git diff --name-only --cached | wc -l)
      local _unp=$(git log --branches --not --remotes --oneline | wc -l)

      PS1+="\[\e[35m\]"
      if (( _mod > 0 )); then
        PS1+=" ❱${_mod}"
      fi
      if (( _del > 0 )); then
        PS1+=" ✖${_del}"
      fi
      if (( _oth > 0 )); then
        PS1+=" •${_oth}"
      fi
      if (( _stg > 0 )); then
        PS1+=" ⬓${_stg}"
      fi
      if (( _unp > 0 )); then
        PS1+=" ⇪${_unp}"
      fi

      PS1+="\[\e[0m\] "
    fi

    if [[ "${_last_exit_code}" != "0" ]]; then
      PS1="${PS1}\[\e[31m\]\$\[\e[0m\] "
    else
      PS1="${PS1}\[\e[32m\]\$\[\e[0m\] "
    fi

    echo -en "\033]0;${USER}@${HOSTNAME} $(pwd)'\007"
}

# use verbose output for ctest
export CTEST_OUTPUT_ON_FAILURE=1
