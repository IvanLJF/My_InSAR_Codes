;
; Write scripts to create all the interferograms by using the given slc images.
;
; Parameters:
;
; Keywods:
;
; Written by:
;   T.LI @ Sasmac, 20150116
;
PRO TLI_INT_SLC_ALL, workpath, slc=slc, rslc=rslc, inttabfile=inttabfile,no_write=no_write, scrfile=scrfile

  IF NOT TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
  
  IF NOT KEYWORD_SET(slc) AND NOT KEYWORD_SET(rslc) THEN rslc=1
  
  IF KEYWORD_SET(slc) THEN BEGIN
    suffix='.slc'
    files=FILE_SEARCH(workpath, '*.slc',count=nfiles)
  ENDIF
  IF NOT KEYWORD_SET(inttabfile) THEN inttabfile=''
  IF KEYWORD_SET(rslc) THEN BEGIN
    suffix='.rslc'
    files=FILE_SEARCH(workpath, '*.rslc',count=nfiles)
  ENDIF
  
  IF NOT KEYWORD_SET(scrfile) THEN BEGIN
    scrfile=workpath+'scr.sh'
  ENDIF
  
  inttab=['', '']
  width_temp=3
  IF KEYWORD_SET(inttabfile) THEN BEGIN
    inttab=TLI_READTXT(inttabfile,/txt)
  ENDIF ELSE BEGIN
    FOR i=0, nfiles-2 DO BEGIN
      master=files[i]
      FOR j=i+1, nfiles-1 DO BEGIN
        slave=files[j]
        IF slave NE master THEN BEGIN
          inttab=[[inttab], [master, slave]]
          width=STRLEN(master+' '+slave)
          width=width>width_temp
        ENDIF
      ENDFOR
    ENDFOR
  ENDELSE
  inttab=inttab[*, 1:*]
  
  IF NOT KEYWORD_SET(no_write) THEN BEGIN
  
    IF NOT FILE_TEST(inttabfile) THEN BEGIN
      inttabfile=workpath+'inttab.txt'
    ENDIF
    
    OPENW, lun, inttabfile, /GET_LUN,width=width+10
    PRINTF, lun, inttab
    FREE_LUN, lun
    
  ENDIF
  nintf=N_ELEMENTS(inttab)/2
  
  OPENW, lun, scrfile,/GET_LUN
  PrintF, lun, '#! /bin/sh'
  PrintF, lun, ''
  PrintF, lun, 'dem=/mnt/data_tli/Data/DEM/TianjinDEM/Tianjin.dem'
  FOR i=0, nintf-1 DO BEGIN
    master=inttab[0, i]
    slave=inttab[1, i]
    mdate=FILE_BASENAME(master, suffix)
    sdate=FILE_BASENAME(slave, suffix)
    intdate=mdate+'-'+sdate
    
    PrintF, lun, 'mkdir '+intdate
    PrintF, lun, 'cd '+intdate
    PrintF, lun, 'tli_interf_SLC '+master+' '+slave+' $dem 8 8 2 0 -'
    PrintF, lun, 'cd ../'
    PrintF, lun, ''
    
  ENDFOR
  
  FREE_LUN, lun
  
  void=DIALOG_MESSAGE(['Please run the following script file using',$
    '  ./your_script', $
    '',$
    'Do this in any path you like to maintain the results'],/center,/information)
    
END
