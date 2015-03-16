;
; Sort the complex array with reference to the specified part (real part or imaginary part).
;
; Parameters
;  array   : The input complex array
;  sort_part: The part to sort.
;    0     : Let the real part be ascending.
;    1     : Let the imaginary part be asending.(Ommitted)
;  ind     : The sorted indices.
;
; Written by:
;  T.LI @ SWJTU, 20140225
;
; History:
;  20140616: Fixed a bug. Add consideration when the end of the iteration was encountered.
;            T.LI @ SWJTU.
;
FUNCTION TLI_SORT_COMPLEX, array, sort_part=sort_part, ind=ind

  type=SIZE(array[0],/TYPE)
  IF type NE 6 AND type NE 9 THEN Message, 'Error! Do not support the non-complex arrays.'
  IF N_ELEMENTS(sort_part) EQ 0 THEN sort_part=1
  sz= SIZE(array,/DIMENSIONS)
  
  r= REAL_PART(array)
  i= IMAGINARY(array)
  n= N_ELEMENTS(array)
  ind=LINDGEN(n)
  
  Case sort_part OF
    0 : BEGIN
      ; Sort the real_part
      temp_ind= SORT(r)
      r=r[temp_ind]
      i=i[temp_ind]
      ind=ind[temp_ind]
      
      ; Sort the imaginary part
      k=0D
      FOR j=0D, n-2D DO BEGIN
        ; Count the number of the elements whose real part are the same.
        IF k EQ 0 THEN j_start=j
        r_start= r[j_start]
        r_end= r[j+1]
        IF r_end NE r_start OR j+1 EQ n THEN BEGIN  ; This is the end of the section
        
          IF j+1 NE n THEN BEGIN
            ; Extract the values
            section_i=i[j_start:j]
            section_ind=ind[j_start:j]
            
            ; Sort the values
            temp_ind=SORT(section_i)
            section_i=section_i[temp_ind]
            section_ind=section_ind[temp_ind]
            
            ; Re-assign the section
            i[j_start:j]=section_i
            ind[j_start:j]=section_ind
            k=0
          ENDIF ELSE BEGIN
            ; Extract the values
            section_i=i[j_start:*]
            section_ind=ind[j_start:*]
            
            ; Sort the values
            temp_ind=SORT(section_i)
            section_i=section_i[temp_ind]
            section_ind=section_ind[temp_ind]
            
            ; Re-assign the section
            i[j_start:*]=section_i
            ind[j_start:*]=section_ind
            k=0
            
          ENDELSE
        ENDIF ELSE BEGIN
          k=k+1
        ENDELSE
        
      ENDFOR
      RETURN, REFORM(COMPLEX(r, i),sz)
    END
    1: BEGIN
      ; Sort the imaginary_part
      temp_ind= SORT(i)
      r=r[temp_ind]
      i=i[temp_ind]
      ind=ind[temp_ind]
      
      ; Sort the real part
      k=0D  ; Count the number of the elements whose real part are the same.
      FOR j=0D, n-2D DO BEGIN
      
        IF k EQ 0 THEN j_start=j
        i_start= i[j_start]
        i_end= i[j+1]
        IF i_end NE i_start OR j+2 EQ n THEN BEGIN  ; This is the end of the section
          IF j+2 NE n THEN BEGIN
          
            ; Extract the values
            section_r=r[j_start:j]
            section_ind=ind[j_start:j]
            
            ; Sort the values
            temp_ind=SORT(section_r)
            section_r=section_r[temp_ind]
            section_ind=section_ind[temp_ind]
            
            ; Re-assign the section
            r[j_start:j]=section_r
            ind[j_start:j]=section_ind
            k=0
          ENDIF ELSE BEGIN
            ; Extract the values
            section_r=r[j_start:*]
            section_ind=ind[j_start:*]
            
            ; Sort the values
            temp_ind=SORT(section_r)
            section_r=section_r[temp_ind]
            section_ind=section_ind[temp_ind]
            
            ; Re-assign the section
            r[j_start:*]=section_r
            ind[j_start:*]=section_ind
            
          ENDELSE
        ENDIF ELSE BEGIN
          k=k+1
        ENDELSE
        
      ENDFOR
      RETURN, REFORM(COMPLEX(r, i), sz)
      
    END
    ELSE: BEGIN
      Message, 'No other method supported !!!'
    END
  ENDCASE
  
END