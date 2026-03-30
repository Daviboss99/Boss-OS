; =============================================================================
; BossOS - Módulo Web Parser (Limpador de HTML)
; Versão: 1.0 "Foco nos Estudos"
; Descrição: Filtra tags HTML e exibe apenas o conteúdo textual na tela.
; =============================================================================

[bits 16]

section .data
    ; --- Estados do Filtro ---
    dentro_da_tag    db 0         ; 0 = Texto comum, 1 = Ignorando código HTML
    
    ; --- Cores de Estudo ---
    cor_texto_estudo db 0x70      ; Cinza claro com letra preta (Estilo papel)
    cor_titulo       db 0x71      ; Cinza claro com azul (Para destacar títulos)

    msg_parser_init  db "PARSER: Formatando conteudo para leitura...", 0
    msg_fim_pagina   db "--- Fim da Pagina ---", 0

section .text

; -----------------------------------------------------------------------------
; FUNÇÃO: processar_html_recebido
; Entrada: SI = Endereço do buffer_rx_rede (Onde o Driver de Rede salvou o site)
; Objetivo: Percorrer o código do site e imprimir apenas o texto.
; -----------------------------------------------------------------------------
processar_html_recebido:
    pusha
    
    mov byte [dentro_da_tag], 0   ; Começamos assumindo que é texto
    call limpar_tela_branco      ; Deixa a tela pronta para o estudo

.loop_leitura:
    lodsb                       ; Carrega 1 caractere do site em AL
    cmp al, 0                   ; Verificamos se o site acabou (fim do buffer)
    je .finalizar

    ; --- Lógica do Filtro de Tags ---
    cmp al, '<'                 ; Começou uma tag HTML? (Ex: <html>)
    je .abriu_tag
    
    cmp al, '>'                 ; Terminou uma tag HTML?
    je .fechou_tag

    ; Se não estamos dentro de uma tag, imprimimos o caractere
    cmp byte [dentro_da_tag], 0
    je .imprimir_caractere
    
    jmp .loop_leitura           ; Se estiver dentro da tag, ignora e volta ao loop

.abriu_tag:
    mov byte [dentro_da_tag], 1
    jmp .loop_leitura

.fechou_tag:
    mov byte [dentro_da_tag], 0
    jmp .loop_leitura

.imprimir_caractere:
    ; Pula caracteres de controle inúteis para a tela
    cmp al, 10                  ; Newline (\n)
    je .nova_linha
    cmp al, 13                  ; Carriage Return (\r)
    je .loop_leitura
    
    ; Chama a função da BIOS para imprimir com a cor de estudo
    mov ah, 0Eh                 ; Modo Teletype
    mov bh, 0                   ; Página 0
    int 10h
    jmp .loop_leitura

.nova_linha:
    mov ah, 0Eh
    mov al, 13
    int 10h
    mov al, 10
    int 10h
    jmp .loop_leitura

.finalizar:
    call proxima_linha
    mov si, msg_fim_pagina
    call print_string
    
    popa
    ret

; -----------------------------------------------------------------------------
; FUNÇÃO: destacar_titulos (Opcional para organizar o estudo)
; -----------------------------------------------------------------------------
; Esta função pode ser expandida para procurar por "<h1>" e mudar a cor 
; do texto para azul, facilitando encontrar os tópicos da matéria.

