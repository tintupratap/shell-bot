# Start from the Debian base image
FROM debian:latest


# User setup
RUN apt-get update && apt-get install apt-utils sudo -y
RUN useradd -m coder
RUN echo "coder:coder" | chpasswd
RUN adduser coder sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# /etc/passwd file(not needed since user is added to sudoers group)
#mark:x:1001:1001:mark,,,:/home/mark:/bin/bash
#[--] - [--] [--] [-----] [--------] [--------]
#|    |   |    |     |         |        |
#|    |   |    |     |         |        +-> 7. Login shell
#|    |   |    |     |         +----------> 6. Home directory
#|    |   |    |     +--------------------> 5. GECOS
#|    |   |    +--------------------------> 4. GID
#|    |   +-------------------------------> 3. UID
#|    +-----------------------------------> 2. Password
#+----------------------------------------> 1. Username
USER coder

# Apply Bot settings
COPY ./shell-bot /home/coder/.shell-bot

# Use bash shell
ENV SHELL=/bin/bash

# Install packages
RUN sudo apt-get update && sudo apt-get install nodejs npm -y

# Fix permissions for bot
RUN sudo chown -R coder:coder /home/coder/.shell-bot
RUN chmod +x /home/coder/.shell-bot/start.sh
WORKDIR /home/coder/.shell-bot

# Entrypoint
ENTRYPOINT ["bash /home/coder/.shell-bot/start.sh"]
