;
; Plot the dem error for PSI analyses.
;
; Parameters:
;   vdhfile      : vdhfile
;   rasfile      : The base image. Only support '*.ras'
;   sarlistfile  : sarlist file.
;
; Keywords:
;   outputfile   : The output file. Kinds of format is supported.
;   xsize        : Size of x dimensions. Unit: inch. Default:3
;   ysize        : Size of y dimensions. If not specified, calculated from xsize.
;   ptsize       : Point size. Unit: inch.  Default:0.03
;   frame        : Show frame or not.
;   tick_major   : Number of major ticks.
;   tick_minor   : Number of minor ticks.
;   refine       : mean +- 3*sigma
;   delta        : Keyword for tli_refine_data
;   show         : show the figure.
;   maxv         : Maximum value to plot
;   minv         : Minimum value to plot
;   no_colorbar  : Don't plot the colorbar
;   unit         : Unit. Ommitted value is "mm/yr"
;   compress     : Compress the image.
;   percent      : If compress is specified, percent is ommitted to be 20%, meaning that the new image is 80% small than the original one.
;   cpt          : Color palette table.
;   intercept    : Intercept of the PS results and leveling.
;   dpi          : Resolution of output image. If not set, dpi is 750 for .pdf and 300 for images.
;   minus        : Make the max value to be 0.
;   geocode      : Geocoded results are provided.
;
; Written by:
;   T.LI @ SWJTU, 20140302
;   This pro is the same as tli_plot_linear_def
;
@tli_plot_linear_def
PRO TLI_PLOT_DEM_ERROR, vdhfile, rasfile, sarlistfile, $
    colorbar_interv=colorbar_interv,compress=compress,cpt=cpt,delta=delta,dpi=dpi,$
    fliph_pt=fliph_pt,flipv_pt=flipv_pt, fliph_image=fliph_image, flipv_image=flipv_image,$
    geocode=geocode, geodims=geodims,intercept=intercept,maxv=maxv, minv=minv,minus=minus,$
    no_colorbar=no_colorbar,noframe=noframe,no_clean=no_clean, outputfile=outputfile,$
    overwrite=overwrite,percent=percent,ptsize=ptsize,refine=refine,show=show,$
    tick_major=tick_major, tick_minor=tick_minor,unit=unit,xsize=xsize, ysize=ysize
    
  IF NOT KEYWORD_SET(tick_major) THEN tick_major=5
  IF NOT KEYWORD_SET(tick_minor) THEN tick_minor=tick_major*2
  IF NOT KEYWORD_SET(ptsize) THEN ptsize=0.01
  IF NOT KEYWORD_SET(unit) THEN unit="m"
  IF NOT KEYWORD_SET(cpt) THEN cpt='rainbow'
  IF NOT KEYWORD_SET(intercept) THEN intercept=0
  
  
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  
  IF KEYWORD_SET(geocode) THEN BEGIN
    IF NOT KEYWORD_SET(geodims) THEN Message, 'Please give the dimension info of the geocoded image.'
    finfo.range_samples=geodims[0]
    finfo.azimuth_lines=geodims[1]
  ENDIF
  IF NOT KEYWORD_SET(xsize) THEN BEGIN
    xsize=3
  ENDIF
  IF NOT KEYWORD_SET(ysize) THEN BEGIN
    ysize=xsize/finfo.range_samples*finfo.azimuth_lines
  ENDIF
  IF not KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=vdhfile+'.jpg'
  ENDIF
  IF not KEYWORD_SET(ptsize) THEN BEGIN
    ptsize=0.01
  ENDIF
  
  ; Reprair the raster file.
  TLI_REPAIR_IMAGE, rasfile, outputfile=rasfile+'_repair.ras', fliph=fliph_image, flipv=flipv_image,compress=compress, percent=percent,overwrite=overwrite
  
  shfile=vdhfile+'.sh'
  
  vdh=TLI_READMYFILES(vdhfile,type='vdh')
  ; Define the params.
  x=vdh[1, *]
  IF KEYWORD_SET(fliph_pt) THEN x=finfo.range_samples-x
  y=vdh[2, *]
  IF NOT KEYWORD_SET(flipv_pt) THEN y=finfo.azimuth_lines-vdh[2, *]
  ;  IF KEYWORD_SET(geocode) THEN y=vdh[2, *]
  
  data=vdh[4, *]
  
  IF KEYWORD_SET(refine) THEN BEGIN
    ind=TLI_REFINE_DATA(data, refined_data=data)
    x=x[*, ind]
    y=y[*, ind]
    data=TRANSPOSE(data)
  ENDIF
  
  IF KEYWORD_SET(minus) THEN BEGIN
    min_data=MIN(data, max=maxdata)
    data=data-min_data
  ENDIF
  
  
  data=data+intercept  ; Use intercept to correct the deformation values.
  
  TLI_WRITE, vdhfile+'.tmp.txt',[x, y, data],/txt
  
  IF ~KEYWORD_SET(minv) THEN minv=MIN(data)
  IF ~KEYWORD_SET(maxv) THEN maxv=MAX(data)
  
  temp=DOUBLE(maxv)-DOUBLE(minv)
  interv=TLI_DEFINE_INTERV(temp)
  colorbar_pos=[xsize*1.1, $
    0.5*ysize,$
    ysize, $
    0.1]  ; Position of colorbar. [startx, centery, height, width]
  IF NOT KEYWORD_SET(colorbar_interv) THEN colorbar_interv=LONG(temp/11)
  IF colorbar_interv EQ 0 THEN BEGIN
    colorbar_interv=FLOAT(temp/5)
    colorbar_interv=STRMID(STRCOMPRESS(colorbar_interv,/remove_all),0, 5)
  ENDIF ELSE BEGIN
    IF colorbar_interv LT 1 THEN colorbar_interv=1
  ENDELSE
  
  xsize_c=STRCOMPRESS(xsize,/REMOVE_ALL)+'i'
  ysize_c=STRCOMPRESS(ysize,/REMOVE_ALL)+'i'
  ptsize_c=STRCOMPRESS(ptsize,/REMOVE_ALL)+'i'
  majorsize=STRCOMPRESS(LONG(finfo.range_samples/tick_major),/REMOVE_ALL)
  minorsize=STRCOMPRESS(LONG(finfo.range_samples/tick_minor),/REMOVE_ALL)
  minv=STRCOMPRESS(minv,/REMOVE_ALL)
  maxv=STRCOMPRESS(maxv,/REMOVE_ALL)
  interv=STRCOMPRESS(interv,/REMOVE_ALL)
  colorbar_pos=STRCOMPRESS(colorbar_pos,/REMOVE_ALL)+'i'
  colorbar_pos=STRJOIN(colorbar_pos,'/')
  colorbar_interv=STRCOMPRESS(colorbar_interv,/REMOVE_ALL)
  ;----------------------------
  
  IF !D.NAME NE 'X' THEN Message, 'System not supported. This can only be operated in Linux.'
  Print, 'Time: '+TLI_TIME(/str)
  Print, 'Plotting the DEM error map. Please wait...'
  CD, FILE_DIRNAME(shfile)
  OPENW, lun, shfile,/GET_LUN
  PrintF,lun, '#!/bin/sh'
  PrintF, lun, 'gmtset ANNOT_FONT_SIZE 9p ANNOT_OFFSET_PRIMARY 0.07i FRAME_WIDTH 0.04i MAP_SCALE_HEIGHT 0.04i \'
  IF KEYWORD_SET(noframe) THEN BEGIN
    PrintF, lun, 'LABEL_FONT_SIZE 10p LABEL_OFFSET 0.05i TICK_LENGTH 0.05i BASEMAP_FRAME_RGB +255/255/255'
  ENDIF ELSE BEGIN
    PrintF, lun, 'LABEL_FONT_SIZE 10p LABEL_OFFSET 0.05i TICK_LENGTH 0.05i'
  ENDELSE
  PrintF, lun, 'output_file="pdem_error.ps"'
  PrintF, lun, '# 创建调色板'
  PrintF, lun, 'makecpt -C'+cpt+' -T'+minv+'/'+maxv+'/'+interv+' -V -Z > g.cpt'
  PrintF, lun, 'psbasemap -R0/'+STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)+'/0/'+STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)+$
    ' -JX'+xsize_c+'/'+ysize_c+' -Ba'+majorsize+'f'+minorsize+'::WeSn -P -K -V  > $output_file'
  PrintF, lun, 'psimage '+rasfile+'_repair.ras'+' -Gtblack -W'+xsize_c+'/'+ysize_c+' -O -K -V >>$output_file'
  IF ~KEYWORD_SET(no_colorbar) THEN BEGIN
    PrintF, lun, 'psxy '+vdhfile+'.tmp.txt'+' -R -J -B -Cg.cpt -V -Sc'+ptsize_c+' -K -O >> $output_file'
    ;  PrintF, lun, 'rm -f '+vdhfile+'.tmp.txt'
    PrintF, lun, 'gmtset BASEMAP_FRAME_RGB +0/0/0'
    PrintF, lun, 'psscale -Cg.cpt -D'+colorbar_pos+' -E -I -O -B'+colorbar_interv+'::/:'+unit+': >> $output_file'
  ENDIF ELSE BEGIN
    PrintF, lun, 'psxy '+vdhfile+'.tmp.txt'+' -R -J -B -Cg.cpt -V -Sc'+ptsize_c+' -O >> $output_file'
  ENDELSE
  IF KEYWORD_SET(dpi) THEN BEGIN
    PrintF, lun, 'ps2raster -A -Tt -E'+STRCOMPRESS(dpi,/REMOVE_ALL)+' $output_file'
  ENDIF ELSE BEGIN
    PrintF, lun, 'ps2raster -A -Tt $output_file'
  ENDELSE
  IF KEYWORD_SET(noframe) THEN BEGIN
    PrintF, lun, 'convert pdem_error.tif -trim -bordercolor White '+outputfile
  ENDIF ELSE BEGIN
    PrintF, lun, 'convert pdem_error.tif '+outputfile
  ENDELSE
  IF KEYWORD_SET(show) THEN BEGIN
    PrintF, lun, 'geeqie '+outputfile
  ;  PrintF, lun, 'shotwell '+outputfile
  ENDIF
  FREE_LUN, lun
  SPAWN, shfile
  IF ~KEYWORD_SET(no_clean) THEN FILE_DELETE, shfile, "pdem_error.ps", "pdem_error.tif", vdhfile+'.tmp.txt','g.cpt',/allow_nonexistent
  
END
