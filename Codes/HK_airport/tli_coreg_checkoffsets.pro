PRO TLI_COREG_CHECKOFFSETS
  
  workpath='/mnt/backup/TSX-HKAirport/rslc_GAMMA/20090623'
  workpath=workpath+PATH_SEP()
  ptfile=workpath+'coreg_4p'
  pt=TLI_READTXT(ptfile)
  
  masterp=pt[*, 0:3]
  slavep=pt[*, 4:*]
  Print, slavep-masterp
  
END
