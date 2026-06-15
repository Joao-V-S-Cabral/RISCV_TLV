# RISCV_TLV
Projeto de implementação de um processador RISC-V (RV32I) utilizando a linguagem **TL-Verilog (Transaction-Level Verilog)** e macros **M5/M4**.

Este projeto fornece uma arquitetura de CPU de 32 bits estruturada para execução e simulação visual no ambiente web **Makerchip**.

## 📂 Estrutura do Projeto

*   **`principal/`**
    *   [RISCV_BASE_ATUAL.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/principal/RISCV_BASE_ATUAL.v): Arquivo do núcleo do processador com pipeline de 5 estágios.
    *   [imem_rb_mem.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/principal/imem_rb_mem.v): Estrutura de memória de dados (`dmem`), banco de registradores (`rf`), memória de instrução (`imem`) e lógica de depuração visual.
    *   [instructions.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/principal/instructions.v): Definição de formatos de instrução e biblioteca de decodificação de opcodes do RV32I.
*   **`fontes_codigo/`**
    *   [conjunto_instrucoes.v](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/fontes_codigo/conjunto_instrucoes.v): Cópia local de referência das especificações do conjunto de instruções.
    *   [instruções disponíveis.txt](file:///c:/Users/jciri/OneDrive/Desktop/RISCV_TLV/RISCV_TLV/fontes_codigo/instru%C3%A7%C3%B5es%20dispon%C3%ADveis.txt): Mnêmicos aceitos pelo montador.
*   **`fontes_teoricas/`**: Manuais e referências em PDF sobre RISC-V, TL-Verilog e depuração visual.

## 🛠️ Principais Características do Projeto

*   **Arquitetura Pipelined (5 Estágios)**: O processador divide a execução das instruções nas etapas clássicas de `@FETCH` (busca), `@DECODE` (decodificação), `@EXEC` (execução), `@MEM` (memória) e `@WB` (write-back).
*   **Encaminhamento de Dados (Forwarding Unit)**: Lógica implementada para mitigar conflitos de dados (data hazards) de forma transparente, permitindo que a saída da ULA de estágios avançados retroalimente diretamente operandos do estágio de execução.
*   **Detecção de Conflitos (Hazard Detection Unit)**: Unidade dedicada a pausar o pipeline (*stall*) quando há dependências de dados intratáveis (ex: leitura de registrador imediatamente após uma instrução de Load) ou realizar o descarte (*flush*) de instruções durante desvios de fluxo.
*   **Lógica de Desvio Dedicada (Branch Unit)**: Lógica para validação e tomada de saltos condicionais (`BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`) diretamente no pipeline.
*   **Suporte a Instruções Customizadas de Sistema**: Mapeamento do montador e decodificador estendidos para suportar as instruções de controle do sistema **`ECALL`** (chamada de ambiente) e **`EBREAK`** (ponto de parada) sem necessidade de passar argumentos de registradores no código assembly.

## 🚀 Simulação

Para simular o processador no **Makerchip**, certifique-se de que o arquivo principal aponta para a biblioteca de memórias hospedada no repositório:
```verilog
m4_include_lib(['https://raw.githubusercontent.com/Joao-V-S-Cabral/RISCV_TLV/main/principal/imem_rb_mem.v'])
```
Isso permite que a plataforma carregue dinamicamente as definições locais do banco de memórias e a lógica customizada de instruções.
