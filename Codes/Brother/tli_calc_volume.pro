; Define the function to be integrated. 
FUNCTION f_var, x 
   RETURN, 2*(( ((2+0.32314*x)^2/4 + (0.975-0.39614*x)^2)^2 / (2*(0.975-0.39614*x)^2) )* ATAN(2*(0.975-0.39614*x)/(2+0.32314*x)) $
           - (2+0.32314*x)/(4*(0.975-0.39614*x)) * ((2+0.32314*x)^2/4 - (0.975-0.39614*x)^2)) $
           + (2.85+0.98729*x)*(2+0.32314*x)
;  RETURN, (2.85D +0.98729D*x)*(2D +0.32314D*x)           
END 
 

PRO TLI_CALC_Volume
;  ;e:弓形边长
;  ;c:弓形高度
;  e=2.45D
;  c=0.42D
;  Sbow= ((e^2/4+c^2)^2/(2*c^2))*ATAN((2*c)/e)-e/(4*c)*(e^2/4-c^2)
;  Print, ((e^2/4+c^2)^2/(2*c^2))*ATAN((2*c)/e)-e/(4*c)*(e^2/4-c^2)
;  Print, 'Sbow:', sbow*2
;  
  ans = IMSL_INTFCN('f', 0, 1.4) 
; Call IMSL_INTFCN to compute the integral. 
  Print, 'Computed Volume:', ans 
;
  ; Upper surface area:
  x=1.4
  Print,'Upper surface area:',2*(( ((2+0.32314*x)^2/4 + (0.975-0.39614*x)^2)^2 / (2*(0.975-0.39614*x)^2) )* ATAN(2*(0.975-0.39614*x)/(2+0.32314*x)) $
           - (2+0.32314*x)/(4*(0.975-0.39614*x)) * ((2+0.32314*x)^2/4 - (0.975-0.39614*x)^2)) $
           + (2.85+0.98729*x)*(2+0.32314*x)
             
    f=2.4524D
  a=0.4204D
  b=4.2322
  e=f 
  c=a
  Sbow= ((e^2/4+c^2)^2/(2*c^2))*ATAN((2*c)/e)-e/(4*c)*(e^2/4-c^2)
  rect= f*b
  Print, 'True volume:', 2*sbow+rect
  ; This volume is larger than the inner endo volume, smaller than the external volume.
  au=5.0730
  bu=2.4524
  ad=4.8
  bd=2
  h=1.4
  ext_vol= (ad*bd+au*bu+((au*ad)*(bu*bd))^0.5)*h/3
  Print, 'External volume:',ext_vol
  
  au=4.2322D
  bu=2.4524D
  ad=2.85D
  bd=2D
  h=1.4D
  ext_vol= (ad*bd+au*bu+SQRT(au*ad*bu*bd))*h/3D
  Print, 'Endo volume:', ext_vol

END