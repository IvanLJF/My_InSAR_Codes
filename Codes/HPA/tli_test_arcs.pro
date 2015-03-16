PRO TLI_TEST_ARCS
  
  simfrompath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  simfrompath= simfrompath+PATH_SEP()
  sarlistfile= simfrompath+'SLC_tab'
  itabfile= simfrompath+'itab'
  simbasepath= simfrompath+'testforCUHK/base'
  
  workpath='/mnt/software/myfiles/Software/experiment/sim'
  workpath=workpath+PATH_SEP()
  logfile= workpath+'log.txt'
  ptfile= workpath+'pt'
  deffile= workpath+'def'
  maskfile= workpath+'mask'
  simlinfile= workpath+'simlin'  ; simulated linear deformation v
  simherrfile= workpath+'simherr'
  simph_unwfile= workpath+'simph_unw' ; Simulated unwrapped phase.
  simphfile= workpath+'simph'  ; simulated different phase
  pbasefile= workpath+'pbase'
  plafile= workpath+'pla'
  
END