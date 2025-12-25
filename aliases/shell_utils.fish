#alias utils='ls ~/.shell_utils/scripts/utils' # Subdirectory for simpler scripts
alias faqs='ls ~/.shell_utils/scripts/faqs'
alias utilities='ls ~/.shell_utils/scripts/utilities/'
alias utils='utilities'
alias shell_utils_default_fish='cp -f ~/.shell_utils/shell_utils.fish ~/.config/fish/conf.d/'
alias shell_utils_default_zshrc='mv -v --backup=t ~/.zshrc ~/.zshrc.shell_utils-backup-$(date +"%Y%m%d%H%M%S"); cp -f ~/.shell_utils/zshrc ~/.zshrc'
alias shell_utils_default_bashrc='mv -v --backup=t ~/.bashrc ~/.bashrc.shell_utils-backup-$(date +"%Y%m%d%H%M%S"); cp -f ~/.shell_utils/bashrc ~/.bashrc'
alias shell_utils_default_inputrc='mv -v --backup=t ~/.inputrc ~/.inputrc.shell_utils-backup-$(date +"%Y%m%d%H%M%S"); cp -f ~/.shell_utils/inputrc ~/.inputrc'
alias shell_utils_defaults='shell_utils_default_zshrc; shell_utils_default_bashrc; shell_utils_default_inputrc; shell_utils_default_fish'

#
alias alias_diff_fish_sh='~/.shell_utils/scripts/diff-fish-sh ~/.shell_utils/aliases/'

# Shell Utils fundamental
alias shell_color_select='~/.shell_utils/scripts/color-select'
alias color_shell_select='shell_color_select'
alias shell_color_palette='shell_color_select'
alias ansi_color_select='shell_color_select'
alias ascii_color_select='shell_color_select'
alias shell_color_palette_select='shell_color_select'

alias ascii_theme_select='~/.shell_utils/scripts/ascii-theme-select'
alias ascii_themes_select='ascii_theme_select'
alias ascii_theme_reload='ascii_theme_select r'
alias I_Love_Baruch_Hashem_ascii_theme_select='ascii_theme_select theme 206; echo -e "\nSelect a theme with:\n\n ascii_theme_select theme"'
alias I_Love_Yeshua_ascii_theme_select='ascii_theme_select theme 209; echo -e "\nSelect a theme with:\n\n ascii_theme_select theme"'
alias I_Love_Jesus_ascii_theme_select='ascii_theme_select theme 207; echo -e "\nSelect a theme with:\n\n ascii_theme_select theme"'
alias penguin_ascii_theme_select='ascii_theme_select theme 259; echo -e "\nSelect a theme with:\n\n ascii_theme_select theme"'
alias Home_Linux_ascii_theme_select='ascii_theme_select theme 204; echo -e "\nSelect a theme with:\n\n ascii_theme_select theme"'