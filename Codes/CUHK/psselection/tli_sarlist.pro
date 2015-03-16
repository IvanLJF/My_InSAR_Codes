;+ 
; Name:
;    TLI_SARLIST
; Purpose:
;    Generate a list containing all the given suffix.
; Calling Sequence:
;    result= TLI_SARLIST(path, suffix, outfile=outfile)
; Inputs:
;    path    :  Full path to search file.
;    suffix  :  File suffix to be searched.
; Keyword Input Parameters:
;    outfile :  Output sarlist file.
; Outputs:
;    An ASCII file containing all the files you need.
; Commendations:
;    None.
; Example:
;    path='D:\myfiles\Software\TSX_PS_Tianjin\piece\'
;    suffix= '.rslc'
;    result= TLI_SARLIST(path, suffix, outfile=outfile)
; Modification History:
;    02/04/2012  : Written by T.Li @ InSAR Team in SWJTU & CUHK
;-    

FUNCTION TLI_SARLIST, path, suffix, outfile=outfile
  
  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 2 THEN MESSAGE, 'Usage: result= TLI_SARLIST(path, suffix, outfile=outfile)'
  IF ~KEYWORD_SET(outfile) THEN outfile= path+'sarlist.txt' 
  
;  result= FILE_SEARCH(path+'*'+suffix, count=fcount)
  result= FILE_SEARCH(path, '*'+suffix, count=fcount)
  IF fcount LT 1 THEN Begin
    Message, 'No files were found.'
  ENDIF
  IF fcount GE 1 THEN BEGIN
    date=0L
    result= TRANSPOSE(result) ; Sort the result in ascending order.
    FOR i=0,fcount-1 DO BEGIN
      fname= result[i]
      fname= STRSPLIT(fname, '-',/EXTRACT)
      sz= N_ELEMENTS(fname)
      fname= STRMID(fname[sz-1], 0, 8)
      date= [date, fname]
    ENDFOR
    date= date[1:*]
    order= SORT(date)
    result= result[*, order]
  ENDIF
  OPENW, lun, outfile,/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun
  
  RETURN, result
  
END