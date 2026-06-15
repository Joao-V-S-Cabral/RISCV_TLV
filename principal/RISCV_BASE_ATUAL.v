\m5_TLV_version 1d: tl-x.org
\m5
   
\SV
//m4_include_lib(['https://raw.githubusercontent.com/stevehoover/RISC-V_MYTH_Workshop/c1719d5b338896577b79ee76c2f443ca2a76e14f/tlv_lib/risc-v_shell_lib.tlv'])
m4_include_lib(['https://raw.githubusercontent.com/Joao-V-S-Cabral/RISCV_TLV/main/principal/instructions.v'])
   //m4_asm(ADD, rd, rs1, rs2)
   //m4_asm(SUB, rd, rs1, rs2)
   //m4_asm(XOR, rd, rs1, rs2)
   //m4_asm(OR, rd, rs1, rs2)
   //m4_asm(AND, rd, rs1, rs2)
   //m4_asm(SLL, rd, rs1, rs2)
   //m4_asm(SRL, rd, rs1, rs2)
   //m4_asm(SRA, rd, rs1, rs2)
   //m4_asm(SLT, rd, rs1, rs2)
   //m4_asm(SLTU, rd, rs1, rs2)

   //m4_asm(ADDI, rd, rs1, imm)
   //m4_asm(XORI, rd, rs1, imm)
   //m4_asm(ORI, rd, rs1, imm)
   //m4_asm(ANDI, rd, rs1, imm)
   //m4_asm(SLLI, rd, rs1, imm)
   //m4_asm(SRLI, rd, rs1, imm)
   //m4_asm(SRAI, rd, rs1, imm)
   //m4_asm(SLTI, rd, rs1, imm)
   //m4_asm(SLTIU, rd, rs1, imm)

   //m4_asm(LB, rd, rs1, imm)
   //m4_asm(LH, rd, rs1, imm)
   //m4_asm(LW, rd, rs1, imm)
   //m4_asm(LBU, rd, rs1, imm)
   //m4_asm(LHU, rd, rs1, imm)

   //m4_asm(SB, rs1, rs2, imm)
   //m4_asm(SH, rs1, rs2, imm)
   //m4_asm(SW, rs1, rs2, imm)

   //m4_asm(BEQ, rs1, rs2, imm)
   //m4_asm(BNE, rs1, rs2, imm)
   //m4_asm(BLT, rs1, rs2, imm)
   //m4_asm(BGE, rs1, rs2, imm)
   //m4_asm(BLTU, rs1, rs2, imm)
   //m4_asm(BGEU, rs1, rs2, imm)

   //m4_asm(JAL, rd, imm)
   //m4_asm(JALR, rd, rs1, imm)

   //m4_asm(LUI, rd, imm)
   //m4_asm(AUIPC, rd, imm)

\SV
   m5_makerchip_module

