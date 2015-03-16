;-
;- Find the max level of HPA that has been finished.
;-
FUNCTION TLI_HPA_LEVEL, hpapath

  IF NOT TLI_HAVESEP(hpapath) THEN BEGIN
    hpapath_c=hpapath+PATH_SEP()
  ENDIF ELSE BEGIN
    hpapath_c=hpapath
  ENDELSE
  
  
  ;  hpafiles= FILE_SEARCH(hpapath_c+'lel*ptstruct', count=nfiles)
  ;  hpafiles= FILE_BASENAME(hpafiles)
  ;  IF nfiles EQ -1 THEN RETURN, 1
  ;  levels= STRMID(hpafiles, 3, 1)
  ;  levels= LONG(levels)
  ;  templevel= MAX(levels)
  
  hpafiles= FILE_SEARCH(hpapath_c+'lel*ptattr', count=nfiles)
  hpafiles= FILE_BASENAME(hpafiles)
  IF nfiles EQ -1 THEN Message, 'Please first run the 1st and 2nd level.'
  
  endpos=STRPOS(hpafiles, 'ptattr')
  levels=0
  FOR i=0, nfiles-1 DO BEGIN
    levels= [levels,STRMID(hpafiles[i], 3,endpos[i])]
  ENDFOR
  levels= LONG(levels[1:*])
  templevel= MAX(levels)
  
  
  
  
  IF templevel EQ 2 THEN RETURN, 2
  result=TLI_HPA_CHECKFILES(hpapath, level=templevel, pass=pass)
  WHILE NOT PASS DO BEGIN
    templevel=templevel-1
    result=TLI_HPA_CHECKFILES(hpapath, level=templevel, pass=pass)
    print, result
    ;    print, templevel
    IF templevel LE 0 THEN BEGIN
      Message, 'There is not any completed level.'
    ENDIF
  ENDWHILE
  RETURN, templevel
  
END