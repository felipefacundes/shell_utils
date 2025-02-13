#################################
# Path to your oh-my-zsh installation.
export ZSH="${HOME}"/.oh-my-zsh

# EXPORTS... in .shell_utils environment

##### STARTUP
RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
RPS2=$RPS1

##### VIM STUFF
#bindkey '\e' vi-cmd-mode
##### BINDINGS VIM
#bindkey "^R" history-incremental-search-backward
#bindkey "\e[A" history-beginning-search-backward
#bindkey "\e[B" history-beginning-search-forward

##### Emacs STUFF
unsetopt vi
bindkey -e

# Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
export KEYTIMEOUT=1
function zle-line-init zle-keymap-select {
  RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
  RPS2=$RPS1
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

##### Ignore Case
set completion-ignore-case On
# Isso é possível ao usar o sistema de conclusão zsh (iniciado por autoload -Uz compinit && compinit) e é controlado por um zstyle:
autoload -Uz compinit && compinit
# Isso diz zshque letras minúsculas corresponderão a letras minúsculas e maiúsculas.
# (ou seja, letras maiúsculas correspondem apenas a letras maiúsculas.)
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Se você quiser que letras maiúsculas também correspondam a letras minúsculas, use:
#zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# Se você deseja correspondência sem distinção entre maiúsculas e minúsculas apenas se não houver
# correspondências com distinção entre maiúsculas e minúsculas, adicione '', e.g.
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="$ZSH_THEME"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# See https://github.com/Powerlevel9k/powerlevel9k
#ZSH_THEME="powerlevel9k/powerlevel9k"
#POWERLEVEL9K_MODE="nerdfont-complete"

POWERLEVEL9K_PROMPT_ON_NEWLINE=true
#POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="↱"
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="╭─"
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="↳"
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="╰─"
#POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND='black'
#POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='deepskyblue1'
#POWERLEVEL9K_CONTEXT_SUDO_FOREGROUND='lightyellow'
#POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND='black'
#POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='red'
#POWERLEVEL9K_CONTEXT_SUDO_BACKGROUND='black'
POWERLEVEL9K_DIR_HOME_FOREGROUND='lightgreen'
POWERLEVEL9K_DIR_HOME_BACKGROUND='brown'
#POWERLEVEL9K_VCS_CLEAN_FOREGROUND='blue'
#POWERLEVEL9K_VCS_CLEAN_BACKGROUND='black'
#POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='yellow'
#POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='black'
#POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='lightred'
#POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='black'
POWERLEVEL9K_OS_ICON_FOREGROUND='blue'
POWERLEVEL9K_OS_ICON_BACKGROUND='brown'
POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND='brown'
POWERLEVEL9K_DISK_USAGE_NORMAL_BACKGROUND='yellow'
POWERLEVEL9K_TIME_FOREGROUND='green1'
POWERLEVEL9K_TIME_BACKGROUND='brown'
POWERLEVEL9K_TIME_FORMAT="%T"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
POWERLEVEL9K_CONTEXT_TEMPLATE="%n"
POWERLEVEL9K_SHORTEN_DELIMITER=""
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"
POWERLEVEL9K_DIR_SHOW_WRITABLE=true
#POWERLEVEL9K_HOME_SUB_ICON=$'\UE18D ' # <-
#POWERLEVEL9K_HOME_ICON='  ﴂ 邏 ﳟ        調       '
POWERLEVEL9K_HOME_ICON='    '

# Lado Esquerdo
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon context)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
# Lado Direito
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status ssh root_indicator background_jobs virtualenv)
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(history time)

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git history archlinux zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
## Plugins section: Enable fish style features
# Use syntax highlighting
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Use history substring search
#source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# Use autosuggestion
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# User configuration

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
