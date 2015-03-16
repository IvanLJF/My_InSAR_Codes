PRO TESTGMT

  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_SH_3/HPA/'
 vdhfile=workpath+'vdh'
 rasfile=workpath+'ave.ras'
 sarlistfile=workpath+'sarlist_Linux'
 outputfile=workpath+'figures/shanghai_linear_def_lel1.jpg'
 
 fliph_pt=1
 fliph_image=1
 no_clean=1
 ptsize=0.004
 show=1
 
 
 TLI_PLOT_LINEAR_DEF, vdhfile, rasfile, sarlistfile, $
    outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,frame=frame, $
    tick_major=tick_major,tick_minor=tick_minor,refine=refine,show=show, maxv=maxv, minv=minv, $
    fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
    no_colorbar=no_colorbar
;
END