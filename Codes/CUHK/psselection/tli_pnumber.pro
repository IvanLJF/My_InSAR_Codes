;+
; Name:
;    TLI_PNUMBER
; Purpose:
;    Find the total number of points in a plist.
; Calling Sequence:
;    result= PNUMBER(plist)
; Inputs:
;    plist: Full path containing a plist file.
; Optional Input Parameters:
;    None
; Keyword Input Parameters:
;    None
; Outputs:
;    Total point number.
; Commendations:
;    None
; Example:
;    plist= '/mnt/software/ForExperiment/TSX_SH_IPTA_Piece/plist.dat'
;    result= PNUMBER(plist)
; Modification History:
;    29/02/2012: Written by T. Li @ InSAR Team in SWJTU & CUHK.

FUNCTION TLI_PNUMBER, plist

  COMPILE_OPT idl2
  
  ON_ERROR, 2
  
  IF N_PARAMS() NE 1 THEN BEGIN
    result= DIALOG_MESSAGE('Usage:'+STRING(13B)+'    result= PNUMBER(plist)')
    RETURN, -1
  ENDIF
  fileinfo= FILE_INFO(plist)
  pno= fileinfo.size/8D
  RETURN, pno
END