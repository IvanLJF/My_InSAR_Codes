;
; Process the deformation params
; 
; Parameters:
; 
; Keywords:
; 
; Written by:
;   T.LI @ SWJTU, 20140226.
;
FUNCTION TLI_PROCESSDEFPARAMS, def_params, ind=ind
  
  
  result=CREATE_STRUCT('tbase', def_params.tbase[*, ind], $
    'bperp', def_params.bperp[*,ind], $
    'pla', def_params.pla, $
    'wavelength', def_params.pla, $
    'ref_r', def_params.ref_r)
  RETURN, result
END