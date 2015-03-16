Function DATE2JULDAT, date
  ; Calculate the julian day of input date in the format of yyyymmdd
  year= FLOOR(date/10000D)
  month= FLOOR((date- year*10000) / 100)
  day= date-year*10000-month*100
  result= JULDAY(month, day, year)
  RETURN, result
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
  ;  WINDOW, /FREE &
  ;  TVSCL,CONGRID(gamma, 100,100) ;作图显示
  coh= MAX(gamma, ind)
  ind= IND2XY(ind, dv_iter)
  dv= dv_all(ind[0], ind[1])
  ddh= ddh_all(ind[0], ind[1])
  result= [dv, ddh, coh]
  RETURN, result
END

PRO TLI_LINEAR_SOLVE_CUHK, sarlistfile,pdifffile,plistfile,itabfile,arcsfile,pbasefile,plafile,dvddhfile, $
    wavelength, deltar, R1
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
  c= 299792458D ; Speed light
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
  pbase= TLI_READDATA(pbasefile, samples= npt, format='DOUBLE')
  
  ; Read look angle
  pla= TLI_READDATA(plafile, samples=npt, format='DOUBLE')
  
  ;- dphi for one arc in all the interferograms.
  Print, '* Extracting delta phase for every single arc. Start. *'
  startind= REAL_PART(arcs[2, *])
  endind= IMAGINARY(arcs[2, *])
  startslc= pdiff[startind, *]
  endslc= pdiff[endind, *]
  dphi=ATAN(endslc*CONJ(startslc),/PHASE)   ;end-start [small_ind - greater_ind]
  dphi= TRANSPOSE(dphi)  ; npt*nitab
  
  
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
    la= pla[ref_p]
    sinla= SIN(la)
    
    ; Bperp
    Bperp= pbase[ref_p, *]
    
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
          
          dv_before=result[0]
          ddh_before=result[1]
          coh_before=result[2]
          
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
            
            IF result[2] GE 0.98 THEN BREAK
            IF result[0]-dv_before LE 0.01 AND result[1]-ddh_before LE 0.01 THEN BREAK
            dv_before=result[0]
            ddh_before=result[1]
            coh_before=result[2]
            
          ENDFOR
          ; cal. sigma for PSD
          psd_phi= K1*Bperp*result[1]+K2*Tbase*result[0]
          psd_err= TOTAL((psd_phi-dphi_i)^2)/nintf
          values= [[values], [start_index[i],end_index[i],result, psd_err]]
        END
        'LS': BEGIN
          ;          coefs_v=REPLICATE(K2, 1, nintf);
          coefs_v= (K2*Tbase)
          coefs_dh= K1*Bperp
          coefs=[coefs_v, coefs_dh]
          coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
          result= coefs_n##dphi_i ; dv ddh
          ls_phi= coefs##result
          temp=dphi_i-ls_phi
          ls_coh= ABS(MEAN(e^COMPLEX(0,temp))) ; coherence
          ls_err= SQRT(TOTAL((dphi_i-ls_phi)^2)/nintf) ; sigma
          ;          Print, 'Least square error:', ls_err
          values=[[values], [start_index[i], end_index[i], TRANSPOSE(result), ls_coh, ls_err]]
          
        ;          WINDOW,/FREE & Plot, dphi_i & OPLOT , ls_phi
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