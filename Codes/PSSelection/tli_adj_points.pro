;-
;- Find the adjacent points for a given coordinate. For quick search and less calculation dunplication.
;- pscoor      : Coordinates of the input point.
;- ptstruct    : Tiling structure of the point.
;- rasstruct   : Tiling structure of the raster image.
;-
;;; This is the test params.
;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/PCP'
;  workpath=workpath+PATH_SEP()
;  
;  plistfile=workpath+'lel1plist'
;  mslc='whatever'
;  sarlistfile=workpath+'sarlist'
;  pt_structfile=plistfile+'.ptstr'
;  
;  pscoor=COMPLEX(100,100)
;  radius=10 ; The radius is suggest to be a quarter of tile_samples or tile_lines
;  tile_samples=50
;  tile_lines=50
;  finfo=TLI_LOAD_SLC_PAR_SARLISt(SARLISTFILE)
;  plist=TLI_READMYFILES(plistfile,type='plist')
;  
;  ptstruct=TLI_HPA_TILE_PT(plistfile,/file, finfo.range_samples, finfo.azimuth_lines, tile_samples, tile_lines, pt_structfile=pt_structfile)
;  rasstruct= TLI_HPA_TILE_DATA(mslc,finfo.range_samples, finfo.azimuth_lines,tile_samples=tile_samples, tile_lines=tile_lines)
;  result=TLI_ADJ_POINTS(pscoor,plist, ptstruct,rasstruct,radius=radius)
;  
;  adj_coors=plist[result]
;;  x=REAL_PART(adj_coors)
;;  y=IMAGINARY(adj_coors)
;;  WINDOW, xsize=rasstruct.samples, ysize=rasstruct.lines
;;  PlotS, x, y , psym=1, symsize=1,/DEVICE;,xrange=[0, rasstruct.samples], yrange=[0, rasstruct.lines]
;;  PlotS, REAL_PART(pscoor), IMAGINARY(pscoor), psym=5, symsize=1,/DEVICE,color=234
;-
;- Written by  : T.LI @ ISEIS, 20130620
FUNCTION TLI_ADJ_POINTS, pscoor,plist, ptstruct,rasstruct,radius=radius
  
  COMPILE_OPT idl2
  IF ~KEYWORD_SET(radius) Then radius=rasstruct.tile_samples/4
  
  ;  ind= rasstruct.index
  
  psx= REAL_PART(pscoor)
  psy= IMAGINARY(pscoor)
  indx= FLOOR(psx/rasstruct.tile_samples)
  indy= FLOOR(psy/rasstruct.tile_lines)
  ; Locate the tile index for this point.
  psind= (rasstruct.index)[indx, indy]
  ; Find the adj tiles.
  tile_start_x=(psx-radius)>0
  tile_end_x=(psx+radius)<(rasstruct.samples-1)
  tile_start_y=(psy-radius)>0
  tile_end_y=psy+radius<(rasstruct.lines-1)
  
  tile_start_xind=FLOOR(tile_start_x/rasstruct.tile_samples)
  tile_end_xind=FLOOR(tile_end_x/rasstruct.tile_samples)
  tile_start_yind=FLOOR(tile_start_y/rasstruct.tile_lines)
  tile_end_yind=FLOOR(tile_end_y/rasstruct.tile_lines)
  
  ; Search the adj. points within the radius.
  psind= (rasstruct.index)[tile_start_xind:tile_end_xind, tile_start_yind:tile_end_yind]
  ntiles=N_ELEMENTS(psind)
  adj_pt=0
  FOR i=0, ntiles-1 DO BEGIN
    IF ptstruct[psind[i]] GE ptstruct[psind[i]+1]-1 THEN CONTINUE
    temp=ptstruct[ptstruct[psind[i]]:ptstruct[psind[i]+1]-1]
    adj_pt=[adj_pt, temp]
  END
  IF N_ELEMENTS(adj_pt) EQ 1 THEN BEGIN
    ;    Print, 'There is no adjacent points.'
    RETURN, -1  ; No adjacent points.
  ENDIF ELSE BEGIN
    adj_pt=adj_pt[1:*] ; adj. points.
    ; Find the points within search radius
    ; Find the coor of this point.
    adj_coors=plist[adj_pt]
    adj_dist=ABS(adj_coors-pscoor)
    ind=WHERE(adj_dist LE radius)
    IF ind[0] EQ -1 THEN BEGIN
      ;      Print, 'There is no adjacent points.'
      RETURN, -1
    ENDIF ELSE BEGIN
      real_ind=adj_pt[ind]
      RETURN, real_ind ; The final result. Index of the adj. points.
    ENDELSE
  ENDELSE
END