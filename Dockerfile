FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install core system tools, Python 3.11, OpenSSH, and Supervisord
RUN apt update -y && apt install -y software-properties-common wget curl gnupg2 && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt update -y && apt install -y \
    openssh-server \
    sudo \
    vim \
    net-tools \
    git \
    tzdata \
    ffmpeg \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    build-essential \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Add official OpenResty repository keys and install Node.js + OpenResty safely
RUN wget -qO - https://openresty.org/pubkey/gpg | apt-key add - && \
    add-apt-repository -y "deb http://openresty.org/bin/ubuntu $(lsb_release -sc) main" && \
    curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt update -y && apt install -y sqlite3 nodejs openresty && \
    rm -rf /var/lib/apt/lists/*

# Install Python Pip and your required packages
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 && \
    python3.11 -m pip install --upgrade pip setuptools wheel

RUN python3.11 -m pip install --no-cache-dir \
    mtranslate \
    google-genai \
    requests \
    g4f \
    mutagen \
    tgcalls==3.0.0.dev6 \
    git+https://github.com/pytgcalls/pytgcalls.git@dev \
    telethon \
    aiocron \
    emoji \
    pytz \
    gtts \
    qrcode \
    Telegram \
    aiohttp \
    fake_useragent \
    user_agent \
    hijri_converter \
    gpytranslate \
    watchdog

# Application Setup
WORKDIR /root
RUN git clone https://github.com/2mrxe2/pro

# SSH Configuration with Password Access
RUN mkdir /var/run/sshd
RUN echo "root:final1997@@@" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Configure Supervisor to manage background actions
RUN mkdir -p /var/log/supervisor
RUN echo '[supervisord]\n\
nodaemon=true\n\
\n\
[program:sshd]\n\
command=/usr/sbin/sshd -D\n\
autorestart=true\n' > /etc/supervisor/conf.d/supervisord.conf

# Expose SSH and standard web ports
EXPOSE 22 80 443 81

# Launch Supervisor as the master process
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
