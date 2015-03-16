;
; Return the date of the input cos file
;
; Parameters:
;   cosfile    : The input file name.
;
; Keywords:
;


FUNCTION TLI_COSDATE, cosfile
  
  temp=FILE_DIRNAME(FILE_DIRNAME(cosfile))
  
  temp=FILE_BASENAME(temp)
  
  temp=STRSPLIT(temp, '_',/extract, count=nstr)
  
  time=temp[nstr-1]
  
  date=STRMID(time, 0, 8)
  
  RETURN, date

END