;
; Edit the fname string and output all the needed information.
;
; Parameters:
;   inputstr            : Full path of input file.
; Keywords:
;   nosuffix            : File path without suffix
;   onlyfname           : File name without suffix and path.
;   onlydir             : File dir name .
;   suffix              : Suffix of the inputstr
;   format              : format of the inputstr. (='.'+suffix)
;   remove_all_suffix   : Remove all suffix.
;
; Written by:
;   T.LI @ Sasmac, 20141120.
;
FUNCTION TLI_FNAME, inputstr, nosuffix=nosuffix, onlyfname=onlyfname, onlydir=onlydir, suffix=suffix, format=format, $
                    remove_all_suffix=remove_all_suffix, all_suffix=all_suffix,dirname=fdir
  
  ; First get the path_sep character.
  psep=PATH_SEP()
  
  ; Second, get the suffix
  temp=STRSPLIT(inputstr, '.',/extract,count=nsuffix)
  IF nsuffix EQ 0 THEN BEGIN
    suffix=''
    format=''
    fname_nosuffix=inputstr
    
    all_suffix=''
    fname_no_all_suffix=inputstr
  ENDIF ELSE BEGIN
    format=temp[nsuffix-1]
    suffix='.'+format
    fname_nosuffix=FILE_BASENAME(inputstr,suffix)
    
    all_suffix='.'+STRJOIN(temp[1:*], '.')
    fname_no_all_suffix=FILE_BASENAME(inputstr, all_suffix)
  ENDELSE
  
  ; Third, get the dirname
  fdir=FILE_DIRNAME(inputstr)+PATH_SEP()
  
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
    
    KEYWORD_SET(remove_all_suffix): BEGIN
      result=fname_no_all_suffix
    END
    
    ELSE:
  
  
  END
  RETURN, result

END