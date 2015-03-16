;-
;-   Check if the input ptr is valid or not
;-
;-   Valid pointers that point to undefined variable can cause an infinite loop.
;-   Refer to: www.idlcoyote.com/programs/undefined.pro
;
FUNCTION TLI_PTR_VALID, ptr
  
  IF NOT PTR_VALID(ptr) THEN RETURN, 0
  IF PTR_VALID(ptr) THEN BEGIN
    IF N_ELEMENTS(*(ptr)) EQ 0 THEN RETURN, 0
    
    RETURN, 1
  ENDIF 

END