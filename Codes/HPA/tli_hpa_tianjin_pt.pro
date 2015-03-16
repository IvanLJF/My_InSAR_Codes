;-
;- Analyze the results of Tianjin HPA.

@tli_extract_ptinfo
@tbase_all
PRO TLI_HPA_TIANJIN_PT
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/figures/'
  IF STRUPCASE(!D.name) EQ 'WIN' THEN workpath=TLI_DIRW2L(workpath,/REVERSE)+PATH_SEP()
  
  sarlistfile=workpath+'sarlist_WIN'
  itabfile=workpath+'itab'
  vdhfile=workpath+'vdh_merge_all'
  plist_lelfile=workpath+'All_leveling_CRs_pix_noname.txt'
  plistfile=workpath+'plist_merge_all'
  lelfile='D:\myfiles\Leveling_Tianjin\信息总表\All_leveling_CRs.txt'
  nonlinearfile=plistfile+'.arcnl.unw'
  npt=TLI_PNUMBER(plistfile)
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  c=299792458D
  lamda=c/finfo.radar_frequency*1000
  
  ;  TLI_UPDATEPLIST, vdhfile, plistfile,/vdhfile
  
  ; Find the proximate coordinates for the leveling points.
  TLI_GAMMA_PROX_PTS, plist_lelfile, plistfile, ind=ind,coors=coors, errs=errs,/txt,/myfiles
  
  ; Get subsidence rate from vdhfile
  vdh=TLI_EXTRACT_PTINFO(ind, vdhfile,type='vdh')
  v_ps=vdh[3, *]
  
  ; Correct the subsidence rate with reference to the leveling data.
  lel_def=TLI_READTXT(lelfile, header_samples=3)
  startdate=20090909
  enddate=20101024
  masterdate=TLI_GAMMA_INT(sarlistfile, itabfile, /onlymaster,/uniq,/date)
  tbaseline=tbase(startdate, enddate)/365D ; yr
  v_lel=-lel_def/tbaseline
  v_ps_LOS=v_ps/cos(degree2radius(41.0788)) ; LOS -> Vertical
  d=v_lel[0]-v_ps_LOS[0,0]  ; intercept
  v_ps_ref=v_ps_LOS+d
  
  ; Calculate the subsidence errors.
  v_err=v_lel-v_ps_ref
  
  ; Interpolate the nonlinear deformation values for the points.
  nl=TLI_EXTRACT_PTINFO(ind, nonlinearfile,samples=npt, format='FLOAT')
  tbaselines=TBASE_ALL(sarlistfile, itabfile,/years)
  starttbase=TBASE(masterdate, startdate,/years)
  endtbase=TBASE(masterdate, enddate,/years)
  start_nl=TLI_INTERPOL(nl, tbaselines, starttbase)/(4*!PI)*lamda
  end_nl=TLI_INTERPOL(nl, tbaselines, endtbase)/(4*!PI)*lamda
  def_nl=end_nl-start_nl
  def_nl_LOS=def_nl/cos(degree2radius(41.0788))
  tempind=WHERE(ABS(def_nl_LOS) GE 10)
  mask=BYTARR(size(def_nl_LOS,/dimensions))+1 & mask[tempind]=0
  def_nl_LOS_refine=def_nl_LOS & def_nl_LOS_refine[tempind]=0
  
  ; Calculate the total deformation values using nonlinear+linear
  all_def=v_ps_ref*tbaseline+def_nl_LOS_refine
  all_err=-lel_def-all_def
  all_err_ref=all_err-all_err[0]
  all_def_ref=all_def+all_err[0]
  
  ;  TLI_WRITE, workpath+'temp.txt',TRANSPOSE(mask),/txt
  
  ; Choose the leveling data.
  x=v_lel
  y=v_ps_ref
  nx=N_ELEMENTS(x)
  ind_orig=LINDGEN(nx)
  ;    ntimes=10
  ;    FOR i=0, ntimes-1 DO BEGIN
  ;      diff=ABS(x-y)
  ;      refind=TLI_REFINE_DATA(diff,delta=3)
  ;      x=x[refind]
  ;      y=y[refind]
  ;    ENDFOR
  diff=ABS(x-y)
  ind=SORT(diff)
  refind=ind[0:23]
  refind=refind[1:*]  ; Remove the first reference point.
  x=x[refind]
  y=y[refind]
  final_mask=BYTARR(size(diff,/DIMENSIONS)) & final_mask[refind]=1
  
  final_mask=TLI_READTXT(workpath+'final_mask')
  
  ;  TLI_WRITE, workpath+'temp.txt',final_mask,/TXT
  ; Plot the regression result.
  IF 1 THEN BEGIN
    x=x[1:*]
    y=y[1:*]
    a=plot(x,y,dimensions=[800,300], linestyle=6, symbol='o',sym_size=0.5,sym_color='black', sym_filled=1, sym_fill_color='red')
    reg=REGRESS(x, y,sigma=sigma, const=const,ftest=ftest, yfit=yfit,correlation=correlation)
    sigma_my=SQRT(MEAN((x-y)^2))
    Print, 'Model: y=ax+b. a is:', reg, '  b is:', const
    Print, "Pearson's r:", correlation
    Print, 'Sigma of the PS deformation values:', sigma_my
    b=plot(x, yfit, linstyle=1,/overplot)
  ENDIF
  
  ; Plot full resolution deformation for the points.
  nl_def=nl/(4*!PI)*lamda/cos(degree2radius(41.0788))
  def_full=TLI_DEF_EVOLUTION(v_ps_ref, tbaselines,nl_def)
  ; extract the valus corresponding to the mask values.
  mask_ind=WHERE(final_mask EQ 1)
  def_full_mask=def_full[mask_ind, *]
  ; Eliminate the first line. It is a reference point.
  def_full_mask=def_full_mask[1:*, *]
  v_ps_mask=v_ps_ref[mask_ind]
  ; Plot them
  ind=[2,8,9]
  FOR i=0,6 DO BEGIN
    data=def_full_mask[ind[i], *]
    v=v_ps_mask[ind[i], *]
    l=v*tbaselines & l=TRANSPOSE(l)
    tb_ind=SORT(tbaselines)
    pt_l_start_jul=DATE2JULDAT(startdate)
    pt_l_end_jul=DATE2JULDAT(enddate)
    
    slavedate=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
    slavejul=DATE2JULDAT(slavedate)
    dummy=LABEL_DATE( date_format='%M. %Y')
    
    t=slavejul[tb_ind]
    data=data[tb_ind]
    l=v[0]*TRANSPOSE(tbaselines[tb_ind])
    
    t_min=MIN(t, max=t_max)
    xrange=[t_min-3, t_max+3]
    yrange=[-30, 17]
    position=[0.1, 0.18, 0.93, 0.95]
;    temp=PLOT(t, data,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
;      symbol='o',sym_size=0.5,sym_color='black', sym_filled=1, sym_fill_color='red',$
;      FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
;      linestyle=0, sym_thick=0.3,xtitle='Acquisition date',ytitle='Deformation (mm)',$
;      xticks=7, xmajor=7)
    temp=PLOT(t, data,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
      symbol='o',sym_size=0.5,sym_color='black', sym_filled=1, sym_fill_color='red',$
      FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
      linestyle=6, sym_thick=0.3,xtitle='Acquisition date',ytitle='Deformation (mm)',$
      xticks=7, xmajor=7)
    temp=PLOT(t, l,FONT_SIZE=13,  linestyle=0, sym_thick=0.3,/overplot)
    temp2=Plot([pt_l_start_jul, pt_l_start_jul],yrange, linestyle=3,/overplot)
    temp2=Plot([pt_l_end_jul, pt_l_end_jul], yrange, linestyle=3,/overplot)

    Print, i
  ENDFOR
END