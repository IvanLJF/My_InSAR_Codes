 ;
;- Convert the geo-coordinates to pixel coordinates.
;- GAMMA is needed.
;- For detailed information, please refer to the script:
;- coord_to_sarpix
;-
;- inputfile  : input text file. Organized as [longitude, latitude]
;- mparfile   : par file of the master image
;- dem_segparfile: if the coordinate is not WGS84, then please specify this file.
;- outputfile : result file. organized as [x, y]
;
;- Written by:
;-   T.Li @ ISEIS


@tli_strsplit
PRO TLI_GAMMA_GEO2PT,inputfile, mparfile,dem_segparfile=dem_segparfile,outputfile=outputfile 

  COMPILE_OPT idl2
  IF N_PARAMS() NE 2 THEN Message, 'Usage Error.'
  
  workpath=FILE_DIRNAME(inputfile)+PATH_SEP() 
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=inputfile+'_sarcoor'
  
  geofile=inputfile
  resultfile=outputfile
  
  ; Read files
  nlines=FILE_LINES(geofile)
  geo=STRARR(nlines)
  OPENR, lun, geofile,/GET_LUN
  READF, lun, geo
  FREE_LUN, lun
  
  geo=TLI_STRSPLIT(geo)
  lons=DOUBLE(geo[0, *])
  lats=DOUBLE(geo[1, *])
  npt=N_ELEMENTS(lons)
  ; Call GAMMA to calculate the coordinates.
  FOR i=0, npt-1 DO BEGIN
;    Print, 'Converting the coordinates from ll to sar...:'+STRCOMPRESS(i)+'/'+STRCOMPRESS(npt-1)
    IF NOT KEYWORD_SET(dem_segparfile) THEN scr='coord_to_sarpix '+mparfile+' - - '+STRCOMPRESS(lats[i])+STRCOMPRESS(lons[i]) $
    ELSE scr='coord_to_sarpix '+mparfile+' - '+dem_segparfile+STRCOMPRESS(lats[i])+STRCOMPRESS(lons[i])
    IF i EQ 0 THEN BEGIN
      scr=scr+'>'+resultfile
    ENDIF ELSE BEGIN
      scr=scr+'>>'+resultfile
    ENDELSE
    SPAWN, scr
  ENDFOR
  ; Extract the useful information from resultfile
  all_pix_y=READ_PARAMS(resultfile, 'azimuth_pixel_number:')
  all_pix_x=READ_PARAMS(resultfile, 'slant_range_pixel_number:')
  all_pix_x=DOUBLE((TLI_STRSPLIT(all_pix_x))[1, *])
  all_pix_y=DOUBLE((TLI_STRSPLIT(all_pix_y))[1, *])
  
  ; Rewrite the data to resultfile
  result=[ STRING(all_pix_x), STRING(all_pix_y)]
  TLI_WRITE, resultfile, result,/TXT  
  TLI_WRITE, workpath+FILE_BASENAME(resultfile,'.txt'), COMPLEX(all_pix_x, all_pix_y)
  
  PRint, 'Main Pro finished. Please check the file:'
  Print, '    '+resultfile
  
  
END