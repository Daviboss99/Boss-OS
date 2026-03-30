; ========================================================>
; moto_IA.asm - IA BossOS (Versão Autossuficiente)
; ========================================================>

abrir_IA:
    pusha
    
    call ia_limpar_tela     ; Usando a função que criamos abaixo
    
    mov dh, 2               ; Linha 2
    mov dl, 2               ; Coluna 2
    call ia_set_cursor      ; Usando a função que criamos abaixo
    
    mov si, msg_ia_banner
    call print_string       ; Esta tem na sua biblioteca!
    
    mov dh, 4
    call ia_set_cursor
    
    mov si, msg_hello
    call print_string

eliza_loop:
    ; --- Posicionar para o Usuário digitar ---
    mov dh, 10
    mov dl, 2
    call ia_set_cursor
    
    mov si, msg_prompt
    call print_string

    ; --- LER TECLADO (Usando interrupção direta da BIOS) ---
    mov di, input_buffer
    call ia_ler_string

    ; --- LÓGICA DE COMPARAÇÃO ---
    mov si, input_buffer
    mov di, key_mae
    call comparar_strings   ; Esta tem na sua biblioteca!
    jc .responder_familia

    ; Resposta padrão
    mov si, resp_default
    call ia_print_resp
    jmp eliza_loop

.responder_familia:
    mov si, resp_mae
    call ia_print_resp
    jmp eliza_loop

; ========================================================>
; FUNÇÕES DE SUPORTE (Para sumir os erros do NASM)
; ========================================================>

ia_limpar_tela:
    mov ax, 03h             ; Reinicia o modo de vídeo (limpa tudo)
    int 10h
    ret

ia_set_cursor:
    mov ah, 02h             ; Função de mover cursor da BIOS
    mov bh, 0               ; Página 0
    int 10h
    ret

ia_print_resp:
    mov dh, 12              ; Linha da resposta
    mov dl, 5
    call ia_set_cursor
    call print_string
    ret

ia_ler_string:
    ; Lê caracteres até apertar ENTER
    .loop_leitura:
        mov ah, 00h
        int 16h             ; Lê tecla
        cmp al, 0Dh         ; É ENTER?
        je .fim_leitura
        mov [di], al        ; Salva no buffer
        inc di
        mov ah, 0Eh         ; Mostra o que digitou (echo)
        int 10h
        jmp .loop_leitura
    .fim_leitura:
        mov byte [di], 0    ; Finaliza a string com 0
        ret

; ========================================================>
; DADOS DA IA
; ========================================================>

section .data
    msg_ia_banner   db "--- BOSS INTELIGENCE SYSTEM ---", 0
    msg_hello       db "IA: Ola Davi. O que houve?", 0
    msg_prompt      db "DIGITE: ", 0
    key_mae         db "MAE", 0
    resp_mae        db "IA: A familia e importante no BossOS.", 0
    resp_default    db "IA: Entendi. Conte-me mais.", 0
    input_buffer    times 64 db 0

