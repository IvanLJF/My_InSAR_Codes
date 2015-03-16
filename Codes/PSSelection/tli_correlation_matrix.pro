;
; Calculate the correlation matrix.
;
; Parameters:
; The input array should be organized as follows:
;   Information of each point stands in a line.
;   Information of each interferogram stands in a sample.
;
; Written by: T.LI @ ISEIS, 20140103
;
FUNCTION TLI_CORRELATION_MATRIX, array

  sz=SIZE(array,/DIMENSIONS)
  npt=sz[0]
  nintf=sz[1]
  result=FLTARR(npt, npt)
  FOR i=0D, npt-1D DO BEGIN
    IF NOT (i MOD 100) THEN BEGIN
      Print, STRCOMPRESS(i)+'/'+STRCOMPRESS(npt-1)
    ENDIF
    tempi=array[i, *]
    FOR j=0, npt-1 DO BEGIN
      tempj=array[j, *]
      result[i, j]=CORRELATE(tempi, tempj)
    ENDFOR
  ENDFOR
  RETURN, result
  
END