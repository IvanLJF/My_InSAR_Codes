;
; Provide the DEM figure for Hong Kong.
;
PRO TLI_PLOT_DEM

  workpath='/mnt/backup/reserved_data/DEM/HKDEM/hkdem_hgt/'
  demfile=workpath+'N22E112.hgt'
  
  samples=1201
  result=TLI_READDATA(demfile, samples=samples, format='INT')
  HELP, result
  Print, result[0:3, 0:3]
  
  TVSCL, result
  STOP
  
END