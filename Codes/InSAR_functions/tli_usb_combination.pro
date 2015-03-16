;
; Determine the ultra-short baseline combination.
;
; Parameters:
;   sarlistfile      : Sarlist file.
;   baselistfile     : baselist file. Generated using base_calc in GAMMA.
;
; Keywords:
;   dv_thresh        : Threshold of relative deformation velocity.
;   ddh_thresh       : Threshold of relative delta h.
;
; Written by:
;   T.LI @ SWJTU, 20140517
;
; Written for Hongguo Jia.
;
FUNCTION TLI_USB_COMBINATION, sarlistfile, itabfile, baselistfile, pbasefile, plafile, plistfile, $
                         dv_thresh=dv_thresh, ddh_thresh=ddh_thresh, mask=mask

  COMPILE_OPT idl2
  
  IF N_ELEMENTS(dv_thresh) EQ 0 THEN dv_thresh=10
  IF N_ELEMENTS(ddh_thresh) EQ 0 THEN ddh_thresh=50
  
  npt=TLI_PNUMBER(plistfile)
  pbase=TLI_READDATA(pbasefile, samples=npt, format='double')
  pla=TLI_READDATA(plafile, samples=npt, format='double')
  
  base=TLI_READTXT(baselistfile, /easy)
  
  tbase=base[4, *]/365D
  bperp=base[3, *]
  
  ref_coor=COMPLEX(0,0)
  def_params= TLI_DEF_PARAMS(sarlistfile, itabfile, pbase=pbase, pla=pla, pind=pind, finfo=finfo, $
                             plist=plist, ref_coor=ref_coor)
  ; Calculate the phase values.
  ref_r= def_params.ref_r
  wavelength= def_params.wavelength
  sinla= SIN(def_params.pla)
  K1= -4*(!PI)/(wavelength*ref_r*sinla)
  K2= -4*(!PI)/(wavelength*1000)
  coefs_v= K2*Tbase
  coefs_dh= K1[0]*Bperp
  result=coefs_v*dv_thresh+coefs_dh*ddh_thresh
  ind=WHERE(result GE -!PI AND result LT !PI)  
  
  nintf=N_ELEMENTS(result)
  mask=LONARR(nintf)
  mask[ind]=1
  
  RETURN, ind
  
  
END