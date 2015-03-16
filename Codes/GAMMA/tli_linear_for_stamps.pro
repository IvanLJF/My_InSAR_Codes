FUNCTION READ_STAMPS_PAR,INFILE_PAR,READ_KW

  COMPILE_OPT idl2
  ON_ERROR, 2 ;- 出错时返回主程序。

  infile_par=infile_par;- 设定要读取的头文件。
  read_kw=read_kw;- 设定要读取的关键字。
  temp='';- 定义空字符串，用来存储要读取的数据。
  kw_line=0;- 定义kw_line，用来存储关键字所在的行数。
  kw_lineinfo='';- 定义kw_lineinfo，用来存储行包含的信息。
  OPENR,lun,infile_par,/get_lun
  nlines=FILE_LINES(infile_par)
  for i=0,nlines-1 do begin
    readf,lun,temp
    kw_column=strpos(temp,read_kw)
    if kw_column gt -1 then begin
      kw_line=[kw_line,i]
      kw_lineinfo=[kw_lineinfo,temp]
    endif
  endfor
  FREE_LUN, lun  
  n= n_elements(kw_line)
  if n eq 1 then Message,'No Such Keyword In SLC Par'
  if n gt 1 then begin
    kw_line=kw_line[1:n-1]
    kw_lineinfo= kw_lineinfo[1:n-1]
    IF n EQ 2 THEN BEGIN ;-对于只有单行单数据的参数，直接返回值
      kw_lineinfo= STRSPLIT(kw_lineinfo, ' ', /EXTRACT)
      IF DOUBLE(read_kw[0]) EQ 0 THEN BEGIN
        kw_lineinfo= kw_lineinfo[2]
      ENDIF ELSE BEGIN
        kw_lineinfo= DOUBLE(kw_lineinfo[1])
      ENDELSE
      RETURN, kw_lineinfo
    ENDIF ELSE BEGIN;- 对于多行或者有多个数据的参数，返回数据行
      RETURN, kw_lineinfo[1:*]
    ENDELSE
  endif

END

PRO TLI_LINEAR_FOR_STAMPS
  COMPILE_OPT idl2
  RESOLVE_ROUTINE, 'TLI_LINEAR_SOLVE'
  
  ; Input files:
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfile= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/sarlist_Linux'
    pdifffile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/pdiff0'
    plistfile= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/plist'
    itabfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/itab'
    arcsfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/pbase'
    outfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/dvddh'
  ENDIF ELSE BEGIN
    sarlistfile= 'D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\sarlist_Win'
    pdifffile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\pdiff0'
    plistfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\plist'
    itabfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\itab'
    arcsfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\arcs'
    pbasefile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\pbase'
    outfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\dvddh'
  ENDELSE
  workpath='F:\ExpGroup\INSAR_20070726_after_mt_prep\PATCH_1'
  pliststafile= workpath+PATH_SEP()+'pscands.1.ij'
  phasefile= workpath+PATH_SEP()+'pscands.1.ph'
  dastafile= workpath+PATH_SEP()+'pscands.1.da'
  
  ; Generate sarlistfile
    path='F:\ExpGroup\INSAR_20070726_after_mt_prep\'
    suffix= '.slc'
    sarlistfile='F:\ExpGroup\INSAR_20070726_after_mt_prep\TestforStaMPS\sarlist_Win'
    sarlist= TLI_SARLIST(path, suffix, outfile=sarlistfile)
  ; Generate plistfile, with DA LE 0.25
    plistfile='F:\ExpGroup\INSAR_20070726_after_mt_prep\TestforStaMPS\plist'
    orignpt=FILE_LINES(pliststafile)
    plist= LONARR(3, orignpt)
    OPENR, lun, pliststafile,/GET_LUN
    READF, lun, plist
    FREE_LUN, lun
    dafile= 'F:\ExpGroup\INSAR_20070726_after_mt_prep\PATCH_1\pscands.1.da'
    da= FLTARR(orignpt)
    OPENR, lun, dafile,/GET_LUN
    READF, lun, da
    FREE_LUN, lun
    dathresh=0.25
    ind= WHERE(da LE 0.25)
    
    plist= COMPLEX(plist[2, ind], plist[1, ind])
    OPENW, lun, plistfile,/GET_LUN
    WriteU, lun, plist
    FREE_LUN, lun
  ; Generate itabfile
    itabfile='F:\ExpGroup\INSAR_20070726_after_mt_prep\TestforStaMPS\itab'
    paramfile='psuedoparam'
    itab= TLI_ITAB(paramfile,sarlistfile,method=2, master=8,output_file=itabfile)
    
  ; Generate pdifffile
    pdifffile='F:\ExpGroup\INSAR_20070726_after_mt_prep\TestforStaMPS\pdiff0'
    finfo= FILE_INFO(phasefile)
    npt= TLI_PNUMBER(plistfile)
    phase= TLI_READDATA(phasefile, samples= orignpt, format='FCOMPLEX')
