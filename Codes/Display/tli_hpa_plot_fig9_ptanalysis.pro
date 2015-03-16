;-
;- Fig. 9
;- Validation of HPA using leveling data.
;-
@tbase_all.pro
PRO TLI_HPA_PTANALYSIS

  COMPILE_OPT idl2
  CLOSE,/ALL
  workpath='D:\myfiles\Software\experiment\TSX_PS_Tianjin'
  workpath=workpath+PATH_SEP()
  
  xq14_ind=111753
  xq07_ind=323397
  ht02_ind=222424
  pt_ind=[ht02_ind,xq14_ind, xq07_ind ]
  
  itabfile=workpath+'itab'
  
  hpapath=workpath+'HPA'+PATH_SEP()
  files=TLI_HPA_FILES(hpapath,level='final')
  plistfile=files.plist & npt=TLI_PNUMBER(plistfile)
  vdhfile=files.vdh
  vdh=TLI_READMYFILES(vdhfile, type='vdh')
  sarlistfile=files.sarlist+'_WIN'
  tslfile=files.time_series_linear ; Time series linear deformation
  logfile=hpapath+'log.txt'
  loglun=TLI_OPENLOG(logfile)
  PrintF, loglun, ''
  PrintF, loglun, '*************************************************'
  PrintF, loglun, 'HPA validation using leveling data.'
  PrintF, loglun, 'Start at time:'+STRJOIN(TLI_TIME())
  PrintF, loglun, ''
  
  ; Read the results provided by TLI_PRT_PT.PRO
  infofile=hpapath+'info_on_points'
  info=TLI_READTXT(infofile)
  
  tb=info[*,0]
  tname=info[*,1]
  ptinfo=info[*,2:*]
  XQ14=ptinfo[*,0]
  XQ07=ptinfo[*,1]
  HT02=ptinfo[*,2]
  tsl=TLI_READDATA(tslfile, samples=npt, format='DOUBLE')
  xq14_tsl=tsl[xq14_ind, 3:*]
  xq14_nl=(xq14-xq14_tsl)
  xq14=xq14_tsl-xq14_nl
  
  ; XQ14 XQ07 HT02
  ;  pt_leveling=[72.53D, 29.29D,36.69D ]; Guozi's modified results.
  pt_leveling=[-33.43D, -13.08D, -16.82D]; Original data.
  pt_l_start=20090926
  pt_l_end=20101024
  master_date=20091113
  pt_l_start_tb=tbase(master_date, pt_l_start)
  pt_l_end_tb=tbase(master_date, pt_l_end)
  XQ14_l=pt_leveling[0]
  XQ07_l=pt_leveling[1]
  HT02_l=pt_leveling[2]
  HT02_l_v=HT02_l/(pt_l_end_tb-pt_l_start_tb)*365D
  XQ14_l_v=XQ14_l/(pt_l_end_tb-pt_l_start_tb)*365D
  XQ07_l_v=XQ07_l/(pt_l_end_tb-pt_l_start_tb)*365D
  l_v=[HT02_l_v, xq14_l_v, xq07_l_v]
  PrintF, loglun, 'Ref. point is: HT02. Vel. of HT02, XQ14,XQ07:'
  PrintF, loglun, STRJOIN(l_v)
  ;  PrintF, loglun, 'Modified Vel. of HT02, XQ14,XQ07:'
  ;  PrintF, loglun, STRJOIN(temp-temp[0])
  PrintF, loglun, ''
  PrintF, loglun, 'Ind. of the points:'+STRJOIN(pt_ind)
  PrintF, loglun, 'Vel. in the vdh file:'+STRJOIN(TRANSPOSE(vdh[3, pt_ind]))
  PrintF, loglun, ''
  PrintF, loglun, 'If we set the vel. of the ref. point (HT02) to the leveling result, then the vel. of vdh:'
  d_v=vdh[3, pt_ind[0]]-l_v[0] ; Difference of velocity
  PrintF, loglun, STRJOIN(TRANSPOSE(vdh[3, pt_ind]-d_v))
  PrintF, loglun, ''
  PrintF, loglun, 'Leveling start at: 20090926. ref. 20091113. Tem. baseline is:'+STRING(pt_l_start_tb/365D)
  PrintF, loglun, 'Leveling end at: 20101024. ref. 20091113. Tem. baseline is:'+STRING(pt_l_end_tb/365D)
  PrintF, loglun, 'Temporal leg:'+STRING((pt_l_end_tb-pt_l_start_tb)/365D)
  PrintF, loglun, ''
  PrintF, loglun, 'The modified value has to be used.'
  PrintF, loglun, 'We add the def. vel. of the ref. point to vdh.'
  def_add=d_v*tb
  XQ14=XQ14-(d_v)*tb
  XQ07=XQ07-def_add
  
  ref=HT02_l
  XQ14_l=XQ14_l-ref
  XQ07_1=XQ07_l-ref
  
  tb_ind=SORT(tb)
  tb=tb[tb_ind]
  XQ14=XQ14[tb_ind]
  XQ07=XQ07[tb_ind]
  
  Print, 'Find the two imaging time of the leveling date.'
  temp=(tb-pt_l_start_tb/365D)
  temp=WHERE(temp LE 0)
  ind_start_tb=tb[N_ELEMENTS(temp)]
  ind_end_tb=tb[N_ELEMENTS(temp)+1]
  times=[temp, temp+1]
  PrintF, loglun, 'Interpolate def. at leveling time for XQ14'
  xq14_inter_s=INTERPOL(xq14[times], tb[times], pt_l_start_tb/365D)
  PrintF, loglun, xq14_inter_s
  PrintF, loglun, ''
  temp=(tb-pt_l_end_tb/365D)
  temp=WHERE(temp LE 0)
  ind_start_tb=tb[N_ELEMENTS(temp)]
  ind_end_tb=tb[N_ELEMENTS(temp)+1]
  times=[temp, temp+1]
  xq14_inter_e=INTERPOL(xq14[times], tb[times], pt_l_end_tb/365D)
  PrintF, loglun, xq14_inter_e
  PrintF, loglun, 'Def. between two leveling time:'+STRING(xq14_inter_s-xq14_inter_e)
  PrintF, loglun, ''
  PrintF, loglun, 'Interpolate def. at leveling time for XQ07'
  temp=(tb-pt_l_start_tb/365D)
  temp=WHERE(temp LE 0)
  ind_start_tb=tb[N_ELEMENTS(temp)]
  ind_end_tb=tb[N_ELEMENTS(temp)+1]
  times=[temp, temp+1]
  PrintF, loglun, 'Interpolate def. at leveling time for XQ14'
  xq07_inter_s=INTERPOL(xq07[times], tb[times], pt_l_start_tb/365D)
  PrintF, loglun, xq07_inter_s
  PrintF, loglun, ''
  temp=(tb-pt_l_end_tb/365D)
  temp=WHERE(temp LE 0)
  ind_start_tb=tb[N_ELEMENTS(temp)]
  ind_end_tb=tb[N_ELEMENTS(temp)+1]
  times=[temp, temp+1]
  xq07_inter_e=INTERPOL(xq07[times], tb[times], pt_l_end_tb/365D)
  PrintF, loglun, xq07_inter_e
  PrintF, loglun, 'Def. between two leveling time:'+STRING(xq07_inter_s-xq07_inter_e)
  
  pt_l_start_jul=DATE2JULDAT(pt_l_start)
  pt_l_end_jul=DATE2JULDAT(pt_l_end)
  
  slavedate=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
  slavejul=DATE2JULDAT(slavedate)
  dummy=LABEL_DATE( date_format='%M. %D, %Y')
  t=slavejul[tb_ind]
  t_min=MIN(t, max=t_max)
  
  
  xrange=[t_min-3, t_max+3]
  yrange=[-50, 30]
  position=[0.1, 0.18, 0.93, 0.95]
  
  temp=PLOT(t, XQ14,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
    symbol='o',sym_size=0.5,sym_color='black', sym_filled=1, sym_fill_color='red',$
    FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
    linestyle=0, sym_thick=0.3,xtitle='Acquisition date!C(a)',ytitle='Deformation (mm)',$
    xticks=6, xmajor=5)
  temp2=Plot([pt_l_start_jul, pt_l_start_jul],yrange, linestyle=3,/overplot)
  temp2=Plot([pt_l_end_jul, pt_l_end_jul], yrange, linestyle=3,/overplot)
  temp.save, hpapath+'XQ14.jpg', border=10,/transparent
  ;    temp.close
  
  
  temp=PLOT(t, XQ07,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
    symbol='o',sym_size=0.5,sym_color='black', sym_filled=1, sym_fill_color='red',$
    FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
    linestyle=0, sym_thick=0.3,xtitle='Acquisition date!C(b)',ytitle='Deformation (mm)',$
    xticks=6, xmajor=5)
  temp2=Plot([pt_l_start_jul, pt_l_start_jul],yrange, linestyle=3,/overplot)
  temp2=Plot([pt_l_end_jul, pt_l_end_jul], yrange, linestyle=3,/overplot)
  temp.save, hpapath+'XQ07.jpg', border=10,/transparent
  ;    temp.close
  
  
  
  
  
