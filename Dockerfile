FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    wget curl \
    net-tools \
    && apt-get clean

WORKDIR /vm

RUN cat << 'EOF' > run.sh
#!/bin/bash

set -e

echo "[1] Creating disk..."
qemu-img create -f qcow2 win10.qcow2 60G

echo "[2] Downloading Windows ISO..."
wget -O win10.iso "https://archive.org/download/win-10-21-h-1-english-x-64_20210711/Win10_21H1_English_x64.iso"

echo "[3] Booting Windows installer..."

qemu-system-x86_64 \
  -m 4096 \
  -smp 2 \
  -cpu qemu64 \
  -drive file=win10.qcow2,format=qcow2 \
  -cdrom win10.iso \
  -boot d \
  -netdev user,id=n1 \
  -device e1000,netdev=n1 \
  -vga std

EOF

RUN chmod +x run.sh

CMD ["bash", "run.sh"]
