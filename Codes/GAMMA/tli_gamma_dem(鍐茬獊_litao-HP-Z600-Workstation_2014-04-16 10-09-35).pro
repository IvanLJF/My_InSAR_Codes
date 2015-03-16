; Create DEM using the given range.
; Format can only be used in GAMMA
;
; range: [start_longitude, end_longitude, start_latitude, end_latitude]

FUNCTION TLI_DEMNAMES, range, suffix=suffix
  ; Return names of the dem files considering the given range.
  range= STRSPLIT(range, /EXTRACT)
  IF N_ELEMENTS(range) NE 4 THEN Message, 'Error: Please specify longitude and latitude ranges'
  
  ;  IF ~KEYWORD_SET(suffix) THEN BEGIN
  ;    suffix='.hgt.zip'
  ;  ENDIF
  
  lons=range[0]
  lone=range[1]
  lats=range[2]
  late=range[3]
  
  lonsann=STRMID(lons, 0,/REVERSE_OFFSET) ; See if they are in the same semisphere
  loneann=STRMID(lone, 0,/REVERSE_OFFSET)
  latsann=STRMID(lats, 0,/REVERSE_OFFSET)
  lateann=STRMID(late, 0,/REVERSE_OFFSET)
  
  lons= FLOAT(STRMID(lons, 0, STRLEN(lons)-1))
  lone= FLOAT(STRMID(lone, 0, STRLEN(lone)-1))
  lats= FLOAT(STRMID(lats, 0, STRLEN(lats)-1))
  late= FLOAT(STRMID(late, 0, STRLEN(late)-1))
  ; Calculate the files to be extracted.
  ; Firstly calculate the Longitude annotation
  IF lonsann NE loneann THEN BEGIN
    IF lonsann EQ 'E' THEN BEGIN
      lonanns_eas= LONG(lons)+LINDGEN(180-lons-1)
      lonanns_eas= lonsann+STRCOMPRESS(lonanns_eas,/REMOVE_ALL)
      lonanns_wes= 180-LINDGEN(CEIL(180-lone)+1)
      lonanns_wes= loneann+STRCOMPRESS(lonanns_wes,/REMOVE_ALL)
    ENDIF ELSE BEGIN
      lonanns_wes= LINDGEN(FLOOR(lons))+1
      lonanns_wes= lonsann+lonanns_wes
      lonanns_eas= LINDGEN(FLOOR(lons))
      lonanns_eas= loneann+lonanns_eas
    ENDELSE
    lonanns= [lonanns_eas, lonanns_wes]
  ENDIF ELSE BEGIN
    IF lonsann EQ 'E' THEN BEGIN
      IF lone LE lons THEN message, 'Longitudes ERROR!'
      lonanns= lonsann+STRCOMPRESS(LONG(lons)+LINDGEN(CEIL(lone)-FLOOR(lons)),/REMOVE_ALL)
    ENDIF ELSE BEGIN
      IF lone GE lons THEN Message, 'Longitudes ERROR!'
      lonanns= lonsann+STRCOMPRESS(CEIL(lone)+LINDGEN(CEIL(lons)-FLOOR(lone))+1,/REMOVE_ALL)
    ENDELSE
  ENDELSE
  ; Secondly calculate the Latitude annotation
  IF latsann NE lateann THEN BEGIN
    IF latsann EQ 'N' THEN BEGIN
      latanns_nor= LONG(lats)+LINDGEN(90-lats-1)
      latanns_nor= latsann+STRCOMPRESS(latanns_nor,/REMOVE_ALL)
      latanns_sou= 90-LINDGEN(CEIL(90-late)+1)
      latanns_sou= lateann+STRCOMPRESS(latanns_sou,/REMOVE_ALL)
    ENDIF ELSE BEGIN
      latanns_nor= LINDGEN(FLOOR(lats))+1
      latanns_nor= latsann+latanns_nor
      latanns_sou= LINDGEN(FLOOR(lats))
      latanns_sou= lateann+latanns_sou
    ENDELSE
    latanns= [latanns_nor, latanns_sou]
  ENDIF ELSE BEGIN
    IF latsann EQ 'N' THEN BEGIN
      IF late LE lats THEN message, 'Latitudes ERROR!'
      latanns= latsann+STRCOMPRESS(LONG(lats)+LINDGEN(CEIL(late)-FLOOR(lats)),/REMOVE_ALL)
    ENDIF ELSE BEGIN
      IF late GE lats THEN Message, 'Longitudes ERROR!'
      latanns= latsann+STRCOMPRESS(CEIL(lone)+LINDGEN(CEIL(lats)-FLOOR(late))+1,/REMOVE_ALL)
    ENDELSE
  ENDELSE
  ; Thirdly combine the annotations to generate file names
  lon_ann_no= N_ELEMENTS(lonanns)
  lat_ann_no= N_ELEMENTS(latanns)
  names= STRARR(lon_ann_no*lat_ann_no)
  k=0
  FOR i=0, lon_ann_no-1 DO BEGIN
    FOR j=0, lat_ann_no-1 DO BEGIN
      names[k]= latanns[j]+lonanns[i]
      k=k+1
    ENDFOR
  ENDFOR
  IF KEYWORD_SET(suffix) THEN names= names+suffix
  RETURN, names
END

