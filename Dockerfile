FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    wget \
    curl \
    net-tools \
    && apt-get clean

WORKDIR /vm

# Create install + run script using cat
RUN cat << 'EOF' > install.sh
#!/bin/bash

set -e

echo "[1/5] Installing dependencies..."
apt-get update -y
apt-get install -y qemu-system-x86 qemu-utils wget curl net-tools

echo "[2/5] Creating virtual disk..."
qemu-img create -f qcow2 win10.qcow2 60G

echo "[3/5] Downloading Windows 10 ISO..."
wget -O windows10.iso "https://archive.org/download/win-10-21-h-1-english-x-64_20210711/Win10_21H1_English_x64.iso"

echo "[4/5] Starting Windows 10 installer..."

qemu-system-x86_64 \
  -m 6144 \
  -smp 4 \
  -cpu host \
  -drive file=win10.qcow2,format=qcow2 \
  -cdrom windows10.iso \
  -boot d \
  -netdev user,id=n1,hostfwd=tcp::3389-:3389 \
  -device e1000,netdev=n1 \
  -vga std

EOF

RUN chmod +x install.sh

# Run automatically when container starts
CMD ["bash", "install.sh"]

# Optional RDP port exposure
EXPOSE 3389
