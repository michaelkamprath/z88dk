
// automatically generated by m4 from headers in proto subdir


#ifndef __NEXTOS_ESXDOS_H__
#define __NEXTOS_ESXDOS_H__

#include <arch.h>
#include <stdint.h>
#include <stddef.h>
#include <time.h>

// extended sna load
// call first thing after sna loads, org >= 24576

extern unsigned char extended_sna_load(unsigned char handle);



/*
   NextOS ESX API

   The interface to NextOS's implementation of the esxdos api
   is kept separate from esxdos.h even though many functions
   are aliases of each other.

   This is because the NextOS api adds several functions to the
   original esxdos api and some functions in the esxdos api are
   not documented so NextOS's implementation may not be the same.

   If you're using a NextOS machine, use these functions for the
   esxdos api.  If you want to ensure things run on esxdos, use
   the esxdos api version in esxdos.h.
   
   NOTE:  To use the esxdos api, ROM3 must be present in the bottom
   16k and layer 2 write-only mode in the bottom 16k must be disabled.
*/

// FAST STREAMING DISK IO

// 1. esx_disk_filemap        : find out how the file is distributed on disk
// 2. esx_stream_start        : prepare to load from one span on disk
// 3. esx_disk_stream_sectors : load whole sectors from the span
// 4. esx_disk_stream_bytes   : load bytes from the span (only use for last access to span)
// 5. esx_disk_stream_end     : terminate streaming from span
//
// No other esxdos calls allowed between steps 2-5

struct esx_filemap_entry
{
   // describes one span on disk

   uint32_t address;
   uint16_t sectors;
};

struct esx_filemap
{
   uint8_t mapsz;
   struct esx_filemap_entry *map;
};

// the following four variables are filled in after a call to esx_disk_stream_start()

extern unsigned char esx_stream_io_port;       // 1
extern unsigned char esx_stream_protocol;      // 2

// the following two variables are updated by esx_disk_stream_sectors()
// and esx_disk_stream_bytes() but only for whole numbers of sectors read

extern uint32_t esx_stream_card_address;       // 3
extern uint16_t esx_stream_sectors_remaining;  // 4

extern unsigned char esx_disk_filemap(uint8_t handle,struct esx_filemap *fmap);


extern unsigned char esx_disk_stream_start(const struct esx_filemap_entry *entry);


extern void *esx_disk_stream_sectors(void *dst,uint8_t sectors);


extern void *esx_disk_stream_bytes(void *dst,uint16_t len);


extern unsigned char esx_disk_stream_end(void);



// TAP FILE EMULATION

extern unsigned char esx_m_tapein_open(const char *filename);


extern unsigned char esx_m_tapein_close(void);


extern unsigned char esx_m_tapein_info(uint8_t *drive,const char *filename);


extern unsigned char esx_m_tapein_setpos(uint16_t block);


extern uint16_t esx_m_tapein_getpos(void);


extern unsigned char esx_m_tapein_toggle_pause(void);



#define ESX_TAPEIN_FLAGS_PAUSE  1   // pause after loading blocks of size 6912 bytes (eg screen$)
#define ESX_TAPEIN_FLAGS_RETRO  2   // tape loading simulated as if from tape recorder

extern unsigned char esx_m_tapein_flags(uint8_t flags);



// open appends to file, trunc replaces or creates

extern unsigned char esx_m_tapeout_open(const char *appendname);


extern unsigned char esx_m_tapeout_trunc(const char *filename);


extern unsigned char esx_m_tapeout_info(uint8_t *drive,const char *filename);


extern unsigned char esx_m_tapeout_close(void);



// DOT COMMANDS

// must call from within a dot command

typedef void (*esx_handler_t)(uint8_t error);

// currently registered error handler (0 = none)

extern esx_handler_t esx_errh;

extern unsigned char esx_m_gethandle(void);


extern esx_handler_t esx_m_errh(esx_handler_t error);



// must not call from within a dot command

// execute dot command, return value is error if not zero
// geterr with non-zero error code, write as zero-terminated string in 33-byte buffer msg

extern uint16_t esx_m_execcmd(char *cmdline);


extern void esx_m_geterr(uint16_t error,char *msg);



// DRIVER API

struct esx_drvapi
{
   union
   {
      uint16_t bc;
      struct
      {
         uint8_t driver;
         uint8_t function;
      }
      call;
   };
   
   uint16_t de;
   uint16_t hl;
};

extern unsigned char esx_m_drvapi(struct esx_drvapi *);



// MISCELLANEOUS

#define ESX_DOSVERSION_ESXDOS     -1
#define ESX_DOSVERSION_NEXTOS_48K  0

#define ESX_DOSVERSION_NEXTOS_MAJOR(v)  (((v)&0xff00)>>8)
#define ESX_DOSVERSION_NEXTOS_MINOR(v)  ((v)&0xff)

extern uint16_t esx_m_dosversion(void);



extern unsigned char esx_m_getdrv(void);


extern unsigned char esx_m_setdrv(unsigned char drive);



#define ESX_CAPS_FAST_TRUNC  __esx_caps_fast_trunc

