;-
;- Purpose:
;-     Calculate residual phase for each point.
;-     Linear deformation in format of time_series is witten out simultaniously
;-
; Parameters:
;
; Keywords:
;   ignore_refind        : Set this to 1 to ignore the refind keyword.
;                          ignore_refind = 1 means that the LS adjustment was applied to calculate deformation
;                          information for each PS point.
;
; Written by:
;   T.LI @ CUHK
;
; History:
;   20140611: Add keyword 'ignore_refind'
;
PRO TLI_GET_RESIDUALS, sarlistfile, plistfile, itabfile, pdifffile, pbasefile, plafile,vdhfile,refind, $
    res_phasefile= res_phasefile, time_series_linearfile= time_series_linearfile, $
    R1,rps, wavelength, ignore_refind=ignore_refind,swap_endian=swap_endian
    
    
  ; Input params
  temp= ALOG(2)
  e= 2^(1/temp)
  workpath=FILE_DIRNAME(vdhfile)+PATH_SEP()
  time_series_linearfile=workpath+'time_series_linear'
  
  ; Read sarlistfile
  nslc= FILE_LINES(sarlistfile)
  sarlist= STRARR(1,nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  ; Read plist
  plist= TLI_READDATA(plistfile, samples=1, format='FCOMPLEX')
  
  ; Load itabfile's info
  itab_stru=TLI_READMYFILES(itabfile, type='itab')
  
  nintf_valid=itab_stru.nintf_valid  ; Number of interferograms.
  itab=itab_stru.itab_valid
  
  ; Load file info.
  finfo=TLI_LOAD_MPAR(sarlistfile,itabfile)
  
  master_index= itab[0, *]-1
  slave_index= itab[1, *]-1
  master_index= master_index[UNIQ(master_index)]
  IF N_ELEMENTS(master_index) EQ 1 THEN BEGIN
    Print, '* The master image index is:', STRCOMPRESS(master_index), $
      '. Its name is: ', FILE_BASENAME(sarlist[master_index]), ' *'
  ENDIF ELSE BEGIN
    Print, '* The master image indices are:', STRJOIN(STRCOMPRESS(master_index),'/'), ' *'
  ENDELSE
  
  ; Load plistfile's info
  npt= TLI_PNUMBER(plistfile); Number of points.
  
  IF NOT KEYWORD_SET(ignore_refind) THEN BEGIN
    ; Check params
    IF refind EQ 0 OR refind EQ npt-1 THEN BEGIN
      MESSAGE, 'Error: We do not believe it is robust to set refind as: ', STRCOMPRESS(refind)
    ENDIF
  ENDIF
  ; Load pdifffile
  pdiff= TLI_READDATA(pdifffile, samples=npt, format='FCOMPLEX',swap_endian=swap_endian)
  sz=SIZE(pdiff,/DIMENSIONS)
  nintf=sz[1]
  IF nintf NE itab_stru.nintf AND nintf NE itab_stru.nintf_valid THEN $
    Message, 'Error! File not consistent. No of intf. in diff is'+STRCOMPRESS(nintf)+'.'
    
  ; Load pbasefile
  pbase= TLI_READDATA(pbasefile, samples= npt, format='DOUBLE')
  
  ; Load vdhfile
  vdh= TLI_READDATA(vdhfile,samples=5, format='DOUBLE')
  npt_arcs= (SIZE(vdh,/DIMENSIONS))[1]
  
  IF NOT KEYWORD_SET(ignore_refind) THEN BEGIN
    ; Differential phase referred to the refind
    refphase= pdiff[refind, *]  ; Phase difference between points and refind.
    pdiff_refind= pdiff*CONGRID(CONJ(refphase), npt, nintf); pdiff - refind*********refrence point included.**********
    pdiff_refind= ATAN(pdiff_refind,/PHASE)                ; phase
    
    ; Calculate dvddh related phase
    
    ref_coor= plist[refind]
    ref_coor= ref_coor[0]
    ref_x= REAL_PART(ref_coor)
    ; Slant range of ref. p
    ref_r= R1+(ref_x)*rps
    ; Look angle of ref. p
    pla= TLI_READDATA(plafile,samples=1, format='DOUBLE')
    la= pla[refind]
    sinla= SIN(la)
    K1= -4*(!PI)/(wavelength*ref_r*sinla) ;GX Liu && Lei Zhang均使用這種計算方法 Please be reminded that K1 and K2 are both negative.
    K2= -4*(!PI)/(wavelength*1000) ;毫米为单位---对应形变
    
    ; Load pbasefile
    Bt= TBASE_ALL(sarlistfile, itabfile)
    
    Bperp= pbase[refind, *]
    
    refind=refind[0]
    refind_ind= WHERE(vdh[0, *] EQ refind)
    ref_v= (vdh[3, refind_ind])[0]
    ref_dh= (vdh[4, refind_ind])[0]
    
    ; Atmospheric phase
    res_phase= DBLARR(npt, nintf+3) ; itab+3 means there is  x line,  y line,and a mask line.
    res_phase[*, 0:1]= TRANSPOSE([REAL_PART(plist), IMAGINARY(plist)])
    time_series_linear = res_phase
    FOR i=0D, npt_arcs-1D DO BEGIN
      IF ~(i MOD 1000) THEN BEGIN
        Print,i, '/', STRCOMPRESS(npt_arcs-1)
      ENDIF
      
      pt_ind= vdh[0, i] ; Point index
      pt_phase= pdiff_refind[pt_ind, *]
      pt_dv= (vdh[3, i]-ref_v)[0]
      pt_ddh= (vdh[4, i]-ref_dh)[0]
      K1=K1[0]
      res= TRANSPOSE(pt_phase-(K1*Bperp*pt_ddh+K2*Bt*pt_dv))
      
      ;    IF TOTAL(res) EQ 0 THEN STOP
      
      res_phase[pt_ind, 2:*]= [1D, res]
      
    ENDFOR
    
    v_all= DBLARR(npt)
    v_ind= TRANSPOSE(vdh[0, *])
    v_all[v_ind] = vdh[3, *]
    
    time_series_linear[v_ind, 2]=1  ; Update index
    time_series_linear[*,3:*]= TRANSPOSE(BT) ## v_all ; Update value
    
    OPENW, lun, res_phasefile,/GET_LUN
    WRITEU, lun, res_phase
    FREE_LUN, lun
    
    OPENW, lun, time_series_linearfile,/GET_LUN
    WRITEU, lun, time_series_linear
    FREE_LUN, lun
    
  ENDIF ELSE BEGIN
  
    pdiff_refind= ATAN(pdiff,/PHASE)                ; phase
    
    ; Calculate dvddh related phase
    
    ref_x= REAL_PART(plist)
    ; Slant range of ref. p
    R1=finfo.near_range_slc
    rps=finfo.range_pixel_spacing
    wavelength=TLI_C()/finfo.radar_frequency
    ref_r= R1+(ref_x)*rps
    ; Look angle of ref. p
    la= TLI_READDATA(plafile,samples=1, format='DOUBLE')
    sinla= SIN(la)
    K1= -4*(!PI)/(wavelength*ref_r*sinla) ;GX Liu && Lei Zhang均使用這種計算方法 Please be reminded that K1 and K2 are both negative.
    K2= -4*(!PI)/(wavelength*1000) ;毫米为单位---对应形变
    
    ; Load pbasefile
    Bt= TBASE_ALL(sarlistfile, itabfile,/ignore_mask)
    
    ; Bperp= pbase[refind, *]
    
    
    
    
    
    
    
    ; Atmospheric phase
    res_phase= DBLARR(npt, nintf+3) ; itab+3 means there is a x line, a y line,and a mask line.
    res_phase[*, 0:1]= TRANSPOSE([REAL_PART(plist), IMAGINARY(plist)])
    time_series_linear = res_phase
    FOR i=0D, npt_arcs-1D DO BEGIN
      IF ~(i MOD 1000) THEN BEGIN
        Print,i, '/', STRCOMPRESS(npt_arcs-1)
      ENDIF
      
      pt_ind= vdh[0, i] ; Point index
      pt_phase= pdiff_refind[pt_ind, *]
      pt_v= (vdh[3, i])[0]
      pt_dh= (vdh[4, i])[0]
      K1_ind=K1[pt_ind]
      Bperp=pbase[pt_ind, *]
      res= (pt_phase-(K1_ind*Bperp*pt_dh+K2*Bt*pt_v))
      
      ;    IF TOTAL(res) EQ 0 THEN STOP
      
      res_phase[pt_ind, 2:*]= [[1D], [res]]
      
    ENDFOR
    
    v_all= DBLARR(npt)
    v_ind= TRANSPOSE(vdh[0, *])
    v_all[v_ind] = vdh[3, *]
    
    time_series_linear[v_ind, 2]=1  ; Update index
    time_series_linear[*,3:*]= TRANSPOSE(BT) ## v_all ; Update value
    
    OPENW, lun, res_phasefile,/GET_LUN
    WRITEU, lun, res_phase
    FREE_LUN, lun
    
    OPENW, lun, time_series_linearfile,/GET_LUN
    WRITEU, lun, time_series_linear
    FREE_LUN, lun
    
    
    
  ENDELSE
  
END