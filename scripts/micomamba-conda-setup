#!/usr/bin/env bash

mamba_setup() {
    # >>> mamba initialize >>>
    # !! Contents within this block are managed by 'mamba init' !!
    export MAMBA_EXE="${HOME}/.micromamba/bin/micromamba";
    export MAMBA_ROOT_PREFIX="${HOME}/.micromamba";
    __mamba_setup="$('${HOME}/.micromamba/bin/micromamba' shell hook --shell bash --prefix '${HOME}/micromamba' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__mamba_setup"
    else
        if [ -f "${HOME}/.micromamba/etc/profile.d/micromamba.sh" ]; then
            . "${HOME}/.micromamba/etc/profile.d/micromamba.sh"
        else
            export  PATH="${HOME}/.micromamba/bin:$PATH"  # extra space after export prevents interference from conda init
        fi
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
}

conda_setup() {
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('${HOME}/.micromamba/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "${HOME}/.micromamba/etc/profile.d/conda.sh" ]; then
            . "${HOME}/.micromamba/etc/profile.d/conda.sh"
        else
            export PATH="${HOME}/.micromamba/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
}

mamba_setup
conda_setup