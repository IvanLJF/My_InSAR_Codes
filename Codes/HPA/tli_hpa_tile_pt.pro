;PRO TLI_HPA_TILE_PT
;
;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA'
;  workpath=workpath+PATH_SEP()
;  plistfile= workpath+'plist'
;
;  sarlistfile= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/SLC_tab'
;  itabfile= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
;  finfo= TLI_LOAD_MPAR(sarlistfile,itabfile)
;  samples= finfo.range_samples
;  lines= finfo.azimuth_lines
;  tile_samples=100
;  tile_lines=100
;  plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
;  result= TLI_HPA_TILE_PT(plist, samples, lines, tile_samples, tile_lines)
;
; This function means to tile the points in order to serach points in a given area.
;
; - file: Set this keyword to indicate that input 'plist' is a plistfile instead of an array
;-
;
@tli_hpa_tile_data
FUNCTION TLI_HPA_TILE_PT, plist_in, samples, lines, tile_samples, tile_lines, file=file, pt_structfile=pt_structfile


  IF N_PARAMS() NE 5 THEN BEGIN
    Message, 'Usage error.'
  ENDIF
  
  IF KEYWORD_SET(file) THEN BEGIN
    Print, 'Reading plist file.'
    plist= TLI_READDATA(plist_in, samples=1, format='FCOMPLEX')
  ENDIF ELSE BEGIN
    plist=plist_in
  ENDELSE
  npt= N_ELEMENTS(plist)
  
  ; Judge the existency of ptstruct_this
  IF KEYWORD_SET(pt_structfile) THEN BEGIN
    IF FILE_TEST(pt_structfile) THEN BEGIN
      finfo_tmp= FILE_INFO(pt_structfile)
      fsize=CEIL(samples/tile_samples)*CEIL(lines/tile_lines)+npt+1
      fsize=fsize*4
      IF finfo_tmp.size EQ fsize THEN BEGIN
        Print, 'We believe that the pt_structfile has already been constructed.'
        result=TLI_READDATA(pt_structfile,lines=1, format='long')
        RETURN, result
      ENDIF
    ENDIF
    
  ENDIF
  
  
  
  
  
  
  
  
  ; Create the result
  inputfile='Tile_pt'
  finfo=TLI_HPA_TILE_DATA(inputfile,samples, lines, tile_samples=tile_samples,tile_lines= tile_lines)
  coor_ind= finfo.index
  result= [LONARR(finfo.ntiles+1), LONARR(npt)]  ; This is the result argument.
  result[0]=result[0]+finfo.ntiles+1
  plist_x= REAL_PART(plist)
  plist_y= IMAGINARY(plist)
  
  startpts= INDEXARR(x= finfo.startx, y= finfo.starty)
  startx= REAL_PART(startpts)
  starty= IMAGINARY(startpts)
  endpts= INDEXARR(x= finfo.endx, y= finfo.endy)
  endx= REAL_PART(endpts)
  endy= IMAGINARY(endpts)
  ; For loops
  count_pt=result[0]
  FOR i=0D, finfo.ntiles-1D DO BEGIN
    Print, 'Tiling points... ', STRCOMPRESS(i),'/', STRCOMPRESS(finfo.ntiles-1)
    ind= WHERE(plist_x GE startx[i] $
      AND plist_x LE endx[i] $
      AND plist_y GE starty[i] $
      AND plist_y LE endy[i], complement= com_ind) ; In fact, complement is not used any more.
    IF ind[0] EQ -1 THEN BEGIN
      result[i+1]=result[i] ;Please be reminded here.
      CONTINUE
    ENDIF
    tile_npt= N_ELEMENTS(ind)
    ;  result[i]=count_pt
    count_pt= count_pt+tile_npt
    result[i+1]=count_pt
    result[result[i]:(result[i+1]-1)]=ind
  ;    Print, 'Original data:', ind
  ;    Print, 'Calculated data:',result[finfo.ntiles+result[i]:finfo.ntiles+result[i+1]-1]
  ENDFOR
  
  IF KEYWORD_SET(pt_structfile) THEN BEGIN
    OPENW, lun, pt_structfile,/GET_LUN
    WRITEU, lun, result
    FREE_LUN, lun
  ENDIF
  
  RETURN, result
  
  
END