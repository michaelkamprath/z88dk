; int esxdos_f_fstat(uchar handle, void *buf)

SECTION code_clib
SECTION code_esxdos

PUBLIC esxdos_f_fstat_callee

EXTERN asm_esxdos_f_fstat

esxdos_f_fstat_callee:

   pop af
   pop hl
   pop bc
   push af

   ld a,c
   jp asm_esxdos_f_fstat
