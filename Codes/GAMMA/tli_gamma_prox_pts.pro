;-
;- Find a nearest point in largeplistfile for each point in smallplistfile
;-   smallplistfile   : The plistfile to use.
;-   largeplistfile   : The plistfile to search.
;-   outputfile       : The new plist result.
;-   errfile          : Locating errors.
;-   ind              : Return values: Index of the result points in largeplistfile.
;-   coors            : Return values: Coors of the result points.
;-   errs             : Return values: Errors of the locations.
;-   myfiles          : If my format is used (Fcomplex, little_endian), please add /myfiles.
;-   txt              : If the inputfile is an ASCII file, please add /txt.
;- Written by:
;-   T.Li @ ISEIS, 20130723
;-
PRO TLI_GAMMA_PROX_PTS, smallplistfile, largeplistfile, outputfile=outputfile, errfile=errfile,$
    ind=ind, coors=coors,errs=errs,myfiles=myfiles,txt=txt
    
  COMPILE_OPT idl2
  ; All the input files are in GAMMA formats.
  IF KEYWORD_SET(txt) THEN BEGIN
    data=TLI_READTXT(smallplistfile,/easy)
    sz=SIZE(data,/DIMENSIONS)
    IF sz[0] NE 2 THEN Message, 'Error, there should be 2 lines in the file:'+$
      STRING(13b)+smallplistfile
    smallplist=COMPLEX(data[0,*], data[1,*])
    
    IF KEYWORD_SET(myfiles) THEN BEGIN
      largeplist=TLI_READMYFILES(largeplistfile, type='plist')
    ENDIF ELSE BEGIN
      largeplist=TLI_READDATA(largeplistfile, samples=2, format='LONG',/swap_endian)
      largeplist=COMPLEX(largeplist[0,*], largeplist[1, *])
    ENDELSE
  
  ENDIF ELSE BEGIN
    IF KEYWORD_SET(myfiles) THEN BEGIN
      smallplist=TLI_READMYFILES(smallplistfile, type='plist')
      largeplist=TLI_READMYFILES(largeplistfile,type='plist')
    ENDIF ELSE BEGIN
    
      smallplist=TLI_READDATA(smallplistfile, samples=2, format='LONG',/swap_endian)
      largeplist=TLI_READDATA(largeplistfile, samples=2, format='LONG',/swap_endian)
      smallplist=COMPLEX(smallplist[0, *], smallplist[1, *])
      largeplist=COMPLEX(largeplist[0, *], largeplist[1, *])
    ENDELSE
  ENDELSE
  
  npt=N_ELEMENTS(smallplist)
  ; Find the correspongding coordinates in largeplist
  ind=LONARR(npt)
  FOR i=0, npt-1 DO BEGIN
    coor_i=smallplist[i]
    
    dis=ABS(largeplist-coor_i)
    mindis=MIN(dis, ind_i)
    ind[i]=ind_i
    
  ENDFOR
  coors=largeplist[*,ind]
  errs=coors-smallplist
  
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=smallplistfile+'_prox'
  ENDIF
  IF NOT KEYWORD_SET(errfile) THEN BEGIN
    errfile=outputfile+'.err'
  ENDIF
  
  IF KEYWORD_SET(myfiles) THEN BEGIN
    TLI_WRITE, outputfile, coors
  ENDIF ELSE BEGIN
    TLI_WRITE,outputfile, LONG([REAL_PART(coors), IMAGINARY(coors)]),/swap_endian
  ENDELSE
  TLI_WRITE, outputfile+'.txt',   LONG([REAL_PART(coors), IMAGINARY(coors)]),/txt
  TLI_WRITE, errfile, errs,/swap_endian
  TLI_WRITE, errfile+'.txt', errs,/txt
  
  max_err=MAX(ABS(errs))
  IF max_err GT 1000 THEN message, 'Error! The locating erros is larger than 100:' +STRCOMPRESS(max_err)
END