
include ../../Make.config

TARGET ?= test

NEWLIBGLOBS := "$(NEWLIB_DIRECTORY)/font/fzx/c/sccz80/*.asm" "$(NEWLIB_DIRECTORY)/font/fzx/z80/*.asm" "$(NEWLIB_DIRECTORY)/font/fzx/fonts/**/*.asm" "$(NEWLIB_DIRECTORY)/font/fzx/fonts/**/*.asm" "$(NEWLIB_DIRECTORY)/font/fzx/zx/z80/*.asm" 
NEWLIB_TARGETS := obj/newlib-z80 

space :=
space +=

OBJECTS = $(CLASSIC_OBJECTS) 

.PHONY: dirs  $(NEWLIB_TARGETS)

all: dirs $(OBJECTS) $(NEWLIB_TARGETS)

obj/newlib-z80:  
	@$(ASSEMBLER) -d -O=obj/z80/x -I$(NEWLIB_DIRECTORY) -I../.. --cpu=z80 -D__CLASSIC $(NEWLIBGLOBS)

dirs:
	@mkdir -p obj/z80 obj/z80-zxn obj/ixiy obj/r2k


clean:
	$(RM) -fr obj 
