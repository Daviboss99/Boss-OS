; ========================================================>
; navegador.asm - Interface Gráfica de Texto (BossBrowser)
; ========================================================>

abrir_navegador:
    pusha
    call limpar_tela_branco      ; Vamos usar um fundo cinza/branco

    ; 1. Desenhar a Barra de Cima (Cinza Escuro)
    mov bh, 0x88                ; Atributo: Fundo Cinza, Letra Preta
    mov cx, 0x0000              ; Início: Linha 0, Col 0
    mov dx, 0x014F              ; Fim: Linha 1, Col 79
    call desenhar_retangulo_colorido

    ; 2. Desenhar a Barra de Endereço (Branca)
    mov bh, 0xF0                ; Atributo: Fundo Branco, Letra Preta
    mov cx, 0x000A              ; Linha 0, Col 10
    mov dx, 0x0046              ; Linha 0, Col 70
    call desenhar_retangulo_colorido

    ; 3. Colocar os Textos Fixos
    mov dh, 0                   ; Linha 0
    mov dl, 1                   ; Coluna 1
    call ia_set_cursor
    mov si, msg_btn_voltar
    call print_string_color     ; Versão da print que aceita cores

    mov dl, 12
    call ia_set_cursor
    mov si, msg_url_exemplo     ; "https://google.com"
    call print_string

    ; 4. Linha de Status (Lá embaixo)
    mov bh, 0x1F                ; Fundo Azul, Letra Branca
    mov cx, 0x1800              ; Linha 24, Col 0
    mov dx, 0x184F              ; Linha 24, Col 79
    call desenhar_retangulo_colorido
    
    mov dh, 24
    mov dl, 1
    call ia_set_cursor
    mov si, msg_status_rede
    call print_string

.loop_navegador:
    ; Aqui o navegador fica esperando você digitar ou chegar pacotes
    call checar_recebimento     ; Chama o driver que a gente fez!
    
    mov ah, 00h
    int 16h                     ; Espera tecla
    cmp al, 27                  ; Tecla ESC sai do navegador
    je .sair
    
    jmp .loop_navegador

.sair:
    popa
    ret

; --- Dados da Interface ---
section .data
    msg_btn_voltar   db "[<] [>] [R]", 0
    msg_url_exemplo  db "www.google.com.br", 0
    msg_status_rede  db "BossBrowser v1.0 - Conectado via RTL8139", 0

