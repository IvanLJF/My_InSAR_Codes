PRO TLI_LINEAR_SOLVE, sarlistfile,pdifffile,plistfile,itabfile,arcsfile,pbasefile,dvddhfile
  COMPILE_OPT idl2
  ; Input files:
;  IF (!D.NAME) NE 'WIN' THEN BEGIN
;    sarlistfile= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/sarlist_Linux'
;    pdifffile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pdiff0'
;    plistfile= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
;    itabfile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
;    arcsfile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/arcs'
;    pbasefile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
;    outfile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/dvddh'
;  ENDIF ELSE BEGIN
;    sarlistfile= TLI_DIRW2L(sarlistfile)
;    pdifffile=TLI_DIRW2L(pdifffile)
;    plistfile=TLI_DIRW2L(plistfile)
;    itabfile=TLI_DIRW2L(itabfile)
;    arcsfile=TLI_DIRW2L(arcsfile)
;    pbasefile=TLI_DIRW2L(pbasefile)
;    outfile=TLI_DIRW2L(outfile)
;  ENDELSE
  
  sarlitfile = sarlistfile
  pdifffile  = pdifffile
  plistfile  = plistfile
  itabfile   = itabfile
  arcsfile   = arcsfile
  pbasefile  = pbasefile
  outfile    = dvddhfile
  
  temp= ALOG(2)
  e= 2^(1/temp)
  c= 299792458D ;  light Speed
