; void *esx_disk_stream_bytes(void *dst,uint16_t len)

SECTION code_esxdos

PUBLIC esx_disk_stream_bytes_callee

EXTERN asm_esx_disk_stream_bytes

esx_disk_stream_bytes_callee:

   pop hl
   pop de
   ex (sp),hl
   
   jp asm_esx_disk_stream_bytes
