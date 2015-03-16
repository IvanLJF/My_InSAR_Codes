; Generate pdiff file or pdiff-like file
; difsuffix: suffix of the files to be used.
; nofolder: The file is supposed to be organized as: parentpath/thisdiffpath/difffile
;           If thisdiffpath is not supposed to be used, add '/nofolder'

PRO TLI_PDIFF, diffpath, resultpath, samples, lines, sarlistfile, itabfile, plistfile, $
    pdifffile=pdifffile,difsuffix=difsuffix, nofolder=nofolder
    
  COMPILE_OPT idl2
  
  IF ~KEYWORD_SET(difsuffix) THEN BEGIN
    difsuffix= '_DInsar.img'
  ENDIF
  
  ; Readfiles
  nslc= FILE_LINES(sarlistfile)
  Print, 'Number of slcs:', STRCOMPRESS(nslc)
  sarlist= STRARR(nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  ; Only maitain the first sample of sarlist
  IF N_ELEMENTS(STRSPLIT(sarlist[0],/EXTRACT)) GT 1 THEN BEGIN
    FOR i=0, nslc-1 DO BEGIN
      temp=STRSPLIT(sarlist[i],/EXTRACT)
      sarlist[i]=temp[0]
      
    ENDFOR
    
  ENDIF
  
  
  nintf= FILE_LINES(itabfile)
  Print, 'Number of interferograms:', STRCOMPRESS(nintf)
  itab= LONARR(4, nintf)
  OPENR, lun, itabfile,/GET_LUN
  READF, lun, itab
  FREE_LUN, lun
  
  npt= TLI_PNUMBER(plistfile)
  Print, 'Number of PSs:', STRCOMPRESS(LONG(npt))
  plist= TLI_READDATA(plistfile, samples=1, format='FCOMPLEX')
  
  ; Pdiff
  Print, 'Extracting data from different interferograms...'
  x= REAL_PART(plist)
  y= IMAGINARY(plist)
  OPENW, lun, pdifffile,/GET_LUN
  
  FOR i=0, nintf-1 DO BEGIN
    Print, STRCOMPRESS(i), '/', STRCOMPRESS(nintf-1)
    int= itab[*, i]
    master_ind= int[0]-1
    slave_ind= int[1]-1
    
    IF master_ind EQ slave_ind THEN BEGIN ; master-master
      pdiff=COMPLEXARR(npt)
      WRITEU, lun, pdiff
      CONTINUE
    ENDIF
    
    master_fname= sarlist[master_ind]
    slave_fname= sarlist[slave_ind]
    ; Locate dinsar file.
    suffix= '.'+STRSPLIT(master_fname, '.',/EXTRACT)
    sz= N_ELEMENTS(suffix)
    suffix= suffix[sz-1]
    difffolder= FILE_BASENAME(master_fname,suffix) $
      + '-'+ FILE_BASENAME(slave_fname, suffix)
    diffname= difffolder+difsuffix
    IF ~KEYWORD_SET(nofolder) THEN BEGIN
      difffull= diffpath+PATH_SEP()+difffolder+PATH_SEP()+diffname
      
    ENDIF ELSE BEGIN
      difffull= diffpath+PATH_SEP()+diffname
      
    ENDELSE
    IF ~FILE_TEST(difffull) THEN BEGIN
      FREE_LUN, lun
      Message, difffull+'ERROR! Different Interferogram Not Found!'
    ENDIF
    
    diff= TLI_READDATA(difffull, samples=samples, format='FCOMPLEX')
    
    pdiff= diff[x,y]
    
    ind= FINITE(pdiff)
    IF TOTAL(ind) NE N_ELEMENTS(pdiff) THEN Message, 'Error!'
    
    WRITEU, lun, pdiff
    
  ENDFOR
  
  FREE_LUN,lun
  Print, 'File written successfully!'
  
END