; Define the function to be integrated. 
FUNCTION func, x 
   RETURN, 4*(((2+0.26612*x)^2 - 4*(0.975-0.32624*x)^2) / (8*(0.975-0.32624*x)) + (0.975-0.32624*x)) * ATAN(2*(0.975-0.32624*x)/(2+0.26612*x)) $
           - (2+0.26612*x)/(2*(0.975-0.32624*x)) * ((2+0.26612*x)^2/2 - (0.975-0.32624*x)^2) $
           + (2.85+0.98729*x)*(2+0.26612*x)
END 
 

PRO TEST_Brother

Print, SOURCEROOT()

ans = IMSL_INTFCN('f', 0, 1.7) 
; Call IMSL_INTFCN to compute the integral. 
PM, 'Computed Answer:', ans 
; Output the results.


END