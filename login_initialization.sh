#!/bin/zsh
# Initialize the project in DevContainer

echo "*** login shell initialize ***"

project_root="${HOME}/workspace"

# Get project github urls from config.yml
config_file="${project_root}/.devcontainer/project_config.yml"
IFS=$'\n' project_github_urls=($(yq '.project_github_urls.[]' ${config_file}))

for url in "${project_github_urls[@]}"; do
    repo_name=$(echo "${url}" | sed -E 's/.*\/(.*)/\1/')

    # Clone the project repo
    if [ ! -e "${project_root}/projects/${repo_name}" ]; then
        echo -n "Cloning into '${repo_name}'... " \
        && git clone "${url}" "${project_root}/projects/${repo_name}" &> /dev/null \
        && echo "done."
    fi

    # Bundle install
    echo -n "Bundle installing for '${repo_name}'... " \
    && cd "${project_root}/projects/${repo_name}" \
    && bundle install 1> /dev/null \
    && cd - 1> /dev/null \
    && echo "done."
done

# set prompt
export PROMPT="(dev) ${PROMPT}"
