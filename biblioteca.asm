; ==========================================================
; biblioteca.asm - As Cordas Vocais do BossOS
; ==========================================================

print_string:
    pusha                ; Guarda todos os registradores para não dar erro
.loop:
    lodsb                ; Carrega a próxima letra de SI para AL
    cmp al, 0            ; É o fim da string (o número 0)?
    je .fim              ; Se sim, para de escrever
    mov ah, 0Eh          ; Função de teletype da BIOS
    mov bh, 0            ; Página de vídeo 0
    int 10h              ; Chama a interrupção de vídeo
    jmp .loop            ; Volta para pegar a próxima letra
.fim:
    popa                 ; Devolve os registradores como estavam
    ret

; --- Aproveite e coloque a comparar_strings aqui também se não tiver ---
comparar_strings:
    push si
    push di
.comp_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .diferente
    cmp al, 0
    je .igual
    inc si
    inc di
    jmp .comp_loop
.diferente:
    pop di
    pop si
    clc
    ret
.igual:
    pop di
    pop si
    stc
    ret

