; One image is lost when changing original image to SLC.
; It is 20090120
PRO TLI_CHECK_HKAIRPORT_FILES
  
  COMPILE_OPT idl2
  
  workpath='/mnt/backup/TSX-HKAirport'
  workpath=workpath+PATH_SEP()
  origpath=workpath+'TerraSAR-X_Spotlight'+PATH_SEP()
  rslcpath=workpath+'rslc_GAMMA'+PATH_SEP()
  slcpath=workpath+'slc_GAMMA'+PATH_SEP()
  
  origfiles=FILE_SEARCH(origpath+'2*')
  origfiles=FILE_BASENAME(origfiles)
  origfiles=origfiles[SORT(origfiles)]
  
  slcfiles=FILE_SEARCH(slcpath+'*.slc')
  slcfiles=FILE_BASENAME(slcfiles, '.slc')
  slcfiles=slcfiles[SORT(slcfiles)]
  
  ; Compare the two sets of images.
  slcfiles=[slcfiles,'']
  results=[[origfiles],[slcfiles]]
  Print, TRANSPOSE(results)
  


END