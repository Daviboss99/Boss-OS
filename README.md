# 🚀 BossOS v2.0
**Um Sistema Operacional de 1.2 KB feito do zero.**

Este é um projeto de estudo de arquitetura de computadores e sistemas operacionais, desenvolvido inteiramente em um smartphone via **Termux**.

## 🛠️ Características:
- **Linguagem:** Assembly x86 (16-bit Real Mode).
- **Tamanho do Kernel:** ~1.2 KB.
- **Drivers Próprios:** Vídeo, Teclado e Biblioteca de funções básicas.
- **Apps Inclusos:** Terminal, Calculadora, Editor de Texto e Relógio.

## 📁 Estrutura do Projeto:
- `bootloader.asm`: O código que acorda o processador.
- `kernel.asm`: O coração do sistema.
- `teclado.asm` & `video.asm`: Drivers para interagir com o hardware.
- `biblioteca.asm`: Funções de sistema (System Calls).

## 💻 Como rodar:
Pode ser executado em qualquer emulador como **QEMU** ou **Bochs** usando a imagem `BossOS.img`.

