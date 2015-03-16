; Show all the deformation points in google earth.
; Add colorbar.
;
; pmapllfile       : Lon. and lat. extracted from GAMMA.
; pdeffile         : Deformation veloctiy for each point.
; cptfile          : Colorbar file. Generated from GMT.
; colorbarfile     : Colorbar image.
; kmlfile          : Outputfile
; phgtfile         : Height value extracted from GAMMA.
; gamma            : If the files are all from GAMMA, then add the keyword. Or else, not.
; maxv             : Max value to draw.
; minv             : Min value to draw.
; colortable_Name  : Name of colortable. Rainbow
; unit             : Unit of the pdeffile. mm/yr
; vacuate          : To vacuate the points. If this keyword is set, only 10000 points are selected.
;
; e.g.:
;workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/geocode/noborder'
;  workpath=workpath+PATH_SEP()
;
;  pmapllfile=workpath+'pdef'
;
;  hpapath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/'
;  vdhfile=workpath+'lel8vdh_merge'
;  pmapllfile=workpath+'lel8plist.pmapll'
;  vacuate=1
;
;  TLI_DEFINGOOGLE,pmapllfile, vdhfile, cptfile=cptfile,  colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
;    maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
;    refine_data=refine_data,delta=delta,refined_data=refined_data
;
; T.LI @ ISEIS, 20130628
@tli_plot_linear_def
@kml
PRO TLI_DEFINGOOGLE,pmapllfile, vdhfile, cptfile=cptfile, colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
    maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
    refine_data=refine_data,delta=delta,refined_data=refined_data,randomu=randomu,randomn=randomn, minus=minus,hgt=hgt
    
  ; Check the env. .
  IF !D.name EQ 'Win' Then Message, 'ERROR: Do not support non-Unix platform.'
  
  ; Check the input file
  workpath=FILE_DIRNAME(vdhfile)+PATH_SEP()
  IF KEYWORD_SET(GAMMA) THEN swap_endian=1
  pmapll=TLI_READDATA(pmapllfile, samples=2, format='FLOAT', /swap_endian)
  vdh=TLI_READMYFILES(vdhfile,type='vdh')
  
  IF KEYWORD_SET(hgt) THEN BEGIN
    pdef=vdh[4, *]
  ENDIF ELSE BEGIN
    pdef=vdh[3, *]
  ENDELSE
  
  lon_max=MAX(pmapll[0, *], min=lat_min)
  lat_max=MAX(pmapll[1, *], min=lon_min)
  IF lat_max GE 90 THEN Message, 'ERROR: The following file should be organized as [longitude, latitude]'$
    +STRING(13B)+pmapllfile
  IF KEYWORD_SET(minus) THEN pdef=pdef-MAX(pdef)
  IF NOT KEYWORD_SET(maxv) THEN maxv=MAX(pdef)
  IF NOT KEYWORD_SET(minv) THEN minv=MIN(pdef)
  IF NOT KEYWORD_SET(colortable_name) THEN colortable_name='tli_def'
  
  IF NOT KEYWORD_SET(unit) THEN BEGIN
    IF KEYWORD_SET(hgt) THEN BEGIN
      unit='m'
    ENDIF ELSE BEGIN
      unit='mm/yr'
    ENDELSE
  ENDIF  
  
  IF NOT KEYWORD_SET(kmlfile) THEN kmlfile=vdhfile+'.kml'
  IF NOT KEYWORD_SET(colorbarfile) THEN colorbarfile=workpath+'colorbar_'+colortable_name+'.jpg'
  IF NOT KEYWORD_SET(npt_final) THEN npt_final=10000
  pdeffile=pmapllfile+'.pdef'
  temp=[pmapll, pdef]
  TLI_WRITE, pdeffile, temp
  TLI_WRITE, pdeffile+'.txt',temp,/txt
  
  IF ABS(maxv)+ABS(minv) EQ 0 THEN BEGIN
    maxv=1
    minv=-1
  ENDIF
  
  IF NOT KEYWORD_SET(cptfile) THEN BEGIN
    ; Create a new one
    colorbar_interv=LONG((maxv-minv)/10)>1
    colorbar_interv=STRCOMPRESS(colorbar_interv,/remove_all)
    cptfile=vdhfile+'.cpt'
    interv=TLI_DEFINE_INTERV(maxv-minv)
    shfile=workpath+'plot_gmt_colorbar_tmp.sh'
    OPENW, lun, shfile,/GET_LUN
    PrintF, lun,"#!/bin/sh"
    PrintF, lun,""
    PrintF, lun,"echo '****************************************'"
    PrintF, lun,"echo '* Plotting GMT colorbar... *' "
    PrintF, lun,"echo '****************************************'"
    PrintF, lun,"cbfile='colorbar_tmp.ps'"
    PrintF, lun,"minv="+STRCOMPRESS(minv,/REMOVE_ALL)
    PrintF, lun,"maxv="+STRCOMPRESS(maxv,/REMOVE_ALL)
    PrintF, lun,"interv="+STRCOMPRESS(interv,/REMOVE_ALL)
    PrintF, lun,""
    PrintF, lun,"gmtset ANNOT_FONT_SIZE 9p ANNOT_OFFSET_PRIMARY 0.07i FRAME_WIDTH 0.04i MAP_SCALE_HEIGHT 0.04i \"
    PrintF, lun,"LABEL_FONT_SIZE 10p LABEL_OFFSET 0.05i TICK_LENGTH 0.05i"
    PrintF, lun,""
    IF KEYWORD_SET(color_inverse) THEN BEGIN
      PrintF, lun,"makecpt -C"+colortable_name+" -T$minv/$maxv/$interv -V -Z > "+cptfile
    ENDIF ELSE BEGIN
      PrintF, lun,"makecpt -C"+colortable_name+" -T$minv/$maxv/$interv -I -V -Z > "+cptfile
    ENDELSE
    PrintF, lun,"######################################################"
    PrintF, lun,"# plot geocoded results."
    PrintF, lun,"psbasemap -R0/100/0/100 -JX1i/1i -B::wesn -P -K -V  > $cbfile"
    PrintF, lun,"psscale -C"+FILE_BASENAME(cptfile)+" -D1.2i/0.5i/1.9i/0.15i -E -I -O -B"+colorbar_interv+"::/:"+unit+": -V >> $cbfile"
    PrintF, lun,"ps2raster -A -Tb $cbfile"
    FREE_LUN, lun
    CD, workpath
    SPAWN, shfile
    ; Subset the image.
    tempfile=workpath+'colorbar_tmp.bmp'
    temp=READ_IMAGE(tempfile)
    temp=temp[*, 327:*, *]
    
    WRITE_IMAGE, tempfile+'.bmp', 'BMP',temp
    scr='convert colorbar_tmp.bmp.bmp '+colorbarfile
    SPAWN, scr
    FILE_DELETE, "colorbar_tmp.ps", shfile, "colorbar_tmp.bmp", "colorbar_tmp.bmp.bmp"
  ENDIF
  
  ;  ctfile=workpath+'mycolors.tbl' ; My color table. Arbitrary file name.
  ;  pdeffile=workpath+'pdef_geo.txt' ; The deformation result. 3 columns: lat, lon, def.
  ;  colorbarfile=workpath+'colorbar_def.jpg' ; The colorbar image.
  ;  kmlfile=workpath+'p_def.kml' ; The output file.
  ;  phgtfile=workpath+'phgt'
  ;  ;  phgtfile=FILE_DIRNAME(workpath)+PATH_SEP()+'lel1phgt_update' ; The height file. Can be used to explore 4-D information.
  
  ;-------Convert color table------
  gmt_color=TLI_READTXT(cptfile,header_lines=3,end_lines=3)
  v_s=gmt_color[0,*]         ; Start value
  color_s=gmt_color[1:3, *]  ; Start color
  v_e=gmt_color[4,*]         ; end value
  color_e=gmt_color[5:7, *]  ; end color
  v=[v_s,v_e]
  min_v=MIN(v, max=max_v)
  color=[[color_s[*,0]], [color_e[*,1:*]]]
  COLOR_CONVERT, color, color_rgb,/HSV_RGB
  ncolors=N_ELEMENTS(v_s)
  x=FINDGEN(ncolors)*255/(ncolors)
  R=INTERPOL(color_rgb[0, *],x, INDGEN(256))
  G=INTERPOL(color_rgb[1, *],x, INDGEN(256))
  B=INTERPOL(color_rgb[2, *],x, INDGEN(256))
  colors=TRANSPOSE([[BYTE(R)],[BYTE(G)],[BYTE(B)]])
  
  ; Write to file
  color_ind=1
  MODIFYCT, color_ind, 'Rainbow_GMT',R,G,B
  ;------------------------------
  
  ;---------Read data-------------
  pdef=TLI_READTXT(pdeffile+'.txt',/easy)
  IF KEYWORD_SET(phgtfile) THEN BEGIN
    phgt=TLI_READDATA(phgtfile,samples=1, format='Float',/swap_endian)
  ENDIF ELSE BEGIN
    phgt=FLTARR(1,file_lines(pdeffile+'.txt'))
  ENDELSE
  npt_orig=FILE_LINES(pdeffile+'.txt')
  npt_phgt=N_ELEMENTS(phgt)
  IF npt_orig NE npt_phgt THEN Message, 'Error: Dimensions of pdeffile and phgtfile are not the same.'
  ;-------------------------------
  
  IF KEYWORD_SET(vacuate) THEN BEGIN
    ;---------vacuate the points------------
    IF NOT KEYWORD_SET(npt_final) THEN npt_final=10000
    npt=npt_final
    IF npt GE npt_orig THEN BEGIN
      Print, 'Waring: Points exported to kml should be less than original points.'
      npt=npt_orig
    ENDIF
    IF KEYWORD_SET(randomu) THEN BEGIN
      ind=RANDOMU(seed,npt)
    ENDIF ELSE BEGIN
      ind=RANDOMN(seed, npt)
    ENDELSE
    min_ind=MIN(ind, max=max_ind);////////////////////////
    ind=(ind-min_ind)/(max_ind-min_ind);/////////////////////////////
    
    ind=LONG(ind*npt_orig)
    ind=ind[SORT(ind)]
    ind=ind[UNIQ(ind)]
    npt=N_ELEMENTS(ind)
    Print, 'The real number of the points:'+STRING(N_ELEMENTS(ind))
    pdef=pdef[*, ind]
    coors=[pdef[1,*],pdef[0,*]]
    def=pdef[2, *]
    pdem=phgt[*,ind]
  ;-----------------------------
  ENDIF ELSE BEGIN
    pdem=phgt
    npt=N_ELEMENTS(pdem)
    def=pdef[2, *]
    coors=[pdef[1, *], pdef[0, *]]
  ENDELSE
  
  coors_3d=[coors, pdem]
  
  ; Refind data
  IF KEYWORD_SET(refine_data) THEN BEGIN
    ind=TLI_REFINE_DATA(def)
    pdef=pdef[*, ind]
    coors_3d=coors_3d[*, ind]
  ENDIF
  ;-----------------
  
  ;--------------Write KML-------------
  I_err=Open_KML(kmlfile,I_Unit)
  ; Define style map
  Transparency='ff'
  Style_iconscale=0.4
  Style_iconhref='http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
  Min_Value=minv
  Max_Value=maxv
  
  For i=0D, npt-1D DO BEGIN
    IF ~(i MOD 10000) THEN Print, STRCOMPRESS(i), '/', STRCOMPRESS(npt-1D)
    Style_name='shaded_dot'+STRCOMPRESS(i,/REMOVE_ALL)
    Style_iconcolor=Color_KML( def[i], Min_Value, Max_Value, COLOR_TB=Color_Tb, TRANSPARENCY=Transparency,Colors=Colors)
    Style_KML,  I_Unit, Style_Name,  $
      Style_iconcolor=Style_iconcolor, Style_iconscale=Style_iconscale,$
      Style_iconhref=Style_iconref,Style_labelcolor=Style_labelcolor
  ENDFOR
  Begin_Folder_KML, I_Unit
  For i=0D, npt-1D DO BEGIN
    IF ~(i MOD 10000) THEN Print, STRCOMPRESS(i), '/', STRCOMPRESS(npt-1D)
    Point_KML, I_Unit, coors_3d[*, i], Style_name='shaded_dot'+STRCOMPRESS(i,/REMOVE_ALL),$
      descri='Subsidence rate: '+STRCOMPRESS(def[i],/REMOVE_ALL)+' mm/yr'+STRING(13b)+'Height: '+STRCOMPRESS(pdem[i],/REMOVE_ALL)+' m'
  ENDFOR
  
  End_Folder_KML, I_Unit
  
  ctimagefile= ColorBar_KML(I_Unit, '', Min_V, Max_V, color_ind, 0, 0,colorbar_imagename=colorbarfile)
  ;  ENDELSE
  
  Close_KML,  I_Unit
  ;----------------------------
  Print, 'Outputfile:'+kmlfile
  Print, 'Main Pro Finished at:', STRCOMPRESS(STRJOIN(TLI_TIME()))

END