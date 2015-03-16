;+
; Name:
;    TLI_PSLC
; Purpose:
;    Generate PSLC file
; Calling Sequence:
;    result=TLI_PSLC(sarlist,plist, samples, lines,data_type,$
;                     swap_endian=swap_endian, outfile=outfile)
; Inputs:
;    sarlist    :  A .txt file containing all the slc files to be used.
;    plist      :  A binary file containing the PSs coordinates.
;    samples    :  Samples of slc files.
;    lines      :  Lines of slc files.
;    data_type  :  For detail, please see TLI_RAS2Vec
; Keyword Input Parameters:
;    swap_endian:  Swap or not? It's your decision.
;    outfile    :  PSLC file to be written.
; Outputs:
;    outfile    :  Binary file formed by n*m float complex array.
;                  m  :  PSs number.
;                  n  :  SLC files to be used.
;                 ------------------------
;                 |    slc1 slc2 ... slcn
;                 | pt1
;                 | pt2
;                 | ...
;                 | ptn
;                 -------------------------
; Commendations:
;    data_type  :  Case sensitive. Please use capital letters.
; Example:
;    plist= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/plist.dat'
;    sarlist= '/mnt/software/myfiles/Software/TSX_PS_Tianjin/sarlist.txt'
;    samples= 3500
;    lines= 3500
;    data_type='SCOMPLEX'
;    swap_endian=1
;    result=TLI_PSLC(sarlist,plist, samples, lines,data_type,$
;                     swap_endian=swap_endian, outfile=outfile)
; Modification History:
;    11/04/2012 :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;-
FUNCTION TLI_PSLC, sarlist,plist, samples, lines,data_type,$
    swap_endian=swap_endian, outfile=outfile, changed_coor= changed_coor, force=force
    
  
    
  IF N_PARAMS() NE 5 THEN Message, 'Usage:result=TLI_PSLC(sarlist,plist, samples, lines,data_type,'+STRING(13B)+ $
    'swap_endian=swap_endian, outfile=outfile)'
  IF ~KEYWORD_SET(outfile) THEN outfile= FILE_DIRNAME(sarlist)+PATH_SEP()+'pslc.pslc'
  
  IF FILE_TEST(outfile) THEN BEGIN
    npt=TLI_PNUMBER(plist) 
    temp=FILE_INFO(outfile)
    nfiles=FILE_LINES(sarlist)
    fsize=nfiles*npt*8
    IF fsize EQ temp.size THEN BEGIN
      IF NOT KEYWORD_SET(force) THEN BEGIN
        Print,'We believe that the pslc file has already been constructed. No duplication is generate.'
        Print, 'Please check the file: '+outfile
        RETURN, 1
      ENDIF
    ENDIF
  
  ENDIF
  
  nlines= FILE_LINES(sarlist)
  slcs= STRARR(1, nlines)
  OPENR, lun, sarlist,/GET_LUN
  READF, lun, slcs
  FREE_LUN, lun
  pno= TLI_PNUMBER(plist)
  coor= COMPLEXARR(pno)
  OPENR, lun, plist,/GET_LUN
  READU, lun, coor
  FREE_LUN, lun
  ;  pslc= [[REAL_PART(coor)],[IMAGINARY(coor)]]
  ;  pslc=coor
  IF ~Keyword_set(outfile) THEN BEGIN
    outfile= FILE_DIRNAME(plist)+PATH_SEP()+'pslc.pslc'
  ENDIF
  OPENW, lun, outfile,/GET_LUN
  FOR i=0, nlines-1 DO BEGIN
    PRINT, i+1, '/', STRCOMPRESS(nlines)
    result= TLI_RAS2VEC(slcs[i],plist,data_type, samples, lines,swap_endian=swap_endian, changed_coor= changed_coor)
    result= COMPLEX(result[*,2],result[*,3])
    ;    pslc=[[pslc],[result]]
    WRITEU, lun, result
  ENDFOR
  
  FREE_LUN, lun
  
  RETURN, 1
END