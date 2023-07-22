#!/bin/sh

qemu-system-x86_64 -fsdev local,id=myid,path=fs0,security_model=none \
    -device virtio-9p-pci,fsdev=myid,mount_tag=fs0 \
    -kernel build/duktape_qemu-x86_64 \
    -nographic
