;
; Calculate the phase increments using deformation parameters, realtive subsidence rate, and relative DEM error.
;
; Parameters:
;   def_params      : Deformation parameters computed using tli_def_params.
;   dv              : Relative deformation velocity.
;   ddh             : Relative DEM error.
;   single          : Return the first value of the phase.
;
; Return:
;   The unwrapped phase increments.
;   phi_w           : The wrapped phase increments.
; Written by:
;   T.LI @ ISEIS, 20131224
;   20140513        : Add the keyword 'single'.
;   20140519        : Add the keyword "ind".
;
FUNCTION TLI_PHASE_INCREMENT, def_params, dv, ddh, phi_hgt=phi_hgt, phi_v=phi_v, phi_w=phi_w, ind=ind

  COMPILE_OPT idl2
  
  nintf=N_ELEMENTS(def_params.tbase)
  IF NOT KEYWORD_SET(ind) THEN ind=LINDGEN(nintf) 
  
  ref_r= def_params.ref_r
  
  Tbase= (def_params.tbase)[*, ind]
  Bperp= (def_params.bperp)[*, ind]
  
  wavelength= def_params.wavelength
  sinla= SIN(def_params.pla)
  
  K1= -4*(!PI)/(wavelength*ref_r*sinla)
  K2= -4*(!PI)/(wavelength*1000)
  coefs_v= K2*Tbase
  coefs_dh= K1[0]*Bperp
  coefs=[coefs_v, coefs_dh]
  ;  coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
  ;  result= coefs_n##dphi_i ; dv ddh
  result=[dv, ddh]
  result= TRANSPOSE(result)
  phi_hgt=TRANSPOSE(coefs_dh)*ddh[0] & void=TLI_ISVECTOR(hpi_hgt, single_line=phi_hgt)
  phi_v=coefs_v*dv[0] & void=TLI_ISVECTOR(phi_v, single_line=phi_v)
  ls_phi_unw= coefs##result
  phi_w=TLI_WRAP_PHASE(ls_phi_unw)
  
  void=TLI_ISVECTOR(ls_phi_unw, single_line=ls_phi_unw)
  RETURN, ls_phi_unw
  
END