FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    USERNAME=yuu \
    PASSWORD=lt4c2025

# Debug marker để chắc chắn image mới
RUN echo ">>> BUILD TIME: $(date)" > /build-info.txt

# Cài desktop + XRDP + tiện ích
RUN apt-get update -qq && \
    apt-get install -y -qq ubuntu-mate-desktop xrdp sudo curl wget git unzip build-essential \
    python3 python3-pip cmake ninja-build kitty dbus-x11 pulseaudio x11-apps net-tools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Tạo user + sudoer
RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

# Brave browser
RUN curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list && \
    apt-get update -qq && \
    apt-get install -y -qq brave-browser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Discord
RUN wget -q -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
    apt-get install -y -qq /tmp/discord.deb || apt-get install -f -y -qq && \
    rm -f /tmp/discord.deb

# XRDP config (dùng mate-session khi login)
RUN echo "mate-session" > /home/$USERNAME/.xsession && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.xsession

EXPOSE 3389

# Start sesman trước, rồi tới xrdp
CMD ["/bin/sh", "-c", "/usr/sbin/xrdp-sesman --nodaemon & exec /usr/sbin/xrdp --nodaemon"]
