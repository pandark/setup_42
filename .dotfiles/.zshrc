if [ -z "$USER" ]; then
    export USER=$(whoami)
fi
if [ -z "$EMAIL" ]; then
    export MAIL="$USER@student.42.fr"
fi
if [ -z "$GROUP" ]; then
    export GROUP=$(id -gn $USER)
fi

export REMOTE_HOME="/tmp/.${USER}_rhome"

if [ ! -d "${REMOTE_HOME}" ]; then
    mkdir "${REMOTE_HOME}"
fi
if [ -z "$(mount | grep "${REMOTE_HOME}")" ]; then
    mount -t nfs zfs-student-1:/tank/sgoinfre/goinfre/Perso/Students/${USER} \
        ${REMOTE_HOME}
fi

export HOMEBREW_CACHE="${REMOTE_HOME}/.tmp/brew_cache"

export NPM_PACKAGES=${REMOTE_HOME}/.npm-packages
export NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"
export PATH="${REMOTE_HOME}/.brew/bin:${NPM_PACKAGES}/bin:${REMOTE_HOME}/.meteor:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/texbin"
#export MANPATH="${MANPATH}"

if [ -f ${REMOTE_HOME}/.opam/opam-init/init.zsh ]; then
    source ${REMOTE_HOME}/.opam/opam-init/init.zsh
fi

if  [ -n "$(which-command nvim 2>/dev/null)" ] ; then
    export EDITOR="nvim"
fi

######################
#      CONF ZSH      #
######################

bindkey -e # vim rocks but zsh vim-bindings suck

# delete key
bindkey "\e[3~"   delete-char

# home / end
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

# search in history based on what is type
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

bindkey '^[[Z' reverse-menu-complete
bindkey ' ' magic-space    # also do history expansion on space

# ctrl + arrows
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# zsh history

HISTFILE=${REMOTE_HOME}/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history # share command history data

# better autocomplete
autoload -U compinit && compinit

# autocomplete menu
zstyle ':completion:*' menu select

# prompt color
autoload -U colors && colors

# add completion provied by bin installed via brew
if [[ -d "${REMOTE_HOME}/.brew/share/zsh/site-functions" ]]; then
    fpath=(${REMOTE_HOME}/.brew/share/zsh/site-functions $fpath)
fi

######################
#    BASH_ALIASES    #
######################

case "$TERM" in
    xterm*|rxvt*|screen|vt100)
        COLOR_TERM=$TERM;; # we know these terms have proper color support
    *)
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            COLOR_TERM=$TERM # we seem to have color support:
            # assume it's compliant with ECMA-48 (ISO/IEC-6429)
        fi;;
esac # >>>

# enable color support for ls and grep when possible <<<
if [ "$COLOR_TERM" ]; then
    # export GREP_COLOR='1;32'
    export GREP_OPTIONS='--color=auto'
    # find the option for using colors in ls, depending on the version: GNU or BSD
    ls --color -d . &>/dev/null 2>&1 \
        && alias ls='ls --group-directories-first --color=auto' \
        || alias ls='ls --group-directories-first -G' # BSD
else
    alias ls='ls --group-directories-first'
fi # >>>

######################
#    PROMPT ZSH      #
######################

# version control
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git hg svn
zstyle ':vcs_info:*'    formats $PS_vcsinfo" [‡ %b]"
zstyle ':vcs_info:hg*'  formats $PS_vcsinfo" [☿ %b]"
zstyle ':vcs_info:git*' formats $PS_vcsinfo" [± %b]"
precmd() {
  vcs_info
}

# prompt parts
local PS_prompt="%# "
local PS_time="%D{%H:%M:%S}" # like "%* but uses a leading zero when needed
local PS_host="@$(hostname)"
local PS_user="%n$PS_host"
local PS_cwd="%~"
local PS_vcsinfo="%r/%S"

# comment this line for a distraction-free prompt <<<
# -- warning: $COLOR_TERM is defined in ~/.bash_aliases
local color_prompt=$COLOR_TERM
if [ "$color_prompt" ]; then
  autoload colors && colors
  PS_prompt="%{$fg_bold[white]%}$PS_prompt%{$reset_color%}"
  PS_host="%{$fg_bold[green]%}$PS_host%{$reset_color%}"
  # time: color coded by last return code
  PS_time="%(?.%{$fg[green]%}.%{$fg[red]%})$PS_time%{$reset_color%}"
  # user: color coded by privileges
  PS_user="%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%})$PS_user%{$reset_color%}"
  PS_cwd="%{$fg_bold[blue]%}$PS_cwd%{$reset_color%}"
  PS_vcsinfo="%{$fg[blue]%}$PS_vcsinfo%{$reset_color%}"
fi
unset color_prompt
# >>>

# two-line prompt with time + current vcs branch on the right
setopt prompt_subst
# RPROMPT="$(__vcs_info)" # defined in ~/.bash_aliases
RPROMPT='${vcs_info_msg_0_}'
PROMPT="${PS_time} ${PS_user}:${PS_cwd}
${PS_prompt}"

