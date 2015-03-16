;
; Report the DEM ERROR using histogram
;
; Parameters:
;
; Keywords:
;
; Examples:
;  int_demfile='/mnt/data_tli/ForExperiment/GAMMA/ISP/05721-25394.hgt'
;  ref_demfile='/mnt/data_tli/ForExperiment/GAMMA/ISP/05721.dem.hgt'
;  parfile='/mnt/data_tli/ForExperiment/GAMMA/ISP/05721.pwr.par'
;  errfile=int_demfile+'.error'
;  reportfile=errfile+'.txt'
;  histfile=errfile+'.hist'
; Written by:
;   T.LI @ Sasmac, 20141216
;
PRO TLI_REPORT_INT_DEM_ERROR, int_demfile, ref_demfile, parfile=parfile, errfile=errfile, reportfile=reportfile, histfile=histfile

  COMPILE_OPT idl2
  ;--------------------------------------
  ; Check input params.
  IF NOT FILE_TEST(int_demfile) THEN Message, 'TLI_REPORT_INT_DEM_ERROR: Error! File not exist:'+int_demfile
  IF NOT FILE_TEST(ref_demfile) THEN Message, 'TLI_REPORT_INT_DEM_ERROR: Error! File not exist:'+ref_demfile
  workpath=FILE_DIRNAME(int_demfile)+PATH_SEP()
  
  utm=1
  temp=STRPOS(FILE_BASENAME(int_demfile),'utm')
  IF temp EQ -1 THEN utm=0
  IF utm EQ 1 THEN BEGIN
    IF NOT KEYWORD_SET(parfile) THEN BEGIN
      parfile=workpath+'dem_seg.par'
    ENDIF
  ENDIF ELSE BEGIN
    IF NOT KEYWORD_SET(parfile) THEN BEGIN
      master_date=STRSPLIT(FILE_BASENAME(int_demfile),'-',/extract,count=nsep)
      IF nsep EQ 0 THEN BEGIN
        Message, 'Error! Please specify parfile.'
      ENDIF ELSE BEGIN
        master_date=master_date[0]
        parfile=workpath+master_date+'.pwr.par'
      ENDELSE
    ENDIF
  ENDELSE
  IF NOT FILE_TEST(parfile) THEN Message, 'ERROR! Please specify parfile.'
  
  IF NOT KEYWORD_SET(errfile) THEN errfile=int_demfile+'.error'
  IF NOT KEYWORD_SET(reportfile) THEN reportfile=errfile+'.txt'
  IF NOT KEYWORD_SET(histfile) THEN histfile=errfile+'.hist'
  
  ;---------------------------------
  ; Assignment
  finfo=TLI_LOAD_PAR(parfile)
  
  IF utm EQ 1 THEN BEGIN
    samples=finfo.width
    lines=finfo.nlines
  ENDIF ELSE BEGIN
    samples=finfo.range_samples
    lines=finfo.azimuth_lines    
  ENDELSE
  ;-------------------------------------
  ; Read the data
  int_dem=TLI_READDATA(int_demfile, samples=samples, format='float',/swap_endian)
  ref_dem=TLI_READDATA(ref_demfile, samples=samples, format='float',/swap_endian)
  sz_int=SIZE(int_dem,/DIMENSIONS)
  sz_ref=SIZE(ref_dem,/DIMENSIONS)
  IF TOTAL(ABS(sz_int-sz_ref)) NE 0 THEN Message, 'TLI_REPORT_INT_DEM_ERROR: ERROR! Dimensions of the input files are inconsistent.'
  ;------------------------------------
  ; Statistics
  ; Ignore 0.0
  ind_valid=WHERE(int_dem NE 0.0 AND ref_dem NE 0.0, complement=ind_invalid)
  err=int_dem-ref_dem
  err[ind_invalid]=!values.F_NAN
  err_valid=err[ind_valid]
  
  err_refine_ind=TLI_REFINE_DATA(err, refined_data=err_refine, complement=comp_ind,/nan)
  err[comp_ind]=!values.f_NAN
  TLI_WRITE, errfile, err,/swap_endian
  
  min_err=MIN(ABS(err_refine), min_ind, max=max_err, subscript_max=max_ind)
  min_err=err_refine[min_ind]
  max_err=err_refine[max_ind]
  
  mean_abs_err=MEAN(ABS(err_refine))
  mean_err=MEAN(err_refine)
  std_err=STDDEV(err_refine)
  
  ;  hist_err=[TRANSPOSE(x), TRANSPOSE(hist_err)]
  TLI_WRITE, histfile, TRANSPOSE(err_refine),/TXT
  RMSE=TLI_RMSE(int_dem[err_refine_ind], y=ref_dem[err_refine_ind])
  
  ; Report error.
  OPENW, lun, reportfile, /GET_LUN
  PrintF, lun, 'DEM Error Report.'
  PrintF, lun, ''
  PrintF, lun, 'Time:        '+TLI_TIME(/str)
  PrintF, lun, ''
  PrintF, lun, 'InSAR_DEM:   '+int_demfile
  PrintF, lun, 'Ref. DEM:    '+ref_demfile
  PrintF, lun, ''
  PrintF, lun, 'Statistics:  '
  PrintF, lun, 'mean_err:    '+STRCOMPRESS(mean_err,/REMOVE_ALL)
  PrintF, lun, 'mean_abs_err:'+STRCOMPRESS(mean_abs_err,/REMOVE_ALL)
  PrintF, lun, 'std_err:     '+STRCOMPRESS(std_err,/REMOVE_ALL)
  PrintF, lun, 'min_err:     '+STRCOMPRESS(min_err,/REMOVE_ALL)
  PrintF, lun, 'max_err:     '+STRCOMPRESS(max_err,/REMOVE_ALL)
  PrintF, lun, 'RMSE:        '+STRCOMPRESS(RMSE,/REMOVE_ALL)
  PrintF, lun, 'hist_err:    '+histfile+'.ras'
  PrintF, lun, ''
  FREE_LUN, lun
  
  ; Plot histogram
  OPENW, lun, histfile+'.sh',/GET_LUN
  PrintF, lun, "#! /bin/sh"
  PrintF, lun, "#####################################"
  PrintF, lun, "## Plot_int_dem_error: Plot DEM Error.###"
  PrintF, lun, "##     using:"
  PrintF, lun, "##       - int_dem: DEM created using InSAR"
  PrintF, lun, "##       - ref_dem: Reference DEM"
  PrintF, lun, "##  "
  PrintF, lun, "#####################################"
  PrintF, lun, "## History"
  PrintF, lun, "##   20141216: Written by T.LI @ Sasmac"
  PrintF, lun, "#####################################"
  PrintF, lun, "echo ''"
  PrintF, lun, "echo '*** plot_int_dem_error Plot DEM error using GMT. v1.0 20141216.'"
  PrintF, lun, "echo ' '"
  PrintF, lun, "echo '      Required data:'"
  PrintF, lun, "echo '        - int_dem: DEM created using InSAR.'"
  PrintF, lun, "echo '        - ref_dem: Reference DEM'"
  PrintF, lun, "echo ''"
  PrintF, lun, ""
  PrintF, lun, "gmtset ANNOT_FONT_SIZE 12p ANNOT_OFFSET_PRIMARY 0.07i FRAME_WIDTH 0.06i MAP_SCALE_HEIGHT 0.04i \"
  PrintF, lun, "LABEL_FONT_SIZE 12p LABEL_OFFSET 0.05i TICK_LENGTH 0.08i"
  title='RMSE='+STRCOMPRESS(RMSE,/REMOVE_ALL)
  PrintF, lun,'pshistogram -Ba20f10:"Elevation Error(m)":/a10f5:"Frequency"::,%::.'+title+':WSne '+$
    histfile+' -R'+STRCOMPRESS(-100,/REMOVE_ALL)+'/'+STRCOMPRESS(100,/REMOVE_ALL)+'/0/20 -JX4.8i/2.4i -Ggray -Lthinner -P -X2i -Y2i -Z1 -W5 --HEADER_FONT_SIZE=14p > '+histfile+'.ps'
  PrintF, lun, 'ps2raster '+histfile+'.ps'+' -Tt -E500 -A '
  PrintF, lun, '#geeqie '+histfile+'.tif &'
  FREE_LUN, lun
  CD, FILE_DIRNAME(histfile), current=pwd
  Print, 'Plotting DEM error figure, please wait...'
  SPAWN, histfile+'.sh'
  CD, pwd
END