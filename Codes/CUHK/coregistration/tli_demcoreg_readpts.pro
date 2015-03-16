;+ 
; Name:
;    TLI_DEMCOREG_READPTS
; Purpose:
;    Read *.pts file and give polynomial coefficients.
; Calling Sequence:
;    Result= TLI_DEMCOREG_READPTS(pts_file, degree=degree)
; Inputs:
;    pts_file    :  *.pts file generated from ENVI.
; Keyword Input Parameters:
;    degree      :  Degree of polynomial.
; Outputs:
;    coefficients needed by Dr. Zhao.
; Commendations:
;    None
; Example:
;    pts_file= 'D:\ISEIS\Data\Img\dem-20091114.pts'
;    degree=1
;    Result= TLI_DEMCOREG_READPTS(pts_file, degree=degree)
; Modification History:
;    06/01/2012        :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;-  
FUNCTION TLI_DEMCOREG_READPTS, pts_file, degree=degree
  
  COMPILE_OPT idl2
  
  nlines= FILE_LINES(pts_file)
  pts=DBLARR(5)
  
  OPENR, lun, pts_file,/GET_LUN
  temp=''
  FOR i=0, 4 DO BEGIN
    READF, lun, temp
  ENDFOR
  FOR i=5, nlines-1 DO BEGIN
    temp=''
    READF, lun, temp
    result= STRSPLIT(temp, ' ',/EXTRACT)
    result=[DOUBLE(result),1]
    pts=[[pts], [result]]
  ENDFOR
  pts= pts[*,1:*]
  FREE_LUN, lun

  ; Polyfit
  foffs=pts
  
  coefs= DBLARR(6,4)
  coefs[*,0:1]= TLI_POLYFIT(foffs,degree=degree)
  
  foffs_c= foffs
  foffs[0:1,*]= foffs_c[2:3,*]
  foffs[2:3,*]= foffs_c[0:1,*]
  coefs[*,2:3]= TLI_POLYFIT(foffs,degree=degree)
  
  coefs_c=coefs
  coefs[1,*]=coefs_c[2,*]
  coefs[2,*]=coefs_c[1,*]
  coefs[3,*]=coefs_c[5,*]
  coefs[5,*]=coefs_c[3,*]
  
  coefs_c=coefs
  coefs[*,0]=coefs_c[*,1]
  coefs[*,1]=coefs_c[*,0]
  coefs[*,2]=coefs_c[*,3]
  coefs[*,3]=coefs_c[*,2]
  
  PRINT, '***********************************************'
  PRINT, '***             Poly Fit Finished!
  PRINT, '***********************************************'
  
  RETURN, coefs
  
END