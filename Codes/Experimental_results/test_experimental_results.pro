PRO TEST_EXPERIMENTAL_RESULTS

  workpath='/mnt/data_tli/ForExperiment/TSX_PS_HK_Airport/HPA/'
  plistfile=workpath+'lel2plist'
  pdifffile=workpath+'lel2pdiff'
  pslcfile=workpath+'lel2pslc'
  
  npt=TLI_PNUMBER(plistfile)
  pdiff=TLI_READDATA(pdifffile, samples=npt, format='fcomplex',/swap_endian)
  Print, 'Congratulations!! The first file is successfully loaded into system.'
  pslc=TLI_READDATA(pslcfile, samples=npt, format='fcomplex',/swap_endian)
  Print,'Congratulations for the second time!!! Guess what happened...'
END