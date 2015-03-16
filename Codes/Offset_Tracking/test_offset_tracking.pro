@slc__define
PRO TEST_OFFSET_TRACKING

  workpath='/mnt/backup/ExpGroup/TSX_offset_tracking/images'
  workpath=workpath+PATH_SEP()
  resultpath='/mnt/backup/ExpGroup/TSX_offset_tracking'+pATH_SEP()
  IF 0 THEN BEGIN
    outputfile=workpath+'20090328.rslc'
    inputfile=workpath+'20090327.rslc'
    
    data=TLI_READSLC(inputfile)
    data=SHIFT(data, 1, 1)
    TLI_WRITE, outputfile, data,/swap_endian
    
    TLI_SC2FC, outputfile, outputfile=outputfile,/REVERSE
  ENDIF
  
  basename=resultpath+'20090328-20090327'
  offrfile=basename+'_r.offsets'
  offazifile=basename+'_azi.offsets'
  
  samples=500
  
  offr=TLI_READDATA(offrfile, samples=500, format='float')
  offr=TLI_STRETCH_DATA(offr, [0,255])
  WRITE_IMAGE, offrfile+'.bmp', 'BMP', offr
  
  offazi=TLI_READDATA(offazifile, samples=500, format='float')
  offazi=TLI_STRETCH_DATA(offazi, [0,255])
  WRITE_IMAGE, offazifile+'.bmp', 'BMP', offazi
  
  STOP
END