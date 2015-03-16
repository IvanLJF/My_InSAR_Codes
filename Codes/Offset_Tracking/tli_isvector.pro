;
; Check if the input param is a vector.
; 
; Params:
;   input     : The input array.
;
; Keywords:
;   dims            : Return value. Dimensions of the input array.
;   single_sample   : Return value. Convert the input array to a single sample array.
;   single_line     : Return value. Convert the input array to a single line array.
;
; Written by:
;   T.LI @ ISEIS, 20131202.
FUNCTION TLI_ISVECTOR, input, dims=dims, single_sample=single_sample, single_line=single_line

  dims=SIZE(input,/DIMENSIONS)
  IF dims[0] EQ 0 OR N_ELEMENTS(dims) GE 3 THEN RETURN, 0
  IF N_ELEMENTS(dims) EQ 1 THEN BEGIN
    single_sample=TRANSPOSE(input)
    single_line=input
    RETURN, 1
  ENDIF
  
  samples=dims[0]
  lines=dims[1]
  
  IF samples EQ 1 THEN BEGIN
    single_sample=input
    single_line=TRANSPOSE(input)
    RETURN, 1
  ENDIF
  
  IF lines EQ 1 THEN BEGIN
    single_sample=TRANSPOSE(input)
    single_line=input
    RETURN, 1
  ENDIF
  
  RETURN, 0
  
END