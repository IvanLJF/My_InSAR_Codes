@tli_linear_solve_cuhk
PRO TLI_KML_MA

  ; Geocoding for the input file

  workpath='/mnt/software/myfiles/Software/experiment/MA'
  workpath=workpath+PATH_SEP()
  hfile=workpath+'height'
  tfile=workpath+'temp'
  defvfile=workpath+'def_v'
  
  phgtfile=workpath+'phgt'
  ptempfile=workpath+'ptemp'
  pdeffile=workpath+'pdef'
  plistfile=workpath+'plist'
  phgtfile_geo=workpath+'phgt_geo'
  tempfile_geo=workpath+'temp_geo'
  pdeffile_geo=workpath+'pdef_geo'
  geofile=workpath+'pmapll_orig'
  
  
  origpath='/mnt/backup/ExpGroup/TSX_HK_DIFF_MA'
  origpath=origpath+PATH_SEP()
  avefile=origpath+'ave.ras'
  
  h=TLI_READDATA(hfile,samples=120, format='FLOAT')
  h=h*SIN(DEGREE2RADIUS(37))
  h=TRANSPOSE(h)  
  h=h+54D -25D
  
  t=TLI_READDATA(tfile, samples=120, format='FLOAT')
  t=TRANSPOSE(t)* FLOAT(1000)
  
  defv=TLI_READDATA(defvfile,samples=120,format='FLOAT')
  defv=TRANSPOSE(defv)*FLOAT(1000)
  
  ; Find the coors of the points whose value is not NAN.
  ind=WHERE(FINITE(t))
  temp=WHERE(FINITE(defv))
  IF TOTAL(ind-temp) NE 0 THEN STOP
  
  sz=SIZE(t,/DIMENSIONS)
  samples=sz[0]
  x=(ind MOD samples)
  y=FLOOR(ind/samples)
  
  h_pt=TRANSPOSE(h[ind])
  t_pt=TRANSPOSE(t[ind])
  def_pt=TRANSPOSE(defv[ind])
;  WINDOW,/FREE, xsize=800,ysize=800
;  TVSCL, t,/NAN
;  STOP
  ; Change the coors to the original coor-space
  ; UL(249,130) - (225,130)
  ; DR(402,225) - (402,249)
  ;  ave=READ_IMAGE(avefile)
  ;  ave=ave[225:402, 130:249]
  ;  WINDOW,/FREE, xsize=800,ysize=800
  ;  TVSCL, ave
  x=x+225L
  y=y+130L
  
  ; Output the plist file
  plist=TRANSPOSE([[x],[y]])
  OPENW, lun, plistfile,/GET_LUN, /SWAP_ENDIAN
  WRITEU, lun, plist
  FREE_LUN, lun
  
  ; Output the pght file & ptemp file & pdef file
  phgt=FLOAT(TRANSPOSE(h_pt))
  OPENW, lun, phgtfile,/GET_LUN, /SWAP_ENDIAN
  WRITEU, lun, phgt
  FREE_LUN, lun
  
  ptemp=FLOAT(TRANSPOSE(t_pt))
  TLI_WRITE, ptempfile,ptemp,/SWAP_ENDIAN
  
  pdef=FLOAT(TRANSPOSE(def_pt))
  TLI_WRITE, pdeffile, pdef,/SWAP_ENDIAN
  ; Print some params
  minh=MIN(h_pt, max=maxh)
  mint=MIN(t_pt, max=maxt)
  mindefv=MIN(def_pt, max=maxdefv)
  Print, 'Max height:', maxh, 'MIN:', minh
  Print, 'Max tem-related h:', maxt, 'MIN:', mint
  Print, 'Max def. v:', maxdefv, 'MIN:', mindefv
  ; Ready for geocoding
  
  ; Refine data
  tempind=TLI_REFINE_DATA(def_pt)
  
  
  ; Ready for kml.
  ; Read ptgeo
  geo=TLI_READDATA(geofile, samples=2, format='FLOAT',/swap_endian)
  offs=[114.184139,22.300069]-[114.183916,22.299977]
  geo=[geo[0,*]+offs[0],geo[1, *]+offs[1]]
  
;  phgt=FLOAT(TRANSPOSE(h_pt))
;  OPENW, lun, phgtfile,/GET_LUN, /SWAP_ENDIAN
;  WRITEU, lun, phgt
;  FREE_LUN, lun
;  TLI_WRITE, phgtfile_geo, FLOAT(([geo, h_pt])[*, tempind])
;  TLI_WRITE, tempfile_geo, FLOAT(([geo, t_pt])[*, tempind])
;  TLI_WRITE, pdeffile_geo, FLOAT(([geo, def_pt])[*, tempind])
;  TLI_WRITE, phgtfile_geo+'.txt', ([geo, h_pt])[*, tempind],/txt,format='(D30,D30,D30)'
;  TLI_WRITE, tempfile_geo+'.txt', ([geo, t_pt])[*, tempind],/txt,format='(D30,D30,D30)'
;  TLI_WRITE, plistfile+'.txt', plist[*, tempind],/TXT,format='(D30,D30,D30)'
;  TLI_WRITE, pdeffile_geo+'.txt', ([geo, def_pt])[*, tempind],/txt, format='(D30,D30,D30)'
  
  TLI_WRITE, phgtfile_geo, FLOAT(([geo, h_pt]))
  TLI_WRITE, tempfile_geo, FLOAT(([geo, t_pt]))
  TLI_WRITE, pdeffile_geo, FLOAT(([geo, def_pt]))
  TLI_WRITE, phgtfile_geo+'.txt', ([geo, h_pt]),/txt,format='(D30,D30,D30)'
  TLI_WRITE, tempfile_geo+'.txt', ([geo, t_pt]),/txt,format='(D30,D30,D30)'
  TLI_WRITE, plistfile+'.txt', plist,/TXT,format='(D30,D30,D30)'
  TLI_WRITE, pdeffile_geo+'.txt', ([geo, def_pt]),/txt, format='(D30,D30,D30)'
  
;  STOP
  tli_defingoogle
END