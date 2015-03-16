;+ 
; Name:
;    TLI_PINT
; Purpose:
;    Generate pint file.
; Calling Sequence:
;    TLI_PINT, pslc_file, plist_file, itab_file, sarlist_file, pint_file=pint_file
; Inputs:
;    pslc_file    :  Full path of pslc file.
;    plist_file   :  Full path of plist file.
;    itab_file    :  Full path of itab file.
;    sarlist_file :  Full path of sarlist file.
; Keyword Input Parameters:
;    pint_file    :  Full path of pint file.
; Outputs:
;    pint_file    :  --------------------------------
;                    | Complex Array
;                    |    itab1 itab2 ... itabn
;                    |pt1
;                    |pt2
;                    |...
;                    |ptn
;                    --------------------------------
; Commendations:
;    pint_file    :  If not set, this is pint.pint, in the same directory as plist_file
; Example:
;    pslc_file= 'D:\myfiles\Software\TSX_PS_Tianjin\pslc.pslc'
;    plist_file= 'D:\myfiles\Software\TSX_PS_Tianjin\plist.dat'
;    itab_file= 'D:\myfiles\Software\TSX_PS_Tianjin\itab.txt'
;    sarlist_file= 'D:\myfiles\Software\TSX_PS_Tianjin\sarlist.txt'
;    pint_file= FILE_DIRNAME(plist_file)+PATH_SEP()+'pint.pint'
;    TLI_PINT, pslc_file, plist_file, itab_file, sarlist_file, pint_file=pint_file
; Modification History:
;    01/06/2012        :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;-   
PRO TLI_PINT, pslc_file, plist_file, itab_file, sarlist_file, pint_file=pint_file
  COMPILE_OPT idl2
  
  nslcs= FILE_LINES(sarlist_file)
  
  pslcsamples= nslcs
  pslclines= TLI_PNUMBER(plist_file)
  pslc= COMPLEXARR(pslcsamples, pslclines)
  OPENR, lun, pslc_file,/GET_LUN
  READU, lun, pslc
  FREE_LUN, lun;读取pslc文件
  
  nint= FILE_LINES(itab_file)
  itab= INTARR(4)
  OPENR, lun, itab_file,/GET_LUN
  FOR i=0, nint-1 DO BEGIN
    tmp=''
    READF, lun, tmp
    tmp= STRSPLIT(tmp, ' ',/EXTRACT)
    tmp= FIX(tmp)
    itab= [[itab],[tmp]]
  ENDFOR
  itab= itab[*,1:*];读取itab文件
  
  ;开始创建pint
  ;pint: complex array.
  ;--------------------------------
  ;|    itab1 itab2 ... itabn
  ;|pt1
  ;|pt2
  ;|...
  ;|ptn
  ;--------------------------------
  pint= pslc[0, *]; Point coordinates.
  FOR i=0, nint-1 DO BEGIN
    master= itab[0, i]
    slave= itab[1, i]
    master= pslc[master-1, *]
    slave= pslc[slave-1, *]
    pint= [pint,(master*CONJ(slave))]
  ENDFOR
  pint= pint[1:*, *]
  
  OPENW, lun, pint_file,/GET_LUN
  WRITEU, lun, pint
  FREE_LUN, lun
  
  Print, 'File written successfully!'
END