;-
;- Function that:
;-  Change the full path of the file from windows to linux
FUNCTION TLI_DIRW2L, windir, rootdir= rootdir, reverse=reverse
  
  IF N_PARAMS() NE 1 THEN Message, 'Usage: TLI_DIR_WIN2LINUX, windir , rootdir=rootdir'
  winpathsep='\'
  linuxpathsep='/'
  IF ~KEYWORD_SET(reverse) THEN BEGIN
    tempdir= (STRSPLIT(windir,winpathsep,/EXTRACT))
    
    ; Set params
    IF ~KEYWORD_SET(rootdir) THEN BEGIN
      Case tempdir[0] OF
        'D:': BEGIN
          rootdir='/mnt/software'
        END
        'E:': BEGIN
          rootdir='/mnt/media'
        END
        'F:': BEGIN
          rootdir='/mnt/backup'
        END
        ELSE: BEGIN
          rootdir='/mnt/ihiusa'
        END
      ENDCASE
    
    ENDIF
    
    result= STRJOIN([rootdir, tempdir[1:*]], linuxpathsep)
    
    RETURN, result
    
  ENDIF ELSE BEGIN
    tempdir= (STRSPLIT(windir,linuxpathsep,/EXTRACT))
    ; Set params
    IF ~KEYWORD_SET(rootdir) THEN BEGIN
      temproot= '/'+STRJOIN(tempdir[0:1], linuxpathsep)
      Case temproot OF
        '/mnt/software': BEGIN
          rootdir='D:'
        END
        '/mnt/media': BEGIN
          rootdir='E:'
        END
        '/mnt/backup': BEGIN
          rootdir='F:'
        END
        ELSE: BEGIN
          rootdir='Z:'
        END
      ENDCASE
    ENDIF
    result= STRJOIN([rootdir, tempdir[2:*]], winpathsep)    
    RETURN, result
    
  ENDELSE
  
END