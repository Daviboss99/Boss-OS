; bootloader.asm
; Montar com: nasm -f bin bootloader.asm -o boot.bin

[org 0x7C00]

KERNEL_OFFSET equ 0x1000    ; Onde o kernel será carregado na memória
KERNEL_SECTORS equ 50       ; Quantos setores ler (ajuste conforme seu kernel)

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [BOOT_DRIVE], dl    ; BIOS coloca o drive em DL

    call load_kernel
    call jump_to_kernel

hang:
    jmp hang

; =========================
; Carregar kernel do disco
; =========================
load_kernel:
    mov bx, KERNEL_OFFSET   ; endereço de destino
    mov dh, KERNEL_SECTORS  ; número de setores

    mov dl, [BOOT_DRIVE]

    mov ah, 0x02            ; função BIOS: ler setores
    mov al, dh              ; quantidade de setores
    mov ch, 0x00            ; cilindro
    mov dh, 0x00            ; cabeça
    mov cl, 0x02            ; setor (começa do 2)

    int 0x13
    jc disk_error           ; se erro, pula

    ret

disk_error:
    mov si, error_msg
    call print_string
    jmp $

; =========================
; Pular para o kernel
; =========================
jump_to_kernel:
    jmp KERNEL_OFFSET

; =========================
; Print simples (BIOS)
; =========================
print_string:
    mov ah, 0x0E
.print_loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_loop
.done:
    ret

; =========================
; Dados
; =========================
BOOT_DRIVE db 0

error_msg db "Erro ao ler o disco!", 0

; =========================
; Padding + assinatura
; =========================
times 510 - ($ - $$) db 0
dw 0xAA55
