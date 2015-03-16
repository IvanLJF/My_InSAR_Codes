;
; Calculate the height ambiguities as well as the deformation ambiguities.
;
; Parameters:
;   sarlistfile   : The sarlist file or .par file.
;   baselistfile  : The base file. Please calculate using base_calc in GAMMA.
; Keywords:
;   dv            : delta deformation_veloctiy
;   ddh           : delta height.
;   int_index     : Interferogram index / Base index.
;                   Start from 1. If not specified, using index 1.
; Written by:
;   T.LI @ SWJTU, 20140321
;
PRO TLI_AMBIGUITIES, sarlistfile, baselistfile,  dv=dv, ddh=ddh, int_index=int_index

  COMPILE_OPT idl2
  c=TLI_C()
  
  IF N_ELEMENTS(dv) EQ 0 THEN dv=0D
  IF N_ELEMENTS(ddh) EQ 0 THEN ddh=0D
  IF NOT KEYWORD_SET(int_index) THEN int_index=1
  
  ; Load base file.
  bases=TLI_READTXT(baselistfile, /easy)
  
  ; Load par file.
  void=TLI_FNAME(sarlistfile, suffix=suffix)
  IF STRLOWCASE(suffix) EQ '.par' THEN BEGIN
    finfo=TLI_LOAD_SLC_PAR(sarlistfile)
  ENDIF ELSE BEGIN
    finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  ENDELSE
  
  ; Print information
  lamda=c/finfo.radar_frequency
  r=finfo.center_range_slc
  theta=finfo.incidence_angle
  baseinfo=bases[*, int_index-1]
  Print, 'TLI_AMBIGUITIES:'
  Print, 'Wavelength:', lamda
  Print, 'Center slant range:', r
  Print, 'Look angle (degree):', theta
  Print, 'Base info [ind, m_date, s_date, b_perp, b_t]:', baseinfo
  
  ; Calculate the ambiguities.
  tbase=ABS(baseinfo[4])
  bbase=ABS(baseinfo[3])
  phi_dv=4D * !PI / lamda * (dv * tbase / 365D / 1000D)
  phi_ddh=(4*!PI* bbase)/( lamda*r*SIN(degree2radians(theta))) * ddh
  
  phi_dv_mddh= 2* !PI - phi_ddh  ;
  phi_ddh_mdv= 2* !PI - phi_dv   ;
  
  dv_amb= phi_dv_mddh * lamda /(4D * !PI * tbase / 365D / 1000D)
  ddh_amb= (phi_ddh_mdv * lamda*r*SIN(degree2radians(theta)))/((4*!PI * bbase))
  
  Print, 'Input dv (mm/yr):', dv, '    Corresponding ddh (m):', ddh_amb
  Print, 'Input ddh (m):', ddh, '   Corresponding dv (mm/yr):', dv_amb
  
END