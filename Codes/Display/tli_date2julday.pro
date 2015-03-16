;-
;- Calculate the julian day of the input date which is in the format of yyyymmdd.
;-
;- Parameter:
;-   inputdate  : The date provided in the format of yyyymmdd.
;- Output:
;-   Julian day.
;-
;- Written by:
;-   T.LI @ ISEIS, 20131125
;-

FUNCTION TLI_DATE2JULDAY, date

  ; Check the input parameter.
  IF STRLEN(STRCOMPRESS(date[0],/REMOVE_ALL)) NE 8 THEN BEGIN
    Message, 'TLI_DATE2JULDAY: Parameter error: we only accept yyyymmdd as input data' $
      +STRING(13b)+STRING(date[0])
  ENDIF
  
  year= FLOOR(date/10000D)
  month= FLOOR((date- year*10000) / 100)
  day= date-year*10000-month*100
  result= JULDAY(month, day, year)
  RETURN, result
  
END