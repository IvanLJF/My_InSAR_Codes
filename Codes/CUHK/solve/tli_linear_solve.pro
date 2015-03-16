Function IND2XY, ind, samples
  ; 将索引转化成xy
  ; 所有索引均从0开始
  x= (ind MOD samples)
  y= FLOOR(ind/ samples)
  result=[x,y]
  RETURN, result
END

Function SOL_SPACE_SEARCH, deltaphi, K1, Bperp, K2, T, $
    dv_low, dv_up, ddh_low, ddh_up, dv_iter, ddh_iter
  ;- 解空间搜索算法
  ;- 输入(假设输入的干涉对数量为M)：
  ;-    deltaphi   : M维向量。值为弧段终点减去起点的差分相位。坐标索引较大的为起点，较小的为终点。
  ;-    K1     : Bperp的系数。单值。
  ;-    Bperp  : M维向量。垂直基线。
  ;-    K2     : 沉降量的系数。单值。
  ;-    T      : M维向量。时间基线。
  ;-    dv_low : 形变速率搜索起始点。默认-0.2mm/day。
  ;-    dv_up  : 形变速率搜索终止点。默认0.2mm/day。
  ;-    ddh_low: 高程误差搜索起始点。默认-20m。
  ;-    ddh_up : 高程误差搜索终止点。默认20m。
  ;-    dv_iter: 形变速率搜索的迭代次数。
  ;-    ddh_iter:高程误差搜索的迭代次数。
  ;- 返回值：
  ;-    dv     : 满足约束条件的形变速率
  ;-    ddh    : 满足约束条件的高程误差
  ;-    coh    : 满足约束条件的弧段两端点相关系数
  ;-
  dv_inc= (dv_up-dv_low)/(dv_iter-1D)
  ddh_inc= (ddh_up-ddh_low)/(ddh_iter-1D)
  dv_all= dv_low+DINDGEN(dv_iter)*dv_inc
  ddh_all= ddh_low+DINDGEN(ddh_iter)*ddh_inc
  space= INDEXARR(x= dv_all, y= ddh_all)
  dv_all= REAL_PART(space)
  ddh_all= IMAGINARY(space)
  ; 与其做解空间循环，不如做干涉对数目的循环
  nint= N_ELEMENTS(deltaphi)
  gamma= COMPLEXARR(dv_iter,ddh_iter); 每一对(dv, ddh)都有对应的残差
  FOR i=0, nint-1 DO BEGIN
    ;    phi_resi=deltaphi[i]-K1*Bperp[i]*ddh_all-K2*T[i]*dv_all
    coef1=K1*Bperp[i]
    coef2=K2*T[i]
    phi_resi=deltaphi[i]-coef1*ddh_all-coef2*dv_all
    ; 目标函数
    temp= COMPLEX(COS(phi_resi),SIN(phi_resi))
    gamma= gamma+temp
  ENDFOR
  gamma= ABS(gamma/nint)
  ;  TVSCL,CONGRID(gamma, 100,100) ;作图显示
  coh= MAX(gamma, ind)
  ind= IND2XY(ind, dv_iter)
  dv= dv_all(ind[0], ind[1])
  ddh= ddh_all(ind[0], ind[1])
  result= [dv, ddh, coh]
  RETURN, result
END


