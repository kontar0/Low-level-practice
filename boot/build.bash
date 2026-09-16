nasm -f bin boot.asm -o boot.img
nasm -f bin stage2.asm -o stage2.img
cat boot.img stage2.img > disk.img
qemu-system-x86_64 -drive format=raw,file=disk.img -display cocoa,zoom-to-fit=on