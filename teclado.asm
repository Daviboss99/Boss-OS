; ==========================================================
; teclado.asm - Controlador de Entradas do BossOS
; ==========================================================

verificar_teclado:
    mov ah, 00h
    int 16h              ; Lê a tecla

    ; --- LOGICA DE ATALHOS (Sempre com espaço antes do comando!) ---
    cmp al, 'i'          ; Tecla 'i' para o Menu
    je .abrir_menu

    cmp al, '1'          ; Tecla '1' para o Terminal
    je .ir_terminal

    cmp al, '2'          ; Tecla '2' para o Editor
    je .ir_editor

    cmp al, '3'          ; Tecla '3' para a Calculadora
    je .ir_calculadora

    jmp .sem_tecla       ; Se não for nada, ignora

; --- DESTINOS (Estes podem ficar encostados na esquerda com ':') ---
.abrir_menu:
    call desenhar_menu_iniciar
    jmp .sem_tecla

.ir_terminal:
    call abrir_terminal_v2
    jmp .sem_tecla

.ir_editor:
    call abrir_editor
    jmp .sem_tecla

.ir_calculadora:
    call abrir_calculadora
    jmp .sem_tecla

.sem_tecla:
    jmp verificar_teclado

