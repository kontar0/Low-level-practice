BITS 16
org 0x7C00

start:
    xor ax, ax
    mov ds, ax
    mov [boot_drive], dl
    
    mov ss, ax
    mov sp, 0x7C00

    xor ah, ah
    xor ch, ch              ; ! цилиндр
    xor dh, dh              ; ! головка
    mov cl, 2               ; ! какой сектор прочитать
    xor ax, ax
    mov es, ax              ; ! какой сегмент прочитать
    mov al, 2               ; ! сколько секторов прочитать
    mov ah, 0x02            ; ! прочитать
    mov bx, 0x7E00          ; ! где прочитать
    mov dl, [boot_drive]    ; !
    int 0x13
    jc print_error
    jmp 0x7E00


print_error:
    mov si, error_message

print_error_main:
    lodsb
    test al, al
    je hang
    mov ah, 0x0E
    int 0x10
    jmp print_error_main

hang:
    jmp hang

boot_drive: db 0
error_message: db 'Error with disk', 0
times 510-($-$$) db 0
dw 0xAA55