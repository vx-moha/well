FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install core system tools, Python 3.11, OpenSSH, and Supervisord
RUN apt update -y && apt install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt update -y && apt install -y \
    openssh-server \
    sudo \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    ffmpeg \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    build-essential \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install Nginx Proxy Manager dependencies (OpenResty/Nginx & Node.js environment)
# Note: Full NPM setup usually requires an intricate build, but we will prepare the 
# system ports and requirements here.
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y sqlite3 nodejs openresty && \
    rm -rf /var/lib/apt/lists/*

# Install Python Pip and packages
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

# SSH Configuration
RUN mkdir /var/run/sshd
RUN echo "root:final1997@@@" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Configure Supervisor to manage both SSH and proxy services
RUN mkdir -p /var/log/supervisor
RUN echo '[supervisord]\n\
nodaemon=true\n\
\n\
[program:sshd]\n\
command=/usr/sbin/sshd -D\n\
autorestart=true\n\
\n\
#[program:nginx-proxy-manager]\n\
#command=node /app/index.js\n\
#autorestart=true\n' > /etc/supervisor/conf.d/supervisord.conf

# Expose SSH, HTTP, HTTPS, and NPM Admin UI
EXPOSE 22 80 443 81

# Launch Supervisor as the master process
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

