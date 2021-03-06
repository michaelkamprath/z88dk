;
;   Define constants for VDP in different platforms of the SEGA/MSX generation
;
;	$Id: vdp.inc,v 1.4 2010-09-15 09:00:39 stefano Exp $
;

IF FORsms
	defc VDP_DATA    = $be
	defc VDP_DATAIN  = $be ; ?
	defc VDP_CMD     = $bf
	defc VDP_STATUS  = $bf ; ?
	defc VRAM_SIZE   = 16
ENDIF
	
IF FORsc3000
	defc VDP_DATA    = $be
	defc VDP_DATAIN  = $be ; ?
	defc VDP_CMD     = $bf
	defc VDP_STATUS  = $bf ; ?
	defc VRAM_SIZE   = 16
ENDIF
	
IF FORmsx
	defc VDP_DATA    = $98
	defc VDP_DATAIN  = $98
	defc VDP_CMD     = $99
	defc VDP_STATUS  = $99
	defc VRAM_SIZE   = 16		; extended are able to get the right size
ENDIF

IF FORsvi
	defc VDP_DATA    = $80
	defc VDP_DATAIN  = $84
	defc VDP_CMD     = $81
	defc VDP_STATUS  = $85
	defc VRAM_SIZE   = 16
ENDIF

IF FORm5
	defc VDP_DATA    = $10
	defc VDP_DATAIN  = $10
	defc VDP_CMD     = $11
	defc VDP_STATUS  = $11
	defc VRAM_SIZE   = 16
ENDIF

IF FORmtx
	defc VDP_DATA    = 1
	defc VDP_DATAIN  = 1
	defc VDP_CMD     = 2
	defc VDP_STATUS  = 2
	defc VRAM_SIZE   = 16		; extended are able to get the right size
ENDIF

IF FOReinstein
	defc VDP_DATA    = 8
	defc VDP_DATAIN  = 8
	defc VDP_CMD     = 9
	defc VDP_STATUS  = 9
	defc VRAM_SIZE   = 16
ENDIF

IF FORpv2000
	defc VDP_DATA    = -0x4000
	defc VDP_DATAIN  = -0x4000
	defc VDP_CMD     = -0x4001
	defc VDP_STATUS  = -0x4001
	defc VRAM_SIZE   = 16
ENDIF

IF FORsg1000
	defc VDP_DATA    = 0xbe
	defc VDP_DATAIN  = 0xbe
	defc VDP_CMD     = 0xbf
	defc VDP_STATUS  = 0xbf
	defc VRAM_SIZE   = 16
ENDIF

IF FORcoleco
	defc VDP_DATA    = 0xbe
	defc VDP_DATAIN  = 0xbe
	defc VDP_CMD     = 0xbf
	defc VDP_STATUS  = 0xbf
	defc VRAM_SIZE   = 16
ENDIF

IF FORspc1000
	defc VDP_DATA    = 0xc800
	defc VDP_DATAIN  = 0xc800
	defc VDP_CMD     = 0xc801
	defc VDP_STATUS  = 0xc801
	defc VRAM_SIZE   = 16

ENDIF
