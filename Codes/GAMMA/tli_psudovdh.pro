; Create a psudo vdh file using the pdeffile
;
; pdeffile   : Single column.
; pmaskfile   : Single column. Byte array.
; outputfile  : The psudo vdh file.
; plistfile   : The plist file.
; Gamma       : Use this keyword to plot gamma data.

PRO TLI_PSUDOVDH, pdeffile, pdhfile=pdhfile, pmaskfile=pmaskfile,outputfile=outputfile,plistfile=plistfile,gamma_file=gamma_file 
  ; Create a psudo vdh file using the pdeffile
  COMPILE_OPT idl2
  
  IF KEYWORD_SET(GAMMA_FILE) THEN BEGIN
    swap_endian=1
    data=TLI_READDATA(pdeffile,samples=1, format='float',swap_endian=swap_endian)*1000  ; Change the unit from m/yr to mm/yr
  ENDIF ELSE BEGIN
    data=TLI_READDATA(pdeffile, samples=1, format='float', swap_endian=swap_endian)  ; mm/yr
  ENDELSE
  npt=N_ELEMENTS(data)
  
  IF KEYWORD_SET(pmaskfile) THEN BEGIN
    pmask=TLI_READDATA(pmaskfile, samples=1, format='byte',swap_endian=swap_endian)
    indices=WHERE(pmask EQ 1)
    IF indices[0] EQ -1 THEN Message, 'Error:'+pmaskfile
  ENDIF ELSE BEGIN
    indices= DINDGEN(npt)
  ENDELSE
  npt=N_ELEMENTS(indices)
  IF KEYWORD_SET(plistfile) THEN BEGIN
    IF KEYWORD_SET(GAMMA_FILE) THEN BEGIN
      plist=TLI_READDATA(plistfile, samples=2, format='Long',swap_endian=swap_endian)
    ENDIF ELSE BEGIN
      plist=TLI_READMYFILES(plistfile, type='plist')
      plist=[REAL_PART(plist),IMAGINARY(plist)]
    ENDELSE
    plist=DOUBLE(plist[*,indices])
  ENDIF ELSE BEGIN
    plist=DBLARR(npt)
  ENDELSE
  
  IF KEYWORD_SET(pdhfile) THEN BEGIN
    pdh=TLI_READDATA(pdhfile, samples=1, format='float',swap_endian=swap_endian)
  ENDIF ELSE BEGIN
    pdh=DBLARR(1, npt)
  ENDELSE
  
  vdh=DBLARR(5, npt)
  vdh[0,*]=DINDGEN(npt)
  vdh[1:2, *]=plist
  vdh[3,*]=data[*, indices]
  vdh[4,*]=pdh
  IF ~KEYWORD_SET(outputfile) THEN outputfile=pdeffile+'.tempvdh'
  TLI_WRITE, outputfile, vdh
  
END