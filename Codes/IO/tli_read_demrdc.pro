PRO TLI_READ_DEMRDC
  COMPILE_OPT idl2
  infile= '/mnt/software/ForExperiment/TSX_PS_HK/sim_sar.rdc'
  samples= 1500
  lines= 1500
  type= 'FLOAT'
  result= FLTARR(samples, lines)
  OPENR, lun, infile, /GET_LUN,/SWAP_ENDIAN
  READU, lun, result
  FREE_LUN, lun
  PRINT, MAX(result), MIN(result)
  scale=0.3
  sz= SIZE(result,/DIMENSIONS)*scale
  pwr= CONGRID((result),sz[0],sz[1])
  WINDOW, /free,XSIZE=sz[0], YSIZE=sz[1], TITLE=infile
  LOADCT,0
  TVSCL, pwr,/ORDER
  

END