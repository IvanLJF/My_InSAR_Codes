;- 
;- Purpose:
;-     Generic index array.
;- Calling Sequence:
;-    
;- Inputs:
;   x  : X coordinates to use. e.g. [1, 2, 3, 4]
;   y  : Y coordinates to use. e.g. [1, 2, 3, 4]
;- Optional Input Parameters:
;- 
;- Keyword Input Parameters:
;-    
;- Outputs:
;-
;- Commendations:
;-
;- Modification History:
;-

FUNCTION INDEXARR, x=x, y=y
  
  COMPILE_OPT idl2
  ON_ERROR,2
  
  IF ~KEYWORD_SET(x) THEN x=FINDGEN(10)
  IF ~KEYWORD_SET(y) THEN y=FINDGEN(10)
  
  sz_x= SIZE(x, /N_ELEMENTS)
  sz_y= SIZE(y, /N_ELEMENTS)
  
  x= TRANSPOSE(TRANSPOSE(x)##REPLICATE(1,sz_y))
  y= y##REPLICATE(1,sz_x)
  
  result= COMPLEX(x,y)
  
  RETURN, result  
  
END