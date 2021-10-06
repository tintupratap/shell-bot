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
#COPY ./shell-bot /home/coder/.shell-bot

# Use bash shell
ENV SHELL=/bin/bash

# Install packages
RUN sudo apt-get update && sudo apt-get install nodejs npm git apt-utils -y

# Fix permissions for bot
RUN git clone https://github.com/botgram/shell-bot /home/coder/.shell-bot

RUN echo '{'  >>  /home/coder/.shell-bot/config.json
RUN echo '    "authToken": "1753768172:AAHfN-yHY14dmm_m6tS-A6sMfDSWbwGnK4M",' >>  /home/coder/.shell-bot/config.json
RUN echo '    "owner": 238675017' >>  /home/coder/.shell-bot/config.json
RUN echo '}' >>  /home/coder/.shell-bot/config.json >>

RUN echo "npm start" >> /home/coder/.shell-bot/loop.sh
RUN echo "bash start.sh" >> /home/coder/.shell-bot/loop.sh

RUN echo "cd /home/coder/.shell-bot/" >> /home/coder/.shell-bot/start.sh
RUN echo "npm start" >> /home/coder/.shell-bot/start.sh
RUN echo "bash loop.sh" >> /home/coder/.shell-bot/start.sh



RUN sudo chown -R coder:coder /home/coder/.shell-bot
RUN chmod +x /home/coder/.shell-bot/start.sh
WORKDIR /home/coder/.shell-bot

# Entrypoint
ENTRYPOINT ["bash /home/coder/.shell-bot/start.sh"]