extern unsigned char esx_m_setcaps(unsigned char caps);



// time.h contains functions dealing with dos time

extern unsigned char esx_m_getdate(struct dos_tm *);



extern uint32_t esx_f_getfree(void);



// OPERATIONS ON DIRECTORIES

#define ESX_PATHNAME_MAX __ESX_PATHNAME_MAX     // max pathname length in bytes including terminating 0, ~256 bytes
#define ESX_FILENAME_MAX __ESX_FILENAME_MAX     // max filename length in bytes not including terminating 0, ~12 bytes
#define ESX_FILENAME_LFN_MAX __ESX_FILENAME_LFN_MAX   // max lfn filename length in bytes not including terminating 0, ~260 bytes

struct esx_p3_hdr
{
   uint8_t  type;    // 0 = program, 1 = numeric array, 2 = char array, 3 = code
   uint16_t length;
   uint8_t  data[4];
   uint8_t  unused;
};

struct esx_dirent
{                                           // <byte>   attributes
   uint8_t attr;                            // <asciiz> name
   uint8_t name[ESX_FILENAME_MAX+1+8];      // <dword>  date-time
};                                          // <dword>  size

struct esx_dirent_p3
{
   uint8_t attr;
   uint8_t name[ESX_FILENAME_MAX+1+8];
   struct  esx_p3_hdr p3;
};

struct esx_dirent_lfn
{                                           // <byte>   attributes
   uint8_t attr;                            // <asciiz> name
   uint8_t name[ESX_FILENAME_LFN_MAX+1+8];  // <dword>  date-time
};                                          // <dword>  size

struct esx_dirent_lfn_p3
{
   uint8_t attr;
   uint8_t name[ESX_FILENAME_LFN_MAX+1+8];
   struct  esx_p3_hdr p3;
};

// slice dirent to access members following filename

struct esx_dirent_slice
{
   struct dos_tm time;   // time.h contains functions dealing with dos time
   uint32_t      size;
};

struct esx_dirent_slice_p3
{
   struct dos_tm time;
   uint32_t      size;
   struct esx_p3_hdr p3;
};

// opendir_ex modes

#define ESX_DIR_USE_LFN     __esx_dir_use_lfn
#define ESX_DIR_USE_HEADER  __esx_dir_use_header

extern unsigned char esx_f_opendir(const char *dirname);


extern unsigned char esx_f_opendir_ex(const char *dirname,uint8_t diruse);


extern unsigned char esx_f_closedir(unsigned char handle);



// file attributes

#define ESX_DIR_A_RDO   __esx_dir_a_rdo     // read only
#define ESX_DIR_A_HID   __esx_dir_a_hid     // hide in normal dir listings
#define ESX_DIR_A_SYS   __esx_dir_a_sys     // system file (must not be physically moved)
#define ESX_DIR_A_VOL   __esx_dir_a_vol     // filename is a volume label
#define ESX_DIR_A_DIR   __esx_dir_a_dir     // directory
#define ESX_DIR_A_ARCH  __esx_dir_a_arch    // file has been modified since last backup
#define ESX_DIR_A_DEV   __esx_dir_a_dev     // device
#define ESX_DIR_A_RES   __esx_dir_a_res     // reserved

extern unsigned char esx_f_readdir(unsigned char handle,void *esx_dirent);


extern void *esx_slice_dirent(void *esx_dirent);



extern uint32_t esx_f_telldir(unsigned char handle);


extern unsigned char esx_f_seekdir(unsigned char handle,uint32_t pos);


extern unsigned char esx_f_rewinddir(unsigned char handle);



extern unsigned char esx_f_getcwd(char *pathname);


extern unsigned char esx_f_chdir(const char *pathname);



extern unsigned char esx_f_mkdir(const char *pathname);


extern unsigned char esx_f_rmdir(const char *pathname);



// OPERATIONS ON FILES

struct esx_stat
{
   uint8_t       drive;
   uint8_t       device;
   uint8_t       attr;
   struct dos_tm time;   // time.h contains functions dealing with dos time
   uint32_t      size;
};

// file open mode

// at least one of:

#define ESX_MODE_READ  __esx_mode_read
#define ESX_MODE_WRITE  __esx_mode_write

#define ESX_MODE_R  __esx_mode_read
#define ESX_MODE_W  __esx_mode_write
#define ESX_MODE_RW  (__esx_mode_read | __esx_mode_write)

// one of:

#define ESX_MODE_OPEN_EXIST  __esx_mode_open_exist
#define ESX_MODE_OPEN_CREAT  __esx_mode_open_creat
#define ESX_MODE_OPEN_CREAT_NOEXIST  __esx_mode_creat_noexist
#define ESX_MODE_OPEN_CREAT_TRUNC  __esx_mode_creat_trunc

#define ESX_MODE_USE_HEADER  __esx_mode_use_header

extern unsigned char esx_f_open(const char *filename,unsigned char mode);


extern unsigned char esx_f_open_p3(const char *filename,unsigned char mode,struct esx_p3_hdr *h);


extern unsigned char esx_f_close(unsigned char handle);



extern unsigned char esx_f_sync(unsigned char handle);