PRO TLI_LINEAR_SOLVE
  COMPILE_OPT idl2
  ; Input files:
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfile= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/sarlist_Linux'
    pdifffile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/pdiff0'
    plistfile= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/plist'
    itabfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/itab'
    arcsfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/pbase'
    outfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/dvddh'
  ENDIF ELSE BEGIN
    sarlistfile= 'D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\sarlist_Win'
    pdifffile='D:\myfiles\Software\TSX_PS_Tianjin\pdiff0'
    plistfile='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\plist'
    itabfile='D:\myfiles\Software\TSX_PS_Tianjin\itab'
    arcsfile='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\arcs'
    pbasefile='D:\myfiles\Software\TSX_PS_Tianjin\pbase'
    outfile='D:\myfiles\Software\TSX_PS_Tianjin\dvddh'
  ENDELSE
  
  ;  e= IMSL_CONSTANT('e',/DOUBLE);不能用
  ;  e= 2.71828
  temp= ALOG(2)
  e= 2^(1/temp)
  Print, e
  
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
  master_index= itab[0, *]
  slave_index= itab[1, *]
  master_index= UNIQ(master_index[SORT(master_index)])
  IF N_ELEMENTS(master_index) EQ 1 THEN BEGIN
    Print, '* The master image index is:', STRCOMPRESS(master_index), $
      ' Its name is: ', sarlist[master_index-1], ' *'
  ENDIF ELSE BEGIN
    Print, '* The master image indices are:', STRCOMPRESS(master_index), ' *'
  ENDELSE
  
  ; Calculate time baseline for each pair.
  date=0
  FOR i=0, nlines -1 DO BEGIN
    temp= FILE_BASENAME(sarlist[i], '.rslc')
    temp= STRMID(temp, 8, /REVERSE_OFFSET)
    temp= LONG(temp)
    year= FLOOR(temp/10000D)
    month= FLOOR((temp- year*10000) / 100)
    day= temp-year*10000-month*100
    temp= JULDAY(month, day, year)
    date= [date, temp]
    Print, year, month, day, temp
  ENDFOR
  date= date[1:*]
  Tbase= (date[slave_index]-date[master_index])
  
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
  radar_frequency= READ_PARAMS(sarlist[master_index[0]]+'.par', 'radar_frequency')
  wavelength = (3e8) / radar_frequency ;米为单位
  FOR i=0, N_ELEMENTS(master_index)-1 DO BEGIN
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'center_latitude')
    lamda= [lamda, temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_semi_major_axis')
    a= [a,temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_semi_minor_axis')
    b= [b,temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'near_range_slc')
    R1= [R1, temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'incidence_angle')
    alpha1= [alpha1, temp]
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
  lamda= lamda[1:*] & lamda= DEGREE2RADIUS(lamda)
  a= a[1:*]
  b= b[1:*]
  R1= R1[1:*]
  R2= R2[1:*]
  R3= R3[1:*]
  deltar= deltar[1:*]
  alpha1= alpha1[1:*] & alpha1= DEGREE2RADIUS(alpha1)
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
  RT= a*SQRT(COS(lamda)^2+(b/a)^4*SIN(lamda)^2)/(SQRT(COS(lamda)^2+(b/a)^2*SIN(lamda)^2))
  ; Calculate RT+H -- Equal to sar_to_earth_center
  RTH= SQRT(RT^2+R1^2+2*RT*R1*COS(alpha1))
  
  ;  Print, 'Error of earth radius below sensor:', TRANSPOSE(STRCOMPRESS(RT-earth_radius_below_sensor))
  ;  Print, 'Error of sar to earth center:', TRANSPOSE(STRCOMPRESS(RTH-sar_to_earth_center))
  ;  Print, 'Height of the sattelite:', TRANSPOSE(STRCOMPRESS(RTH-RT))
  Print, 'We use GAMMA result as true value to extract incident angle, the error is:'
  alpha1_GAMMA= ACOS(-(R1^2+RT^2-sar_to_earth_center^2)/(2*R1*RT))
  Print, (STRCOMPRESS(DEGREE2RADIUS((alpha1-alpha1_GAMMA),/REVERSE)))
  ;  Print, 'If the incident angle is actually of the center point, here is the error:'
  ;  alpha1_GAMMA= ACOS(-(R3^2+earth_radius_below_sensor^2-sar_to_earth_center^2)/(2*R3*earth_radius_below_sensor))
  ;  Print, TRANSPOSE(STRCOMPRESS(DEGREE2RADIUS((alpha1-alpha1_GAMMA),/REVERSE)))
  
  ; Calculate incident angle for the near range point.
  costheta1= (R1+RT*COS(alpha1))/(RTH)
  ; Calculate geocentric angle of the near range point.
  phi1= alpha1-ACOS(costheta1)
  ; Calculate geocentric angle of each point.
  phi= phi1+ DOUBLE(REAL_PART(plist)) * deltar / RT
  ; Calculate slant range for each point.
  Ri=SQRT(RT^2+(RTH)^2-2*RT*(RTH)*COS(phi))
  ; Calculate incident angle for each point.
  cosalphai=((RTH)^2-Ri^2-RT^2)/(2*Ri*RT)
  ; Calculate look down angle for each point
  costhetai=(Ri+RT*cosalphai)/(RTH)
  sinthetai= SQRT(1-costhetai^2)
  
  ; Construct equations for each point.
  start_index= REAL_PART(arcs[2, *]) ;弧段起点索引
  end_index= IMAGINARY(arcs[2, *])  ;弧段终点索引
  
  values= DBLARR(3)
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
    K1= 4*(!PI)/(wavelength*Ri[start_index[i]]*sinthetai[start_index[i]]) ;米为单位---对应高程
    K2= 4*(!PI)/(wavelength*1000) ;毫米为单位---对应形变
    
    ;----------开始解空间搜索-------------------
    
    IF TOTAL(dphi_i) EQ 0 THEN Begin
    ;      Print, 'Warning! No information on the',STRCOMPRESS(i),' th arc was extracted.'
    ;      WriteU, lun, values=[[values], [0,0,0]]
    ENDIF ELSE BEGIN
      dv_low= -0.2 ;毫米为单位
      dv_up=0.2
      ddh_low=-20 ;米为单位
      ddh_up=20
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
      values= [[values], [result]]
    ;      Print, 'The ', STRCOMPRESS(i), 'th arcs was processed successfully!'
    ;      Print, result
    ENDELSE
  ENDFOR
  values=values[*, 1:*]
  OPENW, lun, outfile,/GET_LUN
  WriteU, lun, values
  Free_lun, lun
  
  Print, 'Test'
  Print, sar_to_earth_center^2
  Print, R3^2+earth_radius_below_sensor^2-2*R3*earth_radius_below_sensor*COS(!PI-alpha1)
  
  Print, 'Main pro finished.'
END
Function IND2XY, ind, samples
  ; 将索引转化成xy
  ; 所有索引均从0开始
  x= (ind MOD samples)
  y= FLOOR(ind/ samples)
  result=[x,y]
  RETURN, result
END

Function SOL_SPACE_SEARCH, deltaphi, K1, Bperp, K2, T, $
    dv_low, dv_up, ddh_low, ddh_up, dv_iter, ddh_iter
  ;- 解空间搜索算法
  ;- 输入(假设输入的干涉对数量为M)：
  ;-    deltaphi   : M维向量。值为弧段终点减去起点的差分相位。坐标索引较大的为起点，较小的为终点。
  ;-    K1     : Bperp的系数。单值。
  ;-    Bperp  : M维向量。垂直基线。
  ;-    K2     : 沉降量的系数。单值。
  ;-    T      : M维向量。时间基线。
  ;-    dv_low : 形变速率搜索起始点。默认-0.2mm/day。
  ;-    dv_up  : 形变速率搜索终止点。默认0.2mm/day。
  ;-    ddh_low: 高程误差搜索起始点。默认-20m。
  ;-    ddh_up : 高程误差搜索终止点。默认20m。
  ;-    dv_iter: 形变速率搜索的迭代次数。
  ;-    ddh_iter:高程误差搜索的迭代次数。
  ;- 返回值：
  ;-    dv     : 满足约束条件的形变速率
  ;-    ddh    : 满足约束条件的高程误差
  ;-    coh    : 满足约束条件的弧段两端点相关系数
  ;-
  dv_inc= (dv_up-dv_low)/(dv_iter-1D)
  ddh_inc= (ddh_up-ddh_low)/(ddh_iter-1D)
  dv_all= dv_low+DINDGEN(dv_iter)*dv_inc
  ddh_all= ddh_low+DINDGEN(ddh_iter)*ddh_inc
  space= INDEXARR(x= dv_all, y= ddh_all)
  dv_all= REAL_PART(space)
  ddh_all= IMAGINARY(space)
  ; 与其做解空间循环，不如做干涉对数目的循环
  nint= N_ELEMENTS(deltaphi)
  gamma= COMPLEXARR(dv_iter,ddh_iter); 每一对(dv, ddh)都有对应的残差
  FOR i=0, nint-1 DO BEGIN
    ;    phi_resi=deltaphi[i]-K1*Bperp[i]*ddh_all-K2*T[i]*dv_all
    coef1=K1*Bperp[i]
    coef2=K2*T[i]
    phi_resi=deltaphi[i]-coef1*ddh_all-coef2*dv_all
    ; 目标函数
    temp= COMPLEX(COS(phi_resi),SIN(phi_resi))
    gamma= gamma+temp
  ENDFOR
  gamma= ABS(gamma/nint)
  ;  TVSCL,CONGRID(gamma, 100,100) ;作图显示
  coh= MAX(gamma, ind)
  ind= IND2XY(ind, dv_iter)
  dv= dv_all(ind[0], ind[1])
  ddh= ddh_all(ind[0], ind[1])
  result= [dv, ddh, coh]
  RETURN, result
END


PRO TLI_LINEAR_SOLVE
  COMPILE_OPT idl2
  ; Input files:
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfile= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/sarlist_Linux'
    pdifffile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/pdiff0'
    plistfile= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/plist'
    itabfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/itab'
    arcsfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/pbase'
    outfile='/mnt/software/myfiles/Software/TSX_PS_Tianjin/dvddh'
  ENDIF ELSE BEGIN
    sarlistfile= 'D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\sarlist_Win'
    pdifffile='D:\myfiles\Software\TSX_PS_Tianjin\pdiff0'
    plistfile='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\plist'
    itabfile='D:\myfiles\Software\TSX_PS_Tianjin\itab'
    arcsfile='D:\myfiles\Software\TSX_PS_Tianjin\testforCUHK\arcs'
    pbasefile='D:\myfiles\Software\TSX_PS_Tianjin\pbase'
    outfile='D:\myfiles\Software\TSX_PS_Tianjin\dvddh'
  ENDELSE
  
  ;  e= IMSL_CONSTANT('e',/DOUBLE);不能用
  ;  e= 2.71828
  temp= ALOG(2)
  e= 2^(1/temp)
  Print, e
  
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
  master_index= itab[0, *]
  slave_index= itab[1, *]
  master_index= UNIQ(master_index[SORT(master_index)])
  IF N_ELEMENTS(master_index) EQ 1 THEN BEGIN
    Print, '* The master image index is:', STRCOMPRESS(master_index), $
      ' Its name is: ', sarlist[master_index-1], ' *'
  ENDIF ELSE BEGIN
    Print, '* The master image indices are:', STRCOMPRESS(master_index), ' *'
  ENDELSE
  
  ; Calculate time baseline for each pair.
  date=0
  FOR i=0, nlines -1 DO BEGIN
    temp= FILE_BASENAME(sarlist[i], '.rslc')
    temp= STRMID(temp, 8, /REVERSE_OFFSET)
    temp= LONG(temp)
    year= FLOOR(temp/10000D)
    month= FLOOR((temp- year*10000) / 100)
    day= temp-year*10000-month*100
    temp= JULDAY(month, day, year)
    date= [date, temp]
    Print, year, month, day, temp
  ENDFOR
  date= date[1:*]
  Tbase= (date[slave_index]-date[master_index])
  
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
  radar_frequency= READ_PARAMS(sarlist[master_index[0]]+'.par', 'radar_frequency')
  wavelength = (3e8) / radar_frequency ;米为单位
  FOR i=0, N_ELEMENTS(master_index)-1 DO BEGIN
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'center_latitude')
    lamda= [lamda, temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_semi_major_axis')
    a= [a,temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'earth_semi_minor_axis')
    b= [b,temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'near_range_slc')
    R1= [R1, temp]
    temp= READ_PARAMS(sarlist[master_index[i]]+'.par', 'incidence_angle')
    alpha1= [alpha1, temp]
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
  lamda= lamda[1:*] & lamda= DEGREE2RADIUS(lamda)
  a= a[1:*]
  b= b[1:*]
  R1= R1[1:*]
  R2= R2[1:*]
  R3= R3[1:*]
  deltar= deltar[1:*]
  alpha1= alpha1[1:*] & alpha1= DEGREE2RADIUS(alpha1)
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
  RT= a*SQRT(COS(lamda)^2+(b/a)^4*SIN(lamda)^2)/(SQRT(COS(lamda)^2+(b/a)^2*SIN(lamda)^2))
  ; Calculate RT+H -- Equal to sar_to_earth_center
  RTH= SQRT(RT^2+R1^2+2*RT*R1*COS(alpha1))
  
  ;  Print, 'Error of earth radius below sensor:', TRANSPOSE(STRCOMPRESS(RT-earth_radius_below_sensor))
  ;  Print, 'Error of sar to earth center:', TRANSPOSE(STRCOMPRESS(RTH-sar_to_earth_center))
  ;  Print, 'Height of the sattelite:', TRANSPOSE(STRCOMPRESS(RTH-RT))
  Print, 'We use GAMMA result as true value to extract incident angle, the error is:'
  alpha1_GAMMA= ACOS(-(R1^2+RT^2-sar_to_earth_center^2)/(2*R1*RT))
  Print, (STRCOMPRESS(DEGREE2RADIUS((alpha1-alpha1_GAMMA),/REVERSE)))
  ;  Print, 'If the incident angle is actually of the center point, here is the error:'
  ;  alpha1_GAMMA= ACOS(-(R3^2+earth_radius_below_sensor^2-sar_to_earth_center^2)/(2*R3*earth_radius_below_sensor))
  ;  Print, TRANSPOSE(STRCOMPRESS(DEGREE2RADIUS((alpha1-alpha1_GAMMA),/REVERSE)))
  
  ; Calculate incident angle for the near range point.
  costheta1= (R1+RT*COS(alpha1))/(RTH)
  ; Calculate geocentric angle of the near range point.
  phi1= alpha1-ACOS(costheta1)
  ; Calculate geocentric angle of each point.
  phi= phi1+ DOUBLE(REAL_PART(plist)) * deltar / RT
  ; Calculate slant range for each point.
  Ri=SQRT(RT^2+(RTH)^2-2*RT*(RTH)*COS(phi))
  ; Calculate incident angle for each point.
  cosalphai=((RTH)^2-Ri^2-RT^2)/(2*Ri*RT)
  ; Calculate look down angle for each point
  costhetai=(Ri+RT*cosalphai)/(RTH)
  sinthetai= SQRT(1-costhetai^2)
  
  ; Construct equations for each point.
  start_index= REAL_PART(arcs[2, *]) ;弧段起点索引
  end_index= IMAGINARY(arcs[2, *])  ;弧段终点索引
  
  values= DBLARR(3)
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
    K1= 4*(!PI)/(wavelength*Ri[start_index[i]]*sinthetai[start_index[i]]) ;米为单位---对应高程
    K2= 4*(!PI)/(wavelength*1000) ;毫米为单位---对应形变
    
    ;----------开始解空间搜索-------------------
    
    IF TOTAL(dphi_i) EQ 0 THEN Begin
    ;      Print, 'Warning! No information on the',STRCOMPRESS(i),' th arc was extracted.'
    ;      WriteU, lun, values=[[values], [0,0,0]]
    ENDIF ELSE BEGIN
      dv_low= -0.2 ;毫米为单位
      dv_up=0.2
      ddh_low=-20 ;米为单位
      ddh_up=20
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
      values= [[values], [result]]
    ;      Print, 'The ', STRCOMPRESS(i), 'th arcs was processed successfully!'
    ;      Print, result
    ENDELSE
  ENDFOR
  values=values[*, 1:*]
  OPENW, lun, outfile,/GET_LUN
  WriteU, lun, values
  Free_lun, lun
  
  Print, 'Test'
  Print, sar_to_earth_center^2
  Print, R3^2+earth_radius_below_sensor^2-2*R3*earth_radius_below_sensor*COS(!PI-alpha1)
  
  Print, 'Main pro finished.'
END