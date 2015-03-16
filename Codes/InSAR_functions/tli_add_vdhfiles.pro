;
; Add the corresponding values for each point in the two vdh file.
;
; Parameters:
;   vdhfile1   : The first vdh file.
;   vdhfile2   : The second vdh file.
;
; Keywords:
;   outputfile : Outputfile. Ommitted value: vdhfile1+vdhfile2
;   minus      : Minus instead of add.
;
; Written by:
;   T.LI @ SWJTU, 20140614
;
PRO TLI_ADD_VDHFILES, vdhfile1, vdhfile2, outputfile=outputfile, minus=minus
  COMPILE_OPT idl2
  
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=vdhfile1+'+'+FILE_BASENAME(vdhfile2)
  ENDIF
  
  vdh1=TLI_READMYFILES(vdhfile1, type='vdh')
  vdh2=TLI_READMYFILES(vdhfile2, type='vdh')
  ;----------------------------------------------------
  ; Locate the identital record indices in these two files.
  plistfile1=vdhfile1+'.plist'
  plistfile2=vdhfile2+'.plist'
  lookupfile=outputfile+'.lookup'
  TLI_WRITE, plistfile1, FLOAT(vdh1[1:2, *])
  TLI_WRITE, plistfile2, FLOAT(vdh2[1:2, *])
  ; Create lookup table.
  TLI_PLIST_LOOKUP, plistfile1, plistfile2, outputfile=lookupfile
  lookup=TLI_READDATA(lookupfile, samples=2, format='double')
  valid_ind=lookup[*, WHERE(lookup[1,*] NE -1)]
  vdh1_ind=valid_ind[0, *]
  vdh2_ind=valid_ind[1, *]
  vdh1_valid=vdh1[*, vdh1_ind]
  vdh2_valid=vdh2[*, vdh2_ind]
  
  result=vdh1_valid
  IF KEYWORD_SET(minus) THEN BEGIN
    result[3:4,*]=vdh1_valid[3:4,*]-vdh2_valid[3:4, *]
    intercept_v=result[3, 0]
    intercept_dh=result[4, 0]
    result[3, *]=result[3, *]-intercept_v
    result[4, *]=result[4, *]-intercept_dh
  ENDIF ELSE BEGIN
    result[3:4,*]=vdh1_valid[3:4,*]+vdh2_valid[3:4, *]
  ENDELSE
  files_to_clear=[plistfile1, plistfile2,lookupfile]
  FILE_DELETE, files_to_clear,/ALLOW_NONEXISTENT
  
  TLI_WRITE, outputfile, result
END