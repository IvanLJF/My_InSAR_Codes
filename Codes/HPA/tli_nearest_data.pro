; find the nearest data in the given array.
;
; Written by:
;   T.LI @ ISEIS
; 20130726
;
FUNCTION TLI_NEAREST_DATA, data, array, ind=ind

  COMPILE_OPT idl2
  
  ind_sort=SORT(array)
  
  array_n=array[ind_sort]
  
  diff=data-array_n
  z_ind=WHERE(diff GE 0, count)
  
  IF count EQ 0 THEN BEGIN
    ind=[-1,ind_sort[0]]
    left=!values.D_NAN
    right=array[ind[1]]
    RETURN, [left, right]
  ENDIF
  
  IF diff[z_ind[count-1]] EQ 0 THEN BEGIN
    ind=[ind_sort[z_ind[count-1]],ind_sort[z_ind[count-1]]]
    RETURN, array[ind]
  ENDIF
  
  left_ind=ind_sort[z_ind[count-1]]
  IF count EQ N_ELEMENTS(array) THEN BEGIN
    right_ind=-1
    ind=[left_ind, -1]
    left=array[left_ind]
    right=!values.D_NAN
    RETURN, [left, right]
  ENDIF ELSE BEGIN
    right_ind=ind_sort[z_ind[count-1]+1]
    ind=[left_ind, right_ind]
    RETURN, array[ind]
  ENDELSE
  
  


END