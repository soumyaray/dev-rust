#!/bin/zsh
# Initialize the project in DevContainer

echo "*** zsh initialize ***"

project_root="${HOME}/workspace"

# Get zsh setting from zsh_config.yml
zsh_config_file="/tmp/zsh_config.yml"
IFS=$'\n'
zsh_theme=($(yq '.oh_my_zsh.zshrc.zsh_theme' ${zsh_config_file}))
theme_install_command=($(yq '.oh_my_zsh.zshrc.theme_install_command' ${zsh_config_file}))
theme_other_commands=($(yq '.oh_my_zsh.zshrc.theme_other_commands.[]' ${zsh_config_file}))
plugins=($(yq '.oh_my_zsh.zshrc.plugins.[].plugin' ${zsh_config_file}))
plugin_install_commands=($(yq '.oh_my_zsh.zshrc.plugins.[].plugin_install_command' ${zsh_config_file}))

zshrc_file="${HOME}/.zshrc_new"
touch ${zshrc_file}
chmod 644 ${zshrc_file}

NEWLINE=$'\n'
content='export ZSH="$HOME/.oh-my-zsh"'${NEWLINE}

# Set zsh theme
content+='ZSH_THEME="'${zsh_theme}'"'${NEWLINE}
if [ ${theme_install_command} != 'null' ]; then
    eval ${theme_install_command}
fi
content+=${NEWLINE}"#Customize the theme"${NEWLINE}
for command in "${theme_other_commands[@]}"; do
    content+=${command}${NEWLINE}
done

# Set zsh plugins
content+=${NEWLINE}"#Plugins"${NEWLINE}
plugin_content=''
for ((i=1; i<=${#plugins[@]}; i++)); do
    if [ ${i} -gt 1 ]; then
        plugin_content+=' '
    fi
    plugin_content+=${plugins[${i}]}

    if [ ${plugin_install_commands[$i]} != 'null' ]; then
        eval ${plugin_install_commands[$i]}
    fi
done
content+='plugins=('${plugin_content}')'${NEWLINE}

content+=${NEWLINE}'source $ZSH/oh-my-zsh.sh'${NEWLINE}

echo ${content} >> ${zshrc_file}
mv ${zshrc_file} ${HOME}/.zshrc