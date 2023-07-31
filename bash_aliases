# some more ls aliases
alias ll='ls -ltrha --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Display result of wget in the console
alias cwget='wget -q -O - "$@"'

# Display PID of a process by name
function ppid()
{
  ps aux | grep "$@" | grep -v grep | awk '{ print $2 }'
}

# systemctl alias
function sctl()
{
  # Some commands aliases
  local cmd="${1}"
  shift
  local services=(${@})

  [[ "${cmd}" == "st" ]] && cmd="status"
  [[ "${cmd}" == "dr" ]] && cmd="daemon-reload"

  if [[ "${cmd}" == "daemon-reload" ]]; then
    sudo systemctl daemon-reload
    return
  fi

  if [[ "${#services[@]}" == "0" ]]; then
    services=(${_SCTL_LAST})
  fi

  for service in "${services[@]}"; do
    echo -e "${FORMAT_DIM}sudo systemctl${FORMAT_RST} ${cmd} ${FORMAT_BOLD}${service}${FORMAT_RST}"
    sudo systemctl ${cmd} ${service}
    export _SCTL_LAST="${service}"
  done
}

# encrypt a string given as parameter
function encrypt()
{
  openssl aes-256-cbc -a -pbkdf2
}

# decrypt a string given as parameter
function decrypt()
{
  openssl aes-256-cbc -d -a -pbkdf2
}

# decrypt a key from the ~/.keys folder
_deckey()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(ls ~/.keys)"

    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}

complete -F _deckey deckey

function deckey()
{
  cat "${HOME}/.keys/${1}" | decrypt
}
