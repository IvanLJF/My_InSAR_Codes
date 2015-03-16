; 
; Find ranges for latitude and longitude for geocoded ave.utm.rmli
;
PRO TLI_GAMMA_LATLON

  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/geocode/'
  demparfile= workpath+'dem_seg.par'
  lookupfile= workpath+'lookup_fine'
  diff_par=workpath+'20091113.diff_par'
  resultfile= workpath+'range.txt'
  
  diffstruct= TLI_LOAD_PAR(diff_par, ':')
  demfstruct= TLI_LOAD_PAR(demparfile,':')
  
  lookup= TLI_READDATA(lookupfile, samples= demfstruct.width, format='FCOMPLEX',/SWAP_ENDIAN)
  sz= SIZE(lookup,/DIMENSIONS)
  IF sz[1] NE demfstruct.nlines THEN BEGIN
    Message, 'Format ERROR!'
  ENDIF
  
  temp=REAL_PART(lookup)
  minx= MIN(temp, max=maxx)
  
  temp= IMAGINARY(lookup)
  miny= MIN(temp, max=maxy)
  Print, minx, maxx, miny,maxy
  
  ; Find 4 edges
  ; left
  


  ; Find 4 points of the original data.
  temp=ABS(lookup - COMPLEX(0, diffstruct.range_samp_1-1))
  temp= MIN(temp, ind)
  ur=TLI_INDEX2COOR(ind, diffstruct.range_samp_1)
  
  temp=ABS(lookup - COMPLEX(1,1))
  temp= MIN(temp, ind)
  ul=TLI_INDEX2COOR(ind, diffstruct.range_samp_1)
  
  temp=ABS(lookup - COMPLEX(0, diffstruct.az_samp_1-1))
  temp= MIN(temp, ind)
  dl=TLI_INDEX2COOR(ind, diffstruct.range_samp_1)
  
  temp=ABS(lookup - COMPLEX(diffstruct.range_samp_1-1,diffstruct.az_samp_1-1))
  temp= MIN(temp, ind)
  dr=TLI_INDEX2COOR(ind, diffstruct.range_samp_1)
  
  Print, ur, ul, dr, dl
  
  ; Calculate the ranges
  ranges=[ur, ul, dr, dl]
  xrange= REAL_PART(ranges)
  yrange= IMAGINARY(ranges)
  xmin= MIN(xrange, max=xmax)
  ymin= MIN(yrange, max=ymax)
  
  minlon= demfstruct.corner_lon+xmin*demfstruct.post_lon
  maxlon= demfstruct.corner_lon+xmax*demfstruct.post_lon
  maxlat= demfstruct.corner_lat-ymin*demfstruct.post_lat
  minlat= demfstruct.corner_lat-ymax*demfstruct.post_lat
  
  OPENW, lun, resultfile,/GET_LUN
  PRINTF, lun, 'min_longitude:'+STRING(minlon)
  PRINTF, lun, 'max_longitude:'+STRING(maxlon)
  PRINTF, lun, 'min_latitude:'+STRING(minlat)
  PRINTF, lun, 'max_latitude:'+STRING(maxlat)
  FREE_LUN, lun
END