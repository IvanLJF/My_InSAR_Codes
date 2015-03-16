;
; Convert the input file to the specified data format.
;
; Parameters:
;   inputfile          : Input file
;
; Keywords:
;   outputfile         : Output file
;   samples            : Samples of the input file.
;   lines              : Lines of the input file.
;   input_format       : Format of the input data.
;                        Supported formats are: int, long, float, double, scomplex, fcomplex
;   output_format      : Format of the output data.
;                        Supported formats are: int, long, float, double, scomplex, fcomplex
;   stretch_data       : Stretch data or not. When the outputformat is int, the data are always need stretch.
;   start_line         : Start line to convert data.
;   end_line           : End line to convert data.
;
; Written by:
;   T.LI @ SASMAC, 20140728
;
PRO TLI_CONVERT_FORMAT, inputfile, outputfile=outputfile, samples=samples, lines=lines, input_format=input_format, output_format=output_format, stretch_data=stretch_data, $
    start_line=start_line, end_line=end_line, swap_endian=swap_endian
    
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=inputfile+'_convert'
  
  IF NOT KEYWORD_SET(samples) AND NOT KEYWORD_SET(lines) THEN BEGIN
    Message, 'Error! Please specify either samples or lines.'
  ENDIF ELSE BEGIN
    imagesize=TLI_IMAGE_SIZE(inputfile, samples=samples, lines=lines, format=input_format)
    samples=imagesize[0]
    lines=imagesize[1]
  END
  
  IF NOT KEYWORD_SET(input_format) THEN Message, 'Error! Please specify data format for the input file.'
  
  IF NOT KEYWORD_SET(output_format) THEN output_format=input_format
  
  IF NOT KEYWORD_SET(start_line) THEN start_line=0
  
  IF NOT KEYWORD_SET(end_line) THEN end_line=lines
  
  end_line=end_line < lines
  
  block_lines=1000D  ; No of lines to load data.
  
  block_no=CEIL(lines/block_lines)
  
  input_format=STRLOWCASE(input_format)
  
  Case input_format OF
    'int'      : length=2
    'long'     : length=4
    'float'    : length=4
    'double'   : length=8
    'scomplex' : length=4
    'fcomplex' : length=8
    'dcomplex' : length=16
    ELSE       : Message, 'ERROR! Format not supported!'
  ENDCASE
  length_to_jump=start_line*samples*length
  
  OPENR, lun, inputfile,/GET_LUN & POINT_LUN, lun, length_to_jump
  OPENW, outputlun, outputfile,/GET_LUN, swap_endian=swap_endian
  
  FOR i=0, block_no-1 DO BEGIN
    
    Print, 'Converting data format: ', STRCOMPRESS(i), '/', STRCOMPRESS(block_no-1)
    
    start_line_i=start_line+block_lines*i
    
    end_line_i=(start_line+(block_lines*(i+1)-1)) < end_line
    
    block_lines_i=end_line_i-start_line_i+1
    
    Case input_format OF
      'int': BEGIN
        block_data=INTARR(samples, block_lines_i)
      END
      
      'long': BEGIN
        block_data=LONARR(samples, block_lines_i)
      END
      
      'float': BEGIN
        block_data=FLTARR(samples, block_lines_i)
      END
      
      'double': BEGIN
        block_data=DBLARR(samples, block_lines_i)
      END
      
      'scomplex': BEGIN
        block_data=INTARR(samples*2, block_lines_i)
      END
      
      'fcomplex': BEGIN
        block_data=FLTARR(samples*2, block_lines_i)
      END
      
      'dcomplex': BEGIN
        block_data=DBLARR(samples*2, block_lines_i)
      END
      
      ELSE: Message, 'Error! Format not supported.'
      
    ENDCASE
    
    READU, lun, block_data
    
    Case output_format OF
      'int': BEGIN
        IF KEYWORD_SET(stretch_data) THEN BEGIN
          block_data=TLI_STRETCH_DATA(block_data, outrange=[0, 255])
        ENDIF
        block_data=BYTE(block_data)
      END
      
      'long': BEGIN
        block_data=LONG(block_data)
      END
      
      'float': BEGIN
        block_data=FLOAT(block_data)
      END
      
      'double': BEGIN
        block_data=DOUBLE(block_data)
      END
      
      'scomplex': BEGIN
        IF input_format NE 'scomplex' AND input_format NE 'fcomplex' AND input_format NE 'dcomplex' THEN BEGIN
          temp=block_data
          block_data=INTARR(samples*2, block_lines_i)
          block_data[0:*:2]=temp
        ENDIF ELSE BEGIN
          IF input_format EQ 'fcomplex' OR input_format EQ 'dcomplex' THEN BEGIN
          
            IF KEYWORD_SET(stretch_data) THEN BEGIN
              block_data=TLI_STRETCH_DATA(block_data)
            ENDIF
            block_data=BYTE(block_data)
            
          ENDIF
        ENDELSE
      END
      
      'fcomplex': BEGIN
        IF input_format NE 'scomplex' AND input_format NE 'fcomplex' AND input_format NE 'dcomplex' THEN BEGIN
          temp=block_data
          block_data=FLTARR(samples*2, block_lines_i)
          block_data[0:*:2]=temp
        ENDIF ELSE BEGIN
          IF input_format EQ 'scomplex' OR input_format EQ 'dcomplex' THEN BEGIN
            block_data=FLOAT(block_data)
          ENDIF
        ENDELSE
      END
      
      'dcomplex': BEGIN
      
        IF input_format NE 'scomplex' AND input_format NE 'fcomplex' AND input_format NE 'dcomplex' THEN BEGIN
          temp=block_data
          block_data=DBLARR(samples*2, block_lines_i)
          block_data[0:*:2]=temp
        ENDIF ELSE BEGIN
          IF input_format EQ 'scomplex' OR input_format EQ 'fcomplex' THEN BEGIN
            block_data=DOUBLE(block_data)
          ENDIF
        ENDELSE
      END
      
      ELSE: Message, 'Error! Format not supported.'
      
    ENDCASE
    
    WRITEU, outputlun, block_data
    
  ENDFOR
  
  FREE_LUN, lun
  FREE_LUN, outputlun
  Print, 'Task finished at time '+TLI_TIME(/str)
  
END