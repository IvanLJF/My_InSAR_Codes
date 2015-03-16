; Load a slc .par file from the sarlist.
FUNCTION TLI_LOAD_SLC_PAR_SARLIST,sarlistfile,ind=ind

  ; Read the sarlistfile
  IF NOT FILE_TEST(sarlistfile) THEN Message, 'File Not Found!!:'+sarlistfile
  nslc=FILE_LINES(sarlistfile)
  IF nslc EQ 0 THEN Message, 'Error! There is no contents in the file'+STRING(13B)$
    +sarlistfile
  IF ~KEYWORD_SET(ind) THEN ind=0
  
  sarlist=STRARR(nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  ; Judge the columns of the input file.
  temp=sarlist[0]
  temp=STRSPLIT(temp,' ',/EXTRACT)
  IF N_ELEMENTS(temp) NE 1 THEN BEGIN
    temp=temp[0: N_ELEMENTS(temp)/2-1]
    parfile=STRJOIN(temp, ' ')
  ENDIF ELSE BEGIN
    parfile=sarlist[ind]
  ENDELSE
  
  finfo=TLI_LOAD_SLC_PAR(parfile+'.par')
  RETURN, finfo
END