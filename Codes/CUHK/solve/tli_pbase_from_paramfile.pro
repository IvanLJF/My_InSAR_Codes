PRO TLI_PBASE, paramfile, sarlistfile, itabfile, pbasefile=pbasefile

  COMPILE_OPT idl2
  ; Read itab
  nintf= FILE_LINES(itabfile)
  itab= LONARR(4, nintf)
  OPENR, lun, itabfile,/GET_LUN
  READF, lun, itab
  FREE_LUN, lun
  
  ; Read sarlist
  nslc= FILE_LINES(sarlistfile)
  sarlist= STRARR(nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  ; Read paramfile
  ; File names should be in ascending order
  OPENR, lun, paramfile,/GET_LUN
  temp=''
  READF, lun, temp
  temp=''
  READF, lun, temp ; 2 useless lines.
  temp=''
  READF, lun, temp ; Get files' number.
  temp= STRSPLIT(temp, '=',/EXTRACT)
  nslc= LONG(temp[1])
  Print, 'SLCs in parameter file:', STRCOMPRESS(nslc)
  date=0L
  FOR i=0, nslc-1 DO BEGIN
    temp=''
    READF, lun, temp
    temp= STRSPLIT(temp, '-',/EXTRACT)
    sz= N_ELEMENTS(temp)
    IF sz EQ 1 THEN BEGIN
      Message, 'Parameter file is not right. Please ask Mr. Zhao for a right file.'
    ENDIF
    temp= temp[sz-1]
    temp= STRMID(temp, 0, 8)
    date= [date, LONG(temp)]
  ENDFOR
  date= date[1:*]
  
  ind_order= SORT(date)
  IF TOTAL(ind_order- INDGEN(nslc)) NE 0 THEN Message, 'Parameter file is not right. Please ask Mr. Zhao for a right file.'
  
  FOR i=0, nslc-1+6 DO BEGIN
    temp=' '
    READF, lun, temp ; nslc+6 useless lines
  ENDFOR
  
  ; Begin extracting params.
  params= CREATE_STRUCT('useless', LONARR(11), 'useful', DBLARR(12))
  params= REPLICATE(params, nslc*(nslc-1)/2)
  READF, lun, params
  FREE_LUN, lun
  
  ; Begin extracting pbases from params.
  ;1 Interferogram Index
  ;2 Master Index
  ;3 Slave Index
  ;4 Flag
  ;5 Master Date
  ;6 Slave Date
  ;7 Temporal Baseline
  ;8 Spatial Baseline
  ;9 Perpendicular Spatial Baseline
  ;10 Parallel Spatial Baseline
  ;11 Horizontal Spatial Baseline
  ;12 Vertical Spatial Baseline
  ;13 Doppler Centroid Difference
  ;14 Azimuth Spacing
  ;15 Azimuth Resolution
  ;16 Orbital Radius
  ;17 Earth Radius
  master_ind= itab[0, *]
  slave_ind= itab[1, *]
  
  pbase= DBLARR(13, nintf)
  master_ind_p= params.useless[1, *]
  slave_ind_p= params.useless[2, *]
  
  FOR i=0, nintf-1 DO BEGIN
    master_ind_i = master_ind[i]
    slave_ind_i= slave_ind[i]
    ;****************************NOT Right at all!!******************Bperp_M_S is not equal to Bperp_S_M******************
    IF master_ind_i GT slave_ind_i THEN BEGIN
      ind= WHERE(master_ind_p EQ slave_ind[i] AND slave_ind_p EQ master_ind[i])
      IF ind EQ -1 THEN Message, 'Parameter file is not right. Please ask Mr. Zhao for a right file.'
      pbase[[6,7], i]= -params[i].useful[1:2]
    ENDIF ELSE BEGIN
      ind= WHERE(master_ind_p EQ master_ind[i] AND slave_ind_p EQ slave_ind[i])
      IF ind EQ -1 THEN Message, 'Parameter file is not right. Please ask Mr. Zhao for a right file.'
      pbase[[6,7], i]= params[i].useful[1:2]
    ENDELSE
  ENDFOR
  
  IF ~KEYWORD_SET(pbasefile) THEN BEGIN
    workpath= FILE_DIRNAME(itabfile)
    pbasefile= workpath+PATH_SEP()+'/pbase'
  ENDIF
  OPENW, lun, pbasefile,/GET_LUN,/SWAP_ENDIAN
  WRITEU, lun, pbase
  FREE_LUN, lun
END