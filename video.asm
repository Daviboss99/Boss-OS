; ==========================================================
; video.asm - Motor Completo de Interface do BossOS
; ==========================================================

; --- 1. Função para Desenhar o Fundo Azul ---
desenhar_fundo_azul:
    mov ah, 06h
    mov al, 0
    mov bh, 0x1F         ; Azul com letra branca
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h
    ret

; --- 2. Função para a Barra de Tarefas ---
desenhar_barra_tarefas:
    mov ah, 06h
    mov al, 0
    mov bh, 0x70         ; Cinza com letra preta
    mov ch, 23           ; Linha da barra
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h

    ; Escrever [ Iniciar ]
    mov ah, 02h
    mov bh, 0
    mov dh, 23
    mov dl, 1
    int 10h
    mov si, txt_iniciar
    call print_string
    ret

; --- 3. Função para o Menu Iniciar ---
desenhar_menu_iniciar:
    mov ah, 06h
    mov al, 0
    mov bh, 0x70         ; Menu Cinza
    mov ch, 10
    mov cl, 1
    mov dh, 22
    mov dl, 20
    int 10h
    
    ; Opções do Menu
    mov dh, 11
    mov dl, 2
    mov si, txt_terminal
    call imprimir_texto_menu
    
    mov dh, 13
    mov dl, 2
    mov si, txt_web
    call imprimir_texto_menu
    
    mov dh, 15
    mov dl, 2
    mov si, txt_calc
    call imprimir_texto_menu
    ret

; --- 4. Função para Janelas de Aplicativos ---
; CH=Y, CL=X, DH=Alt, DL=Larg, SI=Titulo
desenhar_janela_app:
    mov ah, 06h
    mov al, 0
    mov bh, 0x70         ; Fundo da janela cinza
    int 10h

    push dx
    mov dh, ch           ; Barra de título azul
    mov ah, 06h
    mov bh, 0x1F
    int 10h
    pop dx

    mov ah, 02h
    mov bh, 0
    inc cl
    int 10h
    call print_string
    ret

; --- Funções Auxiliares ---
imprimir_texto_menu:
    mov ah, 02h
    mov bh, 0
    int 10h
    call print_string
    ret
; video.asm
limpar_tela_total:
    mov ah, 06h          ; Função de Scroll (limpar)
    mov al, 0            ; 0 = Limpar tela inteira
    mov bh, 0x07         ; 0 = Fundo Preto, 7 = Letra Branca
    mov ch, 0            ; Linha inicial
    mov cl, 0            ; Coluna inicial
    mov dh, 24           ; Linha final
    mov dl, 79           ; Coluna final
    int 10h
    ret

resetar_cursor:
    mov ah, 02h          ; Função de posicionar cursor
    mov bh, 0            ; Página 0
    mov dh, 0            ; Linha 0
    mov dl, 0            ; Coluna 0
    int 10h
    ret

; --- TEXTOS ---
txt_iniciar  db "[ Iniciar ]", 0
txt_terminal db "1. Terminal", 0
txt_web      db "2. Navegador", 0
txt_calc     db "3. Calculadora", 0

