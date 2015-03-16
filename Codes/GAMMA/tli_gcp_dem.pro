;
; Get GCP from SRTM data.
;
; Parameters
;   unwfile      : Unwrapped file.
;   demfile      : Dem file. Use TLI_GAMMA_DEM to create dem.
;
; Keywords:
;   gcpfile      : GCP file. Default is workpath+fname+'.gcp'
;   npt          : Number of points to use. Default is 1000.
;   geocode_method: Geocode method.
;                  0: Coarse coreg
;                  1: Fine coreg
;                  2: Using existed lookup table.
; Example:
;
;  workpath='/mnt/data_tli/ForExperiment/int_ERS_Shanghai/int_ERS_shanghai_2000_10000'
;  workpath=workpath+PATH_SEP()
;
;  unwfile=workpath+'19960325-19960326.flt.filt.unw'
;  demfile='/mnt/data_tli/Data/DEM/ShanghaiDEM_ERS/Shanghai.dem'
;  fname=TLI_FNAME(unwfile, /REMOVE_ALL_SUFFIX)
;  gcpfile=workpath+fname+'.gcp'
;
;  npt=1000
;  TLI_GCP_DEM, unwfile, demfile, gcpfile=gcpfile, npt=npt
;
; Written by:
;   T.LI @ Sasmac, 20141127
; History
;   T.LI @ Sasmac, 20141222: Add keywords: geocode_method
;
PRO TLI_GCP_DEM, unwfile, demfile, gcpfile=gcpfile, npt=npt, geocode_method=geocode_method

  IF NOT FILE_TEST(unwfile) OR NOT FILE_TEST(demfile) THEN BEGIN
    Message, 'TLI_GCP_DEM: ERROR! Input files are not found.'+STRING(13b)+unwfile+STRING(13b)+demfile
  ENDIF
  
  workpath=FILE_DIRNAME(unwfile)+PATH_SEP()
  fname=TLI_FNAME(unwfile, /REMOVE_ALL_SUFFIX)
  IF NOT KEYWORD_SET(gcpfile) THEN BEGIN
    gcpfile=workpath+fname+'.gcp'
  ENDIF
  IF NOT KEYWORD_SET(npt) THEN BEGIN
    npt=1000
  ENDIF
  
  IF N_ELEMENTS(geocode_method) EQ 0 THEN geocode_method=1
  
  ;----------------------------------------------------------
  ; Geocode the pwr file and dem file.
  temp=STRSPLIT(FILE_BASENAME(unwfile), '-',/extract)
  master_date=temp[0]
  pwrfile=workpath+master_date+'.pwr'
  IF NOT FILE_TEST(pwrfile) THEN BEGIN
    Message, 'TLI_GCP_DEM: ERROR! File not found:'+pwrfile
  ENDIF
  
  finfo=TLI_LOAD_SLC_PAR(pwrfile+'.par')
  scr='tli_geocode_dem '+pwrfile+' '+demfile+' - '+STRCOMPRESS(geocode_method,/REMOVE_ALL)
  Print, 'Runing the scripts '+STRING(13b)+scr+STRING(13b)
  Print, 'Please wait.'
  
  
  CD, workpath[0], current=thispath
  SPAWN, scr
  CD, thispath
  ;------------------------------------------------------------------
  ; Extract ground control points.
  
  ccfile=workpath+fname+'.filt_presv.cc'
  hgtfile=workpath+master_date+'.dem.hgt'
  
  IF NOT FILE_TEST(ccfile) THEN BEGIN
    ccfile=workpath+fname+'.filt.cc'
    IF NOT FILE_TEST(ccfile) THEN BEGIN
      Print, 'TLI_GCP_DEM: ERROR! File not found:'+unwfile
      Message, 'Please run tli_unwrap first.'
    ENDIF
  ENDIF
  TLI_MASK_INT, ccfile, files_to_mask=hgtfile,output_pattern='.msk'
  
  hgtfile=hgtfile+'.msk'
  hgt=TLI_READDATA(hgtfile, samples=finfo.range_samples, format='float',/swap_endian)
  
  valid_ind=WHERE(hgt NE 0.0,nvalid, complement=invalid_ind)
  
  plist=RANDOMN(seed, npt)
  plist=TLI_STRETCH_DATA(plist, [0, nvalid-1])
  plist=LONG(plist[SORT(plist)])
  plist=plist[UNIQ(plist)]
  plist=valid_ind[plist]
  
  temp=ARRAY_INDICES(hgt, plist)
  x=temp[0, *]
  y=temp[1, *]
  data_plist=hgt[plist]
  
  npt_final=N_ELEMENTS(x)
  gcp=[STRCOMPRESS(LINDGEN(1, npt_final)+1), STRCOMPRESS(LONG(x)), STRCOMPRESS(LONG(y)), STRCOMPRESS(FLOAT(TRANSPOSE(data_plist)))]
  
  TLI_WRITE, gcpfile, gcp,/TXT
  
  Print, 'TLI_GCP_DEM: Task finished successfully!'+TLI_TIME(/str)
  
END