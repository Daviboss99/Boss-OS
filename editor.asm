; ==========================================================
; editor.asm - IDE de Desenvolvimento do BossOS
; ==========================================================

abrir_editor:
    mov bh, 0x1E         ; Cor: Fundo Azul (1), Letra Amarela (E)
    call limpar_tela_total
    call resetar_cursor
    
    mov si, msg_editor_topo
    call print_string
    
    mov si, msg_editor_instrucao
    call print_string

    ; Loop de escrita do Editor
    jmp loop_editor

loop_editor:
    mov ah, 00h          ; Ler tecla
    int 16h
    
    cmp al, 27           ; ESC para sair
    je voltar_desktop_editor

    mov ah, 0Eh          ; Mostrar letra na tela
    mov bh, 0
    int 10h
    
    jmp loop_editor

voltar_desktop_editor:
    call desenhar_fundo_azul
    call desenhar_barra_tarefas
    ret

; --- Textos ---
msg_editor_topo      db "--- BossOS Code Editor v1.0 ---", 13, 10, 0
msg_editor_instrucao db "Digite seu codigo abaixo (ESC para sair):", 13, 10, 0

