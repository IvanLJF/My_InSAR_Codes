FUNCTION COORMTOS, coef, coor_m , offs=offs
  ;- Calculate slave coor according to the ls coef and master coor.
  ;- coef: LS coeficients get from coarse_coreg_cc.pro
  ;- coor_m : master coor. real part is x coor, imaginary is y coor.
  ;- offs   : If use coefs of offsets, then please use this keyword.
  COMPILE_OPT idl2
  IF ~KEYWORD_SET(offs) THEN BEGIN
    coefx=coef[*,0]  &  coefy=coef[*,1]
    coor_sx= coefx[0]+coefx[1]*(REAL_PART(coor_m))+coefx[2]*(IMAGINARY(coor_m))+coefx[3]*REAL_PART(coor_m)*IMAGINARY(coor_m)$
             +coefx[4]*REAL_PART(coor_m)^2+coefx[5]*IMAGINARY(coor_m)^2
    coor_sy= coefy[0]+coefy[1]*(REAL_PART(coor_m))+coefy[2]*(IMAGINARY(coor_m))+coefy[3]*REAL_PART(coor_m)*IMAGINARY(coor_m)$
             +coefy[4]*REAL_PART(coor_m)^2+coefy[5]*IMAGINARY(coor_m)^2
    result= COMPLEX(coor_sx, coor_sy)
    RETURN, result
  ENDIF ELSE BEGIN
    coefx=coef[*,0]  &  coefy=coef[*,1]
    off_sx= coefx[0]+coefx[1]*(REAL_PART(coor_m))+coefx[2]*(IMAGINARY(coor_m))+coefx[3]*REAL_PART(coor_m)*IMAGINARY(coor_m)$
             +coefx[4]*REAL_PART(coor_m)^2+coefx[5]*IMAGINARY(coor_m)^2
    off_sy= coefy[0]+coefy[1]*(REAL_PART(coor_m))+coefy[2]*(IMAGINARY(coor_m))+coefy[3]*REAL_PART(coor_m)*IMAGINARY(coor_m)$
             +coefy[4]*REAL_PART(coor_m)^2+coefy[5]*IMAGINARY(coor_m)^2
    coor_sx= Real_part(coor_m)+off_sx
    coor_sy= IMAGINARY(coor_m)+off_sy
    result= COMPLEX(coor_sx, coor_sy)
    RETURN, result
  ENDELSE
END