;    phase= TRANSPOSE(phase); The same to matlab.
    pdiff=phase[ind, *]; All lines
    OPENW, lun, pdifffile,/GET_LUN
    WRITEU, lun, pdiff
    FREE_LUN, lun
    
;    Generate arcs file
    arcsfile= 'F:\ExpGroup\INSAR_20070726_after_mt_prep\TestforStaMPS\arcs'
    range_pixel_spacing= 25
    azimuth_pixel_spacing= 25
    dist_thresh=1000
    result= TLI_DELAUNAY(plistfile,outname= arcsfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
    
;    Generate pbase file
    pbasefile= 'F:\ExpGroup\INSAR_20070726_after_mt_prep\TestforStaMPS\pbase'
    pbasestafile= 'F:\ExpGroup\INSAR_20070726_after_mt_prep\bperp.1.in'
    nintf= FILE_LINES(pbasestafile)
    bperp= DBLARR(1,nintf)
    OPENR, lun, pbasestafile,/GET_LUN
    READF, lun, bperp
    FREE_LUN, lun
    pbase= DBLARR(13, nintf)
    pbase[7, *]=bperp
    OpenW, lun, pbasefile,/GET_LUN
    WRITEU, lun, pbase
    FREE_LUN, lun
    
  
  

;  e= IMSL_CONSTANT('e',/DOUBLE);不能用
;  e= 2.71828
  temp= ALOG(2)
  e= 2^(1/temp)
;  Print, e
  
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
  
  ;;;------------------------------------------------------------????
  ; Read pdiff
  pdiff= COMPLEXARR(npt,nintf)
  OPENR, lun, pdifffile, /GET_LUN
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
  master_index= (master_index[UNIQ(master_index)])
  IF N_ELEMENTS(master_index) EQ 1 THEN BEGIN
    Print, '* The master image index is:', STRCOMPRESS(master_index), $
    ' Its name is: ', sarlist[master_index-1], ' *'
  ENDIF ELSE BEGIN
    Print, '* The master image indices are:', STRCOMPRESS(master_index), ' *'
  ENDELSE
  
  ; Calculate temporal baseline for each pair.
  date=0
  FOR i=0, nlines -1 DO BEGIN
    IF i EQ 7 THEN BEGIN
      temp= FILE_DIRNAME(sarlist[i])
      temp= STRMID(temp,18, 8)
    ENDIF ELSE BEGIN
      temp= FILE_DIRNAME(sarlist[i])
      temp= STRMID(temp, 41, 8)
    ENDELSE
    temp= LONG(temp)
    year= FLOOR(temp/10000D)
    month= FLOOR((temp- year*10000) / 100)
    day= temp-year*10000-month*100
    temp= JULDAY(month, day, year)
    date= [date, temp]
    Print, year, month, day, temp
  ENDFOR
  date= date[1:*]
  Tbase= (date[slave_index]-date[master_index])/365D;时间基线是以年为单位的

  ; Read arcs
  file_structure= FILE_INFO(arcsfile)
  arcs_no=file_structure.size/24
  PRINT, '* There are', STRCOMPRESS(arcs_no),' arcs in the Delaunay triangulation. *'
  arcs= COMPLEXARR(3, arcs_no)
  OPENR, lun, arcsfile,/GET_LUN
  READU, lun, arcs
  FREE_LUN, lun
  
  ; Read pbase
  pbase= DBLARR(13, nintf)
  OPENR, lun, pbasefile,/GET_LUN
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
  dphi=ATAN(endslc*CONJ(startslc),/PHASE)   ;end-start
  dphi= TRANSPOSE(dphi)  ; npt*nitab
;  Print, '* Extracting delta phase for every single arc. Finished. *'
  
  ;- RT and RT+H of center point.
  ;
  ;ATTENTION! incident_angle should be the near range incident angle, not the incident angle of the center point.
  ;We have to check if this is right the value we want.
  ;
  ;Read center latitude(lamda), semi major axis(a), semi minor axis(b), near_range_slc(R1), incidence_angle(alpha1)
  ;     earth_radius_below_sensor, sar_to_earth_center(NOT very necessary.), center_range_slc(R2), far_range_slc(R3)
  
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
;  radar_frequency= READ_PARAMS(sarlist[master_index[0]]+'.par', 'radar_frequency')
  wavelength = 0.056;(3e8) / radar_frequency ;米为单位
;  FOR i=0, N_ELEMENTS(master_index)-1 DO BEGIN
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'center_latitude')
;    lamda= [lamda, temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_semi_major_axis')
;    a= [a,temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_semi_minor_axis')
;    b= [b,temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'near_range_slc')
    R1= 830000;[R1, temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'incidence_angle')
;    alpha1= [alpha1, temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'range_pixel_spacing')
    deltar= 25;[deltar, temp]
    
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'center_range_slc')
    R2= 830000;[R2, temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'far_range_slc')
    R3= 830000;[R3, temp]    
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_radius_below_sensor')
;    earth_radius_below_sensor= [earth_radius_below_sensor, temp]
;    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'sar_to_earth_center')
;    sar_to_earth_center= [sar_to_earth_center, temp]
;  ENDFOR
;  lamda= lamda[1:*] & lamda= DEGREE2RADIUS(lamda)
;  a= a[1:*]
;  b= b[1:*]
;  R1= R1[1:*]
;  R2= R2[1:*]
;  R3= R3[1:*]
;  deltar= deltar[1:*]
;  alpha1= alpha1[1:*] & alpha1= DEGREE2RADIUS(alpha1)
;  earth_radius_below_sensor= earth_radius_below_sensor[1:*]
;  sar_to_earth_center= sar_to_earth_center[1:*]
;  IF N_ELEMENTS(lamda) EQ 1 THEN lamda=lamda[0]
;  IF N_ELEMENTS(a) EQ 1 THEN a=a[0]
;  IF N_ELEMENTS(b) EQ 1 THEN b=b[0]
;  IF N_ELEMENTS(R1) EQ 1 THEN R1=R1[0]
;  IF N_ELEMENTS(R2) EQ 1 THEN R2=R2[0]
;  IF N_ELEMENTS(R3) EQ 1 THEN R3=R3[0]
;  IF N_ELEMENTS(deltar) EQ 1 THEN deltar=deltar[0]
;  IF N_ELEMENTS(alpha1) EQ 1 THEN alpha1=alpha1[0]
;  IF N_ELEMENTS(earth_radius_below_sensor) EQ 1 THEN earth_radius_below_sensor=earth_radius_below_sensor[0]
;  IF N_ELEMENTS(sar_to_earth_center) EQ 1 THEN sar_to_earth_center=sar_to_earth_center[0]
  
  ; Calculate RT-- Equal to earth_radius_below_sensor
