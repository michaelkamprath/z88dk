; unsigned char esx_f_closedir(unsigned char handle)

SECTION code_esxdos

PUBLIC esx_f_closedir

EXTERN esx_f_close

defc esx_f_closedir = esx_f_close
