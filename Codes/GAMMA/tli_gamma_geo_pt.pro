;-
;- Generate the geocoded deformation results.
;-
PRO TLI_GAMMA_GEO_PT

  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  
  workpath=workpath+PATH_SEP()
  hpapath=workpath+'HPA'+PATH_SEP()
  geocodepath=workpath+'geocode'+PATH_SEP()
  resultpath=geocodepath+'noborder'+PATH_SEP()
  
  plistfile=hpapath+'plist_merge_all_GAMMA'
  pdeffile=hpapath+'vdh'
  pllfile=geocodepath+'pmapll_lel1' ; Lat. & lon.
  
  geopdeffile=resultpath+'pdef_ll_lel1'
  geopdeffile_txt=geopdeffile+'.txt'
  
  vdh=TLI_READMYFILES(pdeffile,type='vdh')
  pll=TLI_READDATA(pllfile,format='FLOAT', samples=2,/swap_endian)
  ; Check input files
  plist=TLI_READDATA(plistfile, format='LONG', samples=2,/swap_endian)
  plist_vdh=vdh[1:2, *]
  temp=TOTAL(ABS(plist_vdh-plist))
  IF temp NE 0 THEN Message, 'Error! Inconsistency of plist!!!'
  Print, 'Files are used successfully!!!'
  
  ; Check the range of pll
  minlon=MIN(pll[0,*], max=maxlon)
  minlat=MIN(pll[1, *], max=maxlat)
  Print, 'Range of longitude:', minlon, maxlon
  Print, 'Range of latitude:', minlat, maxlat
  
  result=[pll, vdh[3, *]]
  OPENW, lun, geopdeffile,/GET_LUN
  WriteU, lun, result
  FREE_LUN, lun
  OPENW, lun, geopdeffile_txt,/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun
  
  
END