;  method= 'PSD' ;
  method= 'LS';
  
  ; File info.
  plistinfo= FILE_INFO(plistfile)
  npt= (plistinfo.size)/8
  pdiffinfo= FILE_INFO(pdifffile)
  nintf= (pdiffinfo.size)/npt/8
  
  ; Read sarlist
  nlines= FILE_LINES(sarlistfile)
  sarlist= STRARR(nlines)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  ; Read plist
  plist= COMPLEXARR(npt)
  OPENR, lun, plistfile,/GET_LUN
  READU, lun, plist
  FREE_LUN, lun
  
  ; Read pdiff
  pdiff= COMPLEXARR(npt,nintf)
  OPENR, lun, pdifffile, /GET_LUN,/SWAP_ENDIAN
  READU, lun, pdiff
  FREE_LUN, lun
  
  ; Read itab
  itab= INTARR(4)
  nlines= FILE_LINES(itabfile)
  IF nintf NE nlines THEN Message, 'ERROR! TLI_LINEAR_SOLVE: pdiff0 and itab are inconsistent!'
  Print, '* There are', STRCOMPRESS(nlines), ' interferograms. *'
  OPENR, lun, itabfile,/GET_LUN
  FOR i=0, nlines-1 DO BEGIN
    tmp=''
    READF, lun, tmp
    tmp= STRSPLIT(tmp, ' ',/EXTRACT)
    itab= [[itab], [tmp]]
  ENDFOR
  FREE_LUN, lun
  itab= itab[*, 1:*]
  master_index= itab[0, *]-1
  slave_index= itab[1, *]-1
  master_index= master_index[UNIQ(master_index)]
  IF N_ELEMENTS(master_index) EQ 1 THEN BEGIN
    Print, '* The master image index is:', STRCOMPRESS(master_index), $
    ' Its name is: ', sarlist[master_index], ' *'
  ENDIF ELSE BEGIN
    Print, '* The master image indices are:', STRCOMPRESS(master_index), ' *'
  ENDELSE
  
  ; Calculate temporal baseline for each pair.
  Tbase= TBASE_ALL(sarlistfile,itabfile)
  
  ; Read arcs
  file_structure= FILE_INFO(arcsfile)
  arcs_no=file_structure.size/24
  PRINT, '* There are', STRCOMPRESS(arcs_no),' arcs in the network. *'
  arcs= COMPLEXARR(3, arcs_no)
  OPENR, lun, arcsfile,/GET_LUN
  READU, lun, arcs
  FREE_LUN, lun
  
  ; Read pbase
  pbase= DBLARR(13, nintf)
  OPENR, lun, pbasefile,/GET_LUN,/SWAP_ENDIAN
  READU, lun, pbase
  FREE_LUN, lun
  IF TOTAL(pbase[6:8, *]) EQ 0 THEN BEGIN
    Print, '* Warning: No precision baseline available. *'
    Bperp= pbase[1, *]
  ENDIF ELSE BEGIN
    Bperp= pbase[7, *]
  ENDELSE

  ;- dphi for one arc in all the interferograms.
  Print, '* Extracting delta phase for every single arc. Start. *'
  startind= REAL_PART(arcs[2, *])
  endind= IMAGINARY(arcs[2, *])
  startslc= pdiff[startind, *]
  endslc= pdiff[endind, *]
  dphi=ATAN(endslc*CONJ(startslc),/PHASE)   ;end-start [small_ind - greater_ind]
  dphi= TRANSPOSE(dphi)  ; npt*nitab

  lamda=0.0
  a=0.0
  b=0.0
  R1=0.0
  R2=0.0
  R3=0.0
  alpha1=0.0
  deltar=0.0
  
  earth_radius_below_sensor = 0.0
  sar_to_earth_center =0.0
  radar_frequency= READ_PARAMS(sarlist[master_index[0]]+'.par', 'radar_frequency')
  wavelength = (c) / radar_frequency ;米为单位
  FOR i=0, N_ELEMENTS(master_index)-1 DO BEGIN
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'center_latitude')
;    lamda= [lamda, temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_semi_major_axis')
;    a= [a,temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_semi_minor_axis')
;    b= [b,temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'near_range_slc')
    R1= [R1, temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'incidence_angle')
;    alpha1= [alpha1, temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'range_pixel_spacing')
    deltar= [deltar, temp]
    
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'center_range_slc')
    R2= [R2, temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'far_range_slc')
    R3= [R3, temp]    
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_radius_below_sensor')
    earth_radius_below_sensor= [earth_radius_below_sensor, temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'sar_to_earth_center')
    sar_to_earth_center= [sar_to_earth_center, temp]
  ENDFOR
;  lamda= lamda[1:*] & lamda= DEGREE2RADIUS(lamda)
;  a= a[1:*]
;  b= b[1:*]
  R1= R1[1:*]
  R2= R2[1:*]
  R3= R3[1:*]
  deltar= deltar[1:*]
;  alpha1= alpha1[1:*] & alpha1= DEGREE2RADIUS(alpha1)
  earth_radius_below_sensor= earth_radius_below_sensor[1:*]
  sar_to_earth_center= sar_to_earth_center[1:*]
  IF N_ELEMENTS(lamda) EQ 1 THEN lamda=lamda[0]
  IF N_ELEMENTS(a) EQ 1 THEN a=a[0]
  IF N_ELEMENTS(b) EQ 1 THEN b=b[0]
  IF N_ELEMENTS(R1) EQ 1 THEN R1=R1[0]
  IF N_ELEMENTS(R2) EQ 1 THEN R2=R2[0]
  IF N_ELEMENTS(R3) EQ 1 THEN R3=R3[0]
  IF N_ELEMENTS(deltar) EQ 1 THEN deltar=deltar[0]
  IF N_ELEMENTS(alpha1) EQ 1 THEN alpha1=alpha1[0]
  IF N_ELEMENTS(earth_radius_below_sensor) EQ 1 THEN earth_radius_below_sensor=earth_radius_below_sensor[0]
  IF N_ELEMENTS(sar_to_earth_center) EQ 1 THEN sar_to_earth_center=sar_to_earth_center[0]
  
  ; Calculate RT-- Equal to earth_radius_below_sensor
;  RT= a*SQRT(COS(lamda)^2+(b/a)^4*SIN(lamda)^2)/(SQRT(COS(lamda)^2+(b/a)^2*SIN(lamda)^2))
  ; Calculate RT+H -- Equal to sar_to_earth_center
;  RTH= SQRT(RT^2+R1^2+2*RT*R1*COS(alpha1))
  
  ; Construct equations for each point.
  start_index= REAL_PART(arcs[2, *]) ;弧段起点索引
  end_index= IMAGINARY(arcs[2, *])  ;弧段终点索引
  
  values= DBLARR(6) ;起点索引，终点索引，dv ddh coh sigma
  time_start=SYSTIME(/SECONDS)
  
  OPENW, lun, outfile,/GET_LUN ; Ready to write file
  
  FOR i=0, arcs_no-1 DO BEGIN
    ref_p= start_index[i]
    ref_coor= plist[ref_p]
    ref_x= REAL_PART(ref_coor)
    ; Slant range of ref. p
    ref_r= R1+(ref_x)*deltar
    ; Look angle of ref. p
    cosla= (sar_to_earth_center^2+ref_r^2-earth_radius_below_sensor^2)/(2*sar_to_earth_center*ref_r)
    sinla= SQRT(1-cosla^2)
    
    
    ; Need to be modified.
    IF ~(i MOD 10000) THEN BEGIN
      time_end= SYSTIME(/SECONDS)
      time_consume= (time_end-time_start)/1000D*(arcs_no-1-i)
      h= FLOOR(time_consume/3600L)
      m= FLOOR((time_consume- 3600*h)/60)
      s= time_consume-3600*h-60*m
      Print, 'Calculating linear deformation and hight error for each arc: ',$
            StrCOMPRESS(i), '/', STRCOMPRESS(arcs_no-1);, $
            ;' Time left:', STRCOMPRESS(h), 'h', STRCOMPRESS(m), 'm', STRCOMPRESS(s), 's'
      time_start= SYSTIME(/SECONDS)
    ENDIF
    
    
    
    
    
    
    
    
    ; dphi for the i-th arc (n pairs)
    dphi_i= dphi[*, i]
    
;    K1= 4*(!PI)/(wavelength*Ri[start_index[i]]*sinthetai[start_index[i]]) ;米为单位---对应高程
    K1= -4*(!PI)/(wavelength*ref_r*sinla) ;GX Liu && Lei Zhang均使用這種計算方法 Please be reminded that K1 and K2 are both negative.
    K2= -4*(!PI)/(wavelength*1000) ;毫米为单位---对应形变
    ; If v is negative, then the land surface is subsiding.
    ; Hslave-Hmaster=dh
    
    ;----------开始解空间搜索-------------------
    iter=1
    IF TOTAL(dphi_i) EQ 0 THEN Begin
;      Print, 'Warning! No information on the',STRCOMPRESS(i),' th arc was extracted.'
;      WriteU, lun, values=[[values], [0,0,0]]

;      +result=[0,0,0]
;      values= [[values], [result]]
    ENDIF ELSE BEGIN
      Case method OF
        'PSD': BEGIN
          dv_low= -0.2 ;毫米为单位
          dv_up=0.2
          ddh_low=-20 ;米为单位
          ddh_up=20
          dv_iter=100
          ddh_iter=100
          result= SOL_SPACE_SEARCH(dphi_i, K1, Bperp, K2, Tbase, $
                                   dv_low, dv_up, ddh_low, ddh_up, dv_iter, ddh_iter)
          FOR j=0, iter-1 DO BEGIN                               
            dv_inc= (dv_up-dv_low)/(dv_iter-1D)
            ddh_inc= (ddh_up-ddh_low)/(ddh_iter-1D)
            dv_low= result[0]- dv_inc
            dv_up= result[0]+ dv_inc
            ddh_low= result[1]- ddh_inc
            ddh_up= result[1]+ ddh_inc
            dv_iter=100
            ddh_iter=100
            result= SOL_SPACE_SEARCH(dphi_i, K1, Bperp, K2, Tbase, $
                                     dv_low, dv_up, ddh_low, ddh_up, dv_iter, ddh_iter)
          ENDFOR
          ; cal. sigma for PSD
          psd_phi= K1*Bperp*result[1]+K2*result[0]
          psd_err= TOTAL((psd_phi-dphi_i)^2)/nintf
          values= [[values], [start_index[i],end_index[i],result, psd_err]]
        END
        'LS': BEGIN
          coefs_v=REPLICATE(K2, 1, nintf)
          coefs_dh= K1*Bperp
          coefs=[coefs_v, coefs_dh]
          coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
          result= coefs_n##dphi_i ; dv ddh
          ls_phi= coefs##result
          temp=ls_phi-dphi_i
          ls_coh= ABS(MEAN(e^COMPLEX(0,temp))) ; coherence
          ls_err= TOTAL((dphi_i-ls_phi)^2)/nintf ; sigma
;          Print, 'Least square error:', ls_err
          values=[[values], [start_index[i], end_index[i], TRANSPOSE(result), ls_coh, ls_err]]
        END
      ENDCASE
    ENDELSE
    
    ;- Write File
    IF ~(i MOD 10000) THEN BEGIN
      IF i EQ 0 THEN CONTINUE
      values= values[*, 1:*]
      WriteU, lun, values
      values= DBLARR(6) ;起点索引，终点索引，dv ddh coh sigma
    ENDIF
  ENDFOR
  values=values[*, 1:*]
  WriteU, lun, values
  Free_lun, lun
  
  Print, 'Calculations done successfully!'
  
END