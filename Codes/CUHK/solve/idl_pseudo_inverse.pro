;+
; :Description:
;    Computes pseudo inverse of this matrix using SVD decomposition. 
;
; :Params:
;    matrix
;
;
; :Author: Stefano Gagliano
;-
function IDL_pseudo_inverse,matrix

la_svd,matrix,S,U,V,/double
return,V##invert(diag_matrix(S))##transpose(U)

end