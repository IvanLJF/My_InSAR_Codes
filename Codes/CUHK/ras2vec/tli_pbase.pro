PRO TLI_PBASE, diffpath, resultpath, samples, lines, sarlistfile, itabfile, plistfile, pbasefile=pbasefile

  COMPILE_OPT idl2
  
  ; Readfiles
  nslc= FILE_LINES(sarlistfile)
  Print, 'Number of slcs:', STRCOMPRESS(nslc)
  sarlist= STRARR(nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
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
  OPENW, lun, pbasefile,/GET_LUN
  
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
    diffname= difffolder+'_BL.img'
    difffull= diffpath+PATH_SEP()+difffolder+PATH_SEP()+diffname
    IF ~FILE_TEST(difffull) THEN BEGIN
      FREE_LUN, lun
      Message, difffull+'ERROR! BASELINE FILE Not Found!'
    ENDIF
    
    diff= TLI_READDATA(difffull, samples=samples, format='FLOAT')
    
    pdiff= DOUBLE(diff[x,y])
    
    WRITEU, lun, pdiff
    
  ENDFOR
  
  FREE_LUN,lun
  Print, 'File written successfully!'
  
END