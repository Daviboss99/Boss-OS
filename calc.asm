; ==========================================================
; calc.asm - Calculadora Científica do BossOS (v1.0)
; ==========================================================

abrir_calculadora:
    call limpar_tela_total
    call resetar_cursor
    
    mov si, msg_calc_boas_vindas
    call print_string

    ; 1. Pega o primeiro número
    mov si, msg_pedir_n1
    call print_string
    call ler_tecla_num
    mov bl, al           ; Guarda N1 em BL

    call pular_linha

    ; 2. Pega a operação
    mov si, msg_operacao
    call print_string
    mov ah, 00h
    int 16h              ; Lê '+', '-', '*', '/'
    mov cl, al           ; Guarda a operação em CL
    mov ah, 0Eh
    int 10h              ; Mostra o sinal na tela

    call pular_linha

    ; 3. Pega o segundo número
    mov si, msg_pedir_n2
    call print_string
    call ler_tecla_num
    mov dl, al           ; Guarda N2 em DL

    call pular_linha

    ; 4. Faz a Lógica (O "Cérebro")
    cmp cl, '+'
    je .fazer_soma
    cmp cl, '-'
    je .fazer_sub
    jmp .erro

.fazer_soma:
    add bl, dl           ; BL = N1 + N2
    jmp .mostrar_res

.fazer_sub:
    sub bl, dl           ; BL = N1 - N2
    jmp .mostrar_res

.mostrar_res:
    mov si, msg_resultado
    call print_string
    
    mov al, bl
    add al, '0'          ; Converte de volta para texto
    mov ah, 0Eh
    int 10h
    jmp .fim

.erro:
    mov si, msg_erro_calc
    call print_string

.fim:
    mov si, msg_sair_calc
    call print_string
    mov ah, 00h
    int 16h
    call desenhar_fundo_azul
    call desenhar_barra_tarefas
    ret

; --- Função Auxiliar para ler e converter ---
ler_tecla_num:
    mov ah, 00h
    int 16h
    mov ah, 0Eh
    int 10h              ; Eco na tela
    sub al, '0'          ; Converte ASCII -> Número
    ret

; --- Mensagens ---
msg_calc_boas_vindas db "--- CALCULADORA BOSS v1.0 ---", 13, 10, 0
msg_pedir_n1         db "Numero 1: ", 0
msg_pedir_n2         db "Numero 2: ", 0
msg_operacao         db "Operacao (+ ou -): ", 0
msg_resultado        db "Resultado: ", 0
msg_erro_calc        db "Operacao invalida!", 0
msg_sair_calc        db 13, 10, "Pressione qualquer tecla para sair...", 0

