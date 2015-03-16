PRO TLI_RESIDUAL_ARC

  COMPILE_OPT idl2
  Print, '*******************************************************************'
  ;Input params
  c=299792458D ; Light speed.
  refind=24736
  pind=24561
  temp= ALOG(2)
  e= 2^(1/temp)
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK'
  IF (!D.NAME) NE 'WIN' THEN BEGIN
    sarlistfilegamma= workpath+'/SLC_tab'
    sarlistfile= workpath+'/testforCUHK/sarlist_Linux'
    pdifffile= workpath+'/pdiff0'
    plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
    plistfile= workpath+'/testforCUHK/plist'
    itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
    arcsfile=workpath+'/testforCUHK/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/arcs'
    pbasefile=workpath+'/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
    dvddhfile=workpath+'/testforCUHK/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/dvddh'
    vdhfile= workpath+'/testforCUHK/vdh'
    atmfile= workpath+'/testforCUHK/atm'
    nonfile= workpath+'/testforCUHK/nonlinear'
    noisefile= workpath+'/testforCUHK/noise'
    time_seriesfile= workpath+'/testforCUHK/time_series'
    pdiffrasfile= workpath+'/ras/pdiff/pdiff0.03.ras'
  ENDIF ELSE BEGIN
    sarlistfile= TLI_DIRW2L(sarlistfile,/reverse)
    pdifffile=TLI_DIRW2L(pdifffile,/reverse)
    plistfile=TLI_DIRW2L(plistfile,/reverse)
    itabfile=TLI_DIRW2L(itabfile,/reverse)
    arcsfile=TLI_DIRW2L(arcsfile,/reverse)
    pbasefile=TLI_DIRW2L(pbasefile,/reverse)
    dvddhfile=TLI_DIRW2L(dvddhfile,/REVERSE)
    vdhfile=TLI_DIRW2L(vdhfile,/REVERSE)
  ENDELSE
  
  ; Read basemap
  pdiffras= READ_IMAGE(pdiffrasfile)
  
  ; Read plist
  plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
  
  ; Specify points to be analyzed.
  refcoor= plist[refind]
  pcoor= plist[pind]
  
  ; Read pdiff
  npt= TLI_PNUMBER(plistfile)
  pdiff= TLI_READDATA(pdifffile,samples=npt,format='FCOMPLEX',/SWAP_ENDIAN)
  refphase= pdiff[refind, *]
  pphase= pdiff[pind, *]
  
  ; Prepare the params.
  deltaphi= ATAN(pphase*CONJ(refphase),/PHASE)
  
  pbase= TLI_READDATA(pbasefile, samples='13', format='DOUBLE',/SWAP_ENDIAN)
  IF TOTAL(pbase[7,*]) EQ 0 THEN BEGIN
    Print, 'No precise baseline available.'
    bperp= pbase[1, *]
  ENDIF ELSE BEGIN
    Print, 'Precise baselines are used.'
    bperp= pbase[7, *]
  ENDELSE
  
  nintf= FILE_LINES(itabfile)
  itab=LONARR(4, nintf)
  OPENR, lun, itabfile,/GET_LUN
  READF, lun, itab
  FREE_LUN, lun
  master_ind= itab[0,*]
  master_ind= UNIQ(master_ind)
  IF N_ELEMENTS(master_ind) EQ 1 THEN BEGIN
    nslc= FILE_LINES(sarlistfile)
    slcs= STRARR(nslc)
    OPENR,lun, sarlistfile,/GET_LUN
    READF, lun, slcs
    FREE_LUN, lun
    mfile= slcs[master_ind]
    Print, 'Single master slc image is used. Master file is:  ', FILE_BASENAME(mfile)
  ENDIF
  
  mpar= mfile+'.par'
  mpar_str= TLI_LOAD_SLC_PAR(mpar)
  R= mpar_str.near_range_slc
  rf= mpar_str.radar_frequency
  rps= mpar_str.range_pixel_spacing
  stec= mpar_str.sar_to_earth_center
  erbs= mpar_str.earth_radius_below_sensor
  
  ;  R= READ_PARAMS(mpar, 'near_range_slc')
  ;  rf= READ_PARAMS(mpar, 'radar_frequency')
  ;  rps= READ_PARAMS(mpar, 'range_pixel_spacing')
  ;  stec= READ_PARAMS(mpar, 'sar_to_earth_center')
  ;  erbs= READ_PARAMS(mpar, 'earth_radius_below_sensor')
  wl= c/rf
  
  ref_r= (REAL_PART(refcoor)-1)*rps+R ; Slant range of reference point.
  cosla= (stec^2+ref_r^2-erbs^2)/(2*stec*ref_r) ; Cosine look angle of ref. p. .
  sinla= SQRT(1-cosla^2)
  
  K1= -4*!PI/(wl*ref_r*sinla)
  K2= -4*!PI/(wl*1000)  ; Set the unit of deformation velocity as mm/yr.
  
  T=TBASE_ALL(sarlistfile, itabfile)
  
  
  
  coefs_v=REPLICATE(K2, 1, nintf)
  coefs_dh= K1*Bperp
  coefs=[coefs_v, coefs_dh]
  coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
  result= coefs_n##deltaphi
  
  delta= deltaphi-coefs##result
  err= -coefs_n##delta
  Print, 'Reference point pixel coordinates:', refind,refcoor
  Print, 'Target point pixel coordinates:', pind,pcoor
  Print, ['ls_dv:', 'ls_ddh:']+ STRCOMPRESS(TRANSPOSE(result))+'+-'+STRCOMPRESS( TRANSPOSE(err))
  
  ls_dv= result[0]
  ls_ddh= result[1]
  
  ls_phi= coefs##result
  
  ls_sig= SQRT(TOTAL((deltaphi-ls_phi)^2)/nintf)
  Print, 'Least square error:', ls_sig
  temp=ls_phi-deltaphi
  ls_coh= ABS(MEAN(e^COMPLEX(0,temp)))
  Print, 'Least square coherence:', ls_coh
  
  vdh= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
  vdh_refind= vdh[*, WHERE(vdh[0, *] EQ refind)]
  vdh_pind= vdh[*, WHERE(vdh[0, *] EQ pind)]
  Print, 'Ref. info.', vdh_refind
  Print, 'Pt. info.', vdh_pind
  
  
  IF 0 THEN BEGIN
  
    mdp= MEAN(deltaphi)
    stdp= STDDEV(deltaphi)
    ind= WHERE(deltaphi GT mdp-3*stdp AND deltaphi LT mdp+3*stdp)
    deltaphi_n= deltaphi[ind]
    T_n= T[ind]
    
    ls_phi_n= ls_phi[ind]; LS result
    ; Use poly fit to calculate deformation velocity.
    ; Assume that there is no phase ambiguities.
    result= POLY_FIT(T_n, deltaphi_n, 1)
    
    poly_err=SQRT(TOTAL((result[0]+result[1]*T-deltaphi)^2)/nintf)
    Print, 'Poly fit result:'+STRCOMPRESS(TRANSPOSE(result))
    Print,'Poly fit error:',STRCOMPRESS(poly_err)
    temp=result[0]+result[1]*T-deltaphi
    poly_coh= ABS(MEAN(e^COMPLEX(0,temp)))
    Print, 'Poly fit coherence:', poly_coh
    
    s_ind= SORT(T_n)
    ;  IPLOT, T, deltaphi, LINESTYLE=6, SYM_INDEX=4, SYMSIZE=0.3
    minx=MIN(T_n[s_ind])-0.3
    maxx= MAX(T_N[s_ind])+0.3
    
    plotx= [minx, T_n[s_ind],maxx]
    ploty= result[0]+result[1]*plotx
    
    workpath= workpath+'/testforCUHK/'+STRCOMPRESS(STRCOMPRESS(pind)+STRCOMPRESS(refind))
    
    OPENW, lun, workpath+'.orig.txt'
    PRINTF, lun, TRANSPOSE([[T_n[s_ind]], [deltaphi_n[s_ind]]])
    FREE_LUN, lun
    
    OPENW, lun, workpath+'.linear_regression.txt'
    PRINTF, lun, TRANSPOSE([[plotx], [ploty]])
    FREE_LUN, lun
    
    IPLOT, T_n[s_ind], deltaphi_n[s_ind], SYM_INDEX=5, SYMSIZE=0.03,LINESTYLE=6, COLOR=[255,0,0],$
      YRANGE=[-!PI, !PI], XRANGE=[minx, maxx], $
      DIMENSIONS=[1200, 1000],/NO_SAVEPROMPT ;Original data
    IPLOT, plotx, ploty , SYM_INDEX=0,SYMSIZE=0.03, LINESTYLE=1,COLOR=[0,255,0],/OVERPLOT,/NO_SAVEPROMPT, $
      thick=2 ; Linear regression.
      
      
    ; Least-Square plot.
      
    plotx=T_N[s_ind]
    ploty=ls_phi[s_ind]
    OPENW, lun, workpath+'.ls.txt'
    PRINTF, lun, TRANSPOSE([[plotx], [ploty]])
    FREE_LUN, lun
    
    IPLOT, plotx,ploty , LINESTYLE=2,COLOR=[0,0,255],SYMSIZE=0.03, SYM_INDEX=0,/OVERPLOT,/NO_SAVEPROMPT, $
      thick=2 ;LS
      
    ; Power spectrum density plot.
    plotx=T_N[s_ind]
    ploty=K2*plotx +K1*Bperp*psd_ddh
    OPENW, lun, workpath+'.psd.txt'
    PRINTF, lun, TRANSPOSE([[plotx], [ploty]])
    FREE_LUN, lun
    
    ;  ploty= ploty MOD (2*!PI)
    IPLOT, plotx,ploty , LINESTYLE=3,COLOR=[0,255,255],SYMSIZE=0.03, SYM_INDEX=0,/OVERPLOT,/NO_SAVEPROMPT, $
      thick=2 ;PSD
      
  ENDIF
END