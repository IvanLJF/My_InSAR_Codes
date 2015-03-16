;-
;- Remove the borders of geocoded image.
;-
;- You can do the same thing in Linux by using GNU.
;-

PRO TLI_REMOVE_BORDER

  COMPILE_OPT idl2
  CLOSE,/all
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_SH/geocode'
  
  workpath=workpath+PATH_SEP()
  
  resultpath=workpath+'noborder'+path_sep()
  logfile=workpath+'log.txt'
  demparfile= workpath+'dem_seg.par'
  lookupfile= workpath+'lookup_fine'
  diff_par=workpath+'20091113.diff_par'
  avefile=workpath+'ave.utm.rmli'
  
  
  IF FILE_TEST(logfile) THEN BEGIN
    OPENW, loglun, logfile,/GET_LUN,/APPEND
  ENDIF ELSE BEGIN
    OPENW, loglun, logfile,/GET_LUN
  ENDELSE
  PrintF,loglun, '*********************************************'
  PrintF, loglun, 'Start at time:'+STRJOIN(TLI_TIME())
  
  IF NOT FILE_TEST(resultpath,/DIRECTORY) THEN BEGIN
    FILE_MKDIR, resultpath
  ENDIF
  
  ; Check the real range of the lookup table in the image. Not mecessary.
  demfstruct= TLI_LOAD_PAR(demparfile,':')
  
  ; Calculate the ranges of image. With borders.
  PrintF, loglun, ''
  PrintF, loglun, 'Original ranges of image:'
  PrintF, loglun, 'x & y ranges of image [min_x, max_x, min_y, max_y]'
  PrintF, loglun, 'ranges_with_borders:'+STRING(0)+string(demfstruct.width-1) $
    +string(0)+string(demfstruct.nlines-1)
  xmin=0
  xmax=demfstruct.width-1
  ymin=0
  ymax=demfstruct.nlines-1
  
  minlon= demfstruct.corner_lon+xmin*demfstruct.post_lon
  maxlon= demfstruct.corner_lon+xmax*demfstruct.post_lon
  minlat= demfstruct.corner_lat+ymin*demfstruct.post_lat
  maxlat= demfstruct.corner_lat+ymax*demfstruct.post_lat
  PrintF, loglun, 'Image ranges in lat. & lon. (with borders)'
  PRINTF, loglun, 'min_longitude_borders:'+STRING(minlon)
  PRINTF, loglun, 'max_longitude_borders:'+STRING(maxlon)
  PRINTF, loglun, 'min_latitude_borders:'+STRING(maxlat)
  PRINTF, loglun, 'max_latitude_borders:'+STRING(minlat)
  
  ; Check the real corners of the image. No borders. Start from 0
  PrintF, loglun, '----------------------------------------------------------------'
  ave=TLI_READDATA(avefile, samples= demfstruct.width, format='FLOAT',/SWAP_ENDIAN)
  temp=TOTAL(ave, 2)
  ind=WHERE(temp NE 0)
  minx=MIN(ind, max=maxx)
  
  temp=TOTAL(ave, 1)
  ind=WHERE(temp NE 0)
  miny=MIN(ind, max=maxy)
  ranges=[minx, maxx, miny, maxy]
  PrintF, loglun, 'x & y ranges of image [min_x, max_x, min_y, max_y]'
  PrintF, loglun, 'ranges_no_border:'+STRJOIN(ranges)
  
  xmin=minx
  xmax=maxx
  ymin=miny
  ymax=maxy
  
  minlon= demfstruct.corner_lon+xmin*demfstruct.post_lon
  maxlon= demfstruct.corner_lon+xmax*demfstruct.post_lon
  minlat= demfstruct.corner_lat+ymin*demfstruct.post_lat
  maxlat= demfstruct.corner_lat+ymax*demfstruct.post_lat
  PrintF, loglun, 'Image ranges in lat. & lon. (no borders)'
  PRINTF, loglun, 'min_longitude_noborder:'+STRING(minlon)
  PRINTF, loglun, 'max_longitude_noborder:'+STRING(maxlon)
  PRINTF, loglun, 'min_latitude_noborder:'+STRING(maxlat)
  PRINTF, loglun, 'max_latitude_noborder:'+STRING(minlat)
  
  ; Calculate the coordinates for the four corners.
  PrintF, loglun, ''
  PrintF, loglun, 'Corner coordinates'
  
  temp=ave[*, ymax]
  ymax_x=WHERE(temp NE 0)
  ymax_lon=demfstruct.corner_lon+ymax_x*demfstruct.post_lon
  PrintF, loglun, 'UL_coner:'+STRING(ymax_lon)+STRING(maxlat)
  
  temp=ave[*, ymin]
  ymin_x=WHERE(temp NE 0)
  ymin_lon=demfstruct.corner_lon+ymin_x*demfstruct.post_lon
  PrintF, loglun, 'DR_coner:'+STRING(ymin_lon)+STRING(minlat)
  
  temp=ave[xmin, *]
  xmin_y=WHERE(temp NE 0)
  xmin_lat=demfstruct.corner_lat+xmin_y*demfstruct.post_lat
  PrintF, loglun, 'DL_coner:'+STRING(minlon)+STRING(xmin_lat)
  
  temp=ave[xmax, *]
  xmax_y=WHERE(temp NE 0)
  xmax_lat=demfstruct.corner_lat+xmax_y*demfstruct.post_lat
  PrintF, loglun, 'UR_coner:'+STRING(maxlon)+STRING(xmax_lat)
  
  
  ; Cut the image
  IF 0 THEN BEGIN
    ave=ave[minx:maxx, miny:maxy]
    ;  ind=WHERE(ABS(ave) LT 5 )
    ;  ave[ind]=0
    Print, 'Filtering: start...'
    ave=MEDIAN(ave,5)
    Print, 'Filtering: end.'
    avefile_noborder=resultpath+'ave.pwr'
    OPENW, lun, avefile_noborder,/GET_LUN,/swap_endian
    WRITEU, lun, ave
    FREE_LUN, lun
    
    OPENW, lun, avefile_noborder+'.par',/GET_LUN
    PrintF, lun, 'range_samples:'+STRING(maxx-minx+1)
    PrintF, lun, 'azimuth_lines:'+STRING(maxy-miny+1)
    PrintF, lun, 'lat_start:'+STRING(minlat)
    PrintF, lun, 'lat_end:'+STRING(maxlat)
    PrintF, lun, 'lon_start:'+STRING(minlon)
    PrintF, lun, 'lon_end:'+STRING(maxlon)
    FREE_LUN, lun
  ENDIF
  FREE_LUN, loglun
  
  STOP
