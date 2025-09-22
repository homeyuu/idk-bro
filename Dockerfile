FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    USERNAME=yuu \
    PASSWORD=lt4c2025

# Desktop + XRDP + tiện ích
RUN apt-get update -qq && \
    apt-get install -y -qq ubuntu-mate-desktop xrdp supervisor sudo curl wget git unzip build-essential \
    python3 python3-pip cmake ninja-build kitty dbus-x11 pulseaudio x11-apps net-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# User + sudoer
RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

# Brave
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update -qq && \
    apt-get install -y -qq brave-browser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Discord
RUN wget -q -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get install -y -qq /tmp/discord.deb || apt-get install -f -y -qq && \
    rm -f /tmp/discord.deb

# XRDP config
RUN echo "mate-session" > /home/$USERNAME/.xsession && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.xsession

# Supervisord
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 3389

CMD ["/usr/bin/supervisord", "-n"]
