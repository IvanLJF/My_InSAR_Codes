;-
; Replace part of the string1 using string2.
;-
;- Parameters:
;-   string1     : String to process;
;-   string2     : String to use;
;- Keywords:
;-   pos         : Position to start replacing/inserting (start from 0).
;-   insert_before  : Insert before the given position.
;-   insert_after: Insert after the given position.
;-   search_str  : Give the search string to take the place of pos.
;-
;- Written by:
;-  T. LI @ ISEIS, 20131107
 
FUNCTION TLI_STRREPLACE, string1, string2, pos=pos, insert_before=insert_before, insert_after=insert_after, search_str=search_str
  
  COMPILE_OPT idl2
  
  ; Judge the input params
  IF N_PARAMS() NE 2 THEN Message, 'TLI_STRREPLACE: Usage Error!'
  
  ; Give the start position to replace.
  sz1=STRLEN(string1)
  sz2=STRLEN(string2)
  IF KEYWORD_SET(search_str) THEN sz3=STRLEN(search_str) $
  ELSE sz3=0
  IF N_ELEMENTS(pos) EQ 0 THEN BEGIN
    IF NOT KEYWORD_SET(search_str) THEN Message, 'TLI_STRREPLACE: Error! Keywords needed: pos/search_str'
    pos=STRPOS(string1, search_str)
    pos=pos[0]
    IF pos EQ -1 THEN Message, 'TLI_STRREPLACE: Error! Wrong search_str.'
  ENDIF
  
  IF pos LT 0 OR pos GT (sz1-1) THEN Message, 'TLI_STRREPLACE: Error! pos should be greater than 0 and less than'$
      +STRCOMPRESS(sz1-1)+' :'+STRCOMPRESS(pos)
  start_pos=pos
  IF KEYWORD_SET(insert_after) THEN start_pos=pos+sz3
  end_pos=start_pos
  IF NOT (KEYWORD_SET(insert_before) OR KEYWORD_SET(insert_after)) THEN end_pos=(start_pos+sz2)<sz1
  
  ; Get the substring in front of start_pos.
  substr_f=STRMID(string1, 0, start_pos)
  
  ; Get the substring at the back of end_pos.
  substr_b=STRMID(string1, end_pos, sz1-end_pos) 
  
  ; Join the substrings
  result=substr_f+string2+substr_b
  RETURN, result
END

FUNCTION TLI_STRREPLACE_ALL, strarray, string2, pos=pos, insert_before=insert_before, insert_after=insert_after, search_str=search_str
  nstr=N_ELEMENTS(strarray)
  result=strarray
  FOR i=0, nstr-1 DO BEGIN
    string1=strarray[i]
    result[i]=TLI_STRREPLACE(string1, string2, pos=pos, insert_before=insert_before, insert_after=insert_after, search_str=search_str)
  ENDFOR
  RETURN, result
END