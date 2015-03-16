PRO TLI_HPA

  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  
  IF 0 THEN BEGIN
    ; Run tli_hpa_1level.pro
    TLI_HPA_1LEVEL
    ; Run tli_hpa_2level.pro
    TLI_HPA_2LEVEL
    
    ; Run tli_hpa_3level.pro
    TLI_HPA_3LEVEL
    
    
    ; Run tli_hpa_loop.pro
    
    TLI_HPA_LOOP, workpath, level=4, coef_amp=coef_amp
    TLI_HPA_LOOP, workpath, level=5, coef_amp=coef_amp
    TLI_HPA_LOOP, workpath, level=6, coef_amp=coef_amp
  TLI_HPA_LOOP, workpath, level=7, coef_amp=coef_amp
  ENDIF
  coef_amp=0.7
  
  TLI_HPA_LOOP, workpath, level=8, coef_amp=coef_amp
  TLI_HPA_LOOP, workpath, level=9, coef_amp=coef_amp
  TLI_HPA_LOOP, workpath, level=10, coef_amp=coef_amp
  TLI_HPA_LOOP, workpath, level=11, coef_amp=coef_amp
  TLI_HPA_LOOP, workpath, level=12, coef_amp=coef_amp
  TLI_HPA_LOOP, workpath, level=13, coef_amp=coef_amp
END