extern unsigned char esx_f_fstat(unsigned char handle,struct esx_stat *es);


extern uint32_t esx_f_fgetpos(unsigned char handle);



#define ESX_SEEK_SET  __esx_seek_set
#define ESX_SEEK_FWD  __esx_seek_fwd
#define ESX_SEEK_BWD  __esx_seek_bwd

extern uint32_t esx_f_seek(unsigned char handle,uint32_t distance,unsigned char whence);


extern uint16_t esx_f_read(unsigned char handle,void *dst,size_t nbytes);


extern uint16_t esx_f_write(unsigned char handle,void *src,size_t nbytes);



extern unsigned char esx_f_ftrunc(unsigned char handle,uint32_t size);



// DIRECT OPERATIONS ON FILES BY FILENAME

// chmod attr

#define ESX_A_WRITE  __esx_a_write
#define ESX_A_READ  __esx_a_read
#define ESX_A_RDWR  __esx_a_rdwr
#define ESX_A_HIDDEN  __esx_a_hidden
#define ESX_A_SYSTEM  __esx_a_system
#define ESX_A_ARCH  __esx_a_arch
#define ESX_A_EXEC  __esx_a_exec
#define ESX_A_ALL  __esx_a_all

extern unsigned char esx_f_chmod(const char *filename,uint8_t attr_mask,uint8_t attr);


extern unsigned char esx_f_rename(const char *old,const char *new);


extern unsigned char esx_f_stat(const char *filename,struct esx_stat *es);


extern unsigned char esx_f_trunc(const char *filename,uint32_t size);


extern unsigned char esx_f_unlink(const char *filename);



// ESX ERROR CODES

#define ESX_OK  __ESX_OK                       // 0 OK 0:1
#define ESX_EOK  __ESX_EOK                     // O.K. ESXDOS, 0:1
#define ESX_ENONSENSE  __ESX_ENONSENSE         // Nonsense in ESXDOS, 0:1
#define ESX_ESTEND  __ESX_ESTEND               // Statement END error, 0:1
#define ESX_EWRTYPE  __ESX_EWRTYPE             // Wrong file TYPE, 0:1
#define ESX_ENOENT  __ESX_ENOENT               // No such FILE or DIR, 0:1
#define ESX_EIO  __ESX_EIO                     // I/O ERROR, 0:1
#define ESX_EINVAL  __ESX_EINVAL               // Invalid FILENAME, 0:1
#define ESX_EACCES  __ESX_EACCES               // Access DENIED, 0:1
#define ESX_ENOSPC  __ESX_ENOSPC               // Drive FULL, 0:1
#define ESX_ENXIO  __ESX_ENXIO                 // Invalid I/O REQUEST, 0:1
#define ESX_ENODRV  __ESX_ENODRV               // No such DRIVE, 0:1
#define ESX_ENFILE  __ESX_ENFILE               // Too many OPEN FILES, 0:1
#define ESX_EBADF  __ESX_EBADF                 // Bad file DESCRIPTOR, 0:1
#define ESX_ENODEV  __ESX_ENODEV               // No such DEVICE, 0:1
#define ESX_EOVERFLOW  __ESX_EOVERFLOW         // File pointer OVERFLOW, 0:1
#define ESX_EISDIR  __ESX_EISDIR               // Is a DIRECTORY, 0:1
#define ESX_ENOTDIR  __ESX_ENOTDIR             // Not a DIRECTORY, 0:1
#define ESX_EEXIST  __ESX_EEXIST               // File already EXISTS, 0:1
#define ESX_EPATH  __ESX_EPATH                 // Invalid PATH, 0:1
#define ESX_ENOSYS  __ESX_ENOSYS               // No SYS, 0:1
#define ESX_ENAMETOOLONG  __ESX_ENAMETOOLONG   // Path too LONG, 0:1
#define ESX_ENOCMD  __ESX_ENOCMD               // No such COMMAND, 0:1
#define ESX_EINUSE  __ESX_EINUSE               // File in USE, 0:1
#define ESX_ERDONLY  __ESX_ERDONLY             // File is READ ONLY, 0:1
#define ESX_EVERIFY  __ESX_EVERIFY             // Verify FAILED, 0:1
#define ESX_ELOADINGKO  __ESX_ELOADINGKO       // Loading .KO FAILED, 0:1
#define ESX_EDIRINUSE  __ESX_EDIRINUSE         // Directory NOT EMPTY, 0:1
#define ESX_EMAPRAMACTIVE  __ESX_EMAPRAMACTIVE // MAPRAM is ACTIVE, 0:1
#define ESX_EDRIVEBUSY  __ESX_EDRIVEBUSY       // Drive is BUSY, 0:1
#define ESX_EFSUNKNOWN  __ESX_EFSUNKNOWN       // Unknown FILESYSTEM, 0:1
#define ESX_EDEVICEBUSY  __ESX_EDEVICEBUSY     // Device is BUSY, 0:1

#define ESX_EMAXCODE  __ESX_EMAXCODE           // Largest valid error code

// original esxdos api

#include <arch/zx/esxdos.h>

#endif
