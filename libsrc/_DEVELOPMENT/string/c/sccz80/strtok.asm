
; char *strtok(char * restrict s1, const char * restrict s2)

SECTION code_clib
SECTION code_string

PUBLIC strtok

EXTERN asm_strtok

strtok:

   pop af
   pop de
   pop hl
   
   push hl
   push de
   push af
   
   jp asm_strtok

; SDCC bridge for Classic
IF __CLASSIC
PUBLIC _strtok
defc _strtok = strtok
ENDIF

