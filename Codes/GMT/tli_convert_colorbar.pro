FUNCTION TLI_LOAD_SURFER_COLORBAR, inputfile
  ; Check the file suffix.
  IF NOT (KEYWORD_SET(inputfile)) THEN Message, 'Error: File not exist:' $
     +STRING(13b)+inputfile
  suffix=STRSPLIT(inputfile,'.',/EXTRACT,count=temp)
  IF temp EQ 0 THEN Message, 'File type is not recognized.'
  
  nlines=FILE_LINES(inputfile)
  strs=STRARR(1, nlines)
  OPENR, lun, inputfile,/GET_LUN
  READF, lun, strs
  FREE_LUN, lun
  
  ; Jump the first line
  strs=strs[*,1:*]
  strs=TLI_STRSPLIT(strs)
  sz=SIZE(strs,/DIMENSIONS)
  nlines=sz[1]
  
  Print, 'Number of the classes:'+STRCOMPRESS(nlines)
  
  mins=DOUBLE(strs[1,*])
  maxs=DOUBLE(strs[0,*])
  symbols=strs[2,*]+' '+strs[3,*]
  unknown=LONG(strs[4,*])
  r=LONG(strs[5,*])
  g=LONG(strs[6,*])
  b=LONG(strs[7,*])
  
  unknowd=FLOAT(strs[8, *])
  ptsize=FLOAT(strs[9,*])
  
  cbinfo=CREATE_STRUCT('mins',0D,'maxs',0D,'symbols',' ', 'r', 0L, 'g', 0L, 'b',0L, 'ptsize', 0.0)
  cbinfo=REPLICATE(cbinfo,nlines)
  cbinfo.mins=TRANSPOSE(mins)
  cbinfo.maxs=TRANSPOSE(maxs)
  cbinfo.symbols=TRANSPOSE(symbols)
  cbinfo.r=TRANSPOSE(r)
  cbinfo.g=TRANSPOSE(g)
  cbinfo.b=TRANSPOSE(b)
  cbinfo.ptsize=TRANSPOSE(ptsize)
  
  RETURN, cbinfo

END

PRO TLI_CONVERT_COLORBAR, inputfile, outputfile=outputfile, surfer2gmt=surfer2gmt, inverse=inverse
  
  COMPILE_OPT idl2
  
  inverse=1
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/surfer'+PATH_SEP()
  cbfile=workpath+'Gamma1.cls'
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=workpath+'GMT_surfer_'+FILE_BASENAME(cbfile, '.cls')+'.cpt'
  
  cbinfo=TLI_LOAD_SURFER_COLORBAR(cbfile)
  
  ; Write header for .cpt file
  OPENW, lun, outputfile,/GET_LUN
  PrintF, lun, '#  $Id: GMT_surfer.cpt v0.1 2013-7-20 14:46:25 $'
  PrintF, lun, '#  Designed by Prof. Guoxiang Liu @ SWJTU'
  PrintF, lun, '#  Created by T. LI @ ISEIS'
  PrintF, lun, '#  COLOR_MODEL= RGB'
   
  ; Prepare the data for .cpt file
  start_v=cbinfo.mins
  end_v=cbinfo.maxs
  r=cbinfo.r
  g=cbinfo.g
  b=cbinfo.b
  
  IF KEYWORD_SET(inverse) THEN BEGIN
    ; The color is inversed.
    Print, 'The color will be inversed.'
    r=ROTATE(r, 5)
    g=ROTATE(g, 5)
    b=ROTATE(b, 5)
  ENDIF
  
  colors=[[r],[g],[b]]
  
  ; Normolization. Change the range to [-1 1]
  all_v=tli_stretch_data(start_v, [-1,1])
  n_all_v=N_ELEMENTS(all_v)
  start_v_n=all_v[1:*]
  end_v_n=all_v[0:(n_all_v-2)]
  
  result=[[end_v_n], [colors[0:(n_all_v-2),*]],[start_v_n], [colors[ 1:(n_all_v-1), *]]]
  PrintF, lun, TRANSPOSE(result), format='(F8.4, I4, I4, I4, F8.4, I4, I4, I4)'
  FREE_LUN, lun
  
  Print, 'The colorbar is successfully converted. Please check the file:'
  Print, outputfile


END