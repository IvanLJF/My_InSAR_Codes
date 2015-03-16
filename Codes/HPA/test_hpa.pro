PRO TEST_HPA

  workpath='D:\ForExperiment\TSX_PS_Tianjin\HPA'  
  workpath=workpath+PATH_SEP()
  
  arcsfile=workpath+'arcs'
  narcs=TLI_ARCNUMBER(arcsfile)
  Print,narcs
  
  mem=91601D * narcs * 4 / 1024 /1024 /1024
  Print, mem
  
  
  STOP
  
  
  logfile=workpath+'log.txt'
  
  plistfile=workpath+'plist'
  arcsfile=workpath+'arcs'
  dvddhfile=workpath+'dvddh'
  dvddhfile_update=dvddhfile+'_update'
  dvddhfile_sort=dvddhfile_update+'_sort'
  mfile=workpath+'tli_ls_dvddh.m'
  weighted=0
  plistfile_update=dvddhfile_update+'.plist'
  vdhfile=workpath+'vdh_matlab_weighted'
  
  
  rasfile=workpath+'ave.ras'
  sarlistfile=workpath+'sarlist'
  minus=1
  show=1
;  fliph_image=1
;  fliph_pt=1
  
  ;      npt=TLI_PNUMBER(plistfile)
  ;      v=TLI_READDATA(v_file,lines=3, format='DOUBLE')
  ;      dh=TLI_READDATA(dh_file, lines=3, format='DOUBLE')
  ;      npt_useful=FILE_LINES(v_file+'.txt')
  ;      vdh=[DINDGEN(1,npt_useful), TRANSPOSE(v), (TRANSPOSE(dh))[2, *]]
  ;      TLI_WRITE, vdhfile, vdh
  
  TLI_PLOT_LINEAR_DEF, vdhfile, rasfile, sarlistfile, $
    outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
    tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
    fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
    no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
    dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
END