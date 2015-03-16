;
; Change pixel coordinates to latitude & longitude
;
@ kml
@ TXT2KML
PRO TLI_QL_CR

  workpath='/mnt/backup/experiment/Qingli_all/select_CR'
  workpath=workpath+PATH_SEP()
  
  geopath=workpath+'geocode'+PATH_SEP()
  
  pxl_coor_mirrorfile= workpath+'cr_coors_pxl'
  pxl_coorfile= pxl_coor_mirrorfile+'.txt'
  plistfile= workpath+'pt'
  latlon_coorfile=geopath+'pmapll'
  geocodefile=geopath+'geocode.sh'
  kml_txtfile=geopath+'kml_txt.txt'
  kmlfile=geopath+'crs.kml'
  
  
  
  nlines=FILE_LINES(pxl_coor_mirrorfile)
  result=LONARR(2, nlines)
  OPENR, lun,pxl_coor_mirrorfile,/GET_LUN
  READF, lun, result
  FREE_LUN, lun
  OPENW, lun, pxl_coorfile,/GET_LUN
  result[0,*]=1658-result[0,*]
  
  PRINTF, lun,result
  FREE_LUN, lun
  
  
  IF 1 THEN BEGIN
    ; Change txt to plist
    TLI_ASCII2DAT, pxl_coorfile, datfile=plistfile,format='LONG',/swap_endian
    
    ; Geocoding
    cd, geopath
;    SPAWN, geocodefile
    TLI_DAT2ASCII, plistfile,samples=2, format='LONG',/swap_endian
    
    
    
    
    ; Read geo_coded longitudes and latitudes
    latlon_coor= TLI_READDATA(latlon_coorfile, samples=1, format='FCOMPLEX',/swap_endian)
    plist= TLI_READDATA(plistfile,samples=2, format='LONG',/swap_endian)
    r_plist= plist[0:*:2]
    i_plist= plist[1:*:2]
    plist=COMPLEX(r_plist, i_plist)
    ; Change them to kml
    OPENW, lun, kml_txtfile,/GET_LUN
    For i=0, N_ELEMENTS(latlon_coor)-1 DO BEGIN
      ;    name='CR:'+STRCOMPRESS(i,/REMOVE_ALL)+STRCOMPRESS(plist[i],/REMOVE_ALL)
      name='CR:'+STRCOMPRESS(i+1,/REMOVE_ALL)
      lat=STRCOMPRESS(REAL_PART(latlon_coor[i]))
      lon=STRCOMPRESS(IMAGINARY(latlon_coor[i]))
      PRINTF, lun, STRJOIN([name, lon, lat],' ')
    ENDFOR
    FREE_LUN, lun
    
    TXT2KML, kml_txtfile, kmlfile=kmlfile
  ENDIF
  ; Modify kml
  
  ; Generate annotation file for GMT
  inputfile='/mnt/backup/experiment/Qingli_all/select_CR/pt.txt'
  prefix=''
  nlines=FILE_LINES(inputfile)
  suffix=' 5 0 3 LM'+STRING(INDGEN(nlines)+1)
  IF NOT KEYWORD_SET(inputfile) THEN BEGIN
    Message, 'Number of input parameters: ERROR!'
  ENDIF
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=inputfile+'.changed'
  ENDIF
  
  OPENR,inlun, inputfile,/GET_LUN
  OPENW, outlun, outputfile,/GET_LUN
  
  
  file= LONARR(2, nlines)
  READF, inlun, file
  IF KEYWORD_SET(prefix) THEN BEGIN
    file=prefix+STRING(file)
  ENDIF
  IF KEYWORD_SET(suffix) THEN BEGIN
    file= STRING(file[0, *]+7)+STRING(9683-file[1, *])+suffix
  ENDIF
  
  ;  FOR i=0, nlines-1 DO BEGIN
  ;
  ;
  ;  ENDFOR
  PRINTF, outlun, file
  
  FREE_LUN, inlun
  FREE_LUN, outlun
  
END