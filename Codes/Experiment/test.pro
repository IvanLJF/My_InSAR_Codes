;-
;- Script that:
;-      Do common test
;- Usage:
;- Author:
;-      T. Li @ InSAR Group in SWJTU

PRO TEST
  hgtfile='/mnt/data_tli/ForExperiment/Casic2/Interferometric DSm/result2/Height_M.dat'
  samples=1298
  
  hgt=TLI_READDATA(hgtfile, samples=samples, format='double')
  
  void=TLI_REFINE_DATA(hgt, refined_data=hgt, /nan)
  
  hgt_min=MIN(hgt, max=hgt_max)
  
  hgt_mean=MEAN(hgt)
  
  hgt_std=STDDEV(hgt)
  
  Print, hgt_min, hgt_max, hgt_mean, hgt_std
END