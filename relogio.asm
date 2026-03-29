; relogio.asm
; Função: atualizar_relogio
; Mostra hora atual (HH:MM:SS) usando BIOS

[bits 16]

atualizar_relogio:
    pusha

    ; =========================
    ; Obter hora via BIOS
    ; =========================
    mov ah, 0x02        ; INT 1Ah - Get RTC Time
    int 0x1A

    ; CH = hora (BCD)
    ; CL = minuto (BCD)
    ; DH = segundo (BCD)

    mov si, buffer

    ; Hora
    mov al, ch
    call bcd_to_ascii
    mov [si], ah
    inc si
    mov [si], al
    inc si

    mov byte [si], ':'
    inc si

    ; Minuto
    mov al, cl
    call bcd_to_ascii
    mov [si], ah
    inc si
    mov [si], al
    inc si

    mov byte [si], ':'
    inc si

    ; Segundo
    mov al, dh
    call bcd_to_ascii
    mov [si], ah
    inc si
    mov [si], al
    inc si

    mov byte [si], 0

    ; =========================
    ; Posicionar cursor (canto superior direito)
    ; =========================
    mov ah, 0x02
    mov bh, 0
    mov dh, 0          ; linha 0
    mov dl, 70         ; coluna (ajuste se quiser)
    int 0x10

    ; =========================
    ; Imprimir string
    ; =========================
    mov si, buffer
    call print_string

    popa
    ret

; =========================
; Converter BCD → ASCII
; Entrada: AL = valor BCD
; Saída: AH = dezena ASCII, AL = unidade ASCII
; =========================
bcd_to_ascii:
    push bx

    mov bl, al

    ; Parte alta (dezena)
    shr al, 4
    add al, '0'
    mov ah, al

    ; Parte baixa (unidade)
    mov al, bl
    and al, 0x0F
    add al, '0'

    pop bx
    ret

; =========================
; Buffer
; =========================
buffer db "00:00:00", 0
