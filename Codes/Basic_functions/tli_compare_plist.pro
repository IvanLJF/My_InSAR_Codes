;
; Compare the two plist file.
;
; Parameters:
;   plistfile1
;   plistfile2
; Keywords:
;   plistexcfile1     : Plist that are exclusively included in plistfile1
;   pliscommfile      : Plist that are shared by the two plist files.
;   plistexcfile2     : Plist that are exclusively included in plistfile2.
;   txt               : Output the txt file.
;   gamma             : output the GAMMA plist file. Please use ras_pt to plot the gamma plist files.
;   samples           : samples of the original image.
;   lines             : lines of the original image.
;   outputlookup      : ouput the lookup file.
;
; Output:
;   plistfile1+'.lookup': Two samples, [index_file1, index_file2],double
;   plistfile2+'.lookup': Two samples, [index_file2, index_file1],double
;
; Written by:
;   T.LI @ SWJTU, 20140313
;
PRO TLI_COMPARE_PLIST, plistfile1, plistfile2,$
    plistexcfile1=plistexcfile1, plistcommonfile=plistcommonfile, plistexcfile2=plistexcfile2,$
    txt=txt,gamma=gamma, samples=samples, lines=lines, outputlookup=outputlookup
    
  IF NOT KEYWORD_SET(plistexcfile1) THEN plistexcfile1=plistfile1+'_exc'
  IF NOT KEYWORD_SET(plistexcfile2) THEN plistexcfile2=plistfile2+'_exc'
  IF NOT KEYWORD_SET(plistcommonfile) THEN plistcommonfile=plistfile1+'_common'
  
  plistlookupfile=plistfile1+'.lookuptmp'
  
  plist1=TLI_READMYFILES(plistfile1, type='plist')
  plist2=TLI_READMYFILES(plistfile2, type='plist')
  
  TLI_PLIST_LOOKUP, plistfile1, plistfile2, outputfile=plistlookupfile
  
  plistlookup=TLI_READDATA(plistlookupfile, samples=2, format='double')
  ind_exc=WHERE(plistlookup[1,*] EQ -1, complement=ind_common)
  
  IF KEYWORD_SET(outputlookup) THEN BEGIN
    FILE_MOVE, plistlookupfile, plistfile1+'.lookup',/OVERWRITE
  ENDIF
  
  IF ind_exc[0] EQ -1 THEN BEGIN
    Print, 'Waring! TLI_COMPARE_PLIST: The two plist files are identical:'
    Print, plistfile1
    Print, plistfile2
    plist1_exc=-1
    plist_common=plist1
    plist2_exc=-1
    TLI_PLIST_LOOKUP, plistfile2, plistfile1, outputfile=plistlookupfile
  ENDIF ELSE BEGIN
  
    plist1_exc=plist1[*, ind_exc]  ; Points exclusively included in Stamps.
    plist_common=plist1[*, ind_common]
    
    TLI_PLIST_LOOKUP, plistfile2, plistfile1, outputfile=plistlookupfile
    
    plistlookup=TLI_READDATA(plistlookupfile, samples=2, format='double')
    ind_exc=WHERE(plistlookup[1, *] EQ -1 , complement=ind_common)
    IF ind_exc[0] EQ -1 THEN BEGIN
      plist2_exc=-1
    ENDIF ELSE BEGIN
      plist2_exc=plist2[*, ind_exc]
    ENDELSE
  ENDELSE
  
  TLI_WRITE, plistfile1+'_exc', plist1_exc
  TLI_WRITE, plistfile1+'_common', plist_common
  TLI_WRITE, plistfile2+'_exc',plist2_exc
  
  IF KEYWORD_SET(txt) THEN BEGIN
    TLI_WRITE, plistfile1+'_exc.txt', [REAL_PART(plist1_exc), IMAGINARY(plist1_exc)],/txt
    TLI_WRITE, plistfile1+'_common.txt', [REAL_PART(plist_common), IMAGINARY(plist_common)],/txt
    TLI_WRITE, plistfile2+'_exc.txt', [REAL_PART(plist2_exc), IMAGINARY(plist2_exc)],/txt
  ENDIF
  
  IF KEYWORD_SET(gamma) THEN BEGIN
    IF NOT KEYWORD_SET(samples) THEN samples=MAX([[REAL_PART(plist1_exc)], [REAL_pART(plist_common)]])
    IF NOT KEYWORD_SET(lines) THEN lines=MAX([[IMAGINARY(plist1_exc)],[IMAGINARY(plist_common)] ])
    TLI_WRITE, plistfile1+'_exc.gamma', LONG([samples-1-REAL_PART(plist1_exc), lines-IMAGINARY(plist1_exc)]),/swap_endian
    TLI_WRITE, plistfile1+'_common.gamma', LONG([samples-1-REAL_PART(plist_common), lines-IMAGINARY(plist_common)]),/swap_endian
    TLI_WRITE, plistfile2+'_exc.gamma', LONG([samples-1-REAL_PART(plist2_exc), lines-IMAGINARY(plist2_exc)]),/swap_endian
  ENDIF
  
  IF KEYWORD_SET(outputlookup) THEN BEGIN
    FILE_MOVE, plistlookupfile, plistfile2+'.lookup',/OVERWRITE
  ENDIF
  FILE_DELETE, plistlookupfile,/ALLOW_NONEXISTENT
  
END