PRO TLI_DEMPAR, inputfile, outputfile=outputfile,name=name

  fname=FILE_BASENAME(inputfile,'.hgt')
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=fname+'.dem.par'
  ENDIF
  IF NOT KEYWORD_SET(name) THEN BEGIN
    name=fname
  ENDIF
  ; UL coner of DEM
  latann=STRMID(fname, 0,1)
  lats=LONG(STRMID(fname, 1,3))
  lonann=STRMID(fname, 4, 1)
  lons=LONG(STRMID(fname, 4, 3))
  
  OPENW, lun, outputfile,/GET_LUN
  PrintF, lun, ' Gamma DIFF&GEO DEM/MAP parameter file'
  PrintF, lun, ' title: '+name
  PrintF, lun, ' DEM_projection:     EQA'
  PrintF, lun, ' data_format:        INTEGER*2'
  PrintF, lun, ' DEM_hgt_offset:          0.00000'
  PrintF, lun, ' DEM_scale:               1.00000'
  PrintF, lun, ' width:                1201'
  PrintF, lun, ' nlines:               1201'
  PrintF, lun, ' corner_lat:     '+STRCOMPRESS(FLOAT(lats+1))+'  decimal degrees'
  PrintF, lun, ' corner_lon:     '+STRCOMPRESS(FLOAT(lons))+'  decimal degrees'
  PrintF, lun, ' post_lat:   -8.3333330e-04  decimal degrees'
  PrintF, lun, ' post_lon:    8.3333330e-04  decimal degrees'
  PrintF, lun, ' '
  PrintF, lun, ' ellipsoid_name: WGS 84'
  PrintF, lun, ' ellipsoid_ra:        6378137.000   m'
  PrintF, lun, ' ellipsoid_reciprocal_flattening:  298.2572236'
  PrintF, lun, ' '
  PrintF, lun, ' datum_name: WGS 1984'
  PrintF, lun, ' datum_shift_dx:              0.000   m'
  PrintF, lun, ' datum_shift_dy:              0.000   m'
  PrintF, lun, ' datum_shift_dz:              0.000   m'
  PrintF, lun, ' datum_scale_m:         0.00000e+00'
  PrintF, lun, ' datum_rotation_alpha:  0.00000e+00   arc-sec'
  PrintF, lun, ' datum_rotation_beta:   0.00000e+00   arc-sec'
  PrintF, lun, ' datum_rotation_gamma:  0.00000e+00   arc-sec'
  PrintF, lun, ' datum_country_list Global Definition, WGS84, World'
  PrintF, lun, ' '
  FREE_LUN, lun
END

PRO TLI_GAMMA_DEM

  sourcepath='/mnt/data_tli/Data/DEM/SRTM/Eurasia'
  workpath='/mnt/data_tli/Data/DEM/ShanghaiDEM'
  range= '121.2E 121.7E 30.9N 31.6N' ; Startx endx starty endy
  name='Shanghai'    ; Annotation of DEM files.

;  sourcepath='/run/media/tao/Fujitsu HDD/Software/Data/DEM/SRTM/Eurasia'
;  workpath='/mnt/backup/DEM/TianjinDEM_GAMMA'
;  range= '116.869E 117.069E 38.895N 39.405N' ; Startx endx starty endy
;  name='Tianjin'    ; Annotation of DEM files.
  
  
  
  suffix='.hgt.zip' ; Suffix of archived files.
  sourcepath=sourcepath+PATH_SEP()
  workpath=workpath+PATH_SEP()
  
  names= TLI_DEMNAMES(range, suffix=suffix)
  ndems= N_ELEMENTS(names)
  
  Print, 'Copying files...'
  FILE_COPY, sourcepath+names, workpath,/verbose,/OVERWRITE
  
  Print, 'Unzipping files...'
  CD, workpath
  cmd='unzip "*'+suffix+'"'
  SPAWN, cmd
  
  basenames= FILE_BASENAME(names,suffix)
  ; Create gamma par files
  FOR i=0, ndems-1 DO BEGIN
    demname=workpath+basenames[i]+'.hgt'
    TLI_DEMPAR,demname,name=name
  ENDFOR
  ; Repair dems
  CD, workpath
  repairshfile=workpath+'repairdem_temp.sh'
  OPENW, lun, repairshfile,/GET_LUN
  PrintF,lun, '#! /bin/sh'
  FOR i=0, ndems-1 DO BEGIN
    hgtfile=basenames[i]
    PrintF, lun, 'hgtfile='+hgtfile
    PrintF, lun, 'replace_values $hgtfile.hgt 0 1 temp_dem 1201 0 4'
    PrintF, lun, 'replace_values temp_dem -32768 0 temp_dem2 1201 0 4'
    PrintF, lun, 'interp_ad temp_dem2 $hgtfile.dem 1201 16 40 81 2 4'
    PrintF, lun, ''
  ENDFOR
  PrintF, lun, 'rm -f temp_dem temp_dem2 Tianjin.dem Tianjin.dem.par'
  cmd='mosaic'+STRCOMPRESS(LONG(ndems))+' '
  FOR i=0, ndems-1 DO BEGIN
    hgtfile= basenames[i]
    cmd= cmd+hgtfile+'.dem '+hgtfile+'.dem.par '
  ENDFOR
  cmd=cmd+name+'.dem '+name+'.dem.par 1 3'
  PRINTF, lun, cmd
  PrintF, lun, 'disdem_par '+name+'.dem '+name+'.dem.par'
  FREE_LUN, lun
  cmd=repairshfile
  SPAWN,cmd
  Print, 'Main pro finished.'

END