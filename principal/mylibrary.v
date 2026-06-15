\m4_TLV_version 1d: tl-x.org
\SV

m4+definitions(['
   // Seus macros M4 aqui
   m4_define(['m4_meu_macro'], ['/* conteúdo */'])
'])

// Seus blocos \TLV aqui
\TLV meu_componente(@_stage)
   @_stage
      $meu_sinal[31:0] = 32'b0;