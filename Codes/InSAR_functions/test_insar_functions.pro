;
; Test the insar functions.
;
PRO TEST_INSAR_FUNCTIONS
  
  workpath='/mnt/data_tli/ForExperiment/TSX_PS_HK_Airport/'
  hpapath=workpath+'HPA/'
  adi1file=workpath+'adi'
  adi2file=hpapath+'adi'
  sarlistfile=workpath+'SLC_tab'
  itabfile=workpath+'itab'
  
  finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
  
  adi1=TLI_READDATA(adi1file, samples=finfo.range_samples, format='float')
  adi2=TLI_READDATA(adi2file, samples=finfo.range_samples, format='float')
  
  
  
  
  
STOP
END