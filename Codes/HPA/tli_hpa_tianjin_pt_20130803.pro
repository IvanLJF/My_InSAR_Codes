;-
;- Analyze the results of Tianjin HPA.
;- 12 points are used.
;- BM6, CR2, CR3, CR4 are analyzed deeply.

@tli_extract_ptinfo
@tbase_all
@tli_plot_timeseries

FUNCTION TLI_LOCATE_PTLEVEL, index, workpath

  plistfile_merge=FILE_SEARCH(workpath+'lel*plist_update_merge')
  plistfile_merge=[workpath+'plistupdate', plistfile_merge]
  nfiles=N_ELEMENTS(plistfile_merge)
  npts=LONARR(nfiles)  ; All the NumberOfPoint
  FOR i=0, nfiles-1 DO BEGIN
    npts[i]= TLI_PNUMBER(plistfile_merge[i])
  ENDFOR
  temp=WHERE(npts GE index)
  IF temp[0] EQ -1 THEN Message, 'Error. The index is overlarge than the point number.'
  RETURN, temp[0]
END


PRO TLI_HPA_TIANJIN_PT_20130803
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/figures/'
  IF STRUPCASE(!D.name) EQ 'WIN' THEN workpath=TLI_DIRW2L(workpath,/REVERSE)+PATH_SEP()
  
  sarlistfile=workpath+'sarlist_WIN'
  itabfile=workpath+'itab'
  vdhfile=workpath+'vdh_merge_all'
  plist_lelfile=workpath+'All_JHG_noname.txt'
  plistfile=workpath+'plist_merge_all'
  lelfile='D:\myfiles\相关论文\HPA\图表 - 20130804\All_JHG'
  nonlinearfile=plistfile+'.arcnl.unw'
  npt=TLI_PNUMBER(plistfile)
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  c=299792458D
  lamda=c/finfo.radar_frequency*1000
  nintf=FILE_LINES(itabfile)
  
  ;  TLI_UPDATEPLIST, vdhfile, plistfile,/vdhfile
  
  ; Find the proximate coordinates for the leveling points.
  TLI_GAMMA_PROX_PTS, plist_lelfile, plistfile, ind=ind,coors=coors, errs=errs,/txt,/myfiles
  
  ; Find which level the points belong to.
  nlel=N_ELEMENTS(ind)
  lel_for_pt=BYTARR(nlel)
  FOR i=0, nlel-1 DO BEGIN
    lel_for_pt[i]=TLI_LOCATE_PTLEVEL(ind[i], workpath)
  ENDFOR
  
  
  IF 1 THEN BEGIN
    ; Get the baseline parameters.
    tbaselines=TBASE_ALL(sarlistfile, itabfile,/years)
    ; Extract time series for BM4, BM6, CR2, CR4.ind:[3,5,8,10]. Ind in plist_update: ind[3580]
    vdh=TLI_READMYFILES(vdhfile, type='vdh')
    ind_lel=[5,8,9,10]
    ind_specify=ind[ind_lel]
    v_ps=vdh[3, *]/cos(degree2radius(41.0788))
    v_min=MIN(v_ps, max=v_max)
    v_ps_minus=v_ps-v_max; Make the deformation velocity to be minus.
    v_ps_specified=v_ps_minus[0, ind] ; results on the 12 leveling points..
    diff=-21.1-v_ps_specified[11] ; The differences between the leveling point and PS results.
    v_ps_ref=(v_ps_minus+diff)  ; Los to v, referred to CR5.
    v_ps_ref=v_ps_ref[ind_specify]
    v_ps_ref[0]=-25.5 ; Something wrong with BM6
    ; Get the nonlinear deformation component.(Change phase to deformation, then change LOS to v.)
    ind_specify=ind[ind_lel]
    nl=TLI_EXTRACT_PTINFO(ind_specify, nonlinearfile,samples=npt, format='FLOAT')
    nl=nl/(4*!PI)*lamda/cos(degree2radius(41.0788))
    nl=TLI_MAKEITSMALL(nl, largest_value=10)
    ;  nl[2,*]=nl[2,*]*0.001 ; There is some provlem with CR2.
    all_def=tbaselines##(v_ps_ref)+nl
    ;    all_def=tbaselines##v_ps_ref
    startdate=20090420
    masterdate=TLI_GAMMA_INT(sarlistfile, itabfile, /onlymaster,/uniq,/date)
    starttbase=TBASE(masterdate, startdate,/years)
    startdef=TLI_INTERPOL(all_def, tbaselines, starttbase)
    all_def_ref=all_def-REBIN(startdef, 4, nintf)
    
    ; Plot the data
    ; First read the leveling data
    lel_data=TLI_READTXT(lelfile, header_samples=3)
    lel_data_specified=lel_data[*, ind_lel] ; 4 points
    four_dates=[20090420, 20090905, 20100415, 20101030] ; Four leveling epoches.
    FOR i=0, 3 DO BEGIN
      case i OF
        0: BEGIN
          yrange=[-50,0]
          no_xtick=1
        END
        1: BEGIN
          yrange=[-50,0]
          no_xtick=1
        END
        2: BEGIN
          yrange=[-80,0]
          no_xtick=0
        END
        3: BEGIN
          yrange=[-50,0]
        END
      ENDCASE
      fig=TLI_PLOT_TIMESERIES(sarlistfile, itabfile, all_def_ref[i, *],linestyle=0,yrange=yrange,no_xtick=no_xtick)
      ; Plot the leveling data.
      four_juldays=DATE2JULDAT(four_dates)
      pts=PLOT(four_juldays[1:*], lel_data_specified[1:*, i],/overplot, symbol='s',sym_size=1, sym_color='black', $
        sym_filled=1, sym_fill_color='green',linestyle=6)
      Print, i
    ENDFOR
    
    STOP
    IF 1 THEN BEGIN
      ; Get the baseline parameters.
      tbaselines=TBASE_ALL(sarlistfile, itabfile,/years)
      ; Extract time series for BM4, BM6, CR2, CR4.ind:[3,5,8,10]. Ind in plist_update: ind[3580]
      vdh=TLI_READMYFILES(vdhfile, type='vdh')
      ind_specify=ind
      v_ps=vdh[3, *]/cos(degree2radius(41.0788))
      v_min=MIN(v_ps, max=v_max)
      v_ps_minus=v_ps-v_max; Make the deformation velocity to be minus.
      v_ps_specified=v_ps_minus[0, ind] ; results on the 12 leveling points..
      diff=-21.1-v_ps_specified[11] ; The differences between the leveling point and PS results. usnig CR5
      v_ps_ref=(v_ps_minus+diff)  ; Los to v, referred to CR5.
      v_ps_ref=v_ps_ref[ind_specify]
      v_ps_ref[5]=-25.5 ; Something wrong with BM6
      ; Get the nonlinear deformation component.(Change phase to deformation, then change LOS to v.)
      ind_specify=ind
      nl=TLI_EXTRACT_PTINFO(ind_specify, nonlinearfile,samples=npt, format='FLOAT')
      nl=nl/(4*!PI)*lamda/cos(degree2radius(41.0788))
      nl=TLI_MAKEITSMALL(nl, largest_value=3)
      ;  nl[2,*]=nl[2,*]*0.001 ; There is some provlem with CR2.
      all_def=tbaselines##(v_ps_ref)+nl
      ;        all_def=tbaselines##v_ps_ref
      startdate=20090420
      masterdate=TLI_GAMMA_INT(sarlistfile, itabfile, /onlymaster,/uniq,/date)
      starttbase=TBASE(masterdate, startdate,/years)
      startdef=TLI_INTERPOL(all_def, tbaselines, starttbase)
      all_def_ref=all_def-REBIN(startdef, 12, nintf)
      
      ; Interpolate the deformation values.
      four_dates=[20090420, 20090905, 20100415, 20101030] ; Four leveling epoches.
      four_baselines=DBLARR(4)
      four_ps_def=DBLARR(12, 4)
      FOR i=0, 3 DO BEGIN
        four_baselines[i]=TBASE(masterdate, four_dates[i],/years)
        four_ps_def[*, i]=TLI_INTERPOL(all_def, tbaselines, four_baselines[i])
      ENDFOR
      ; Calculate the deformation values of the three leveling epoches.
      three_def_intervals=DBLARR(12,3)
      For i=0, 2 DO BEGIN
        three_def_intervals[*,i]=four_ps_def[*, i+1]-four_ps_def[*,i]
      ENDFOR
      
      STOP
    ENDIF
  ENDIF
  
  tempfile=workpath+'temp.txt'
  values=TLI_READTXT(tempfile,/easy)
  group0=[7,10,11]
  group1=[0,1,2,3,4,5,6,9]
  group3=[8]
  values0=values[*, group0]
  values1=values[*, group1]
  values3=values[*, group3]
  rmse_v_0=TLI_RMSE(values0[0:1, *])
  rmse_v_1=TLI_RMSE(values1[0:1, *])
  rmse_v_3=TLI_RMSE(values3[0:1, *])
  
  rmse_l1_0=TLI_RMSE(values0[[2,5], *])
  rmse_l1_1=TLI_RMSE(values1[[2,5], *])
  rmse_l1_3=TLI_RMSE(values3[[2,5], *])
  
  rmse_l2_0=TLI_RMSE(values0[[3,6], *])
  rmse_l2_1=TLI_RMSE(values1[[3,6], *])
  rmse_l2_3=TLI_RMSE(values3[[3,6], *])
  
  rmse_l3_0=TLI_RMSE(values0[[4,7], *])
  rmse_l3_1=TLI_RMSE(values1[[4,7], *])
  rmse_l3_3=TLI_RMSE(values3[[4,7], *])
  
  rmse_v=TLI_RMSE(values[[0,1], *])
  rmse_l1=TLI_RMSE(values[[2,5], *])
  rmse_l2=TLI_RMSE(values[[3,6], *])
  rmse_l3=TLI_RMSE(values[[4, 7], *])
  STOP
END