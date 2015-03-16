;-
;- Clear the specified level for HPA.
;-
;- workpath  : The current work path for HPA
;- level     : The level of the HPA.

PRO TLI_HPA_CLEAR_FOR_LEVEL, level,workpath,force=force

  IF KEYWORD_SET(force) THEN BEGIN
    lel=level
  ENDIF ELSE BEGIN
    lel=level-1
  ENDELSE
  IF lel LE 1 THEN RETURN ; Don't delete any files of HPA level 1.
  
  files=TLI_HPA_FILES(workpath, level=lel)
  
  files_del=[files.pdiff, files.pdiff_swap, files.pslc, files.pbase, files.pla, $
             files.plist, files.plist_gamma]
  FILE_DELETE, files_del,/allow_nonexistent
  Print, 'The following files are deleted.'
  Print, TRANSPOSE(files_del)
  
END