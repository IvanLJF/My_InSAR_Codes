;+ 
; Name:
;    phase2sc
; Purpose:
;    Change phase to single complex
; Calling Sequence:
;    Result= PHASE2SC(infile,outfile, samples, lines)
; Inputs:
;    infile    :  File path of input phase file.
;    outfile   :  File path of output single complex file.
;    samples   :  Samples of input file.
;    lines     :  Lines of input file.
; Optional Input Parameters:
;    None.
; Keyword Input Parameters:
;    None.
; Outputs:
;    Output file of Single Complex.
; Commendations:
;    None.
; Example:
;    infile= 'D:\myfiles\ISEIS\data\ASAR20070726.phase'
;    outfile= 'D:\myfiles\ISEIS\data\ASAR20070726.slc'
;    samples= 5195
;    lines=27313
;    result= PHASE2SC(infile,outfile, samples, lines)
; Modification History:
;    18/04/2012: Written by T.Li @ InSAR Team in SWJTU & CUHK.
;- 


FUNCTION PHASE2SC, infile,outfile,samples, lines
  
  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 4 THEN Message, 'Usage:Result= PHASE2SC(infile,outfile, infile_type, samples, lines)'
  
  IF ~FILE_TEST(infile) THEN Message, 'No such files.'
  info= FILE_INFO(infile)
  sz= info.SIZE
  IF sz NE (4*samples*lines) THEN Message, 'Files size or data type is not right.'
  
  arr= FLTARR(samples, lines)
  
  OPENR, lun, infile,/GET_LUN
  READU, lun, arr
  FREE_LUN, lun
  
  r= COS(arr)*255
  i= SIN(arr)*255
  
  sc_arr= FLTARR(samples*2, lines)
  sc_arr[0:*:2]= r
  sc_arr[1:*:2]= i
  
  sc_arr= FIX(sc_arr)
  
  OPENW, lun, outfile,/GET_LUN
  WRITEU, lun, sc_arr
  FREE_LUN, lun
  
  PRINT, 'File convert successfully!'
  
  RETURN, 1

END