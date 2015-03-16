;+ 
; Name:
;    GetImage
; Purpose:
;    返回tif的行列数
; Calling Sequence:
;    result= GetImage(tif)
; Inputs:
;    tif    :   .tif文件的全路径 
; Outputs:
;    result :   数组，包含两个值[列数，行数]
; Commendations:
;    infile :   只支持tif或者tiff
; Example:
;    infile= 'D:\myfiles\My_InSAR_Tools\RSTool\lena.tif'
;    result= GetImage(infile)
;    Print, result
; Modification History:
;-   


Function GetImage, infile

  temp= STRSPLIT(infile, '.', /EXTRACT)
  IF (STRCMP(temp[1], 'TIF')+STRCMP(temp[1], 'TIFF')) Then BEGIN ; 只支持.tif和.tiff
    Message, 'Image type not support!'
  ENDIF 
  
  result= QUERY_TIFF(infile,s)
  coled= (s.dimensions)[1]
  rowed= (s.dimensions)[0]
  return_result= [coled, rowed]
  RETURN, return_result
  
END