\TLV REG_BANK()
   
   |cpu
      @1
         /register_bank
            // 1. Definição do registrador de escrita
            $write_register[4:0] = |cpu>>3$rd[4:0];
            
            // 2. Lógica de controle de escrita
            $res_write_en  = ($write_register != 5'd0) && (|cpu>>3$jal_taken || |cpu>>3$jalr_taken);
            $exec_write_en = ($write_register != 5'd0) && |cpu>>3$exec_reg_write;
            
            $wen         = $res_write_en || $exec_write_en;
            $wdata[31:0] = $res_write_en ? |cpu$jal_jalr_wb_data[31:0] : |cpu>>3$write_data[31:0];

            // 3. Banco de Registradores usando escopos
            /regs[31:0]
               $w_en = |cpu/register_bank$wen && (|cpu/register_bank$write_register == #regs);
               
               $val[31:0] = |cpu$reset ? 32'd0 :
                            $w_en      ? |cpu/register_bank$wdata :
                                         >>1$val;
            
            $rs1_idx[4:0] = |cpu$rs1[4:0];
            $rs2_idx[4:0] = |cpu$rs2[4:0];
            
            // 4. Leitura dos Registradores 
            $rdata1[31:0] = ($rs1_idx == 5'd0) ? 32'd0 : /regs[$rs1_idx]$val;
            $rdata2[31:0] = ($rs2_idx == 5'd0) ? 32'd0 : /regs[$rs2_idx]$val;
\TLV FORW_UNIT()
   |cpu
      @1
         /forw_unit
            $id_op1[31:0] =
               (|cpu$rs1[4:0] == |cpu>>1$rd[4:0]) && (|cpu>>1$rd[4:0] != 0 ) && (|cpu>>1$exec_reg_write) && (!|cpu>>1$is_load) ? |cpu>>1$alu_result[31:0] :
               (|cpu$rs1[4:0] == |cpu>>2$rd[4:0]) && (|cpu>>2$rd[4:0] != 0 ) && (|cpu>>2$exec_reg_write) && (!|cpu>>2$is_load) ? |cpu>>2$returning_data[31:0] :
               |cpu$rs1_data[31:0];

            $id_op2[31:0] =
               (|cpu$rs2[4:0] == |cpu>>1$rd[4:0]) && (|cpu>>1$rd[4:0] != 0 ) && (|cpu>>1$exec_reg_write) && (!|cpu>>1$is_load) ? |cpu>>1$alu_result[31:0] :
               (|cpu$rs2[4:0] == |cpu>>2$rd[4:0]) && (|cpu>>2$rd[4:0] != 0 ) && (|cpu>>2$exec_reg_write) && (!|cpu>>2$is_load) ? |cpu>>2$returning_data[31:0] :
               |cpu$rs2_data[31:0];
            
            $forwarding_hit = $id_op1[31:0] ? 1 : 0;
            
\TLV BRANCH_UNIT()
   |cpu
      @1
         /branch_unit
            $br_type[2:0] = |cpu$funct3[2:0];
            $id_op1[31:0] = |cpu/forw_unit$id_op1[31:0];
            $id_op2[31:0] = |cpu/forw_unit$id_op2[31:0];
            
            $br_verif =
                  // BEQ / BNE
                  $br_type[2:0] == 3'b000 ? ($id_op1[31:0] == $id_op2[31:0]) :
                  $br_type[2:0] == 3'b001 ? ($id_op1[31:0] != $id_op2[31:0]) :
            
                  // BLT signed
                  $br_type[2:0] == 3'b100 ? (
                     ($id_op1[31] != $id_op2[31])
                        ? $id_op1[31]       // se sinais diferentes, op1<op2 se op1 for negativo
                        : $id_op1[31:0] < $id_op2[31:0] // se sinais iguais, compara normal
                  ) :
            
                  // BGE signed
                  $br_type[2:0] == 3'b101 ? (
                     ($id_op1[31] != $id_op2[31])
                        ? ~($id_op1[31])    // se sinais diferentes, op1>=op2 se op1 for positivo
                        : $id_op1[31:0] >= $id_op2[31:0]
                  ) :
            
                  // BLTU unsigned
                  $br_type[2:0] == 3'b110 ? ($id_op1[31:0] < $id_op2[31:0]) :
            
                  // BGEU unsigned
                  $br_type[2:0] == 3'b111 ? ($id_op1[31:0] >= $id_op2[31:0]) :
            
                  1'b0;
            $br_tk = $br_verif && |cpu$is_branch;
            
\TLV HAZARD_DETEC()
   |cpu
      /hazard_detec
         @2
            $is_hazard = (|cpu$is_load && (|cpu$rd[4:0] != 0)
               && (|cpu$rd[4:0] == |cpu<<1$rs1[4:0]
               ||  |cpu$rd[4:0] == |cpu<<1$rs2[4:0]))
            
               || (|cpu>>1$is_load && (|cpu>>1$rd[4:0] != 0)
               && (|cpu<<1$is_branch || |cpu<<1$jal_taken || |cpu<<1$jalr_taken)
               && (|cpu>>1$rd[4:0] == |cpu<<1$rs1[4:0]
               ||  |cpu>>1$rd[4:0] == |cpu<<1$rs2[4:0]));
            
            
\TLV
   //definindo memória de instrução
   // /====================\
   // | Sum 1 to 4 Program |
   // \====================/
   //
   // Program for MYTH Workshop to test RV32I
   // Add 1,2,3,4(in that order).
   //
   // Regs:
   //  r10 (a0): In: 0, Out: final sum
   //  r12 (a2): 10
   //  r13 (a3): 1..10
   //  r14 (a4): Sum
   // 
   // External to function:
   m4_asm(ADDI, r1, r0, 1100)
   m4_asm(SUB, r2, r0, r1)
   m4_asm(ADDI, r1, r0, 1100)
   m4_asm(SUB, r2, r0, r1)



   // Optional:
   m4_define_hier(['M4_IMEM'], M4_NUM_INSTRS)
   
   //definindo estágios do pipeline
   m4_define(FETCH, 0)
   m4_define(DECODE, 1)
   m4_define(EXEC, 2)
   m4_define(MEM, 3)
   m4_define(WB, 4)
   
   //definindo estâncias dos componentes
   m5+REG_BANK()
   m5+FORW_UNIT()
   m5+BRANCH_UNIT()
   m5+HAZARD_DETEC()
   
   |cpu
      m4+imem(@FETCH)
      m4+dmem(@MEM)
      @FETCH
         
         $reset = *reset;
         $imem_rd_en = !$reset && (/hazard_detec>>2$is_hazard);//if_id_write n existe
         $pc_write = /hazard_detec>>2$is_hazard? 0 : 1;
         $if_write = /hazard_detec>>2$is_hazard? 0 : 1;
         
         $pc[31:0] =
            >>1$reset        ? 32'b0 : //se primeira instrução
            !$pc_write       ? $RETAIN : //se trava o fluxo
            >>2$branch_taken ? >>2$br_tgt_pc[31:0] : //se branch
            >>2$jal_taken    ? >>2$jal_target[31:0] : // se jal
            >>2$jalr_taken   ? >>2$jalr_target[31:0] : // se jalr
                               >>1$pc_inc[31:0]; //se incrementa normalmente
         
         $pc_inc[31:0] = $pc[31:0] + 32'd4;
         
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
         $instr[31:0] = $imem_rd_data;
         
         $if_id_pc[31:0] = //pc do registrador if_id não sofre nop
            $if_write ? $pc[31:0] :
                        $RETAIN;
         
         $if_id_instr[31:0] =
            !$if_write    ? $RETAIN :
                            $instr[31:0];
         $if_id_reg[63:0] = {$if_id_pc[31:0], $if_id_instr[31:0]};
         
      @DECODE
         // ======================================================
         // REGISTRADOR ID E EXTRAÇÃO DOS CAMPOS
         // ======================================================
         $id_reg[63:0] =
            ($reset || >>1$if_id_is_nop) ? 63'b0 :
            $if_id_is_stall              ? $RETAIN :
                                           |cpu$if_id_reg[63:0];
         $id_pc[31:0] = $id_reg[63:32];
         $id_instr[31:0] = $id_reg[31:0];
         
         $opcode[6:0] = $id_instr[6:0];
         $rd[4:0]     = $id_instr[11:7];
         $funct3[2:0] = $id_instr[14:12];
         $rs1[4:0]    = $id_instr[19:15];
         $rs2[4:0]    = $id_instr[24:20];
         $funct7[6:0] = $id_instr[31:25];
         
         // ======================================================
         // DEFININDO PRINCIPAIS SINAIS
         // ======================================================
         $is_load     = ($opcode == 7'b0000011);
         $is_store    = ($opcode == 7'b0100011);
         $is_alu_imm  = ($opcode == 7'b0010011);
         $is_alu_reg  = ($opcode == 7'b0110011);
         $is_branch   = ($opcode == 7'b1100011);
         $jal_taken   = ($opcode == 7'b1101111);
         $jalr_taken  = ($opcode == 7'b1100111);
         $is_lui      = ($opcode == 7'b0110111);
         $is_auipc    = ($opcode == 7'b0010111);
         *failed      = ($opcode == 7'b1110011);
         
         // ======================================================
         // DEFININDO IMEDIATOS
         // ======================================================
         $imm_s[31:0] = {{20{$id_instr[31]}}, $id_instr[31:25],$id_instr[11:7]};
         $imm_i[31:0] = {{20{$id_instr[31]}}, $id_instr[31:20]};
         $imm_b_raw[11:0] = { $id_instr[31], $id_instr[7], $id_instr[30:25], $id_instr[11:8] };
         $imm_b[31:0] = {{19{$imm_b_raw[11]}}, $imm_b_raw[11:0], 1'b0};
         $imm_u[31:0] = { $id_instr[31:12], 12'b0 };
         $imm_j_raw[19:0] = { $id_instr[31], $id_instr[19:12], $id_instr[20], $id_instr[30:21] };
         $imm_j[31:0] = {{12{$imm_j_raw[19]}}, $imm_j_raw[19:0]};
         
         // ======================================================
         // PASSANDO PARÂMETROS E RECEBENDO RETORNO DO REG_BANK
         // ======================================================
         $rs1_data[31:0] = /register_bank$rdata1[31:0];
         $rs2_data[31:0] = /register_bank$rdata2[31:0];
         
         $data_a[31:0] =
            $is_lui   ? 32'b0 :
            $is_auipc ? $id_pc[31:0] :
                        $rs1_data[31:0];
         $data_b[31:0] = $is_lui || $is_auipc ? $imm[31:0] : $rs2_data[31:0];
         
         // ====================================================================
         // DEFININDO SINAIS ID_EX PROS PRÓXIMOS ESTADOS E SE LIMPA CONFORME NOP
         // ====================================================================
         $alu_op[1:0] = $is_lui || $is_auipc ? 4'd1 :(($is_alu_imm || $is_alu_reg) ? 4'd2 : 4'd0);
         $alu_src = ($is_alu_imm || $is_load || $is_store || $is_lui || $is_auipc);
         //$mem_read = $is_load;
         //$mem_write = $is_store;
         $reg_write = $is_load || $is_alu_imm || $is_alu_reg || $jal_taken || $jalr_taken || $is_lui || $is_auipc;
         $mem_to_reg = $is_load;
         
         // ====================================================================
         // DEFININDO SE HÁ BOLHA E NOP CONFORME HAZARD
         // ====================================================================
         $if_id_is_stall = /hazard_detec>>2$is_hazard? 1 : 0;
         
         $if_id_is_nop = $branch_taken || $jal_taken || $jalr_taken;
         
         // ====================================================================
         // DEFININDO SALTOS E SEUS ALVOS 
         // ====================================================================
         $branch_taken = /branch_unit$br_tk;
         $br_tgt_pc[31:0] = $id_pc[31:0] + $imm_b[31:0];
         
         $jal_target[31:0] = $id_pc[31:0] + $imm_j[31:0];
         $jalr_data[31:0] = /forw_unit$forwarding_hit ? /forw_unit$id_op1[31:0] : /register_bank$rdata1[31:0];
         $jalr_target[31:0] = $jalr_data[31:0] + $imm_i[31:0];
         $jal_jalr_wb_data[31:0] = $id_pc[31:0] + 32'd4;
         
         // ====================================================================
         // DEFININDO IMEDIATO E REGISTRADOR ID_EX
         // ====================================================================
         $imm[31:0] =
            $is_store               ? $imm_s[31:0] :
            $is_alu_imm || $is_load ? $imm_i[31:0] :
            $is_lui || $is_auipc    ? $imm_u[31:0] :
                                      32'b0;
         
      @EXEC
         $id_ex_is_nop = /hazard_detec>>1$is_hazard? 1 : 0;
         
         $exec_alu_src = $id_ex_is_nop? 1'b0 : $alu_src;
         $exec_is_load = $id_ex_is_nop? 1'b0 : $is_load;
         $exec_is_store = $id_ex_is_nop? 1'b0 : $is_store;
         $exec_reg_write = $id_ex_is_nop? 1'b0 : $reg_write;
         $exec_mem_to_reg = $id_ex_is_nop? 1'b0 : $mem_to_reg;
         
         // ======================================================
         // UNIDADE DE FORWARDING (EX -> MEM)
         // ======================================================
         $forwarda_exmem = (>>1$exec_reg_write && (>>1$rd[4:0] != 5'b0) && (>>1$rd[4:0] == $rs1));
         $forwardb_exmem = (>>1$exec_reg_write && (>>1$rd[4:0] != 5'b0) && (>>1$rd[4:0] == $rs2));
         
         $forwarda_memwb = (>>2$reg_write && (>>2$rd[4:0] != 5'b0) && (>>2$rd[4:0] == $rs1));
         $forwardb_memwb = (>>2$reg_write && (>>2$rd[4:0] != 5'b0) && (>>2$rd[4:0] == $rs2));
         
         // ======================================================
         // SELEÇÃO DOS OPERANDOS COM FORWARDING
         // ======================================================
         $srca[31:0] =
          $forwarda_exmem ? >>1$alu_result[31:0] :
          $forwarda_memwb ? >>2$write_data[31:0] :
          $data_a[31:0];
         $srcb_temp[31:0] =
          $forwardb_exmem ? >>1$alu_result[31:0] :
          $forwardb_memwb ? >>2$write_data[31:0] :
          $data_b[31:0];
         $srcb[31:0] = $exec_alu_src ? $imm[31:0] : $srcb_temp[31:0];
         
         $alu_control[3:0] =
            ($alu_op == 2'b10) ? (
            ($funct3 == 3'b000 && $funct7 == 7'b0000000 || $is_alu_imm) ? 4'b0000 : // ADD
            ($funct3 == 3'b000 && $funct7 == 7'b0100000 || $is_alu_imm) ? 4'b0001 : // SUB
            ($funct3 == 3'b111) ? 4'b0010 : // AND
            ($funct3 == 3'b110) ? 4'b0011 : // OR
            ($funct3 == 3'b100) ? 4'b0100 : // XOR
            ($funct3 == 3'b001) ? 4'b0101 : // SLL
            ($funct3 == 3'b101 && $funct7 == 7'b0000000) ? 4'b0110 : // SRL
            ($funct3 == 3'b101 && $funct7 == 7'b0100000) ? 4'b0111 : // SRA
            ($funct3 == 3'b010) ? 4'b1000 : // SLT
            ($funct3 == 3'b011) ? 4'b1001 : // SLTU
            4'b1111): // NOP/Desconhecido
            ($alu_op == 2'b00) ? 4'b0000 : // ADD (endereçamento)
            ($alu_op == 2'b01) ? 4'b0000 : // ADD (tipo u)
            4'b1111;
         
         // ======================================================
         // ULA
         // ======================================================
         $alu_result[31:0] =
           ($alu_control == 4'b0000) ? ($srca + $srcb) :
           ($alu_control == 4'b0001) ? ($srca - $srcb) :
           ($alu_control == 4'b0010) ? ($srca & $srcb) :
           ($alu_control == 4'b0011) ? ($srca | $srcb)  :
           ($alu_control == 4'b0100) ? ($srca ^ $srcb) :
           ($alu_control == 4'b0101) ? ($srca << $srcb[4:0]) :
           ($alu_control == 4'b0110) ? ($srca >> $srcb[4:0]) :
         
           ($alu_control == 4'b0111) ?
           (
           ($srca[31] == 1'b1) ?
           // A negativo → preencher com 1s à esquerda
           ( ($srca >> $srcb[4:0]) |
           (32'hFFFF_FFFF << (32 - $srcb[4:0])) ) :
           // A positivo → shift lógico comum
           ($srca >> $srcb[4:0])
           ) :
         
           ($alu_control == 4'b1000) ?
           (
           // Se A negativo e B positivo → SLT = 1
           (!$srca[31] && $srcb[31]) ? 32'd1 :
         
           // Se A positivo e B negativo → SLT = 0
           ($srca[31] && !$srcb[31]) ? 32'd0 :
         
           // Sinais iguais → compara sem sinal
           ( ($srca < $srcb) ? 32'd1 : 32'd0 )
           ) :
         
           ($alu_control == 4'b1001) ? {31'b0, ($srca < $srcb)} :
           32'b0;
         
      @MEM
         // ======================================================
         // ALIMENTANDO E RECEBENDO RESPOSTA DA MEMÓRIA DE DADOS
         // ======================================================
         
         $store_data[31:0] =
            ($funct3 == 3'b000) ? {{24{$srcb_temp[7]}}, $srcb_temp[7:0]} :   // SB
            ($funct3 == 3'b001) ? {{16{$srcb_temp[15]}}, $srcb_temp[15:0]} : // SH
                                        $srcb_temp[31:0];                     // SW
         
         $load_data[31:0] =
            ($funct3 == 3'b000) ? {{24{$dmem_rd_data[7]}},  $dmem_rd_data[7:0]}  : // LB
            ($funct3 == 3'b001) ? {{16{$dmem_rd_data[15]}}, $dmem_rd_data[15:0]} : // LH
            ($funct3 == 3'b010) ? $dmem_rd_data[31:0] : // LW
            ($funct3 == 3'b100) ? {24'b0,                  $dmem_rd_data[7:0]}  : // LBU
            ($funct3 == 3'b101) ? {16'b0,                  $dmem_rd_data[15:0]} : // LHU
                                         $dmem_rd_data;
         
         $dmem_wr_en = $exec_is_store;
         $dmem_rd_en = $exec_is_load;
         $dmem_addr[31:0]  = $alu_result[31:0];
         $dmem_wr_data[31:0] = $store_data[31:0];
         $returning_data[31:0] = $jal_taken || $jalr_taken ? $jal_jalr_wb_data[31:0] : $alu_result[31:0];
         
      @WB
         // ======================================================
         // DECIDINDO DADO A SER ENVIADO PARA REG_BANK
         // ======================================================
         $write_data[31:0] = $exec_mem_to_reg ? $load_data[31:0] : $alu_result[31:0];
   *passed = *cyc_cnt > 40;
\SV
   endmodule