      ; command line parsing for esxdos dot commands

      ; hl = pointer to args or 0 if no args

      ld a,h
      or l
      jr nz, cmdline_present

   cmdline_missing:

      include "../crt_cmdline_empty.inc"
      jr cmdline_end

   cmdline_present:

      include "crt_cmdline_esxdos_len.inc"
      
      ; copy command line words from basic program to stack

      EXTERN l_command_line_parse
      call   l_command_line_parse
      
      ; esxdos does not supply program name in command line
      ; so place empty string in argv[0] instead
      
      ; bc = int argc
      ; hl = char *argv[]
      ; de = & empty string
      ; bc'= num chars in redirector
      ; hl'= char *redirector
      
      push de                  ; empty string added to front of argv[]
      
      dec hl
      dec hl                   ; char *argv[] adjusted to include empty string at index 0
      
      inc c                    ; argc++

   cmdline_end:

      ; hl = char **argv
      ; bc = int    argc
