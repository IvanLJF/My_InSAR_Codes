; Print results on the specified points.
;
; Used in my paper HPA
;

PRO TLI_PRT_PT

  COMPILE_OPT idl2
  
  
  ; Points' coordinates (lon. & lat.)
  x=[117.034390D, 117.09286D, 117.063420D]
  y=[39.144972D, 39.151833D, 39.072306D]
  coors=COMPLEX(x,y)
  
  ; Locate the files
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/'
  workpath=workpath+PATH_SEP()
  
  
  
  
  geocodepath=FILE_DIRNAME(workpath)+path_sep()+'geocode'+path_sep()
  
  loglun=TLI_OPENLOG(geocodepath+'log.txt')
  PrintF, loglun, ''
  PrintF, loglun, '****************************************'
  PrintF, loglun, 'Printing the given points information.'
  PrintF, loglun, 'Start at time:'+STRJOIN(TLI_TIME())
  
  
  resultfile=geocodepath+'info_on_points'
  lun=TLI_OPENLOG(resultfile)
  
  files=TLI_HPA_FILES(workpath, level='final')
  
  plistfile=geocodepath+'lel7plist_update_merge'
  final_resultfile=files.final_result
  itabfile=files.itab
  plistfile_geo=geocodepath+'lel7plist_update_merge_GAMMA.pmapll'
  sarlistfile=files.sarlist+'_Linux'
  vdhfile=geocodepath+'lel7vdh_merge'
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  ranges=COMPLEX(finfo.range_samples, finfo.azimuth_lines)
  
  ; Read plistfile_geo
  plist_geo=TLI_READDATA(plistfile_geo, samples=2, format='FCOMPLEX',/swap_endian)
  vdh=TLI_READMYFILES(vdhfile,type='vdh')
  ; Find the indices of the points
  npt_prt=N_ELEMENTS(coors) ; Points to print.
  npt=TLI_PNUMBER(plistfile)
  indices=DBLARR(npt)
  ;  final_result=TLI_READDATA(final_resultfile, samples=npt, format='DOUBLE');/////////////////////////////////
  plist=TLI_READMYFILES(plistfile, type='plist')
  nintf=FILE_LINES(itabfile)
  
  
  fstrarr= REPLICATE('A6', nintf)
  sep=', '
  fstring= '('+STRJOIN(fstrarr,sep)+')'
  
  tb=TBASE_ALL(sarlistfile, itabfile)
  tb_ind=INDGEN(nintf)
  tb_ind_sort=SORT(tb)
  IF TOTAL(tb_ind_sort-tb_ind) NE 0 THEN Message, 'Please check the files.'
  
  names=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
  PrintF, lun, STRJOIN(TRANSPOSE(tb),'')
  PrintF, lun, STRJOIN(names, ' ')
  PrintF, loglun, ''
  PrintF, loglun, STRJOIN(names,' ')
  plist=TLI_READDATA(plistfile, samples=1, format='fcomplex')
  FOR i=0, npt_prt-1 DO BEGIN
    temp=plist_geo-coors[i]
    min_dis=MIN(ABS(temp), ptind)
    indices[i]=ptind
    ; load the time-series def..
    ;    ts=final_result[ptind,3:*];////////////////////////////////////////
    ;    coor_i= COMPLEX(final_result[ptind,0],final_result[ptind,1]);////////////////////////////////////////
    ;    coor_plist_i=plist[ptind];////////////////////////////////////////
    ;    IF coor_i NE coor_plist_i THEN Message, 'Error! Pls check the files.';////////////////////////////////////////
    PrintF, loglun, ''
    PrintF, loglun, 'Point number:'+STRING(i)
    PrintF, loglun, 'Point index:'+STRING(ptind)
    ;    PrintF, loglun, 'Point coor:'+STRING(coor_i);////////////////////////////////////////
    PrintF, loglun, 'Point coor:'+STRING(ranges-plist[ptind]);////////////////////////////////////////
    PrintF, loglun, 'Def. vel. (mm/yr):'+STRING(vdh[3, ptind])
  ;    PrintF, lun, STRCOMPRESS(ts), format=fstring;////////////////////////////////////////
  ENDFOR
  
  PrintF, loglun, 'End at time:'+STRJOIN(TLI_TIME())
  Print, 'Main pro finished.'
  
  FREE_LUN, loglun
  FREE_LUN, lun
  
  IF 0 THEN BEGIN
  
  
  
  
    ; Points' coordinates (lon. & lat.)
    x=[117.034390D, 117.09286D, 117.063420D]
    y=[39.144972D, 39.151833D, 39.072306D]
    coors=COMPLEX(x,y)
    
    ; Locate the files
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA'
    workpath=workpath+PATH_SEP()
    
    resultfile=workpath+'info_on_points'
    OPENW, lun, resultfile,/GET_LUN
    loglun=TLI_OPENLOG(workpath+'log.txt')
    PrintF, loglun, ''
    PrintF, loglun, '****************************************'
    PrintF, loglun, 'Printing the given points information.'
    PrintF, loglun, 'Start at time:'+STRJOIN(TLI_TIME())
    geocodepath=FILE_DIRNAME(workpath)+path_sep()+'geocode'+path_sep()
    files=TLI_HPA_FILES(workpath, level='final')
    plistfile=files.plist
    final_resultfile=files.final_result
    itabfile=files.itab
    plistfile_geo=geocodepath+'plist_merge_all_GAMMA.pmapll'
    sarlistfile=files.sarlist+'_Linux'
    vdhfile=files.vdh
    
    ; Read plistfile_geo
    plist_geo=TLI_READDATA(plistfile_geo, samples=2, format='FCOMPLEX',/swap_endian)
    vdh=TLI_READMYFILES(vdhfile,type='vdh')
    ; Find the indices of the points
    npt_prt=N_ELEMENTS(coors) ; Points to print.
    npt=TLI_PNUMBER(plistfile)
    indices=DBLARR(npt)
    final_result=TLI_READDATA(final_resultfile, samples=npt, format='DOUBLE')
    plist=TLI_READMYFILES(plistfile, type='plist')
    nintf=FILE_LINES(itabfile)
    
    
    fstrarr= REPLICATE('A6', nintf)
    sep=', '
    fstring= '('+STRJOIN(fstrarr,sep)+')'
    
    tb=TBASE_ALL(sarlistfile, itabfile)
    tb_ind=INDGEN(nintf)
    tb_ind_sort=SORT(tb)
    IF TOTAL(tb_ind_sort-tb_ind) NE 0 THEN Message, 'Please check the files.'
    
    names=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
    PrintF, lun, STRJOIN(TRANSPOSE(tb),'')
    PrintF, lun, STRJOIN(names, ' ')
    PrintF, loglun, ''
    PrintF, loglun, STRJOIN(names,' ')
    
    FOR i=0, npt_prt-1 DO BEGIN
      temp=plist_geo-coors[i]
      min_dis=MIN(ABS(temp), ptind)
      indices[i]=ptind
      ; load the time-series def..
      ts=final_result[ptind,3:*]
      coor_i= COMPLEX(final_result[ptind,0],final_result[ptind,1])
      coor_plist_i=plist[ptind]
      IF coor_i NE coor_plist_i THEN Message, 'Error! Pls check the files.'
      PrintF, loglun, ''
      PrintF, loglun, 'Point number:'+STRING(i)
      PrintF, loglun, 'Point index:'+STRING(ptind)
      PrintF, loglun, 'Point coor:'+STRING(range-coor_i)
      PrintF, loglun, 'Def. vel. (mm/yr):'+STRING(vdh[3, ptind])
      PrintF, lun, STRCOMPRESS(ts), format=fstring
    ENDFOR
    
    PrintF, loglun, 'End at time:'+STRJOIN(TLI_TIME())
    Print, 'Main pro finished.'
    
    FREE_LUN, loglun
    FREE_LUN, lun
  ENDIF
END