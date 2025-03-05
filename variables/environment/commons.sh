# Defining environmental variables
export DISPLAY=:0
export __NV_PRIME_RENDER_OFFLOAD=0
export vblank_mode=0
export __GL_SYNC_TO_VBLANK=0
export PYENV_ROOT="${HOME}/.pyenv"
export SHELL_UTILS="${HOME}/.shell_utils"

# Updating Path
PATH=$PATH:/bin:/usr/bin:"${HOME}/.local/bin":"${SHELL_UTILS}/scripts":"${SHELL_UTILS}/scripts/faqs":"${SHELL_UTILS}/scripts/utils":"${SHELL_UTILS}/scripts/Freds_img":"${HOME}/.local/share/gem/ruby/3.0.0/bin/":"$PYENV_ROOT/bin:$PATH":"${HOME}/.perl5/bin${PATH:+:${PATH}}"; export PATH;
###export PATH="$PATH:~/Library/Python/2.7/bin:$HOME/Library/Haskell/bin"

# Configuring perl5lib
PERL5LIB="${HOME}/.perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;

# Configuring perl_local_lib_root
PERL_LOCAL_LIB_ROOT="${HOME}/.perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;

# Configuring perl_mb_opt
PERL_MB_OPT="--install_base \"${HOME}/.perl5\""; export PERL_MB_OPT;

# Configuring perl_mm_opt
PERL_MM_OPT="INSTALL_BASE=${HOME}/.perl5"; export PERL_MM_OPT;

# Booting pyenv if it is available
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
fi

# Defining the favorite editor
if command -v nvim &>/dev/null; then
    export EDITOR="${EDITOR:-nvim}"
    export VISUAL="${VISUAL:-nvim}"

elif command -v vim &>/dev/null; then
    export EDITOR="${EDITOR:-vim}"
    export VISUAL="${VISUAL:-vim}"

elif command -v emacs &>/dev/null; then
    export EDITOR="${EDITOR:-emacs}"
    export VISUAL="${VISUAL:-emacs}"

else
    export EDITOR="${EDITOR:-nano}"
    export VISUAL="${VISUAL:-nano}"
fi

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# More variables
export vblank_mode=0
export __GL_SYNC_TO_VBLANK=0

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#export EDITOR='vim'
# else
#export EDITOR='nvim'
# fi