;  RT= a*SQRT(COS(lamda)^2+(b/a)^4*SIN(lamda)^2)/(SQRT(COS(lamda)^2+(b/a)^2*SIN(lamda)^2))
  ; Calculate RT+H -- Equal to sar_to_earth_center
;  RTH= SQRT(RT^2+R1^2+2*RT*R1*COS(alpha1))
  
;  Print, 'Error of earth radius below sensor:', TRANSPOSE(STRCOMPRESS(RT-earth_radius_below_sensor))
;  Print, 'Error of sar to earth center:', TRANSPOSE(STRCOMPRESS(RTH-sar_to_earth_center))
;  Print, 'Height of the sattelite:', TRANSPOSE(STRCOMPRESS(RTH-RT))  
;  Print, 'We use GAMMA result as true value to extract incident angle, the error is:'
  incidentfiles= FILE_SEARCH('F:\ExpGroup\INSAR_20070726_after_mt_prep', 'coreg.out', count=fcount)
  incidents= 0D
  FOR i= 0,fcount-1 DO BEGIN
    temp= READ_STAMPS_PAR(incidentfiles[i], 'inc_angle  [deg]')
    incidents=[[incidents], temp]
  ENDFOR
  incidents= incidents[1:*]
  



;  alpha1_GAMMA= ACOS(-(R1^2+RT^2-sar_to_earth_center^2)/(2*R1*RT))
;  Print, (STRCOMPRESS(DEGREE2RADIUS((alpha1-alpha1_GAMMA),/REVERSE)))
;  Print, 'If the incident angle is actually of the center point, here is the error:'
;  alpha1_GAMMA= ACOS(-(R3^2+earth_radius_below_sensor^2-sar_to_earth_center^2)/(2*R3*earth_radius_below_sensor))
;  Print, TRANSPOSE(STRCOMPRESS(DEGREE2RADIUS((alpha1-alpha1_GAMMA),/REVERSE)))
  
