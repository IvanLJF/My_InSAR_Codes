PRO TLI_GAMMA2MYFORMAT_SARLIST, sarlistfilegamma, outputfile

  IF N_PARAMS() NE 2 THEN BEGIN
    Message, 'TLI_GAMMA2MYFORMAT_SARLIST: Usage error!'
  ENDIF
  nlines= FILE_LINES(sarlistfilegamma)
  sarlist= STRARR(nlines)
  OPENR, lun, sarlistfilegamma,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  ;
  
  result=''
  temp=''
  For i=0, nlines-1 DO BEGIN
    temp= STRSPLIT(sarlist[i], ' ',/EXTRACT)
    IF !D.NAME NE 'X' THEN BEGIN
      temp= TLI_DIRW2L(temp,/REVERSE)
    ENDIF
    result=[[result], [temp[0]]]
  ENDFOR
  result= result[1:*]
  
  OPENW, lun, outputfile,/GET_LUN
  PrintF, lun, result
  FREE_LUN, lun
  
  
END