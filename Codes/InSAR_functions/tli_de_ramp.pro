; 
; Remove phase ramp from SAR Images.
;
; Parameters:
;   file        : File to remove phase ramp.
;
; Keywords:
;   parfile     : PWR par file. Master.pwr.par are used as default. 
;   rampfile    : Phase ramp file. file.ramp is
;   derampfile  : File with ramp deliminated.
;   invalid_data: Invalid data of the input file
;   npt         : Number of points used to fit the ramp trend.
; Example:
;   workpath='/mnt/data_tli/ForExperiment/int_tsx_tianjin/10000_10000_ml'
;   workpath=workpath+PATH_SEP()
;   file=workpath+'20090407-20090418.hgt'
;   parfile=workpath+'20090407.pwr.par'
;   rampfile=file+'.ramp'
;   derampfile=file+'.deramp'  
;   invalid_data=0.0
;   npt=1000
;   degree=1
;   TLI_DE_RAMP, file, parfile=parfile, rampfile=rampfile, derampfile=derampfile, invalid_data=invalid_data, npt=npt, degree=degree
; Written by:
;   T.LI @ Sasmac, 20141127
; 
PRO TLI_DE_RAMP, file, parfile=parfile, rampfile=rampfile, derampfile=derampfile, invalid_data=invalid_data, npt=npt, degree=degree
  
  COMPILE_OPT idl2
  workpath=FILE_DIRNAME(file)+PATH_SEP()
  IF NOT KEYWORD_SET(parfile) THEN BEGIN
    fname=TLI_FNAME(file, /remove_all_suffix)
    fname=STRSPLIT(fname, '-',/extract,count=nsep)
    IF nsep EQ 0 THEN BEGIN
      Message, 'TLI_DE_RAMP: ERROR! Please specify pwr parfile.'
    ENDIF
    master_date=fname[0]
    slave_date=fname[1]
  ENDIF
  
  IF NOT KEYWORD_SET(parfile) THEN parfile=workpath+master_date+'.pwr.par'
  IF NOT KEYWORD_SET(rampfile) THEN rampfile=file+'.ramp'
  IF NOT KEYWORD_SET(derampfile) THEN derampfile=file+'.deramp'
  IF NOT KEYWORD_SET(invalid_data) THEN invalid_data=0.0
  IF NOT KEYWORD_SET(npt) THEN npt=1000
  IF NOT KEYWORD_SET(degree) THEN degree=2
  
  ;------------------------------------
  ; Create plist.
  finfo=TLI_LOAD_SLC_PAR(parfile)
  data=TLI_READDATA(file, samples=finfo.range_samples, format='float',/swap_endian)
  valid_ind=WHERE(data NE invalid_data,nvalid, complement=invalid_ind)
  
  plist=RANDOMN(seed, npt)
  plist=TLI_STRETCH_DATA(plist, [0, nvalid-1])
  plist=LONG(plist[SORT(plist)])
  plist=plist[UNIQ(plist)]
  plist=valid_ind[plist]
  
  temp=ARRAY_INDICES(data, plist)
  x=temp[0, *]
  y=temp[1, *]
  data_plist=data[plist]
  
  ;-------------------------------------------
  ; Calculate ramp raster
  ;
  x_all=REBIN(FINDGEN(finfo.range_samples), finfo.range_samples, finfo.azimuth_lines)
  y_all=REBIN(FINDGEN(1, finfo.azimuth_lines), finfo.range_samples, finfo.azimuth_lines)
  ; ramp=a0+a1*x+a2*y+a3*xy+a4*x^2+a5*y^2
  ramp=TLI_POLYFIT2D(x, y, data_plist, x_all, y_all, degree=degree)
  deramp=data-ramp
  deramp[invalid_ind]=0
  ramp[invalid_ind]=0
  
  TLI_WRITE, rampfile, FLOAT(ramp),/swap_endian
  TLI_WRITE, derampfile, FLOAT(deramp),/swap_endian
  
  ;--------------------------------------------------
  ; Plot images
  pwrfile=workpath+FILE_BASENAME(parfile, '.par')
  scr='rashgt '+rampfile+' '+pwrfile+' '+STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
  SPAWN, scr
  scr='rashgt '+derampfile+' '+pwrfile+' '+STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
  SPAWN, scr
  Print, 'Task finished successfully.'+TLI_TIME(/str)
END