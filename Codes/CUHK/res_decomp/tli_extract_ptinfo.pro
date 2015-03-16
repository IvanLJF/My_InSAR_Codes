;-
;- Extract points' info on the given points.
;- Latitude Longitude x y PS_x PS_y delta_x delta_y - - Write for DAM
;-
;- T.LI @ ISEIS, 20130326

@tli_linear_solve_cuhk.pro
PRO TLI_EXTRACT_PTINFO

  CLOSE,/ALL
  COMPILE_OPT idl2
  
  workpath= '/mnt/backup/ExpGroup/TSX_PS_HK_DAM'
  workpath=workpath+PATH_SEP()
  resultpath=workpath+'/testforCUHK'
  resultpath=resultpath+PATH_SEP()
  basepath=workpath+'base'
  ; Input files
  sarlistfilegamma= workpath+'SLC_tab'
  pdifffile= workpath+'pdiff0'
  pdiff_swapfile= workpath+'pdiff0_swap'
  plistfilegamma= workpath+'pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
  plistfile= resultpath+'plist'
  itabfile= workpath+'itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=resultpath+'arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  pbasefile=resultpath+'pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
  dvddhfile=resultpath+'dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
  vdhfile= resultpath+'vdh'
  sarlistfile= resultpath+'sarlist'
  ptattrfile= resultpath+'ptattr'                          ; 点位信息文件(包含结算过程中所有有用信息)
  plafile= resultpath+'pla'                                ; 点位侧视角文件
  arcs_resfile= resultpath+'arcs_res'                      ; 弧段残差
  res_phasefile= resultpath+'res_phase'                    ; 点位残差
  time_series_linearfile= resultpath+'time_series_linear'  ; 线性形变
  res_phase_slfile= resultpath+'res_phase_sl'              ; 空间滤波结果
  res_phase_tlfile= resultpath+'res_phase_tl'              ; 时间滤波结果
  final_resultfile= resultpath+'final_result'              ; 形变时间序列
  nonlinearfile= resultpath+'nonlinear'                    ; 非线性形变序列
  atmfile= resultpath+'atm'                                ; 大气残差
  time_seriestxtfile= resultpath+'Time_Series.txt'
  dhtxtfile= resultpath+'HeightError.txt'                  ; 最终产品：高程误差
  vtxtfile= resultpath+'Deformation_Rate.txt' ; 最终产品：点位年形变速率
  
  wsdpath=workpath+'WSD_Points'+PATH_SEP()
  coor_file=wsdpath+'Rip-Raps-1D.txt'
  outputfile=FILE_DIRNAME(coor_file)+PATH_SEP()+FILE_BASENAME(coor_file,'.txt')+'_time_series.txt'
  logfile= coor_file+'.log'
  loglun=TLI_OPENLOG(logfile)
  PrintF, loglun, '------------------------------------------------------------------'
  PrintF, loglun, 'Start at time:'+STRJOIN(TLI_TIME())
  
  nintf= FILE_LINES(itabfile)
  roff=17900 ; Offsets of rows
  loff=16040 ; Offsets of lines
  
  coor_dam=TLI_READTXT(coor_file, header_lines=1, header_samples=1)
  
  basefile=file_basename(coor_file,'.txt')
  dim=STRSPLIT(basefile,'-',/EXTRACT)
  dim=dim[N_ELEMENTS(dim)-1]
  IF dim EQ '3D' THEN BEGIN
  ; Change the deformation in the three dimensions to LOS
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  theta=finfo.incidence_angle
  phi=finfo.heading
  theta=DEGREE2RADIUS(theta)
  phi=DEGREE2RADIUS(phi)
  dv=coor_dam[4,*]
  dn=coor_dam[6,*]
  de=coor_dam[5, *]
  d=dv*COS(theta)-dn*SIN(phi)*SIN(Theta)-De*COS(phi)*SIN(theta)
  coor_dam=[coor_dam[0:3, *], (d)]
  ENDIF
  
  coor_geo= coor_dam[2:3, *]
  coor_pxl= coor_dam[0:1, *]
  def_dam= coor_dam[4,*]*1000
  
  
  coor_npt= N_ELEMENTS(coor_pxl)/2
  
  x_pxl= coor_pxl[0, *]-roff-1D ; Please notice here. Zhao let y come first.
  y_pxl= coor_pxl[1, *]-loff-1D
  
  coor_pxl= COMPLEX(x_pxl, y_pxl)
  
  ; Read final_result file
  npt= TLI_PNUMBER(plistfile)
  fresult= TLI_READDATA(final_resultfile, samples=npt,format='DOUBLE') ; Final result
  psc_coor= COMPLEX(fresult[*, 0],fresult[*, 1])
  psc_msk= fresult[*,2]
  ps_ind= WHERE(psc_msk EQ 1)
  ps_coor=psc_coor[ps_ind]
  fresult=fresult[ps_ind,*]
  
  result=DBLARR(8+nintf, coor_npt); Latitude Longitude x y PS_x PS_y delta_x delta_y time_series
  tbase= TBASE_ALL(sarlistfile, itabfile)
  tbase_ind= SORT(tbase)
  tbase=tbase[tbase_ind]
  PS_ind= LONARR(coor_npt)
  
  
  
  FOR i=0, coor_npt-1 DO BEGIN
    ; Locate the point
    this_pxl= coor_pxl[i]
    dis=ABS(ps_coor-this_pxl)
    dis_ind= SORT(dis)
    near_pxl= dis_ind[0]
    PS_i= ps_coor[near_pxl] ; PS index
    PS_ind[i]=near_pxl
    PS_x= REAL_PART(PS_i)
    PS_y= IMAGINARY(PS_i)
    time_series= TRANSPOSE(fresult[near_pxl, 3:*])
    time_series=time_series[tbase_ind]
    result[*, i]=[coor_geo[0,i],coor_geo[1, i], x_pxl[i],y_pxl[i],$
      PS_x, PS_y, PS_x-x_pxl[i], PS_y-y_pxl[i], $
      time_series ]
  ;    PLOT, tbase,time_series, yrange=[-10,10]
  ;    Print, CORRELATE(time_series, tbase)
  ;    wait, .3
  ENDFOR
  IF 0 THEN BEGIN
    fstrarr1= REPLICATE('A8', 4)
    fstrarr2= REPLICATE('A6', 2)
    fstrarr3= REPLICATE('A6', 2)
    fstrarr4= REPLICATE('A6', nintf)
    fstrarr=[fstrarr1, fstrarr2,fstrarr3,fstrarr4]
    sep=',"'+STRING(9B)+'",'
    fstring= '('+STRJOIN(fstrarr,sep)+')'
    
    OPENW, lun, outputfile,/GET_LUN
    temp= TLI_GAMMA_INT(sarlistfile,itabfile,/onlyslave,/date)
    PRINTF, lun, 'Latitude Longitude x y PS_x PS_y delta_x delta_y '+STRJOIN(STRCOMPRESS(temp,/REMOVE_ALL),' ')
    PRINTF, lun, STRCOMPRESS(result,/REMOVE_ALL), format= fstring
    FREE_LUN, lun
  ENDIF
  
  PrintF, loglun, ''
  PrintF, loglun, 'Number of points to analyze:'+STRCOMPRESS(coor_npt)
  PrintF, loglun, ''
  PrintF, loglun, 'Their pxl. coordinates P(x, y):'
  PrintF, loglun, coor_pxl
  PrintF, loglun, ''
  PrintF, loglun, 'Their geo. coordinates (lon., lat.):'
  PrintF, loglun, coor_geo
  PrintF, loglun, ''
  PrintF, loglun, 'Their PS coordinates PS(x, y):'
  PrintF, loglun, result[4:5, *]
  PrintF, loglun, 'Their location error PS(x, y) - P(x, y):'
  PrintF, loglun, result[6:7, *]
  PrintF, loglun, ''
  PrintF, loglun, 'The corresponding index in ptattrfile (with bad points eliminated):'+ptattrfile
  PrintF, loglun, STRJOIN(PS_ind)
  PrintF, loglun, ''
  PrintF, loglun, 'We have to compare the difference during 20081113-20100728'
  l_s=20081113
  l_e=20100728
  m_date=20091114
  l_s_jul=DATE2JULDAT(l_s)
  l_e_jul=DATE2JULDAT(l_e)
  
  vdh=TLI_READMYFILES(vdhfile,type='vdh')
  ; check the PS index & PS coors
  pscoor_vdh=vdh[1:2, PS_ind]
  pscoor_dif= pscoor_vdh-result[4:5]
  IF TOTAL(pscoor_dif) NE 0 THEN Message, 'Error: Coordinates inconsistency!!!'
  
  v=vdh[3,*]
  v_ps=v[PS_ind]/0.8;***********************************************************
  
  PrintF, loglun, 'PS def. vel. :'+STRJOIN(v_ps)
  
  l_ref_ind=0
  l_tbase=TBASE(l_s, l_e)/365D
  l_def_ind=def_dam[l_ref_ind]
  l_v_ind=l_def_ind/l_tbase
  ps_v_ind=v_ps[l_ref_ind]
  v_diff=l_v_ind-ps_v_ind ; The difference
  v_ps_mod=v_ps+v_diff
  ; PS defomation on the start time
  dates=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
  juldays= DATE2JULDAT(dates)
  def_s= TLI_INTERP_DEF(result[8:*,*], juldays, l_s)/0.8;**********************
  def_e= TLI_INTERP_DEF(result[8:*,*], juldays, l_e)/0.8;**********************
  
  PrintF, loglun, ''
  PrintF, loglun, 'We have to choose a reference point: BX1.'
  PrintF, loglun, 'Its info. is: (x, y, lon., lat., def.)'+STRING( coor_dam[*, 0])
  PrintF, loglun, 'Its time lag is (yr):'+STRING(l_tbase)
  PrintF, loglun, 'Its vel. is (mm/yr)'+STRING(l_v_ind)
  PrintF, loglun, ''
  PrintF, loglun, 'Its vel. in PS result is:'+STRING(ps_v_ind)
  PrintF, loglun, 'The difference is:'+STRING(v_diff)
  PrintF, loglun, 'We add the difference to the PS results.'
  PrintF, loglun, '***********************************************************************'
  PrintF, loglun, 'The modified PS def. vel. (mm/yr):'
  PrintF, loglun, STRJOIN(TRANSPOSE(v_ps_mod))
  PrintF, loglun, ''
  PrintF, loglun, 'The leveling result of def. vel. (mm/yr):'
  PrintF, loglun, STRJOIN(def_dam/l_tbase)
  PrintF, loglun, ''
  PrintF, loglun, 'The difference of def. vel. (lel. - PS) (mm/yr):'
  PrintF, loglun, STRING(def_dam/l_tbase-TRANSPOSE(v_ps_mod))
  PrintF, loglun, ''
  PrintF, loglun, 'We check the linear regression results between the two set of data (PS via lel.):'
  result= REGRESS(def_dam/l_tbase, v_ps_mod, sigma=sigma, const=const)
  PrintF, loglun, 'Constant:'+STRING(const)
  PrintF, loglun, 'Coefficient:'+STRING(result)
  PrintF, loglun, 'Standard error:'+STRING(sigma)
  PrintF, loglun, ''
  PrintF, loglun, 'Def. of PS (mm): start at time:'+STRING(l_s)
  PrintF, loglun, def_s
  PrintF, loglun, 'Def. of PS (mm): end at time:'+STRING(l_e)
  PrintF, loglun, def_e
  PrintF, loglun, 'The deformation of the PS pixels (end - start +vdiff) (notmodified) (mm):'
  PrintF, loglun, def_e-def_s
  PrintF, loglun, ''
  PrintF, loglun, 'The deformation of leveling data:'
  PrintF, loglun, def_dam
  PrintF, loglun, ''
  PrintF, loglun, 'The deformation of the PS pixels (referenced to BX1):'
  refer_def=def_e-def_s-(def_e[0]-def_s[0]-def_dam[0])
  PrintF, loglun, refer_def
  PrintF, loglun, 'The deformation error is (lel. - PS) (mm):'
  PrintF, loglun, def_dam-(refer_def)
  PrintF, loglun, ''
  PrintF, loglun, 'RMSE: (mm)'
  PrintF, loglun, SQRT(MEAN((def_dam-refer_def)^2))
  PrintF, loglun, '***********************************************************************'
  
  
  FREE_LUN, loglun
END