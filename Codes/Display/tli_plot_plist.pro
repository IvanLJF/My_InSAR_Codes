

;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/PCP'
;  workpath=workpath+PATH_SEP()
;
;  plistfile=workpath+'lel1plist'
;  rasfile=FILE_DIRNAME(workpath)+PATH_SEP()+'ave.ras'
;  sarlistfile=workpath+'sarlist_Linux'
;  outputfile=workpath+'PS_POINTS.png'
;
;;  ptsize=0.01
;  TLI_PLOT_PLIST_FUN,plistfile, rasfile, sarlistfile, $
;    gamma=gamma, outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,frame=frame, $
;    tick_major=tick_major,tick_minor=tick_minor


@ tli_plot_linear_def
PRO TLI_FLIP, inputfile, finfo, v=v, h=h, outputfile=outputfile, type=type,gamma=gamma

  ON_ERROR, 2
  
  ; Mirror the file.
  IF not KEYWORD_SET(v) AND not KEYWORD_SET(h) THEN BEGIN
    v=1
  ENDIF
  IF NOT KEYWORD_SET(type) THEN type='plist'
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    IF KEYWORD_SET(v) THEN BEGIN
      outputfile=inputfile+'_v_flip'
    ENDIF ELSE BEGIN
      outputfile=inputfile+'_h_flip'
    ENDELSE
  ENDIF
  IF KEYWORD_SET(gamma) THEN BEGIN
    data=TLI_READDATA(inputfile,samples=2, format='LONG',/swap_endian)
    data=COMPLEX(data[0, *], data[1, *])
  ENDIF ELSE BEGIN
    data=TLI_READMYFILES(inputfile, type=type)
    
  ENDELSE
  type=STRUPCASE(type)
  
  IF KEYWORD_SET(v) THEN BEGIN
    CASE type OF
      'PLIST': BEGIN
        data=COMPLEX(REAL_PART(data), finfo.azimuth_lines-IMAGINARY(data))
      END
      'VDH': BEGIN
        data[2,*]=finfo.azimuth_lines-data[2, *]
      END
      ELSE: BEGIN
        Message, 'The keyword type:"'+type+'" is not legall.'
      END
    ENDCASE
    
  ENDIF ELSE BEGIN
    CASE type OF
      'PLIST': BEGIN
        data=COMPLEX(finfo.range_samples-REAL_PART(data), IMAGINARY(data))
      END
      'VDH': BEGIN
        data[1,*]=finfo.range_samples-data[1, *]
      END
      ELSE: BEGIN
        Message, 'The keyword type:"'+type+'" is ilegall.'
      END
    ENDCASE
  ENDELSE
  OPENW, lun, outputfile,/GET_LUN
  WriteU, lun, data
  FREE_LUN,  lun
  
END