;  ; Calculate incident angle for the near range point.
;  costheta1= (R1+RT*COS(alpha1))/(RTH)
;  ; Calculate geocentric angle of the near range point.
;  phi1= alpha1-ACOS(costheta1)
;  ; Calculate geocentric angle of each point.
;  phi= phi1+ DOUBLE(REAL_PART(plist)) * deltar / RT
;  ; Calculate slant range for each point.
;  Ri=SQRT(RT^2+(RTH)^2-2*RT*(RTH)*COS(phi))
;  ; Calculate incident angle for each point.
;  cosalphai=((RTH)^2-Ri^2-RT^2)/(2*Ri*RT)
;  ; Calculate look down angle for each point
;  costhetai=(Ri+RT*cosalphai)/(RTH)
;  sinthetai= SQRT(1-costhetai^2)
  
  ; Construct equations for each point.
  start_index= REAL_PART(arcs[2, *]) ;弧段起点索引
  end_index= IMAGINARY(arcs[2, *])  ;弧段终点索引
  
  values= DBLARR(5) ;起点索引，终点索引，dv ddh corr
  time_start=SYSTIME(/SECONDS)
  FOR i=0, arcs_no-1 DO BEGIN
    IF ~(i MOD 1000) THEN BEGIN
      time_end= SYSTIME(/SECONDS)
      time_consume= (time_end-time_start)/1000D*(arcs_no-1-i)
      h= FLOOR(time_consume/3600L)
      m= FLOOR((time_consume- 3600*h)/60)
      s= time_consume-3600*h-60*m
      Print, 'Calculating linear deformation and hight error for each arc: ',$
            StrCOMPRESS(i), '/', STRCOMPRESS(arcs_no-1), $
            ' Time left:', STRCOMPRESS(h), 'h', STRCOMPRESS(m), 'm', STRCOMPRESS(s), 's'
      time_start= SYSTIME(/SECONDS)
    ENDIF
    ; dphi for the first arc (n pairs)
    dphi_i= dphi[*, i]
;    K1= 4*(!PI)/(wavelength*Ri[start_index[i]]*sinthetai[start_index[i]]) ;米为单位---对应高程
    K1= 4*(!PI)/(wavelength*R2*SIN(DEGREE2RADIUS(22.3))) ;GX Liu && Lei Zhang均使用這種計算方法
    K2= 4*(!PI)/(wavelength*1000) ;毫米为单位---对应形变
    
    ;----------开始解空间搜索-------------------
    
    IF TOTAL(dphi_i) EQ 0 THEN Begin
;      Print, 'Warning! No information on the',STRCOMPRESS(i),' th arc was extracted.'
;      WriteU, lun, values=[[values], [0,0,0]]

;      +result=[0,0,0]
;      values= [[values], [result]]
    ENDIF ELSE BEGIN
      dv_low= -2 ;Relative deformation of arc nodes.  mm/yr
      dv_up=2
      ddh_low=-5 ;Relative hight error of arc nodes. m
      ddh_up=5
      dv_iter=100
      ddh_iter=100
      result= SOL_SPACE_SEARCH(dphi_i, K1, Bperp, K2, Tbase, $
                               dv_low, dv_up, ddh_low, ddh_up, dv_iter, ddh_iter)
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
      values= [[values], [start_index[i],end_index[i],result]]
;      Print, 'The ', STRCOMPRESS(i), 'th arcs was processed successfully!'
;      Print, result
    ENDELSE
  ENDFOR
  values=values[*, 1:*]
  outfile='F:\ExpGroup\INSAR_20070726_after_mt_prep\TestforStaMPS\dvddh'
  OPENW, lun, outfile,/GET_LUN
  WriteU, lun, values
  Free_lun, lun  
  
  Print, 'Main pro finished.'

END