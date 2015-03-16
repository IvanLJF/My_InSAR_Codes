PRO TLI_UPDATEPLIST, inputfile, outputfile, $
      dvddhfile=dvddhfile, vdhfile=vdhfile

  IF KEYWORD_SET(dvddhfile) OR KEYWORD_SET(vdhfile) THEN BEGIN
    temp= TLI_READDATA(inputfile, samples=5, format='DOUBLE')
    temp= COMPLEX(temp[1, *],temp[2, *])
    OPENW, lun, outputfile, /GET_LUN
    WRITEU, lun, temp
    FREE_LUN, lun
  ENDIF



END