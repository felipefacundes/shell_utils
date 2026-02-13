# Defining environmental variables
set -gx DISPLAY ":0"
set -gx __NV_PRIME_RENDER_OFFLOAD 0
set -gx vblank_mode 0
set -gx __GL_SYNC_TO_VBLANK 0
set -gx PYENV_ROOT "$HOME/.pyenv"
set -gx SHELL_UTILS "$HOME/.shell_utils"
set -gx SHELL_UTILS_USERS "$HOME/.local/shell_utils"

# Updating Path
set -gx PATH $PATH /bin /usr/bin "$HOME/.local/bin" "$SHELL_UTILS/scripts" "$SHELL_UTILS_USERS/scripts" "$SHELL_UTILS/scripts/faqs" "$SHELL_UTILS/scripts/utils" "$SHELL_UTILS_USERS/scripts/utils" "$SHELL_UTILS/scripts/Freds_img" "$HOME/.local/share/gem/ruby/3.0.0/bin" "$PYENV_ROOT/bin" "$HOME/.perl5/bin"

# Configuring perl5lib
set -gx PERL5LIB "$HOME/.perl5/lib/perl5"
if test -n "$PERL5LIB"
    set PERL5LIB "$PERL5LIB:$PERL5LIB"
end

# Configuring perl_local_lib_root
set -gx PERL_LOCAL_LIB_ROOT "$HOME/.perl5"
if test -n "$PERL_LOCAL_LIB_ROOT"
    set PERL_LOCAL_LIB_ROOT "$PERL_LOCAL_LIB_ROOT:$PERL_LOCAL_LIB_ROOT"
end

# Configuring perl_mb_opt
set -gx PERL_MB_OPT "--install_base \"$HOME/.perl5\""

# Configuring perl_mm_opt
set -gx PERL_MM_OPT "INSTALL_BASE=$HOME/.perl5"

# Booting pyenv if it is available
# if command -v pyenv > /dev/null
#     eval (pyenv init -)
# end

# Defining the favorite editor
if command -v nvim &>/dev/null
    set -gx EDITOR (echo "$EDITOR" | string length -q; or echo nvim)
    set -gx VISUAL (echo "$VISUAL" | string length -q; or echo nvim)

else if command -v vim &>/dev/null
    set -gx EDITOR (echo "$EDITOR" | string length -q; or echo vim)
    set -gx VISUAL (echo "$VISUAL" | string length -q; or echo vim)

else if command -v emacs &>/dev/null
    set -gx EDITOR (echo "$EDITOR" | string length -q; or echo emacs)
    set -gx VISUAL (echo "$VISUAL" | string length -q; or echo emacs)

else
    set -gx EDITOR (echo "$EDITOR" | string length -q; or echo nano)
    set -gx VISUAL (echo "$VISUAL" | string length -q; or echo nano)
end

# User configuration
# set -gx MANPATH "/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# set -gx LANG "en_US.UTF-8"

# Compilation flags
# set -gx ARCHFLAGS "-arch x86_64"

# ssh
# set -gx SSH_KEY_PATH "~/.ssh/rsa_id"

# More variables
set -gx vblank_mode 0
set -gx __GL_SYNC_TO_VBLANK 0

# Preferred editor for local and remote sessions
# if test -n "$SSH_CONNECTION"
#     set -gx EDITOR 'vim'
# else
#     set -gx EDITOR 'nvim'
# end