PRO TLI_CWN
  inputfile='/mnt/software/ForExperiment/int_tsx_tianjin/1000/20090407.rslc'
  parfile=inputfile+'.par'
  finfo=TLI_LOAD_SLC_PAR(parfile)
  samples=finfo.range_samples
  format=finfo.image_format
  
  slc=TLI_READDATA(inputfile, samples=samples, format=format,/swap_endian)
  
  sz=SIZE(slc,/DIMENSIONS)  ; Get the size of the image.
  sz=sz*0.5
  
  slc=CONGRID(slc, sz[0], sz[1])  ; Resample the image.
  
  amp=ABS(slc)
  amp=amp^0.25    ; Stretch the amplitude.
  
  WINDOW, /free, xsize=sz[0], ysize=sz[1]
  
  TVSCL, amp
  
  STOP
  
END