#NORMAL="%{$reset_color%}"
## Definition du prompt
#prompt_hook ()
#{
#    if [ $? -eq 0 ] ; then
#        COLOR3="%{$fg[green]%}"
#    else
#        COLOR3="%{$fg[red]%}"
#    fi
#    ISGIT=$(git status --ignore-submodules 2> /dev/null)
#    if [ -n "$ISGIT" ] ; then
#        STATUS=$(echo "$ISGIT" | grep "modified:\|renamed:\|new file:\|deleted:" | grep -v ".vim/bundle\|untracked")
#        BRANCH=$(git branch | cut -d ' ' -f 2 | tr -d '\n')
#        if [ -n "$STATUS" ] ; then
#            COLOR="%{$fg[red]%}"
#        else
#            REMOTE_EXIST=$(git branch -a | grep remotes/origin/$BRANCH)
#            if [ -n "$REMOTE_EXIST" ] ; then
#                REMOTE=$(git diff --ignore-submodules origin/$BRANCH)
#                if [ -n "$REMOTE" ] ; then
#                    COLOR="%{$fg[yellow]%}"
#                else
#                    COLOR="%{$fg[green]%}"
#                fi
#            else
#                COLOR="%{$fg[green]%}"
#            fi
#        fi
#        RPROMPT="%{$COLOR%}($BRANCH)%{$NORMAL%}"
#    else
#        RPROMPT=""
#    fi
#    PROMPT="%B%{$fg[green]%}%n@%m%{$NORMAL%}%B:%{$fg[blue]%}%~%{$NORMAL%}
#    %B%{$COLOR3%}> %{$NORMAL%}%b"
#}
#
#[[ -z $precmd_functions ]] && precmd_functions=()
#precmd_functions=($precmd_functions prompt_hook)

#######################
#    LS EN COULEUR    #
#######################

#a     black
#b     red
#c     green
#d     brown
#e     blue
#f     magenta
#g     cyan
#h     light grey
#A     bold black, usually shows up as dark grey
#B     bold red
#C     bold green
#D     bold brown, usually shows up as yellow
#E     bold blue
#F     bold magenta
#G     bold cyan
#H     bold light grey; looks like bright white
#x     default foreground or background

DIR="ex"
SYMLNK="gx"
SOCKET="xx"
PIPE="xx"
EXEC="cx"
BLCKSPE="xx"
CHARSPE="xx"
EXECSUID="cx"
EXECSGID="cx"
DIRWSB="ad"
DIRW="ad"
export LSCOLORS="$DIR$SYMLNK$SOCKET$PIPE$EXEC$BLCKSPE$CHARSPE$EXECSUID$EXECSGID$DIRWSB$DIRWd"

#######################
#    MAN EN COULEUR   #
#######################

man()
{
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
        man "$@"
}

#######################
#        ALIAS        #
#######################

unalias l 2>/dev/null
unalias ls 2>/dev/null
unalias ll 2>/dev/null
unalias la 2>/dev/null
unalias lah 2>/dev/null
unalias lh 2>/dev/null
alias l='ls -lAG'
#alias ls=exa
#alias l='exa -l --group --git -A'
#alias ll='exa -l --group --git'
#alias la='exa -l --group --git -a'
#alias lg='exa -l --group --git --grid'
#alias lt='exa -l --group --git --tree'

alias vi='nvim'
alias vim='nvim'
alias neovim='nvim'

alias gdb='lldb'

alias vim_clean='find "${REMOTE_HOME}/.tmp/nvim" -mindepth 1 -delete'
alias npm_clean='find "${REMOTE_HOME}/.npm-packages" -mindepth 1 -delete'
alias redshift_stop='kill $(pgrep redshift)'

alias ocaml='rlwrap ocaml'
alias ocalm='rlwrap ocaml'
alias v='vi *.ml'
alias o='ocamlopt *.ml'

#######################
#   START PROGRAMS    #
#######################

if [ -n "$(which-command redshift)" -a -z "$(pgrep redshift)" ] ; then
    echo "launching redshift"
    nohup redshift 2>&1 >/dev/null &
fi

#######################
#   EXERCICES AT 42   #
#######################

function next ()
{
    nb=$(basename `pwd` | grep "ex")
    if [[ -n "$nb" ]]; then
        if [[ -n "$1" ]]; then inc=$1; else inc=1; fi
        nb=$(expr `echo $nb | tr -d "[a-z]"` + $inc)
        if [[ $nb -lt 10 ]] ; then
            dir="../ex0$nb"
        else
            dir="../ex$nb"
        fi
        mkdir -p $dir
        cd $dir
    fi
}

function prev ()
{
    nb=$(basename `pwd` | grep "ex")
    if [[ -n "$nb" ]]; then
        if [[ -n "$1" ]]; then dec=$1; else dec=1; fi
        nb=$(expr `echo $nb | tr -d "[a-z]"` - $dec)
        if [[ $nb -lt 0 ]] ; then
            dir="../ex00"
        elif [[ $nb -lt 10 ]] ; then
            dir="../ex0$nb"
        else
            dir="../ex$nb"
        fi
        cd $dir
    fi
}