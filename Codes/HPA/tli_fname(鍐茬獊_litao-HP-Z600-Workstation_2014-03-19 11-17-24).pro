FUNCTION TLI_FNAME, inputstr, nosuffix=nosuffix, onlyfname=onlyfname, onlydir=onlydir, suffix=suffix, format=format

  ; First get the path_sep character.
  psep=PATH_SEP()
  
  ; Second, get the suffix
  temp=STRSPLIT(inputstr, '.',/extract,count=nsuffix)
  IF nsuffix EQ 0 THEN BEGIN
    suffix=''
    format=''
    fname_nosuffix=inputstr
  ENDIF ELSE BEGIN
    format=temp[nsuffix-1]
    suffix='.'+format
    fname_nosuffix=FILE_BASENAME(inputstr,suffix)
  ENDELSE
  
  ; Third, get the dirname
  fdir=FILE_DIRNAME(inputstr)
  
  ; Guess if the inputstr is from windows or linux.
  result=inputstr
  Case 1 OF
   
    KEYWORD_SET(nosuffix): BEGIN
      result=fname_nosuffix
    END
    
    KEYWORD_SET(onlyfname): BEGIN
      result=FILE_BASENAME(result)
    END
    
    KEYWORD_SET(onlydir): BEGIN
      result=FILE_DIRNAME(result)
    END
    
    ELSE:
  
  
  END
  RETURN, result

END