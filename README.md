# RISCV_TLV
Projeto de implementação de um processador RISC-V (RV32I) na linguagem TL-Verilog (Transaction-Level Verilog).

Este projeto faz parte do workshop de desenvolvimento de processadores RISC-V utilizando o simulador e ambiente virtual Makerchip.

## 📂 Estrutura do Projeto

*   **`principal/`**
    *   [RISCV_BASE_ATUAL.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/principal/RISCV_BASE_ATUAL.v): Arquivo principal do processador pipelined (5 estágios) em TL-Verilog.
    *   [imem_rb_mem.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/principal/imem_rb_mem.v): Definição de memórias e do banco de registradores (Register File) e visualizadores. Inclui a biblioteca de instruções.
    *   [instructions.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/principal/instructions.v): Definição dos opcodes e decodificação do conjunto de instruções RISC-V RV32I.
*   **`fontes_codigo/`**
    *   [conjunto_instrucoes.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/fontes_codigo/conjunto_instrucoes.v): Cópia local de referência das especificações de instruções.
    *   [instruções disponíveis.txt](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/fontes_codigo/instru%C3%A7%C3%B5es%20dispon%C3%ADveis.txt): Listagem de mneumônicos suportados pelo montador.
*   **`fontes_teoricas/`**: PDFs úteis para estudo (Guia do RISC-V, Guia de Macros M4, TL-Verilog, etc).

## 🚀 Como Executar e Simular

No ambiente online [Makerchip](https://makerchip.com/), abra o arquivo principal [RISCV_BASE_ATUAL.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/principal/RISCV_BASE_ATUAL.v).

O arquivo principal inclui a biblioteca `imem_rb_mem.v` diretamente do repositório remoto público no GitHub para carregar a estrutura de hardware necessária.

```verilog
m4_include_lib(['https://raw.githubusercontent.com/Joao-V-S-Cabral/RISCV_TLV/main/principal/imem_rb_mem.v'])
```

## ➕ Programa de Teste (Soma de 1 a 9)

O processador está configurado para executar um laço que soma os números inteiros de 1 a 9.
*   Registrador `r10` (a0): Guarda o resultado acumulado (Soma final).
*   Registrador `r13` (a3): Contador (`1` até `10`).
*   Registrador `r12` (a2): Limite do loop (`10`).

### Código Assembly M4:
```verilog
m4_asm(ADDI, r10, r0, 0)   // Soma acumulada = 0
m4_asm(ADDI, r13, r0, 1)   // Contador = 1
m4_asm(ADDI, r12, r0, 10)  // Limite = 10
m4_asm(ADD, r10, r10, r13) // Loop: Soma = Soma + Contador
m4_asm(ADDI, r13, r13, 1)  // Contador = Contador + 1
m4_asm(BNE, r13, r12, -8)  // Se Contador != 10, desvia para início do loop (offset de -8 bytes)
m4_asm(EBREAK)             // Finaliza o programa
```

A soma final acumulada em `r10` ao término da simulação será **45** (\(1+2+3+4+5+6+7+8+9 = 45\)).

## ⚙️ Customizações de Instruções

Adicionamos suporte no nível do montador e decodificador de hardware para as instruções de sistema:
*   **`ECALL`** (Environment Call): codificado com `32'h00000073`.
*   **`EBREAK`** (Breakpoint): codificado com `32'h00100073`.

Ambas estão integradas por meio de uma subclasse customizada `I2` e podem ser utilizadas normalmente nos programas Assembly da simulação.