;  IF 0 then BEGIN
;  
;    slavedate=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
;    slavejul=DATE2JULDAT(slavedate)
;    dummy=LABEL_DATE( date_format='%M. %Y')
;    t=slavejul[tbase_ind]
;    
;    temp=PLOT(t, XQ14,yrange=[-50, 30], xrange=[-0.7, 1.1],dimensions=[800,300],$
;      symbol='o',sym_size=0.5,sym_color='black', sym_filled=1, sym_fill_color='red',$
;      FONT_SIZE=10, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
;      linestyle=0, sym_thick=0.3)
;    temp2=Plot([pt_l_start_tb/365D, pt_l_start_tb/365D], [-30,20], linestyle=3,/overplot)
;    temp2=Plot([pt_l_end_tb/365D, pt_l_end_tb/365D], [-30,20], linestyle=3,/overplot)
;    temp.save, hpapath+'XQ14.bmp', border=10,/transparent
;    ;    temp.close
;    
;    
;    temp=PLOT(t, XQ07,yrange=[-50, 30], xrange=[-0.7, 1.1],dimensions=[800,300],$
;      symbol='o',sym_size=0.5,sym_color='black', sym_filled=1, sym_fill_color='red',$
;      FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
;      linestyle=0, sym_thick=0.3,xtitle='Acquisition date!C(b)',ytitle='Deformation (mm)')
;    temp2=Plot([pt_l_start_tb/365D, pt_l_start_tb/365D], [-30,20], linestyle=3,/overplot)
;    temp2=Plot([pt_l_end_tb/365D, pt_l_end_tb/365D], [-30,20], linestyle=3,/overplot)
;    temp.save, hpapath+'XQ07.bmp', border=10,/transparent
;  ;    temp.close
;  ENDIF
  
  
  
  FREE_LUN, loglun
  STOP
END