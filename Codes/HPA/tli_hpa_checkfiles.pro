;-
;- Check input files for HPA
;-
;- Written by:
;-   T.LI @ ISEIS, 09/04/2013
;-


FUNCTION TLI_HPA_CHECKFILES, hpapath, level=level, pass=pass

;  COMPILE_OPT idl2
  ;  ON_ERROR, 2
  IF N_PARAMS() NE 1 THEN Message, 'Usage Error!'
  ;
  ;  IF TLI_HAVESEP(workpath) THEN BEGIN
  ;    workpath_c=workpath
  ;  ENDIF ELSE BEGIN
  ;    workpath_c=workpath+PATH_SEP()
  ;  ENDELSE
  workpath_c=FILE_DIRNAME(hpapath)+PATH_SEP()
  
  resultpath=workpath_c+FILE_BASENAME(hpapath)+PATH_SEP()
  IF NOT N_ELEMENTS(level) EQ 0 THEN BEGIN
  
  
    ; Check in the workpath_c the level
    ;    hpafiles= FILE_SEARCH(resultpath+'lel*', count=nfiles)
    ;    hpafiles= FILE_BASENAME(hpafiles)
    ;    IF nfiles EQ -1 THEN Message, 'Please first run the 1st and 2nd level.'
    ;    levels= STRMID(hpafiles, 3, 1)
    ;    levels= LONG(levels)
    ;    level= MAX(levels)
  
  
    hpafiles= FILE_SEARCH(resultpath+'lel*ptattr', count=nfiles)
    hpafiles= FILE_BASENAME(hpafiles)
    IF nfiles EQ -1 THEN Message, 'Please first run the 1st and 2nd level.'
    
    endpos=STRPOS(hpafiles, 'ptattr')
    levels=0
    FOR i=0, nfiles-1 DO BEGIN
      levels= [levels,STRMID(hpafiles[i], 3,endpos[i])]
    ENDFOR
    levels= LONG(levels[1:*])
    level= MAX(levels)
    
  ENDIF
  
  ; Find the files
  pdifffile= workpath_c+'pdiff0'
  plistfile= resultpath+'plist'
  itabfile= workpath_c+'itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  mskfile= resultpath+'msk'
  
  lelaplistfile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'plist'
  lelapslcfile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'pslc'
  lelapbasefile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'pbase'
  lelaplafile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'pla'
  lelaptattrfile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'ptattr'
  lelaptstructfile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'ptstruct'
  lelavdhfile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'vdh'
  
  lelavdhfile_merge= lelavdhfile+'_merge'
  
  
  files=[ pdifffile, $
    plistfile, $
    itabfile,$
    mskfile,$
    lelaplistfile, $
    ;    lelapslcfile, $
    ;    lelapbasefile, $
    lelaplafile, $
    lelaptattrfile, $
    lelaptstructfile, $
    lelavdhfile, $
    lelavdhfile_merge]
    
  files=TRANSPOSE(files)
  result= FILE_TEST(files)
  ; Check if there is any file that does not exist
  ind= WHERE(result EQ 0)
  IF ind[0] EQ -1 THEN BEGIN
    pass=1
    return, 'Files all exist.'
  ENDIF ELSE BEGIN
    result=files[*,ind]+' can not be found!'
    
    pass=0
    return, result
  ENDELSE
  
END