PRO TLI_PLOT_PLIST, plistfile, rasfile, sarlistfile, $
    gamma=gamma, outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,frame=frame, $
    tick_major=tick_major,tick_minor=tick_minor,show=show, ptcolor=ptcolor
  COMPILE_OPT idl2
  ON_ERROR, 2
  ; plistfile    : point listfile.
  ; rasfile      : The base image. Only support '*.ras'
  ; sarlistfile  : sarlist file.
  ; gamma        : If the plist file is generated using GAMMA.
  ; outputfile   : The output file. Kinds of format is supported.
  ; xsize        : Size of x dimensions. Unit: inch. Default:3
  ; ysize        : Size of y dimensions. If not specified, calculated from xsize.
  ; ptsize       : Point size. Unit: inch.  Default:0.03
  ; frame        : Show frame or not.
  ; tick_major   : Number of major ticks.
  ; tick_minor   : Number of minor ticks.
  
  IF KEYWORD_SET(gamma) THEN BEGIN
    swap_endian=1
  ENDIF
  IF NOT KEYWORD_SET(tick_major) THEN tick_major=5
  IF NOT KEYWORD_SET(tick_minor) THEN tick_minor=tick_major*10
  IF NOT KEYWORD_SET(ptsize) THEN ptsize=0.01
  IF NOT KEYWORD_SET(ptcolor) THEN ptcolor='green'
  
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  IF NOT KEYWORD_SET(xsize) THEN BEGIN
    xsize=3
  ENDIF
  IF NOT KEYWORD_SET(ysize) THEN BEGIN
    ysize=xsize/finfo.range_samples*finfo.azimuth_lines
  ENDIF
  IF not KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=plistfile+'.jpg'
  ENDIF
  
  
  xsize=STRCOMPRESS(xsize,/REMOVE_ALL)+'i'
  ysize=STRCOMPRESS(ysize,/REMOVE_ALL)+'i'
  ptsize=STRCOMPRESS(ptsize,/REMOVE_ALL)+'i'
  majorsize=STRCOMPRESS(finfo.range_samples/tick_major)
  minorsize=STRCOMPRESS(finfo.range_samples/tick_minor)
  
  
  shfile=plistfile+'.sh'
  IF NOT KEYWORD_SET(gamma) THEN BEGIN
    TLI_FLIP, plistfile, finfo,/v, outputfile=plistfile+'.tmp0'
    TLI_GAMMA2MYFORMAT_PLIST, plistfile+'.tmp0', plistfile+'.tmp',/REVERSE
    TLI_DAT2ASCII, plistfile+'.tmp', outputfile=plistfile+'.txt',samples=2, format='LONG', /swap_endian
    FILE_DELETE, plistfile+'.tmp0', plistfile+'.tmp'
  ENDIF ELSE BEGIN
    TLI_DAT2ASCII, plistfile, outputfile=plistfile+'.txt',samples=2, format='LONG',/swap_endian
  ENDELSE
  
  ; Repair the image
  TLI_REPAIR_IMAGE, rasfile, outputfile=rasfile+'.ras'
  
  CD, FILE_DIRNAME(plistfile)
  output_ps='pt.ps'
  OPENW, lun, shfile,/GET_LUN
  PrintF,lun, '#!/bin/sh'
  PrintF, lun, 'gmtset ANNOT_FONT_SIZE 9p ANNOT_OFFSET_PRIMARY 0.07i FRAME_WIDTH 0.04i MAP_SCALE_HEIGHT 0.04i \'
  PrintF, lun, 'LABEL_FONT_SIZE 10p LABEL_OFFSET 0.05i TICK_LENGTH 0.05i'
  PrintF, lun, 'output_file='+output_ps
  IF NOT KEYWORD_SET(frame) THEN BEGIN
    PrintF, lun, 'psbasemap -R0/'+STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)+'/0/'+STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)+$
      ' -JX'+xsize+'/'+ysize+' -B::wesn -P -K -V  > $output_file'
  ENDIF ELSE BEGIN
    PrintF, lun, 'psbasemap -R0/'+STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)+'/0/'+STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)+$
      ' -JX'+xsize+'/'+ysize+' -Ba'+majorsize+'f'+minorsize+'::WeSn -P -K -V  > $output_file'
  ENDELSE
  PrintF, lun, 'psimage '+rasfile+'.ras'+' -Gtblack -W'+xsize+'/'+ysize+' -O -K -V >>$output_file'
  PrintF, lun, 'psxy '+plistfile+'.txt'+' -G'+ptcolor+' -R -J -B -V -Sc'+ptsize+' -O >> $output_file'
  PrintF, lun, 'ps2raster -A -Tb $output_file'
  PrintF, lun, 'convert pt.bmp '+outputfile
  IF KEYWORD_SET(show) THEN BEGIN
    PrintF, lun, 'xv '+outputfile
  ENDIF
  FREE_LUN, lun
  Print, 'Running the script, please wait...'
  SPAWN, shfile
  
  FILE_DELETE, 'pt.bmp',output_ps, shfile,plistfile+'.txt'
END
