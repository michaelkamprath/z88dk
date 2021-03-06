divert(-1)

###############################################################
# ZX NEXT ROM ENTRY POINTS
# rebuild the library if changes are made
#

# ROM3 (48k Spectrum)

define(`__ROM3_MAKE_ROOM', 0x1655)
define(`__ROM3_RECLAIM_2', 0x19e8)

#
# END OF USER CONFIGURATION
###############################################################

divert(0)

dnl#
dnl# COMPILE TIME CONFIG EXPORT FOR ASSEMBLY LANGUAGE
dnl#

ifdef(`CFG_ASM_PUB',
`
PUBLIC `__ROM3_MAKE_ROOM'
PUBLIC `__ROM3_RECLAIM_2'
')

dnl#
dnl# LIBRARY BUILD TIME CONFIG FOR ASSEMBLY LANGUAGE
dnl#

ifdef(`CFG_ASM_DEF',
`
defc `__ROM3_MAKE_ROOM' = __ROM3_MAKE_ROOM
defc `__ROM3_RECLAIM_2' = __ROM3_RECLAIM_2
')

dnl#
dnl# COMPILE TIME CONFIG EXPORT FOR C
dnl#

ifdef(`CFG_C_DEF',
`
`#define' `__ROM3_MAKE_ROOM'  __ROM3_MAKE_ROOM
`#define' `__ROM3_RECLAIM_2'  __ROM3_RECLAIM_2
')
