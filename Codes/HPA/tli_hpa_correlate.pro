PRO TLI_HPA_CORRELATE
  
  nintf= 40
  tbase= DINDGEN(nintf)*15/365
  v= 80 ; mm/yr
  lamda=0.03 ; 3cm
  
  a= RANDOMN(seed, nintf)
;  range=[-!PI, !PI]
;  a= TLI_STRETCH_DATA(a, range)
  
  phi_vel= v*tbase*(lamda/4*!PI)
  b=a+phi_vel
  
  noise= RANDOMN(seed, nintf)
  noise= noise*SQRT(15/365)
  b=b+noise
  
  b_wrap= TLI_WRAP_PHASE(b)
  
;  plot,b
;  oplot, b_wrap
;  oplot, phi_vel
Print, TRANSPOSE([[b],[b_wrap]])
Print, 'Correlation:', CORRELATE(b, b_wrap)

; Simulation have to be taken considering the correlation 
; between the second order deviation and the correlation of the phase
  STOP
END