# Dockerized development environment
#
# This Dockerfile is for building development environment only,
# not for any distribution/production usage.
#
# Please note that it'll use about 1.2 GB disk space and about 15 minutes to
# build this image, it depends on your hardware.

FROM ubuntu:latest

# Set the SHELL to bash with pipefail option
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Prevent dialog during apt install
ENV DEBIAN_FRONTEND noninteractive

# ShellCheck version
ENV SHELLCHECK_VERSION=0.7.0

# Pick a Ubuntu apt mirror site for better speed
# ref: https://launchpad.net/ubuntu/+archivemirrors
#ENV UBUNTU_APT_SITE ubuntu.cs.utah.edu

# Disable src package source
#RUN sed -i 's/^deb-src\ /\#deb-src\ /g' /etc/apt/sources.list

# Replace origin apt package site with the mirror site
#RUN sed -E -i "s/([a-z]+.)?archive.ubuntu.com/$UBUNTU_APT_SITE/g" /etc/apt/sources.list
#RUN sed -i "s/security.ubuntu.com/$UBUNTU_APT_SITE/g" /etc/apt/sources.list

# Install apt packages
RUN apt update         && \
    apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  && \
    apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"     \
        coreutils             \
        util-linux            \
        bsdutils              \
        file                  \
        openssl               \
        libssl-dev            \
        locales               \
        ca-certificates       \
        ssh                   \
        wget                  \
        patch                 \
        sudo                  \
        htop                  \
        dstat                 \
        vim                   \
        tmux                  \
        curl                  \
        git                   \
        jq                    \
        zsh                   \
        ksh                   \
        gcc                   \
        g++                   \
        xz-utils              \
        build-essential       \
        bash-completion       && \
    apt-get clean

RUN wget https://github.com/koalaman/shellcheck/releases/download/v$SHELLCHECK_VERSION/shellcheck-v$SHELLCHECK_VERSION.linux.x86_64.tar.xz -O- | \
    tar xJvf - shellcheck-v$SHELLCHECK_VERSION/shellcheck          && \
    mv shellcheck-v$SHELLCHECK_VERSION/shellcheck /bin             && \
    rmdir shellcheck-v$SHELLCHECK_VERSION
RUN shellcheck -V

# Set locale
RUN locale-gen en_US.UTF-8

# Print tool versions
RUN bash --version | head -n 1
RUN zsh --version
RUN ksh --version || true
RUN dpkg -s dash | grep ^Version | awk '{print $2}'
RUN git --version
RUN curl --version
RUN wget --version

# Add user "coder" as non-root user
RUN useradd -ms /bin/bash coder

# Copy and set permission for nvm directory
COPY . /home/coder/.nvm/
RUN chown coder:coder -R "home/coder/.nvm"

# Set sudoer for "coder"
RUN echo 'coder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Switch to user "coder" from now
USER coder

# nvm and shell-bot
RUN echo 'export NVM_DIR="/home/coder/.nvm"'                                       >> "/home/coder/.bashrc"
RUN echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> "/home/coder/.bashrc"
RUN echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion" # This loads nvm bash_completion' >> "/home/coder/.bashrc"
#RUN echo 'cd /home/coder/.nvm/shell-bot && bash start.sh'                                       >> "/home/coder/.bashrc"

# nodejs and tools
RUN bash -c 'source $HOME/.nvm/nvm.sh   && \
    nvm install node                    && \
    npm install -g doctoc urchin eclint dockerfile_lint && \
    npm install --prefix "$HOME/.nvm/"'

# Set WORKDIR to nvm directory
WORKDIR /home/nvm/.nvm

ENTRYPOINT ["/bin/bash"]