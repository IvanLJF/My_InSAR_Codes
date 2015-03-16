PRO TLI_ASCII2DAT, asciifile, datfile=datfile, samples=samples, lines=lines, format=format, swap_endian=swap_endian

  IF ~KEYWORD_SET(datfile) THEN BEGIN
    nlines= FILE_LINES(asciifile)
    temp= STRSPLIT(asciifile,'.',/extract)
    IF temp[0] EQ asciifile THEN BEGIN
      datfile=asciifile+'.dat'
    ENDIF ELSE BEGIN
      suffix= '.'+temp[1]
      basename= FILE_BASENAME(asciifile, suffix)
      IF suffix EQ '.dat' THEN BEGIN
        datfile= basename
      ENDIF ELSE BEGIN
        datfile= basename+'.dat'
      ENDELSE
    ENDELSE
    
  ENDIF
  
  ascii= TLI_READTXT(asciifile)
  Case format OF
    'BYTE': BEGIN
      result=BYTE(ascii)
    END
    'INT': BEGIN
      result=FIX(ascii)
    END
    'LONG':  BEGIN
      result=LONG(ascii)
    END
    'FLOAT': BEGIN
      result=FLOAT(ascii)
    END
    'DOUBLE': BEGIN
    END
    'SCOMPLEX': BEGIN
      ;        r_part= ascii[0:*:2, *]
      ;        i_part= ascii[1:*:2, *]
      ;        result= COMPLEX(FIX(r_part),FIX(i_part))
      result=FIX(ascii)
    END
    'FCOMPLEX': BEGIN
      r_part= ascii[0:*:2, *]
      i_part= ascii[1:*:2, *]
      result= COMPLEX(FIX(r_part),FIX(i_part))
    END
    ELSE: BEGIN
      Message, 'TLI_READDATA: Format Error! This keyword is case sensitive.'
    END
  ENDCASE
  OPENW, lun, datfile,/GET_LUN, swap_endian=swap_endian
  WRITEU, lun, result
  FREE_LUN, lun
  
END