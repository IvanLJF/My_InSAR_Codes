PRO TLI_UPDATE_DVDDH, plistfile_orig, dvddhfile, coh=coh, sigma=sigma, keep_zero=keep_zero, $
    plistfile_update=plistfile_update, dvddhfile_update=dvddhfile_update
    
    
  IF NOT KEYWORD_SET(dvddhfile_update) THEN dvddhfile_update=dvddhfile+'_update'
  IF NOT KEYWORD_SET(plistfile_update) THEN plistfile_update=dvddhfile_update+'.plist'
  IF NOT KEYWORD_SET(coh) THEN coh=0.0
  IF NOT KEYWORD_SET(sigma) THEN sigma=1000
;  IF NOT KEYWORD_SET(sigma) THEN sigma=2*!PI
  
  npt=TLI_PNUMBER(plistfile_orig)
  dvddh=TLI_READMYFILES(dvddhfile, type='dvddh')
  
  ; Sort dvddh file according to the the adjacent point index.
  adj_ind=dvddh[1, *]
  dvddh=dvddh[*, SORT(adj_ind)]
  
  ; update dvddh
  IF KEYWORD_SET(keep_zero) THEN BEGIN
    dvddh_ind=WHERE(dvddh[4, *] GE coh AND dvddh[5,*] LT sigma, complement=discarded_ind)
  ENDIF ELSE BEGIN
    dvddh_ind=WHERE(dvddh[3, *] NE 0.0 AND dvddh[4, *] GE coh AND dvddh[5,*] LT sigma, complement=discarded_ind)
  ENDELSE
  dvddh=dvddh[*, dvddh_ind]
  
  
  ; For examination
  IF 0 THEN BEGIN
    wired_ind=[51562, 53684, 55256, 55574, 55576, 55720, 55722, 55726, 55750]
    wired_lines=FLOOR(wired_ind/2)
    wired_dvddh=dvddh[*, wired_lines]   ; Get the corresponding lines.
    Print, wired_dvddh
    
    lookupfile=plistfile_orig+'.lookup'
    lookup=TLI_READDATA(lookupfile, samples=2, format='DOUBLE')
    dvddh=dvddh[*, wired_lines]
    dvddh[0, *]=lookup[1, dvddh[0, *]]
    dvddh[1, *]=lookup[1, dvddh[1, *]]
    Print, dvddh
  ENDIF
  
  plist_ind=[[dvddh[0,*]], [dvddh[1,*]]]
  plist_ind=plist_ind[SORT(plist_ind)]
  plist_uniq=plist_ind[UNIQ(plist_ind)]
  ; Re-design the indices
  plist=TLI_READMYFILES(plistfile_orig, type='plist')
  plist_new=plist[*, plist_uniq]
  TLI_WRITE, plistfile_update, plist_new  
  
  
  
  
  ; Generate the lookup file.
  lookupfile=plistfile_orig+'.lookup'
  TLI_PLIST_LOOKUP, plistfile_orig, plistfile_update, outputfile=lookupfile
  
  lookup=TLI_READDATA(lookupfile, samples=2, format='DOUBLE')
  ; Convert the indices.
  dvddh[0, *]=lookup[1, dvddh[0, *]]
  dvddh[1, *]=lookup[1, dvddh[1, *]]
  
  ind=WHERE(dvddh[0:1, *] EQ -1)
  IF ind[0] NE -1 THEN Message, 'Error! There should not be any points that not contained in plistfile_update.'
  
  ; Write the results.
  TLI_WRITE, dvddhfile_update, dvddh
  TLI_WRITE, plistfile_update, plist_new
  
  Print, 'dvddh file(1) and plistfile(2) are successfully updated. Please check the files:'
  Print, '(1):  ', dvddhfile_update
  Print, '(2):  ', plistfile_update
  
END