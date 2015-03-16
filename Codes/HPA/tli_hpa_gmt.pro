;-
;- Call GMT to plot figures
;-
PRO TLI_HPA_GMT

  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA'
  workpath=workpath+PATH_SEP()
  scrfile=workpath+'plot_linear_def_HPA.sh'
  
  ; Check the level
  level= TLI_HPA_LEVEL(workpath)
  
  ; Write the scripts.
  OPENW, lun, scrfile,/GET_LUN
  PRINTF, lun, '#!/bin/sh'
  
  PrintF, lun, "lel1vdhfile='vdh.txt'"
  printF, lun, "lel1psfile='lel1pdef.ps'"
  PrintF, lun, ''
  PrintF, lun, 'sz=0.01i # Size of the points'
  PrintF, lun, "gmtset ANNOT_FONT_SIZE 9p ANNOT_OFFSET_PRIMARY 0.07i FRAME_WIDTH 0.04i MAP_SCALE_HEIGHT 0.04i \
  PrintF, lun, "LABEL_FONT_SIZE 10p LABEL_OFFSET 0.05i TICK_LENGTH 0.05i"
  PrintF, lun, "makecpt -Crainbow -T-31/18/1 -I -V -Z > g.cpt"
  PrintF, lun, ''
  PrintF, lun, '######################################################'
  PrintF, lun, "# plot lel1 result."
  PrintF, lun, "awk '{print $2,6150-$3,$4}' $lel1vdhfile >v.txt"
  PrintF, lun, "psbasemap -R0/5000/0/6150 -JX5i/6.15i -Ba1000f200::WeSn -P -K -V  > $lel1psfile"
  PrintF, lun, "psimage ../ave.ras -W5i/6.15i -O -V -K >> $lel1psfile"
  PrintF, lun, "psxy v.txt -R -J -B -Cg.cpt -V -Sc$sz -K -O >> $lel1psfile"
  PrintF, lun, "psscale -Cg.cpt -D5.5i/1.4i/1.9i/0.15i -E -I -O -B5::/:mm/\y: -V >> $lel1psfile"
  PrintF, lun, "ps2raster -A -V $lel1psfile"
  PrintF, lun, ''
  IF level EQ 1 THEN BEGIN
  
  ENDIF ELSE BEGIN
    FOR i=2, level DO BEGIN
      lel=STRCOMPRESS('lel'+STRING(i),/REMOVE_ALL)
      PrintF, lun, ''
      PrintF, lun, '###############################################'
      PRINTF, lun, lel+"vdhfile='"+lel+"vdh.txt'"
      PRINTF, lun, lel+"mergevdhfile='"+lel+"vdh_merge.txt'"
      PrintF, lun, lel+"psfile='"+lel+"pdef.ps'"
      PrintF, lun, lel+"mergepsfile='"+lel+"vdh_merge.ps'"
      PrintF, lun, "# plot "+lel+" results."
      PrintF, lun, "awk '{print $2,6150-$3,$4}' $"+lel+"vdhfile >v.txt"
      PrintF, lun, "psbasemap -R0/5000/0/6150 -JX5i/6.15i -Ba1000f200::WeSn -P -K -V  > $"+lel+"psfile"
      PrintF, lun, "psimage ../ave.ras -W5i/6.15i -O -V -K >> $"+lel+"psfile"
      PrintF, lun, "psxy v.txt -R -J -B -Cg.cpt -V -Sc$sz -K -O >> $"+lel+"psfile"
      PrintF, lun, "psscale -Cg.cpt -D5.5i/1.4i/1.9i/0.15i -E -I -O -B5::/:mm/\y: -V >> $"+lel+"psfile"
      PrintF, lun, "ps2raster -A -V $"+lel+"psfile"
      PrintF, lun, ''
      PrintF, lun, "awk '{print $2,6150-$3,$4}' $"+lel+"mergevdhfile >v.txt"
      PrintF, lun, "psbasemap -R0/5000/0/6150 -JX5i/6.15i -Ba1000f200::WeSn -P -K -V  > $"+lel+"mergepsfile"
      PrintF, lun, "psimage ../ave.ras -W5i/6.15i -O -V -K >> $"+lel+"mergepsfile"
      PrintF, lun, "psxy v.txt -R -J -B -Cg.cpt -V -Sc$sz -K -O >> $"+lel+"mergepsfile"
      PrintF, lun, "psscale -Cg.cpt -D5.5i/1.4i/1.9i/0.15i -E -I -O -B5::/:mm/\y: -V >> $"+lel+"mergepsfile"
      PrintF, lun, "ps2raster -A -V $"+lel+"mergepsfile"
      PrintF, lun, ''
    ENDFOR
    
  ENDELSE
  FREE_LUN, lun
END