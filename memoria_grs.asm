; ========================================================>
; memoria.asm - Gerenciador de RAM do BossOS
; ========================================================>

[bits 16]

; --- VARIÁVEIS DE CONTROLE ---
section .data
    ; Cada bit representa 4KB. 32 bytes = 256 blocos = 1MB
    mapa_ram_bitmap    times 32 db 0 
    total_ram_kb       dw 0
    msg_mem_info       db "RAM TOTAL: ", 0
    msg_kb             db " KB", 0x0D, 0x0A, 0

section .text

inicializar_gerenciador_memoria:
    pusha
    ; 1. Pergunta para a BIOS quanta RAM tem
    int 12h             ; Retorna KB em AX
    mov [total_ram_kb], ax
    
    ; 2. Marcar os primeiros 64KB como ocupados (Kernel)
    ; O primeiro byte do bitmap controla os primeiros 32KB
    mov byte [mapa_ram_bitmap], 0xFF 
    mov byte [mapa_ram_bitmap + 1], 0xFF
    
    popa
    ret

; --- FUNÇÃO: ALOCAR MEMÓRIA ---
; Entrada: AX = Quantos blocos de 4KB você precisa
; Saída: BX = Segmento inicial da memória alocada
alocar_memoria:
    push cx
    push dx
    
    ; Aqui você percorreria o 'mapa_ram_bitmap' procurando
    ; por bits que sejam '0'.
    
    ; Exemplo simples: Retorna sempre o segmento 0x2000 (acima do Kernel)
    mov bx, 0x2000
    
    pop dx
    pop cx
    ret

; --- FUNÇÃO: MOSTRAR STATUS DA RAM ---
exibir_status_memoria:
    pusha
    mov si, msg_mem_info
    call print_string
    
    ; Aqui você converteria o valor de [total_ram_kb] 
    ; de número para texto para exibir na tela.
    
    mov si, msg_kb
    call print_string
    popa
    ret

