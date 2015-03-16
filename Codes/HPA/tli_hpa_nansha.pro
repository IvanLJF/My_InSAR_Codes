PRO TLI_MOD_PLL,llfile,lonoff, latoff,outputfile=outputfile

  IF  NOT KEYWORD_SET(outputfile) THEN outputfile=llfile+'.mod'
  ll=TLI_READDATA(llfile, samples=2, format='float',/swap_endian)
  ll[0, *]=ll[0, *]+lonoff
  ll[1, *]=ll[1, *]+latoff
  TLI_WRITE, outputfile,ll,/swap_endian 
  
END
PRO TLI_HPA_NANSHA

  ;  workpath='/mnt/software/myfiles/Software/experiment/Env_PS_NanSha/'
  workpath='/mnt/software/myfiles/Software/experiment/Env_PS_NanSha/Nansha_result_byIPTA/'
  hpapath=workpath+'/HPA'+PATH_SEP()
  
  plistfile=workpath+'plist'
  pdeffile=workpath+'pdef'
  rasfile=workpath+'ave.ras'
  pmaskfile=workpath+'pmask'
  sarlistfile=FILE_DIRNAME(workpath)+'/SLC_tab'
  minus=1
  noclean=1
  show=1
  IF 0 THEN BEGIN
    TLI_PLOT_LINEAR_DEF_GAMMA, plistfile, pdeffile, rasfile, sarlistfile, pmaskfile=pmaskfile,$
      outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
      tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
      fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
      no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
      dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
  ENDIF
  
  IF 0 THEN BEGIN
    mask_arc=0.8
    mask_pt_coh=0.8
    v_acc=10
    dh_acc=10
    TLI_HPA_1LEVEL,workpath, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh, v_acc=v_acc, dh_acc=dh_acc
    outputfile=hpapath+'vdh_v'+(TLI_TIME(/STR))+'.jpg'
    tli_plot_linear_def,hpapath+'vdh', hpapath+'ave.ras',hpapath+'sarlist_Linux',/show,ptsize=0.005,/no_clean
  ENDIF
  
  
  IF 1 then BEGIN
  
    pmapllfile_orig=workpath+'pmapll_orig'
    pdeffile=workpath+'pdef'
    pmaskfile=workpath+'pmask'
    pmapllfile=pmapllfile_orig+'.mod'
    
    tli_mod_pll, pmapllfile_orig, -0.002808, -0.00055, outputfile=pmapllfile
    
    vacuate=1
    npt_final=10000
    tli_defingoogle_gamma,pmapllfile, pdeffile, pmaskfile=pmaskfile, cptfile=cptfile,  colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
      maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
      refine_data=refine_data,delta=delta,refined_data=refined_data, minus=minus
  ENDIF
  
END