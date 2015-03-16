;
; Export the slc ranges for all the images in the given dir.
;
; Parameters:
;   inputdir   : Working directory.
;
; Keywords:
;   outputdir  : Output directory.
;                The files are named as dirname+'YYYYMMDD.kml'
;   merge      : Merge the results or not.
;
; Written by:
;   T.LI @ Sasmac, 201470919
;
@kml
PRO TLI_SLC_RANGE_ALL, inputdir, outputdir=outputdir, merge=merge

  COMPILE_OPT idl2
  IF NOT KEYWORD_SET(outputdir) THEN BEGIN
    IF NOT TLI_HAVESEP(inputdir) THEN inputdir=inputdir+PATH_SEP()
    outputdir=inputdir+'kml'+PATH_SEP()
  ENDIF
  IF KEYWORD_SET(merge) THEN outputdir=FILE_DIRNAME(outputdir)+PATH_SEP()
  IF NOT FILE_TEST(outputdir,/DIRECTORY) THEN BEGIN
    FILE_MKDIR, outputdir
  ENDIF
  
  parfiles=FILE_SEARCH(inputdir, "*.slc.par", count=nfiles)
  IF nfiles EQ 0 THEN BEGIN
    parfiles=FILE_SEARCH(inputdir, "*.rslc.par", count=nfiles)
  ENDIF
  
  IF NOT KEYWORD_SET(merge) THEN BEGIN
    FOR i=0L, nfiles-1L DO BEGIN
      parfile=parfiles[i]
      outputfile=outputdir+FILE_BASENAME(FILE_DIRNAME(parfile))+'_'+FILE_BASENAME(parfile)+'.kml'
      TLI_SLC_RANGE, parfiles[i], outputfile=outputfile
    ENDFOR
  ENDIF ELSE BEGIN
    outputfile=outputdir+FILE_BASENAME(inputdir)+'.kml'
    ; Make kml file
    ; First write 4 corner points.
    I_err=Open_KML(outputfile,I_Unit)
    Transparency='ff'
    Style_iconscale=0.8
    Style_iconhref='http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
    style_names=['UL', 'DL', 'DR', 'UR']
    
    Style_iconcolor=Transparency+STRING(0,255,0,format='(3z2.2)')
    FOR i=0, 3 DO BEGIN
      Style_name=style_names[i]
      Style_KML,  I_Unit, Style_Name,  $
        Style_iconcolor=Style_iconcolor, Style_iconscale=Style_iconscale,$
        Style_iconhref=Style_iconref,Style_labelcolor=Style_labelcolor
    ENDFOR
    
    Begin_Folder_KML, I_Unit
    
    FOR i=0L, nfiles-1 DO BEGIN
      parfile=parfiles[i]
      ; Call SLC_corners to calculate SLC corners.
      scr='SLC_corners '+parfile+' >tli_slc_range_temp'
      workpath=FILE_DIRNAME(parfile)+PATH_SEP()
      CD, current=temp
      CD, workpath
      SPAWN, scr
      CD, temp
      
      ; Read results from SLC_corners
      slc_range=TLI_READTXT(workpath+'tli_slc_range_temp',/txt)
      slc_range=slc_range[*, 2:5]
      
      slc_range=TLI_STRSPLIT(slc_range)
      
      slc_range=DOUBLE(slc_range[[2, 5], *])
      
      ; Determine the connections.
      slc_range=TLI_SLC_RANGE_CONNECTION(slc_range)
      
      
      
      For j=0, 3 DO BEGIN
        Point_KML, I_Unit, [slc_range[*, j], 0], Style_name=style_names[j],$
          descri='[lon., lat.] = ['+STRCOMPRESS(slc_range[1, j],/REMOVE_ALL)+', '+STRCOMPRESS(slc_range[0,j],/REMOVE_ALL)+']'+ STRING(13b)+STRING(13b)
      ENDFOR
      
      
      
      ; Second write the ractangle.
      annotation=''
      polygon=[slc_range, FLTARR(1,4)]
      polygon=[[polygon], [polygon[*, 0]]]
      description='SLC par file:'+parfile+STRING(13b)+STRING(13b)+$
        'SLC corners:'+STRING(13b)+STRING(13b)+$
        TLI_ARRAY2STRING(slc_range)+STRING(13b)+STRING(13b)+$
        annotation
        
      Polygon_kml, I_Unit , polygon, name='Range of SLC: '+FILE_BASENAME(parfile), color=Transparency+STRING(0,255,255, format='(3z2.2)'),description=description
      
    ENDFOR
    
    ; Close the KML file.
    End_Folder_KML, I_Unit
    Close_KML,  I_Unit
    ;----------------------------
    
    FILE_DELETE, workpath+'tli_slc_range_temp'
  ENDELSE
  Print, ""
  Print, ".kml file was output successfully, please check the file:"
  Print, outputfile
  Print, "" 
  Print, 'Task finished at time: '+TLI_TIME(/str)
END