BITS 16
org 0x7E00

start2:
    cld
    xor bh, bh
    xor dx, dx
    mov es, dx
    mov word [curr_text], text_buffer
    mov word [curr_log_buffer], log_buffer
    
    mov ax, 0xFFFF
    mov es, ax
    mov ax, [es:0x7E0E]
    cmp ax, 0xAA55
    je equal
    mov si, a20_on
    jmp continue_start
    equal:
    mov si, a20_off
    continue_start:
    xor ax, ax
    mov es, ax
    call print
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov ah, 0x0E
    mov al, 0x0A
    int 0x10

    mov si, basic_message
    call print
    jmp to_keyboard

print:
    lodsb
    test al, al
    jne continue
    ret
    continue:
    mov ah, 0x0E
    int 0x10
    jmp print


to_keyboard:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov ah, 0x0E
    mov al, 0x0A
    int 0x10

print_keyboard:
    mov ah, 0x00
    int 0x16
    cmp al, 0x00
    jne continue_print
    cmp ah, 0x4B
    je left_log
    cmp ah, 0x4D
    je right_log
    jmp print_keyboard
    continue_print:
    cmp al, 0x03
    je interupted

    cmp al, 0x1A
    je ctrl_z

    cmp al, 0x08
    je backspace

    cmp al, 0x0D
    je keyboard_enter_log

    call text_push
    call log_push
    mov ah, 0x0E
    int 0x10
    mov al, 0x01
    call log_push
    jmp print_keyboard

left_log:
    mov al, 0x02
    call log_push
    test dl, dl
    jne continue_left
    call log_pop
    jmp print_keyboard
left:
    xor bh, bh
    mov ah, 0x03
    int 0x10
    continue_left:
    dec dl
    mov ah, 0x02
    int 0x10
    jmp print_keyboard

right_log:
    mov al, 0x03
    call log_push
right:
    xor bh, bh
    mov ah, 0x03
    int 0x10
    inc dl
    mov ah, 0x02
    int 0x10
    jmp print_keyboard

text_push:
    mov di, [curr_text]
    stosb
    mov [curr_text], di
    ret

text_pop:
    mov si, [curr_text]
    cmp si, text_buffer
    jbe .empty
    dec si
    mov al, [si]
    mov [curr_text], si
    ret

.empty:
    xor al, al
    ret

log_push:
    mov di, [curr_log_buffer]
    stosb
    mov [curr_log_buffer], di
    ret

log_pop:
    mov si, [curr_log_buffer]
    cmp si, log_buffer
    jbe .empty_log
    dec si
    mov al, [si]
    mov [curr_log_buffer], si
    ret

.empty_log:
    xor al, al
    ret

keyboard_enter_log:
    xor bh, bh
    mov ah, 0x03
    int 0x10
    mov al, dh
    call log_push
    mov al, dl
    call log_push
    mov al, 0x0A
    call log_push
    mov word [curr_text], text_buffer

keyboard_enter:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov ah, 0x0E
    mov al, 0x0A
    int 0x10
    jmp print_keyboard

backspace:
    call text_pop
    test al, al
    je print_keyboard
    call log_push
    mov al, 0x08
    call log_push

backspace_text:
    mov al, 0x08
    mov ah, 0x0E
    int 0x10
    mov al, ' '
    mov ah, 0x0E
    int 0x10
    mov al, 0x08
    mov ah, 0x0E
    int 0x10
    jmp print_keyboard

interupted:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov ah, 0x0E
    mov al, 0x0A
    int 0x10
    mov si, interupted_message
    call print
    jmp hang

ctrl_z:
    call log_pop
    test al, al
    je print_keyboard

    cmp al, 0x08
    jne continue_z1
    call log_pop
    call text_push
    mov ah, 0x0E
    int 0x10
    jmp print_keyboard
    continue_z1:

    cmp al, 0x0A
    jne continue_z2
    call log_pop
    mov dl, al
    call log_pop
    mov dh, al
    mov ah, 0x02
    int 0x10
    jmp print_keyboard
    
    continue_z2:
    cmp al, 0x01
    jne continue_z3
    call log_pop
    call text_pop
    jmp backspace_text
    continue_z3:
    cmp al, 0x02
    je right
    cmp al, 0x03
    je left
    jmp print_keyboard
    
hang:
    jmp hang

curr_log_buffer equ 0x8008
curr_text equ 0x8000
text_buffer equ 0x800F
log_buffer equ 0x810F
a20_on: db "a20 in turned on", 0
a20_off: db "a20 in turned off", 0
basic_message: db "Hello from sector 2", 0
interupted_message: db 'Keyboard was interupted. Bye!', 0
times 1024-($-$$) db 0