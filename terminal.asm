; ==========================================================
; terminal_v2.asm - O Cérebro do BossOS v2.0
; ==========================================================

buffer_cmd times 32 db 0     ; Buffer para o comando digitado
pos_buffer dw 0              ; Contador de letras no buffer

abrir_terminal_v2:
    call limpar_tela_total
    call resetar_cursor
    mov si, msg_header_v2
    call print_string
    jmp .novo_prompt

.novo_prompt:
    mov si, prompt_v2
    call print_string
    mov word [pos_buffer], 0 ; Reseta o contador do buffer

.loop_leitura:
    mov ah, 00h
    int 16h                  ; Lê a tecla

    cmp al, 13               ; ENTER?
    je .processar
    
    cmp al, 8                ; BACKSPACE?
    je .apagar_letra

    cmp al, 27               ; ESC?
    je voltar_ao_desktop

    ; Exibe a letra e guarda no buffer
    mov ah, 0Eh
    int 10h
    mov bx, [pos_buffer]
    mov [buffer_cmd + bx], al
    inc word [pos_buffer]
    jmp .loop_leitura

.apagar_letra:
    ; Lógica simples de backspace (opcional para v2)
    jmp .loop_leitura

.processar:
    call pular_linha
    
    ; Finaliza a string do buffer com zero (null-terminator)
    mov bx, [pos_buffer]
    mov byte [buffer_cmd + bx], 0

    ; --- COMPARAÇÃO DE COMANDOS ---
    
    ; 1. Comando "cls"
    mov si, buffer_cmd
    mov di, cmd_cls
    call comparar_strings
    je .exec_cls

    ; 2. Comando "ver"
    mov si, buffer_cmd
    mov di, cmd_ver
    call comparar_strings
    je .exec_ver

    ; 3. Comando "help"
    mov si, buffer_cmd
    mov di, cmd_help
    call comparar_strings
    je .exec_help

    ; Se não for nenhum:
    mov si, msg_erro_v2
    call print_string
    jmp .novo_prompt

; --- FUNÇÕES DOS COMANDOS ---

.exec_cls:
    call limpar_tela_total
    call resetar_cursor
    jmp .novo_prompt

.exec_ver:
    mov si, msg_versao_info
    call print_string
    jmp .novo_prompt

.exec_help:
    mov si, msg_ajuda
    call print_string
    jmp .novo_prompt

; --- DADOS E MENSAGENS ---
msg_header_v2    db "BossOS Terminal v2.0 - Digite 'help'", 13, 10, 0
prompt_v2        db "Boss@Davi> ", 0
cmd_cls          db "cls", 0
cmd_ver          db "ver", 0
cmd_help         db "help", 0
msg_erro_v2      db "Comando invalido!", 13, 10, 0
msg_versao_info  db "BossOS v2.0 - Desenvolvido por Davi R. Boss", 13, 10, 0
msg_ajuda        db "Comandos: cls, ver, help, exit(ESC)", 13, 10, 0

; --- FUNCAO PARA PULAR LINHA NO TERMINAL ---
pular_linha:
    mov ah, 0Eh
    mov al, 13          ; Retorno de carro (volta para o inicio da linha)
    int 10h             ; Chama a BIOS
    
    mov al, 10          ; Nova linha (desce o cursor)
    int 10h             ; Chama a BIOS
    ret
voltar_ao_desktop:
    call desenhar_fundo_azul     ; Nome da função que pinta a tela no video.asm
    call desenhar_barra_tarefas  ; Nome da função da barra cinza
    ret

