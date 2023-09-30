#!/bin/sh

qemu-system-aarch64 \
    -fsdev local,id=myid,path=$(pwd)/fs0,security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0,disable-modern=on,disable-legacy=off \
    -kernel build/duktape_qemu-arm64 \
    -nographic \
    -machine virt -cpu cortex-a57
