# ~/.bashrc: personal Bash config for dev containers.
# Installed by VS Code's dotfiles feature (see install.sh).
# Project environment (ROS 2, venimapping) is loaded separately from
# /etc/bash.bashrc, which Bash reads before this file.

# =============================================================================
# INTERACTIVE GUARD
# =============================================================================
# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================
export VIRTUAL_ENV_DISABLE_PROMPT=1

# =============================================================================
# HISTORY CONFIGURATION
# =============================================================================
# Don't put duplicate lines or lines starting with a space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it.
shopt -s histappend

# History length.
HISTSIZE=50000
HISTFILESIZE=50000

# =============================================================================
# SHELL OPTIONS
# =============================================================================
# Check the window size after each command; update LINES and COLUMNS.
shopt -s checkwinsize

# =============================================================================
# LESS / PAGER
# =============================================================================
# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# =============================================================================
# PROMPT
# =============================================================================
# Set variable identifying the chroot, if applicable.
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

update_prompt() {

    # Colors
    local RESET='\[\033[0m\]'
    local GREEN='\[\033[1;32m\]'
    local BLUE='\[\033[1;34m\]'
    local YELLOW='\[\033[1;33m\]'
    local MAGENTA='\[\033[1;35m\]'

    # Prompt information
    local host="${HOSTNAME%%.*}"
    local cwd="${PWD/#$HOME/~}"
    local userhost="${USER:-$(id -un)}@${host}"
    local chroot="${debian_chroot:+(${debian_chroot})}"

    # Python virtual environment
    local venv_name=""
    local venv_text=""

    if [ -n "${VIRTUAL_ENV:-}" ]; then
        venv_name="${VIRTUAL_ENV%/}"
        venv_name="${venv_name##*/}"
        venv_text="(${venv_name}) "
    fi

    # Git branch
    local branch=""

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch=$(git branch --show-current 2>/dev/null)

        # Detached HEAD fallback.
        if [ -z "$branch" ]; then
            branch="detached:$(git rev-parse --short HEAD 2>/dev/null)"
        fi
    fi

    # Right alignment
    local left_text="${venv_text}${chroot}${userhost} ${cwd}"
    local columns="${COLUMNS:-80}"
    local padding=""
    local spaces=0

    if [ -n "$branch" ]; then
        spaces=$(( columns - ${#left_text} - ${#branch} ))

        # Only display the branch if there is enough room to keep at least
        # two spaces between the path and the branch.
        if (( spaces >= 2 )); then
            printf -v padding '%*s' "$spaces" ''
        else
            branch=""
        fi
    fi

    # Terminal title
    local title=""

    case "$TERM" in
        xterm*|rxvt*)
            title="\[\e]0;${userhost}: ${cwd}\a\]"
            ;;
    esac

    # Final prompt
    if [ -n "$branch" ]; then
        PS1="${title}${MAGENTA}${venv_text}${RESET}${GREEN}${chroot}${userhost}${RESET} ${BLUE}${cwd}${RESET}${padding}${YELLOW}${branch}${RESET}\n> "
    else
        PS1="${title}${MAGENTA}${venv_text}${RESET}${GREEN}${chroot}${userhost}${RESET} ${BLUE}${cwd}${RESET}\n> "
    fi
}

# Build the prompt before every command. Prepend rather than replace, so
# anything already in PROMPT_COMMAND (from /etc/bash.bashrc or the project)
# keeps running.
case ";${PROMPT_COMMAND:-};" in
    *";update_prompt;"*) ;;
    *) PROMPT_COMMAND="update_prompt${PROMPT_COMMAND:+;${PROMPT_COMMAND}}" ;;
esac

# =============================================================================
# COLOR SUPPORT
# =============================================================================
# Enable color support of ls and grep.
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# =============================================================================
# ALIASES
# =============================================================================
# Navigation
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gpl='git pull'
alias gb='git branch'
alias gf='git fetch'

# Utilities
alias mkdir='mkdir -pv'
alias h='history'
alias c='clear'
alias df='df -h'
alias du='du -h'
alias path='echo -e ${PATH//:/\\n}'

# Tree (only works if `tree` is installed in the image)
TREE_IGNORE="__pycache__|*.pyc|.git|build|install|log"
alias tree='tree -C -I "$TREE_IGNORE"'
alias tree1='tree -C -I "$TREE_IGNORE" -L 1'
alias tree2='tree -C -I "$TREE_IGNORE" -L 2'
alias treea='tree -C -I "$TREE_IGNORE" -a'
alias treed='tree -C -I "$TREE_IGNORE" -d'

# Safety (interactive prompts before overwrite/delete)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Shell configuration
# `code` is only on PATH in VS Code terminals, not in `docker exec` shells.
alias editbash='code ~/.bashrc'
alias reloadbash='source ~/.bashrc && echo "[OK] .bashrc reloaded"'

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================
mkcd() {
    mkdir -p "$1" && cd "$1"
}

ff() {
    find . -iname "*${1}*" 2>/dev/null
}

backup() {
    [ -z "$1" ] && { echo "Usage: backup <file>"; return 1; }
    local stamp
    stamp="$(date +%Y%m%d_%H%M%S)"
    command cp -r "$1" "$1.backup.${stamp}"
    echo "Backed up to: $1.backup.${stamp}"
}

# =============================================================================
# COMPLETION
# =============================================================================
# Enable programmable completion features.
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
