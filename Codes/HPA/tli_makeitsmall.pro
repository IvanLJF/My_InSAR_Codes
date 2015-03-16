;
; Make the data small enough
; line: process line by line.
; largest_value: The largest value to keep.
FUNCTION TLI_MAKEITSMALL,array, largest_value=largest_value, line=line

  ; First devide the large number by 2.
  IF KEYWORD_SET(line) THEN BEGIN
    array_new=TRANSPOSE(array)
  ENDIF
  array_new=array
  IF NOT KEYWORD_SET(largest_value) THEN largest_value=5
  
  ; Process sample by sample
  sz=SIZE(array,/dimensions)
  nsamples=sz[0]
  FOR i=0, nsamples-1 DO BEGIN
    max_i=MAX(ABS(array_new[i, *]))
    IF max_i GE largest_value THEN BEGIN
      stop_i=0
    ENDIF ELSE BEGIN
      stop_i=1
    ENDELSE
    WHILE NOT stop_i DO BEGIN
      stop_i=1
      IF max_i GE largest_value THEN BEGIN
        array_new[i, *]=array_new[i, *]/2
        stop_i=0
        max_i=MAX(ABS(array_new[i,*]))
      ENDIF
    ENDWHILE
    
  ENDFOR
  RETURN, array_new
END