FROM rust:1-bullseye

# Install essentials and utilities
RUN \
    apt update \
    && apt upgrade -y \
    && apt-get install -y sudo \
    && apt-get install -y micro \
    && apt-get install -y zsh \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install Ruby for command line tools
RUN git clone https://github.com/rbenv/ruby-build.git \
  && PREFIX=/usr/local ./ruby-build/install.sh \
  && ruby-build -v 3.1.2 /usr/local \
  && rm -rfv /tmp/ruby-build* \
  && rm -rfv /ruby-build/

# Install gems
RUN gem install --no-document bundler \
  && gem install reenrb

# Add User
ARG USERNAME
ARG GITHUB_USERNAME
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN echo "groupadd --gid ${USER_GID} ${USERNAME}"
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && usermod -aG sudo ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/add_sudoers \
    && chmod 0440 /etc/sudoers.d/add_sudoers

ARG HOME=/home/${USERNAME}
RUN echo "source ${HOME}/workspace/.devcontainer/profile.sh" >> '/etc/zsh/zprofile' \
    && echo "source ${HOME}/.zshrc" >> '/etc/zsh/zshrc' \
    && echo "source ${HOME}/workspace/.devcontainer/login_initialization.sh" >> '/etc/zsh/zlogin'

# Install Oh My Zsh
USER ${USERNAME}

COPY ./zsh_initialization.sh ./zsh_config.yml /tmp/
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended \
    && touch ~/.zshrc \
    && /tmp/zsh_initialization.sh \
    && sudo rm /tmp/zsh_initialization.sh /tmp/zsh_config.yml

# Copy in dotfiles from Github
# see: https://drewdevault.com/2019/12/30/dotfiles.html
RUN \
  cd ~ \
  && git init \
  && git remote add origin https://github.com/${GITHUB_USERNAME}/dotfiles.git \
  && git fetch \
  && git checkout -f main \
  && rm -rf .git