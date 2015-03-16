;
; Extract point value at the given coord.
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20150121
;
FUNCTION TLI_EXTRACT_PT_VALUE, inputfile, coord, samples=samples, format=format, swap_endian=swap_endian

  IF N_ELEMENTS(coord) NE 2 THEN Message, 'Error! Coordinates should be in format of [x, y]'
  
  format=STRLOWCASE(format)
  Case format OF
    'int'      : BEGIN
      length=2 & result=0
    END
    'long'     : BEGIN
      length=4 & result=0L
    END
    'float'    : BEGIN
      length=4 & result=0.0
    END
    'double'   : BEGIN
      length=8 & result=0D
    END
    'scomplex' : BEGIN
      length=4 & result=[0,0]
    END
    'fcomplex' : BEGIN
      length=8 & result=[0.0,0.0]
    END
    'dcomplex' : BEGIN
      length=16 & result=[0D,0D]
    END
    'alt_line_data'    : BEGIN
      length=8 & result=[0.0,0.0]
    END
    'alt_sample_data'  : BEGIN
      length=8 & result=[0.0,0.0]
    END
    ELSE: Message, 'Error! Format not supported!'
  ENDCASE
  
  pointer=samples*length*coord[1]+length*coord[0]
  
  OPENR, lun, inputfile,/GET_LUN,swap_endian=swap_endian
  POINT_LUN, lun, pointer
  READU, lun, result
  
END