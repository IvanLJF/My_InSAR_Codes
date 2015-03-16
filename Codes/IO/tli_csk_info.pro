;
; Get simple file info from h5 file.
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20150108.
;   For more information, please check CSKProductHandbook.pdf 
; 
FUNCTION TLI_CSK_INFO, h5file
  
  file=FILE_BASENAME(h5file, '.h5')
  IF STRLEN(file) NE 56 THEN Message, 'Please provide CSK file name with length of 59.'
  
  temp=STRSPLIT(file, '_',/extract)
  
  result=CREATE_STRUCT($
         'Mission', temp[0], $
         'Product', temp[1]+'_'+temp[2], $
         'Mode', temp[3],$
         'Swath', temp[4],$  ; temp[3] is fixed as S2
         'Pol', temp[5],$
         'Look_Dir', STRMID(temp[6], 0,1),$
         'Orb_Dir', STRMID(temp[6], 1,1),$
         'Delivery', STRMID(temp[7], 0, 1),$
         'GPS', STRMID(temp[7], 1,1),$
         'Start_time', temp[8],$
         'End_time', temp[9] )
  Return, result

END