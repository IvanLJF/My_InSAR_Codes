;-
;- Modify the coordinates according to multi-look factors.
;-
;- Written by: T.LI in CUHK
PRO TLI_REG_MULTI_LOOK

  workpath='F:\ExpGroup\Reg'
  workpath=workpath+PATH_SEP()
  
  regfile= workpath+'multi_look_1_5.pts'
  outputfile=workpath+'Coreg_DEM.pts'
  
  ml_r=1 ; Multilook factor in range direction.
  ml_a=5 ; Multilook factor in azimutn direction.
  
  OPENW, outlun, outputfile,/GET_LUN
  PrintF, outlun, '; ENVI Image to Image GCP File'
  PrintF, outlun, '; base file: F:\ExpGroup\reg\20080817_MultiLook.mli'
  PrintF, outlun, '; warp file: F:\ExpGroup\reg\20080817_SimImg'
  PrintF, outlun, '; Base Image (x,y), Warp Image (x,y)'
  PrintF, outlun, ';'
  
  coregdata=TLI_READTXT(regfile, header_lines=5)
  sz=SIZE(coregdata,/DIMENSIONS)
  npts= sz[1]
  factors= REBIN([ml_r, ml_a, ml_r, ml_a], 4, npts)
  result= coregdata*factors
  
  PrintF, outlun, result
  FREE_LUN, outlun
  STOP
END