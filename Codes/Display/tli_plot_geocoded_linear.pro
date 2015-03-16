PRO TLI_GEO_VDH, vdhfile, llfile, outputfile=outputfile
  COMPILE_OPT idl2
  geopath=FILE_DIRNAME(llfile)+PATH_SEP()
  
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=geopath+FILE_BASENAME(vdhfile)+'_geo'
  ENDIF
  
  vdh=TLI_READMYFILES(vdhfile,type='vdh')
  ll=TLI_READDATA(llfile, samples=2,format='LONG',/swap_endian)
  IF (SIZE(vdh,/DIMENSIONS))[1] NE (SIZE(ll,/DIMENSIONS))[1] THEN $
  Message, 'Error: The sizes of the input files are not consistent.'
  
  vdh[1:2, *]=ll
  
  TLI_WRITE, outputfile, vdh

END


PRO TLI_PLOT_GEOCODED_LINEAR
  
  geopath='/mnt/ihiusa/mydata_TLI/chenfulong/PSI_TLI/geocode'
  
  IF ~TLI_HAVESEP(geopath) THEN geopath=geopath+PATH_SEP()
  
  geomapfile=geopath+'pt_map'
  hpapath=FILE_DIRNAME(geopath)+PATH_SEP()+'HPA'+PATH_SEP()
  vdhfile=geopath+'vdh'
  sarlistfile=hpapath+'sarlist'
  rasfile=geopath+'ave.utm.rmli.ras'
  outputfile=geopath+'vdh_geocoded.tif'
  ptsize=0.001
  show=1
  no_clean=1
  los_to_v=1
  minus=1
  vdhfile_geo=vdhfile+'_geo'
  geocode=1
  geodims=[4740,6840]
  TLI_GEO_VDH, vdhfile, geomapfile, outputfile=vdhfile_geo
  
  TLI_PLOT_LINEAR_DEF, vdhfile_geo, rasfile, sarlistfile, $
    outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
    tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
    fliph_pt=fliph_pt,flipv_pt=flipv_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
    no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
    dpi=dpi, minus=minus,colorbar_interv=colorbar_interv,geocode=geocode, geodims=geodims
  
  

END