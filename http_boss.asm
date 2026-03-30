; =============================================================================
; BossOS - Módulo de Protocolo HTTP (HyperText Transfer Protocol)
; Versão: 1.0 "Estudo Web"
; Descrição: Responsável por formatar pedidos de páginas para o Navegador.
; =============================================================================

[bits 16]

section .data
    ; --- Cabeçalhos Padrão do Protocolo ---
    http_metodo      db "GET / ", 0
    http_versao      db " HTTP/1.1", 13, 10, 0        ; 13, 10 = CRLF (Nova linha)
    http_host_label  db "Host: ", 0
    http_user_agent  db "User-Agent: BossOS/1.0 (Davi Edition)", 13, 10, 0
    http_connection  db "Connection: close", 13, 10, 13, 10, 0 ; Fim do cabeçalho

    ; --- Variáveis de Controle ---
    url_destino      times 128 db 0
    pacote_completo  times 512 db 0                   ; Onde montamos o pedido final

    ; --- Mensagens de Sistema ---
    msg_http_gerando db "HTTP: Gerando requisicao para o servidor...", 0
    msg_http_pronto  db "HTTP: Pacote de dados pronto para o driver de rede.", 0

section .text

; -----------------------------------------------------------------------------
; FUNÇÃO: montar_requisicao_http
; Entrada: SI = Endereço da URL digitada na barra de pesquisa (ex: "google.com")
; Saída: O buffer 'pacote_completo' estará preenchido com o texto HTTP.
; -----------------------------------------------------------------------------
montar_requisicao_http:
    pusha
    
    mov si, msg_http_gerando
    call print_string
    call proxima_linha          ; Função da sua biblioteca para pular linha

    ; 1. Limpar o buffer do pacote antigo (Zerar o lixo da memória)
    mov di, pacote_completo
    mov al, 0
    mov cx, 512
    rep stosb                   ; Preenche 512 bytes com ZERO

    ; 2. Começar a montagem: Copiar "GET / "
    mov di, pacote_completo
    mov si, http_metodo
    call .copiar_string

    ; 3. Copiar a Versão: " HTTP/1.1" + Quebra de linha
    mov si, http_versao
    call .copiar_string

    ; 4. Adicionar o Host: "Host: "
    mov si, http_host_label
    call .copiar_string

    ; 5. Adicionar a URL que o usuário digitou (ex: google.com)
    ; SI aqui deve apontar para onde o BossBrowser guardou a URL
    mov si, url_destino         ; Supondo que a URL esteja aqui
    call .copiar_string
    
    ; Adicionar quebra de linha após o Host
    mov al, 13
    stosb
    mov al, 10
    stosb

    ; 6. Adicionar User-Agent (Dizendo ao site que é o BossOS)
    mov si, http_user_agent
    call .copiar_string

    ; 7. Finalizar o cabeçalho (Connection: close + Duplo Enter)
    ; O duplo Enter é obrigatório no protocolo HTTP para o servidor responder
    mov si, http_connection
    call .copiar_string

    mov si, msg_http_pronto
    call print_string
    
    popa
    ret

; --- Subfunção Interna: Copiar String para o Buffer DI ---
.copiar_string:
.loop_copy:
    lodsb               ; Carrega de SI
    cmp al, 0           ; Fim da string?
    je .done_copy
    stosb               ; Salva em DI
    jmp .loop_copy
.done_copy:
    ret

; -----------------------------------------------------------------------------
; FUNÇÃO: enviar_pedido_estudo
; Objetivo: Pega o pacote montado e joga no driver de rede (RTL8139).
; -----------------------------------------------------------------------------
enviar_pedido_estudo:
    pusha
    
    ; Precisamos contar quantos bytes o pacote tem no total
    mov si, pacote_completo
    mov cx, 0
.contar:
    lodsb
    cmp al, 0
    je .enviar
    inc cx
    jmp .contar

.enviar:
    ; Agora chamamos o Driver que você já tem pronto!
    mov si, pacote_completo
    ; CX já tem o tamanho do pacote
    call enviar_pacote_rede     ; Função que está no rede_rtl8139.asm
    
    popa
    ret

