;
; Judge if the given string is a tag name of a structure
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20150106
;
FUNCTION TLI_IS_TAG_NAME, struct, tag_name
  
  COMPILE_OPT idl2
  
  IF N_PARAMS() LT 2 THEN Message, 'Error! Usage: result=TLI_IS_TAG_NAME(struct, tag_name)'
  
  str=STRJOIN(TAG_NAMES(struct), ' ')
  
  pos=STRPOS(str, STRUPCASE(tag_name))
  
  IF pos EQ -1 THEN RETURN, 0
  
  RETURN, 1
END
