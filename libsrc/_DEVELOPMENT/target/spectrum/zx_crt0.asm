
; zx spectrum crt0 for testing purposes

org 32768

XLIB start
XDEF _Exit

LIB _ff_ao_SoixanteQuatre, asm_memset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INCLUDE "../crt_defs.inc"      ; crt defines
INCLUDE "crt_zx_defs.inc"      ; crt defines varying by target

defc __heap_sz = 2048          ; malloc's heap, eliminate if not required
defc __qtbl_sz = 6             ; balloc's qtable, eliminate if not required

defc __exit_stack_sz      = 6  ; set to 0 if not required, default is 32
defc __quickexit_stack_sz = 6  ; set to 0 if not required, default is 32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:

   ld (__sp),sp

   IF STACKPTR                 ; pragma to locate stack
   
      ld sp,STACKPTR
   
   ENDIF

   INCLUDE "../crt_init.asm"   ; intialize crt state

   ; clear screen 

   call cls                    ; clear screen, reset fzx state
      
   ; initialize fzx state
   
   ld hl,_ff_ao_SoixanteQuatre
   ld (_fzx),hl                ; initial font
   
   ; call user program

   call _main                  ; hl holds return status

   INCLUDE "../crt_exit.asm"   ; run exit stack
   
_Exit:

   INCLUDE "../crt_cleanup.asm"  ; close files 

   ld c,l
   ld b,h                      ; return status to basic

   ld sp,(__sp)
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__FILE_STDIN:
   
   defb 195                    ; jp driver
   defw __kbd_driver
   defb $80                    ; open for reading
   defb $02                    ; last op was read, to skip auto-flush
   defb 0
   defb 0
   defs 6                      ; mutex

__FILE_STDOUT:

   defb 195                    ; jp driver
   defw __fzx_driver
   defb $40                    ; open for writing
   defb 0
   defb 0
   defb 0
   defs 6                      ; mutex

__FILE_STDERR:

   ; separate from stdout allows output
   ; even when stdout is in an error state

   defb 195                    ; jp driver
   defw __fzx_driver
   defb $40                    ; open for writing
   defb 0
   defb 0
   defb 0
   defs 6                      ; mutex

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INCLUDE "../crt_vars.asm"      ; crt variable declarations
INCLUDE "../crt_stubs.asm"     ; crt stubs for unimplemented lib functions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; fzx state

XDEF _fzx

_fzx:   defs 6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cls:

   ; reset fzx
   
   ld hl,0
   ld (_fzx + 2),hl
   ld (_fzx + 4),hl

   ; attributes
   
   ld e,0
   ld hl,$5800
   ld bc,768
   
   call asm_memset

   ; pixels
   
   ld e,0
   ld hl,$4000
   ld bc,6144
   
   jp asm_memset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INCLUDE "__fzx_driver.asm"     ; output driver
INCLUDE "__kbd_driver.asm"     ; input driver
