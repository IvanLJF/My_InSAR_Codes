;-
;- Script that:
;-      Do common test
;- Usage:
;- Author:
;-      T. Li @ InSAR Group in SWJTU
PRO TEST
workpath='D:\ForExperiment\temp\'
files=FILE_SEARCH(workpath+'*',count=nfiles)

nlines=0
FOR i=0, nfiles-1 DO BEGIN
  nlines_i=FILE_LINES(files[i])
  nlines=nlines+nlines_i
  Print, FILE_BASENAME(files[i]), nlines_i
ENDFOR

Print, nlines

STOP
END