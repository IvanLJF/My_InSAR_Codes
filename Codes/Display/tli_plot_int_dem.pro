;
; Plot DEM generated using my script: tli_interf_SLC using GMT.
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20141211
;

@tli_plot_linear_def
PRO TLI_PLOT_INT_DEM, demfile, dem_segparfile=dem_segparfile, outputfile=outputfile
  COMPILE_OPT idl2
  
  IF NOT FILE_TEST(demfile) THEN BEGIN
    Message, 'Error! File does not exist.'
  ENDIF
  workpath=FILE_DIRNAME(demfile)
  workpath=workpath+PATH_SEP()
  outputfile=demfile+'.tif'
  scrfile=workpath+'plot_int_dem.sh'
  
  IF NOT KEYWORD_SET(dem_segparfile) THEN dem_segparfile=workpath+'dem_seg.par'
  IF NOT FILE_TEST(dem_segparfile) THEN BEGIN
    Message, 'Error! Please specify the dem seg par file.'
  ENDIF
  finfo=TLI_LOAD_PAR(dem_segparfile)
  
  samples=finfo.width
  lines=finfo.nlines
  clat=finfo.corner_lat
  clon=finfo.corner_lon
  plat=ABS(finfo.post_lat)
  plon=finfo.post_lon
  
  ; Check data consistency
  sz=TLI_IMAGE_SIZE(demfile, samples=samples, format='float')
  lines_dem=sz[1]
  IF lines_dem NE lines THEN Message, 'TLI_PLOT_INT_DEM: ERROR! Data are inconsistent, please check the interferometric DEM and the dem_seg par file.'
  
  ; Convert 0.0 to nan
  TLI_VALUE_CONVERT, demfile, samples=samples, format='float',/swap_endian,outputfile=demfile+'.convert', value_in=0.0, value_out=!values.f_nan,$
       min=minv, max=maxv, meanv=meanv,/refine
  
  ;-----------------------------------------------------------------
  ; Calculate default values for GMT
  west1=clon
  alon=plon*(samples-1)
  east1=clon+alon
  north1=clat
  alat=plat*(lines-1)
  south1=clat-alat
  xsize=plon*3600.0
  ysize=plat*3600.0
  
  ; Determine thresholds for height values
  hgt_min=minv
  hgt_max=maxv
  hgt_mean=meanv
  
  hgt_up=ABS(hgt_max-hgt_mean)
  hgt_low=ABS(hgt_mean-hgt_min)
  hgt_semi=hgt_up>hgt_low

  hgt_min=hgt_mean-hgt_semi
  hgt_max=hgt_mean+hgt_semi  

  hgt_interval=TLI_DEFINE_INTERV(maxv-minv)
  
  ; Positions
  com_x=east1-(121.6715-121.63)/(121.6715-121.16333)*alon
  com_y=north1-(31.3183-31.27)/(31.3183-30.8802)*alat
  com_size=0.9
  
  l_x=west1+(121.25-121.163333)/(121.6715-121.16333)*alon
  l_y1=south1+(30.9-30.8802)/(31.3183-30.8802)*alat
  l_y2=l_y1+0.1
  pscoast_msk=0
  grdcontour_msk=1
  
  ; GMT Default values as references.
  ; PrintF, lun, "west1=121.1633333"
  ;  PrintF, lun, "east1=121.67149994634"
  ;  PrintF, lun, "north1=31.3183334"
  ;  PrintF, lun, "south1=30.88016675086"
  ;  PrintF, lun, "xsize=0.59999997600"
  ;  PrintF, lun, "ysize=0.59999997600"
  ;  PrintF, lun, "hgt_min=-20"
  ;  PrintF, lun, "hgt_max=20"
  ;  PrintF, lun, "hgt_interval=1"
  ;  PrintF, lun, ""
  ;  PrintF, lun, "com_x=121.63"
  ;  PrintF, lun, "com_y=31.27"
  ;  PrintF, lun, "com_size=0.9"
  ;  PrintF, lun, ""
  ;  PrintF, lun, "l_x=121.25"
  ;  PrintF, lun, "l_y1=30.9"
  ;  PrintF, lun, "l_y2=31.55"
  ;  PrintF, lun, ""
  
  ;---------------------------------------------------------
  ; Create scripts and execuate plot commands.
  demfile_convert=FILE_BASENAME(demfile+'.convert')
  OPENW, lun, scrfile,/GET_LUN
  PrintF, lun, "#! /bin/sh"
  PrintF, lun, "#####################################"
  PrintF, lun, "## plot_dem: Plot DEM figures using GMT."
  PrintF, lun, "##     using:"
  PrintF, lun, "##       - DEM"
  PrintF, lun, "##  "
  PrintF, lun, "#####################################"
  PrintF, lun, "## History"
  PrintF, lun, "##   20141209: Written by T.LI & CW @ Sasmac"
  PrintF, lun, "#####################################"
  PrintF, lun, "echo ' ' "
  PrintF, lun, "echo '*** plot_dem Plot DEM figures using GMT. v1.0 20141209.'"
  PrintF, lun, "echo ''"
  PrintF, lun, "echo '      Required data:'"
  PrintF, lun, "echo '        - DEM .'"
  PrintF, lun, ""
  PrintF, lun, "if [ $# -lt 0 ]; then"
  PrintF, lun, "  echo 'Usage: plot_dem <dem>'"
  PrintF, lun, "  echo ' '"
  PrintF, lun, "  echo 'input params:'"
  PrintF, lun, "  echo ''"
  PrintF, lun, "  echo 'dem        : Full path of input DEM file.'"
  PrintF, lun, "  echo ' '"
  PrintF, lun, "  exit"
  PrintF, lun, "fi "
  PrintF, lun, ""
  PrintF, lun, "##############################"
  PrintF, lun, "# Assignment"
  PrintF, lun, "#############################"
  PrintF, lun, "dem="+demfile+'.convert'
  PrintF, lun, "out=$dem.ps"
  PrintF, lun, "west1="+STRCOMPRESS(west1,/REMOVE_ALL)
  PrintF, lun, "east1="+STRCOMPRESS(east1,/REMOVE_ALL)
  PrintF, lun, "north1="+STRCOMPRESS(north1,/REMOVE_ALL)
  PrintF, lun, "south1="+STRCOMPRESS(south1,/REMOVE_ALL)
  PrintF, lun, "xsize="+STRCOMPRESS(xsize,/REMOVE_ALL)
  PrintF, lun, "ysize="+STRCOMPRESS(ysize,/REMOVE_ALL)
  PrintF, lun, "hgt_min="+STRCOMPRESS(hgt_min,/REMOVE_ALL)
  PrintF, lun, "hgt_max="+STRCOMPRESS(hgt_max,/REMOVE_ALL)
  PrintF, lun, "hgt_interval="+STRCOMPRESS(hgt_interval,/REMOVE_ALL)
  PrintF, lun, ""
  PrintF, lun, "com_x="+STRCOMPRESS(com_x,/REMOVE_ALL)
  PrintF, lun, "com_y="+STRCOMPRESS(com_y,/REMOVE_ALL)
  PrintF, lun, "com_size="+STRCOMPRESS(com_size,/REMOVE_ALL)
  PrintF, lun, ""
  PrintF, lun, "l_x="+STRCOMPRESS(l_x,/REMOVE_ALL)
  PrintF, lun, "l_y1="+STRCOMPRESS(l_y1,/REMOVE_ALL)
  PrintF, lun, "l_y2="+STRCOMPRESS(l_y2,/REMOVE_ALL)
  PrintF, lun, ""
  PrintF, lun, "xyz2grd $dem -G$dem.grd -I$xsize'c'/$ysize'c' -R$west1/$east1/$south1/$north1 -ZTLfw"
  PrintF, lun, ""
  PrintF, lun, "# resample to the resolution for 1:5000 DEM data (-I2.5e) and trimmed to the same size"
  PrintF, lun, "grdsample $dem.grd -G$dem.res.grd -I$xsize'c'/$ysize'c'"
  PrintF, lun, "grdgradient $dem.res.grd -Ne0.6 -A45/315 -Ggradient.grd"
  PrintF, lun, "makecpt -T$hgt_min/$hgt_max/$hgt_interval -Cnrwc.cpt > g.cpt"
  PrintF, lun, ""
  PrintF, lun, "# Plot"
  PrintF, lun, "gmtset ANNOT_FONT_SIZE 12p ANNOT_OFFSET_PRIMARY 0.07i FRAME_WIDTH 0.06i MAP_SCALE_HEIGHT 0.04i \"
  PrintF, lun, "LABEL_FONT_SIZE 12p LABEL_OFFSET 0.05i TICK_LENGTH 0.08i"
  PrintF, lun, ""
  PrintF, lun, "grdimage $dem.res.grd -Igradient.grd -R$west1/$east1/$south1/$north1 -JM16c -Cg.cpt -Q -K -P -V > $out"
  PrintF, lun, ""
  PrintF, lun, "psbasemap -Ba0.2/a0.1WSEN -JM16c -R$west1/$east1/$south1/$north1 -K -Tf$com_x/$com_y/$com_size/1 -Lf$l_x/$l_y1/$l_y2/10+l -O -P --HEADER_FONT_SIZE=12p --HEADER_OFFSET=0.05i -V >> $out"
  IF KEYWORD_SET(pscoast_msk) THEN PrintF, lun, "pscoast -JM16c -R$west1/$east1/$south1/$north1 -W -K -O -Df -Slightblue -Ia/1p/88/196/227 -V >>$out"
  IF KEYWORD_SET(grdcontour_msk) THEN PrintF, lun, "grdcontour $dem.res.grd -C5 -A5+s9 -Gd3i -JM16c -K -O -S10 -T:'-+' -W >> $out"
  PrintF, lun, 'psscale -B'+STRCOMPRESS(LONG((hgt_max-hgt_min)/6.0),/REMOVE_ALL)+'/:"m": -Cg.cpt -D14c/2c/3c/0.3c -O -I -E>>$out'
  PrintF, lun, "ps2raster $out -A -Tt"
  PrintF, lun, "convert `basename $out '.ps'`.tif "+outputfile
  PrintF, lun, "#geeqie "+outputfile
  FREE_LUN, lun
  
  CD, workpath, current=pwd
  Print, 'Plotting DEM figures using GMT. Please wait...'
  SPAWN, scrfile
  CD, pwd
  
END