;
; Convert the file format using given constrains.
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 201410111.
;
PRO TLI_FORMAT_CONVERT, inputfile, samples, input_format, outputfile=outputfile, output_format=output_format, $
    input_swap_endian=input_swap_endian, output_swap_endian=output_swap_endian
    
  COMPILE_OPT idl2
  
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=inputfile+'.convert'
  IF NOT KEYWORD_SET(output_format) THEN output_format=output_format
  
  ; Using file-tiling technique to process the files block-by-block
  sz=TLI_IMAGE_SIZE(inputfile, samples=samples, format=input_format)
  lines=sz[1]
  pos=0D
  blk_lines=500D
  
  IF KEYWORD_SET(input_swap_endian) THEN BEGIN
    OPENR, inputlun, inputfile,/GET_LUN,/swap_endian
  ENDIF ELSE BEGIN
    OPENR, inputlun, inputfile,/GET_LUN
  ENDELSE
  
  IF KEYWORD_SET(output_swap_endian) THEN BEGIN
    OPENW, outputlun, outputfile,/GET_LUN,/swap_endian
  ENDIF ELSE BEGIN
    OPENW, outputlun, outputfile,/GET_LUN
  ENDELSE
  
  nblks=CEIL(lines/blk_lines)
  
  input_format=STRLOWCASE(input_format)
  output_format=STRLOWCASE(output_format)
  
  j=0
  IF input_format EQ 'alt_sample_data' THEN BEGIN
    blks_all=nblks*2
  ENDIF ELSE BEGIN
    blks_all=nblks
  END
  FOR i=0, nblks-1 DO BEGIN
    Print, 'Format converting: '+STRCOMPRESS(i+(nblks-1)*j,/REMOVE_ALL)+'/'+STRCOMPRESS((blks_all),/REMOVE_ALL)
    start_line=blk_lines*i
    end_line=(blk_lines*(i+1D)-1D)<(lines-1)
    nlines_i=end_line-start_line+1
    Case input_format OF
      'float': BEGIN
        arr=FLTARR(samples,nlines_i)
        ele_size=4
      END
      'double': BEGIN
        arr=DBLARR(samples, nlines_i)
        ele_size=8
      END
      'fcomplex': BEGIN
        arr=COMPLEXARR(samples*2, nlines_i)
        ele_size=8
      END
      'int': BEGIN
        arr=INTARR(samples, nlines_i)
        ele_size=2
      END
      'byte': BEGIN
        arr=BYTARR(samples, nlines_i)
        ele_size=1
      END
      'scomplex': BEGIN
        arr=INTARR(samples*2, nlines_i)
        ele_size=4
      END
      'alt_line_data': BEGIN
        arr=FLTARR(samples*2, nlines_i)
        ele_size=8
      END
      'alt_sample_data': BEGIN
        arr=FLTARR(samples, nlines_i)
        ele_size=8
      END
      ELSE: BEGIN
        Message, 'ERROR: TLI_FORMAT_CONVERT, format not supported:'+input_format
      END
    ENDCASE
    
    ; Locate the pointer
    pos=start_line*samples*ele_size
    POINT_LUN, inputlun, pos
    
    IF input_format EQ 'alt_line_data' THEN BEGIN
      READU, inputlun, arr
      arr=arr[samples: samples*2-1, *]
    ENDIF ELSE BEGIN
      IF input_format NE 'alt_sample_data' AND j EQ 0 THEN READU, inputlun, arr  ; Do not read data of alt_sample_data band 2.
    ENDELSE
    
    Case output_format OF
      'float': BEGIN
        IF input_format NE 'float' AND input_format NE 'fcomplex' THEN arr=FLOAT(arr)
      END
      'double': BEGIN
        IF input_format NE 'double' THEN arr=DOUBLE(arr)
      END
      'fcomplex': BEGIN
        IF input_format NE 'scomplex' THEN BEGIN
          arr=COMPLEX(arr, FLTARR(samples, nlines_i))
        ENDIF ELSE BEGIN
          arr=FLOAT(arr)
        ENDELSE
      END
      'scomplex': BEGIN
        IF input_format NE 'fcomplex' THEN BEGIN
          arr=COMPLEX(arr, INTARR(samples, nlines_i))
        ENDIF ELSE BEGIN
          arr=FIX(arr)
        ENDELSE
      END
      'int': BEGIN
        IF input_format NE 'int' AND input_format NE 'scomplex' THEN arr=FIX(arr)
      END
      'byte': BEGIN
        IF input_format NE 'byte' THEN arr=BYTE(arr)
      END
      'alt_line_data': BEGIN
        IF input_format NE 'alt_line_data' THEN BEGIN
          arr=[FLTARR(samples, nlines_i), arr]
        ENDIF
      END
      'alt_sample_data': BEGIN
        IF input_format NE 'alt_sample_data' THEN BEGIN
          arr=FLOAT(arr)
          IF i EQ nblks-1 AND j EQ 0 THEN BEGIN
            i=0 ; Repeat the steps.
            j=1 ; Assign the mask.
          ENDIF
        ENDIF
      END
      
    ENDCASE
    
    ;Write the data
    WRITEU, outputlun, arr
    
  ENDFOR
  
  ; Free lun
  FREE_LUN, inputlun
  FREE_LUN, outputlun
  
  
  Print, 'Task finished successfully:'+TLI_TIME(/str)
  Print, 'Please check the file:'+outputfile
END