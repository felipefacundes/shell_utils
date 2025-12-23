shell_colors()
{
echo '
# View map array of ${shell_color_palette[@]}
'
    ccat --color=always ~/.shell_utils/variables/shell_colors.sh | awk 'NR >= 1 && NR <= 3250' | less -i -R -N --use-color --color=HBCEMNPRSWsu
}