END




;
;;-
;;- Remove the borders of geocoded image.
;;-
;;- The wrong version
;;- Main error occurs from where the lookup table coordinates is introduced.
;;-
;
;PRO TLI_REMOVE_BORDER_WRONG
;
;  COMPILE_OPT idl2
;  CLOSE,/all
;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/geocode'
;
;  workpath=workpath+PATH_SEP()
;
;  resultpath=workpath+'noborder'+path_sep()
;  logfile=workpath+'log.txt'
;  demparfile= workpath+'dem_seg.par'
;  lookupfile= workpath+'lookup_fine'
;  diff_par=workpath+'20091113.diff_par'
;  avefile=workpath+'ave.utm.rmli'
;
;
;  IF FILE_TEST(logfile) THEN BEGIN
;    OPENW, loglun, logfile,/GET_LUN,/APPEND
;  ENDIF ELSE BEGIN
;    OPENW, loglun, logfile,/GET_LUN
;  ENDELSE
;  PrintF,loglun, '*********************************************'
;  PrintF, loglun, 'Start at time:'+STRJOIN(TLI_TIME())
;
;  IF NOT FILE_TEST(resultpath,/DIRECTORY) THEN BEGIN
;    FILE_MKDIR, resultpath
;  ENDIF
;
;
;  ; Check the real range of the lookup table in the image. Not mecessary.
;  diffstruct= TLI_LOAD_PAR(diff_par, ':')
;  demfstruct= TLI_LOAD_PAR(demparfile,':')
;
;  lookup= TLI_READDATA(lookupfile, samples= demfstruct.width, format='FCOMPLEX',/SWAP_ENDIAN)
;  sz= SIZE(lookup,/DIMENSIONS)
;  IF sz[1] NE demfstruct.nlines THEN BEGIN
;    Message, 'Format ERROR!'
;  ENDIF
;  IF 0 THEN BEGIN
;    temp=REAL_PART(lookup)
;    minx= MIN(temp, max=maxx)
;
;    temp= IMAGINARY(lookup)
;    miny= MIN(temp, max=maxy)
;    PrintF,loglun,  'Ranges of lookup table: [minx, maxx, miny, maxy]'
;    PrintF,loglun,  minx, maxx, miny,maxy
;  ENDIF
;
;  ; Calculate the ranges of image. With borders.
;  PrintF, loglun, ''
;  PrintF, loglun, 'Original ranges of image:'
;  PrintF, loglun, 'x & y ranges of image [min_x, max_x, min_y, max_y]'
;  PrintF, loglun, 'ranges_with_borders:'+STRING(0)+string(diffstruct.range_samp_1-1) $
;    +string(0)+string(diffstruct.az_samp_1-1)
;  minx=1
;  maxx=diffstruct.range_samp_1-1
;  miny=1
;  maxy=diffstruct.az_samp_1-1
;  corners=[COMPLEX(minx, maxy), $
;    COMPLEX(minx, miny), $
;    COMPLEX(maxx, maxy), $
;    COMPLEX(maxx, miny)]  ;UL,UR,DL,DR;
;
;  temp=ABS(lookup - corners[0])
;  temp= MIN(temp, ind)
;  ul=TLI_INDEX2COOR(ind, demfstruct.width)
;
;  temp=ABS(lookup - corners[1])
;  temp= MIN(temp, ind)
;  ur=TLI_INDEX2COOR(ind, demfstruct.width)
;
;  temp=ABS(lookup - corners[2])
;  temp= MIN(temp, ind)
;  dl=TLI_INDEX2COOR(ind, demfstruct.width)
;
;  temp=ABS(lookup - corners[3])
;  temp= MIN(temp, ind)
;  dr=TLI_INDEX2COOR(ind, demfstruct.width)
;
;  Print, ur, ul, dr, dl
;  PrintF, loglun, ''
;  PrintF, loglun, 'Image corners in lookup coordinates (with borders)'
;  PrintF, loglun, 'ul_img_borders: '+STRING(ul)
;  PrintF, loglun, 'ur_img_borders: '+STRING(ur)
;  PrintF, loglun, 'dl_img_borders: '+string(dl)
;  PrintF, loglun, 'dr_img_borders: '+string(dr)
;  PrintF, loglun, ''
;
;  ; Calculate the real ranges of image in lat. & lon. No borders.
;  ranges=[ur, ul, dr, dl]
;  xrange= REAL_PART(ranges)
;  yrange= IMAGINARY(ranges)
;  xmin= MIN(xrange, max=xmax)
;  ymin= MIN(yrange, max=ymax)
;
;  minlon= demfstruct.corner_lon+xmin*demfstruct.post_lon
;  maxlon= demfstruct.corner_lon+xmax*demfstruct.post_lon
;  minlat= demfstruct.corner_lat-ymin*demfstruct.post_lat
;  maxlat= demfstruct.corner_lat-ymax*demfstruct.post_lat
;
;  PrintF, loglun, 'Image ranges in lat. & lon. (with borders)'
;  PRINTF, loglun, 'min_longitude_borders:'+STRING(minlon)
;  PRINTF, loglun, 'max_longitude_borders:'+STRING(maxlon)
;  PRINTF, loglun, 'min_latitude_borders:'+STRING(minlat)
;  PRINTF, loglun, 'max_latitude_borders:'+STRING(maxlat)
;
;
;
;  ; Check the real corners of the image. No borders. Start from 0
;  PrintF, loglun, '----------------------------------------------------------------'
;  ave=TLI_READDATA(avefile, samples= demfstruct.width, format='FLOAT',/SWAP_ENDIAN)
;  temp=TOTAL(ave, 2)
;  ind=WHERE(temp NE 0)
;  minx=MIN(ind, max=maxx)
;
;  temp=TOTAL(ave, 1)
;  ind=WHERE(temp NE 0)
;  miny=MIN(ind, max=maxy)
;  ranges=[minx, maxx, miny, maxy]
;  PrintF, loglun, 'x & y ranges of image [min_x, max_x, min_y, max_y]'
;  PrintF, loglun, 'ranges_no_border:'+STRJOIN(ranges)
;
;  ; Locate the corners in the lookup table.
;  ;  define the ranges to be detect
;  corners=[COMPLEX(minx, maxy), $
;    COMPLEX(minx, miny), $
;    COMPLEX(maxx, maxy), $
;    COMPLEX(maxx, miny)]  ;UL,UR,DL,DR;
;
;  temp=ABS(lookup - corners[0])
;  temp= MIN(temp, ind)
;  ul=TLI_INDEX2COOR(ind, demfstruct.width)
;
;  temp=ABS(lookup - corners[1])
;  temp= MIN(temp, ind)
;  ur=TLI_INDEX2COOR(ind, demfstruct.width)
;
;  temp=ABS(lookup - corners[2])
;  temp= MIN(temp, ind)
;  dl=TLI_INDEX2COOR(ind, demfstruct.width)
;
;  temp=ABS(lookup - corners[3])
;  temp= MIN(temp, ind)
;  dr=TLI_INDEX2COOR(ind, demfstruct.width)
;
;  Print, ur, ul, dr, dl
;  PrintF, loglun, ''
;  PrintF, loglun, 'Image corners in lookup coordinates'
;  PrintF, loglun, 'ul_img:'+STRING(ul)
;  PrintF, loglun, 'ur_img:'+STRING(ur)
;  PrintF, loglun, 'dl_img:'+string(dl)
;  PrintF, loglun, 'dr_img:'+string(dr)
;  PrintF, loglun, ''
;
;  ; Calculate the real ranges of image in lat. & lon. No borders.
;  ranges=[ur, ul, dr, dl]
;  xrange= REAL_PART(ranges)
;  yrange= IMAGINARY(ranges)
;  xmin= MIN(xrange, max=xmax)
;  ymin= MIN(yrange, max=ymax)
;
;  minlon= demfstruct.corner_lon+xmin*demfstruct.post_lon
;  maxlon= demfstruct.corner_lon+xmax*demfstruct.post_lon
;  minlat= demfstruct.corner_lat-ymin*demfstruct.post_lat
;  maxlat= demfstruct.corner_lat-ymax*demfstruct.post_lat
;
;  PrintF, loglun, 'Image ranges in lat. & lon. (no border)'
;  PRINTF, loglun, 'min_longitude:'+STRING(minlon)
;  PRINTF, loglun, 'max_longitude:'+STRING(maxlon)
;  PRINTF, loglun, 'min_latitude:'+STRING(minlat)
;  PRINTF, loglun, 'max_latitude:'+STRING(maxlat)
;
;  ; Cut the image
;  ave=ave[minx:maxx, miny:maxy]
;;  ind=WHERE(ABS(ave) LT 5 )
;;  ave[ind]=0
;
;  ave=MEDIAN(ave,9)
;  avefile_noborder=resultpath+'ave.pwr'
;  OPENW, lun, avefile_noborder,/GET_LUN,/swap_endian
;  WRITEU, lun, ave
;  FREE_LUN, lun
;  OPENW, lun, avefile_noborder+'.par',/GET_LUN
;  PrintF, lun, 'range_samples:'+STRING(maxx-minx+1)
;  PrintF, lun, 'azimuth_lines:'+STRING(maxy-miny+1)
;  PrintF, lun, 'lat_start:'+STRING(minlat)
;  PrintF, lun, 'lat_end:'+STRING(maxlat)
;  PrintF, lun, 'lon_start:'+STRING(minlon)
;  PrintF, lun, 'lon_end:'+STRING(maxlon)
;  FREE_LUN, lun
;
;  FREE_LUN, loglun
;
;END