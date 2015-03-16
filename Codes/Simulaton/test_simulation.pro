PRO TEST_SIMULATION

  hpapath='/mnt/data_tli/ForExperiment/Lemon_gg/HPA/'
  workpath=FILE_DIRNAME(hpapath)+PATH_SEP()
  
  plistfile=workpath+'pt'  
  simlinfile=workpath+'simlin'
  simherrfile=workpath+'simherr'
  simvdhfile=workpath+'simvdh'
  
  plist=TLI_READDATA(plistfile, samples=2, format='LONG',/swap_endian)
  simlin=TLI_READDATA(simlinfile, samples=1, format='DOUBLE')
  simherr=TLI_READDATA(simherrfile, samples=1, format='DOUBLE')
  ind=DINDGEN(1, TLI_PNUMBER(plistfile))
  temp=DBLARR(1, TLI_PNUMBER(plistfile))
  simvdh=[ind, plist, simlin, simherr, temp+1, temp]
  
  TLI_WRITE, simvdhfile, simvdh
  
  TLI_DEDUPLICATE_VDHFILE, simvdhfile, outputfile=simvdhfile+'_dedu'
  
END