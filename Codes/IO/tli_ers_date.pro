;
; Calculate ERS date 
; 
; Parameters:
;   date    : Input date. e.g., E1_96_Mar25
FUNCTION TLI_ERS_DATE, date, mission=mission
  IF STRLEN(date) LT 10 THEN Message, 'Error! TLI_ERS_DATE, input date format error (E1_96_Mar25):'+date
  
  mission=(STRMID(date, 0,2))[0]
  yyyy=STRMID(date,3, 2)
  mmm=STRMID(date,6, 3)
  IF STRLEN(date) EQ 10 THEN BEGIN
    dd='0'+STRMID(date,9,1)
  ENDIF ELSE BEGIN
    dd=STRMID(date,9, 2)
  ENDELSE
  
  IF LONG(yyyy) GE 90 THEN BEGIN
    yyyy=STRCOMPRESS(yyyy+1900,/REMOVE_ALL)
  ENDIF ELSE BEGIN
    yyyy=STRCOMPRESS(yyyy+2000,/REMOVE_ALL)
  ENDELSE
  
  Case STRLOWCASE(mmm) OF
    'jan': mm='01'
    'feb': mm='02'
    'mar': mm='03'
    'apr': mm='04'
    'may': mm='05'
    'jun': mm='06'
    'jul': mm='07'
    'aug': mm='08'
    'sep': mm='09'
    'oct': mm='10'
    'nov': mm='11'
    'dec': mm='12'
  ENDCASE
  RETURN, (yyyy+mm+dd)[0]
END