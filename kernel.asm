; ==========================================================
; BossOS - Kernel Principal (Versão Modular)
; ==========================================================
[org 0x1000]

start:
    ; 1. Setup Inicial de Segmentos
    mov ax, 0
    mov ds, ax
    mov es, ax
    
    ; 2. Configurar Modo de Vídeo (80x25 Texto)
    mov ax, 0x0003
    int 0x10

    ; 3. Desenhar a Interface Inicial
    call desenhar_fundo_azul
    call desenhar_barra_tarefas

main_loop:
    ; --- Módulo de Relógio ---
    call atualizar_relogio

    ; --- Módulo de Teclado (O que o ChatGPT vai fazer) ---
    call verificar_teclado    ; Esta função virá do driver do Aliado

    jmp main_loop

; ==========================================================
; INCLUSÃO DOS MÓDULOS (OS "DRIVERS")
; ==========================================================

%include "video.asm"      ; Funções de desenho e janelas
%include "relogio.asm"    ; Lógica do relógio CMOS
%include "biblioteca.asm"
%include "terminal.asm"
%include "editor.asm"
%include "calc.asm"
%include "teclado.asm"
; Mensagens globais
msg_erro db "Erro no modulo!", 0
