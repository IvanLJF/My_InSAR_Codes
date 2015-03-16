PRO TEST_DEF_VELOCITY

  ; Data Preparation
  workpath='/mnt/software/myfiles/Software/experiment/TerraSARTestArea'
  slcpath=workpath+'/Area_Management/Area_Processing/Area1'
  diffpath=workpath+'/Basic_InSAR/Interferogram_Generation/Area1'
  resultpath=workpath+'/PSI'
  
  plistfile= resultpath+'/plist' ; PS .
  
  ; PS selection--------------------------------------------------------------------------------------------------------------------------
  
  ;- Generate a sarlist file.
  path=slcpath
  outfile= plistfile
  suffix= '.img'
  result= TLI_SARLIST(path, suffix, outfile=outfile)
  PRINT, '**************************************'
  PRINT, '* Sarlist file written successfully! *'
  PRINT, '**************************************'
  ;  ;- Find PSs.
  samples= 2679
  lines= 1471
  float=1
  swap_endian=0
  outfile= 'F:\Qingzang_envisat\MagNorm\MultiLook\plist'
  thr_da= 0.25
  thr_amp= 1
  ;    result= TLI_PSSELECT(sarlist, samples, lines,$
  ;                  float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian, $
  ;                  outfile=outfile, thr_da=thr_da, thr_amp=thr_amp)
  PRINT, '**************************************'
  PRINT, '*   PSs file written successfully    *'
  PRINT, '**************************************'
  
  ;- Display result.
  
  plist= COMPLEXARR(TLI_PNUMBER(plistfile))
  OPENR, lun, plistfile,/GET_LUN
  READU, lun, plist;点坐标文件
  FREE_LUN, lun
  
  tempmaster=''
  OPENR, lun, sarlist,/GET_LUN
  READF, lun, tempmaster
  FREE_LUN, lun
  
  pwr= COMPLEXARR(samples, lines)
  OPENR, lun, tempmaster
  READU, lun, pwr
  FREE_LUN, lun
  pwr= ALOG(ABS(pwr))
  ;    pwr= ABS(OPENSLC(tempmaster,columns=3500,lines=3500,data_type='SCOMPLEX',/swap_endian));底图
  scale= 0.5
  sz=SIZE(pwr,/DIMENSIONS)
  pwr= CONGRID(pwr,sz[0]*scale, sz[1]*scale)
  ;  pwr= ROTATE(pwr, 5)
  ps_index_s= REAL_PART(plist)*scale
  ps_index_l= IMAGINARY(plist)*scale
  WINDOW, xpos=0, ypos=0, xsize=sz[0]*scale, ysize=sz[1]*scale,0
  ;    TVSCL, linear2(pwr)
  TVSCL, pwr
  wait, 3
  PLOTS, ps_index_s, ps_index_l, psym=1, symsize=1, COLOR=200,/DEVICE
; Networking--------------------------------------------------------------------------------------------------------------------------
  
; Solve--------------------------------------------------------------------------------------------------------------------------
  
; Residuals decompsition--------------------------------------------------------------------------------------------------------------------------
  
; Sort out the results--------------------------------------------------------------------------------------------------------------------------
  
  
END