;
; Calculate the gamma/phase_sigma value with reference to Colesanti et al., 2003
;   phase_sigma=SQRT(-2*ln(ABS(gamma)))
; 
; Keywords:
;   gamma       : Gamma. Also called single point multiimage coherence or temporal coherence or ensemble phase coherence.
;   phase_sigma : Phase sigma.
;
; Written by:
;   T.LI @ SWJTU, 20140302
; 
@tli_e
FUNCTION TLI_GAMMA_PHASESIGMA, gamma=gamma, phase_sigma=phase_sigma
  
  COMPILE_OPT idl2
  
  e=TLI_E()
  Case 1 OF
  
    KEYWORD_SET(gamma): BEGIN
      result=SQRT(-2*ALOG(ABS(gamma)))
    END
    
    KEYWORD_SET(phase_sigma): BEGIN
      result=ABS(e^((phase_sigma^2)/(-2)))
    END
    
    ELSE: Message, 'Usage Error!'
  ENDCASE
  
  RETURN, result


END