;-
;- Call GMT to plot figures
;-
;- hpapath       : Path set for HPA
;- level         : The levels to process.
;-                 If level is consisted of a single element, then plot the figures of level-1 ~ level-level
;-                 If level is consisted of two elements. then plot the figures of level[0] ~ level[1]
;- ptsize        : Point size.
;
@tli_hpa_checkfiles
@tli_hpa_files
@tli_plot_plist
PRO TLI_PLOT_HPA, hpapath, level=level, $
    xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
    tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
    fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
    no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
    dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
  IF ~TLI_HAVESEP(hpapath) THEN hpapath=hpapath+PATH_SEP()
  
  scrfile=hpapath+'plot_linear_def_HPA.sh'
  
  ; Check the level
  IF ~KEYWORD_SET(level) THEN level= TLI_HPA_LEVEL(hpapath)
  rasfile=hpapath+'ave.ras'
  sarlistfile=hpapath+'sarlist'
  
  IF N_ELEMENTS(level) EQ 1 THEN BEGIN
    iter_start=1
    iter_end=level
  ENDIF ELSE BEGIN
    iter_start=level[0]
    iter_end=level[1]
  ENDELSE
  
  FOR i=iter_start, iter_end DO BEGIN
    IF KEYWORD_SET(ptsize) THEN ptsize_orig=ptsize
    level_i=i
    files=TLI_HPA_FILES(hpapath, level=level_i)
    
    
    ;*************************************************Before merge********************
    plistfile=files.plist
    outputfile=plistfile+'.tif'
    ; Plot the points.
    TLI_PLOT_PLIST, plistfile, rasfile, sarlistfile, $
      gamma=gamma, outputfile=outputfile, ptsize=ptsize_orig
      
    ; Plot the linear deformation velocity map.
    vdhfile=files.vdh
    outputfile=vdhfile+'.tif'
    TLI_PLOT_LINEAR_DEF,  vdhfile, rasfile, sarlistfile, $
      outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
      tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
      fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
      no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
      dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
      
      
    ;*************************************************After merge********************
    plistfile=files.plist_merge
    outputfile=plistfile+'.tif'
    TLI_PLOT_PLIST, plistfile, rasfile, sarlistfile,outputfile=outputfile, ptsize=ptsize_orig
    
    vdhfile=files.vdh_merge
    outputfile=vdhfile+'.tif'
    TLI_PLOT_LINEAR_DEF,   vdhfile, rasfile, sarlistfile, $
      outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
      tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
      fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
      no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
      dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
      
  ENDFOR
  
  
  
END

;*****************************The old version*********************************
;PRO TLI_PLOT_HPA, hpapath, level=level
;;;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA'
;;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/HPA'
;;  workpath=workpath+PATH_SEP()
;
;  IF ~TLI_HAVESEP(hpapath) THEN hpapath=hpapath+PATH_SEP()
;  scrfile=hpapath+'plot_linear_def_HPA.sh'
;
;  ; Check the level
;  IF ~KEYWORD_SET(level) THEN level= TLI_HPA_LEVEL(workpath)
;
;  ; Write the scripts.
;  OPENW, lun, scrfile,/GET_LUN
;  PRINTF, lun, '#!/bin/sh'
;
;  PrintF, lun, "lel1vdhfile='vdh.txt'"
;  printF, lun, "lel1psfile='lel1pdef.ps'"
;  PrintF, lun, ''
;  PrintF, lun, 'sz=0.01i # Size of the points'
;  PrintF, lun, "gmtset ANNOT_FONT_SIZE 9p ANNOT_OFFSET_PRIMARY 0.07i FRAME_WIDTH 0.04i MAP_SCALE_HEIGHT 0.04i \
;  PrintF, lun, "LABEL_FONT_SIZE 10p LABEL_OFFSET 0.05i TICK_LENGTH 0.05i"
;  PrintF, lun, "makecpt -Crainbow -T-31/18/1 -I -V -Z > g.cpt"
;  PrintF, lun, ''
;  PrintF, lun, '######################################################'
;  PrintF, lun, "# plot lel1 result."
;  PrintF, lun, "awk '{print $2,6150-$3,$4}' $lel1vdhfile >v.txt"
;  PrintF, lun, "psbasemap -R0/5000/0/6150 -JX5i/6.15i -Ba1000f200::WeSn -P -K -V  > $lel1psfile"
;  PrintF, lun, "psimage ../ave.ras -W5i/6.15i -O -V -K >> $lel1psfile"
;  PrintF, lun, "psxy v.txt -R -J -B -Cg.cpt -V -Sc$sz -K -O >> $lel1psfile"
;  PrintF, lun, "psscale -Cg.cpt -D5.5i/1.4i/1.9i/0.15i -E -I -O -B5::/:mm/\y: -V >> $lel1psfile"
;  PrintF, lun, "ps2raster -A -V $lel1psfile"
;  PrintF, lun, ''
;  IF level EQ 1 THEN BEGIN
;
;  ENDIF ELSE BEGIN
;    FOR i=2, level DO BEGIN
;      lel=STRCOMPRESS('lel'+STRING(i),/REMOVE_ALL)
;      PrintF, lun, ''
;      PrintF, lun, '###############################################'
;      PRINTF, lun, lel+"vdhfile='"+lel+"vdh.txt'"
;      PRINTF, lun, lel+"mergevdhfile='"+lel+"vdh_merge.txt'"
;      PrintF, lun, lel+"psfile='"+lel+"pdef.ps'"
;      PrintF, lun, lel+"mergepsfile='"+lel+"vdh_merge.ps'"
;      PrintF, lun, "# plot "+lel+" results."
;      PrintF, lun, "awk '{print $2,6150-$3,$4}' $"+lel+"vdhfile >v.txt"
;      PrintF, lun, "psbasemap -R0/5000/0/6150 -JX5i/6.15i -Ba1000f200::WeSn -P -K -V  > $"+lel+"psfile"
;      PrintF, lun, "psimage ../ave.ras -W5i/6.15i -O -V -K >> $"+lel+"psfile"
;      PrintF, lun, "psxy v.txt -R -J -B -Cg.cpt -V -Sc$sz -K -O >> $"+lel+"psfile"
;      PrintF, lun, "psscale -Cg.cpt -D5.5i/1.4i/1.9i/0.15i -E -I -O -B5::/:mm/\y: -V >> $"+lel+"psfile"
;      PrintF, lun, "ps2raster -A -V $"+lel+"psfile"
;      PrintF, lun, ''
;      PrintF, lun, "awk '{print $2,6150-$3,$4}' $"+lel+"mergevdhfile >v.txt"
;      PrintF, lun, "psbasemap -R0/5000/0/6150 -JX5i/6.15i -Ba1000f200::WeSn -P -K -V  > $"+lel+"mergepsfile"
;      PrintF, lun, "psimage ../ave.ras -W5i/6.15i -O -V -K >> $"+lel+"mergepsfile"
;      PrintF, lun, "psxy v.txt -R -J -B -Cg.cpt -V -Sc$sz -K -O >> $"+lel+"mergepsfile"
;      PrintF, lun, "psscale -Cg.cpt -D5.5i/1.4i/1.9i/0.15i -E -I -O -B5::/:mm/\y: -V >> $"+lel+"mergepsfile"
;      PrintF, lun, "ps2raster -A -V $"+lel+"mergepsfile"
;      PrintF, lun, ''
;    ENDFOR
;
;  ENDELSE
;  FREE_LUN, lun
;
;  CD, hpapath
;  Print, 'Plotting the figures for HPA, please wait...'
;  SPAWN, scrfile
;-
