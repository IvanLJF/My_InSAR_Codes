; Plot figure for pdef which is generated from GAMMA.
; Call GMT in Linux.
;
; workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_SH/'
; pdeffile=workpath+'pddef2'
; rasfile=workpath+'ave.ras'
; sarlistfile=workpath+'sarlist'
; pmaskfile=workpath+'pmask1'
; tli_plot_linear_def_GAMMA, pdeffile, rasfile,sarlistfile, pmaskfile=pmaskfile,/show
;
; Written by:
; T.Li @ ISEIS, 20130709
PRO TLI_PLOT_LINEAR_DEF_GAMMA, plistfile, pdeffile, rasfile, sarlistfile, pmaskfile=pmaskfile,$
    outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
    tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
    fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
    no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
    dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
  
  COMPILE_OPT idl2
  
  vdhfile=pdeffile+'.tempvdh'
  TLI_PSUDOVDH, pdeffile, pmaskfile=pmaskfile,outputfile=vdhfile,plistfile=plistfile,/gamma_file
  TLI_PLOT_LINEAR_DEF, vdhfile, rasfile, sarlistfile, $
    outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
    tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
    fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
    no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
    dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
  FILE_DELETE, vdhfile
END