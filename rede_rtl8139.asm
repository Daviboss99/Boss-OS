; =============================================================================
; BossOS - Driver Monolítico de Rede (Realtek RTL8139)
; Versão: 1.0 "Conectividade Total"
; Descrição: Gerenciamento completo de Hardware, RX e TX.
; =============================================================================

[bits 16]

section .data
    ; --- Configurações de Hardware ---
    rtl_io_base      dw 0xC000    ; Porta Base I/O padrão do Limbo
    
    ; --- Buffers de Memória ---
    ; A placa precisa de um lugar na RAM para descarregar o que chega da internet
    ; O buffer de RX precisa de 8KB + 16 bytes de cabeçalho
    align 4
    buffer_rx_rede   times 8192 + 16 db 0
    
    ; O buffer de TX é onde colocamos o pacote que queremos enviar (ex: pedido do site)
    align 4
    buffer_tx_rede   times 2048 db 0

    ; --- Mensagens de Log do Sistema ---
    msg_rede_init    db "REDE: Inicializando controlador RTL8139...", 0
    msg_rede_ready   db "REDE: Dispositivo pronto para transmissao.", 0
    msg_rede_err     db "REDE: Falha ao resetar o hardware!", 0
    msg_send_ok      db "REDE: Pacote enviado com sucesso.", 0
    msg_recv_ok      db "REDE: Pacote recebido na memoria.", 0

section .text

; -----------------------------------------------------------------------------
; FUNÇÃO: inicializar_driver_rede
; Objetivo: Acordar a placa, resetar registros e configurar buffers de RAM.
; -----------------------------------------------------------------------------
inicializar_driver_rede:
    pusha
    
    mov si, msg_rede_init
    call print_string

    ; 1. LIGAR O CHIP (Wake up)
    ; Escrevemos 0 no registro CONFIG_1 para tirar a placa do modo de espera
    mov dx, [rtl_io_base]
    add dx, 0x52                ; Offset para Config 1
    mov al, 0x00
    out dx, al

    ; 2. COMANDO DE RESET
    ; Enviamos o comando 0x10 para o registro de comando (0x37)
    mov dx, [rtl_io_base]
    add dx, 0x37                ; Command Register
    mov al, 0x10
    out dx, al

.check_reset:
    in al, dx
    test al, 0x10               ; Verifica se o bit 4 (Reset) limpou
    jnz .check_reset            ; Enquanto estiver 1, a placa esta reiniciando

    ; 3. CONFIGURAR O ENDEREÇO DO BUFFER DE RECEPÇÃO (RX)
    ; Dizemos para a placa: "Salve tudo o que chegar no endereço buffer_rx_rede"
    mov dx, [rtl_io_base]
    add dx, 0x30                ; RBSTART (Receive Buffer Start Address)
    mov eax, buffer_rx_rede     ; Usamos EAX para pegar o endereço completo
    out dx, eax

    ; 4. CONFIGURAR INTERRUPÇÕES
    ; Queremos que a placa nos avise quando chegar um pacote (ROK) ou enviar (TOK)
    mov dx, [rtl_io_base]
    add dx, 0x3C                ; IMR (Interrupt Mask Register)
    mov ax, 0x0005              ; ROK (Bit 0) + TOK (Bit 2)
    out dx, ax

    ; 5. CONFIGURAR REGRAS DE RECEPÇÃO (RCR)
    ; Aceitar pacotes destinados a nós, pacotes de Broadcast e Multicast
    mov dx, [rtl_io_base]
    add dx, 0x44                ; RCR (Receive Configuration Register)
    mov eax, 0x0000000F         ; AB + AM + APM + AAP (Modo Promiscuo)
    out dx, eax

    ; 6. ATIVAR TRANSMISSOR E RECEPTOR
    mov dx, [rtl_io_base]
    add dx, 0x37                ; Command Register
    mov al, 0x0C                ; Bits RE (Receiver Enable) e TE (Transmitter Enable)
    out dx, al

    mov si, msg_rede_ready
    call print_string
    
    popa
    ret

; -----------------------------------------------------------------------------
; FUNÇÃO: enviar_pacote_rede
; Entrada: SI = Endereço dos dados, CX = Tamanho do pacote
; -----------------------------------------------------------------------------
enviar_pacote_rede:
    pusha
    
    ; 1. Copiar dados do SI para o buffer_tx_rede
    mov di, buffer_tx_rede
    rep movsb                   ; Copia CX bytes
    
    ; 2. Informar a placa o endereço físico do TX
    mov dx, [rtl_io_base]
    add dx, 0x20                ; TSAD0 (Transmit Start Address 0)
    mov eax, buffer_tx_rede
    out dx, eax
    
    ; 3. Iniciar a transmissão informando o tamanho
    ; O bit 13 (OWN) deve ser 0 para começar
    mov dx, [rtl_io_base]
    add dx, 0x10                ; TSD0 (Transmit Status Descriptor 0)
    mov ax, cx                  ; Tamanho do pacote em bytes
    and ax, 0x1FFF              ; Garante que não passe de 8KB
    out dx, ax                  ; A TRANSMISSÃO COMEÇA AQUI!

.wait_tx:
    in ax, dx
    test ax, 0x8000             ; Verifica se o bit OWN mudou para 1 (Terminou)
    jz .wait_tx
    
    mov si, msg_send_ok
    call print_string
    
    popa
    ret

; -----------------------------------------------------------------------------
; FUNÇÃO: checar_recebimento
; Objetivo: Verificar se a internet mandou algo para o BossOS.
; -----------------------------------------------------------------------------
checar_recebimento:
    pusha
    
    mov dx, [rtl_io_base]
    add dx, 0x37                ; Command Register
    in al, dx
    test al, 0x01               ; Verifica o bit BUFE (Buffer Empty)
    jnz .sem_dados              ; Se estiver vazio, sai fora
    
    ; Se chegou aqui, tem pacote!
    mov si, msg_recv_ok
    call print_string
    
    ; O navegador vai ler os dados aqui do buffer_rx_rede
    
.sem_dados:
    popa
    ret

