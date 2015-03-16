;PRO TLI_HPA_TILE_DATA
;  ; Params
;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/piece'
;  workpath=workpath+PATH_SEP()
;  inputfile= workpath+'20090327.rslc'
;  finfo= TLI_LOAD_SLC_PAR(inputfile+'.par')
;  samples=finfo.range_samples
;  lines= finfo.azimuth_lines
;  tile_samples=100
;  tile_lines=100
;  result= TLI_HPA_TILE_DATA(inputfile,samples, lines, ntiles=ntiles, ntiles_s=ntiles_s, ntiles_l=ntiles_l, $
;    tile_samples=tile_samples, tile_lines= tile_lines)
;   Params

FUNCTION TLI_HPA_TILE_DATA,inputfile,samples, lines, _ntiles=ntiles, ntiles_s=ntiles_s, ntiles_l=ntiles_l, $
    tile_samples=tile_samples, tile_lines= tile_lines
    
  COMPILE_OPT IDL2
  ON_ERROR, 2
  
  IF N_PARAMS() NE 3 THEN Message, 'Usage Error!'
  IF KEYWORD_SET(ntiles) THEN BEGIN
  
    Print, 'Keyword ntiles is set to ', STRCOMPRESS(ntiles), 'Other keywords are neglected.'
    IF SQRT(DOUBLE(ntiles)) NE LONG(SQRT(ntiles)) THEN BEGIN
      Message, 'Error: ntiles ~= n^2!'
    ENDIF
    ntiles_s_tmp= LONG(SQRT(ntiles))
    ntiles_l_tmp= ntiles_s_tmp
    tile_samples_tmp= LONG(samples/ntiles_s_tmp)
    tile_lines_tmp= LONG(lines/ntiles_l_tmp)
  ENDIF ELSE BEGIN
  
    IF KEYWORD_SET(ntiles_s)+KEYWORD_SET(ntiles_l) EQ 2 THEN BEGIN
      Print, 'Keyword ntiles_s and ntiles_l are set.'
      tile_samples_tmp= LONG(samples/ntiles_s)
      tile_lines_tmp= LONG(lines/ntiles_l)
    ENDIF ELSE BEGIN
      IF KEYWORD_SET(tile_samples)+ KEYWORD_SET(tile_lines) EQ 2 THEN BEGIN
        tile_samples_tmp= LONG(tile_samples)
        tile_lines_tmp= LONG(tile_lines)
      ENDIF ELSE BEGIN
        Message, 'Input keywords error. You must specify either ntiles or [ntiles_s, ntiles_l], or [tile_samples, tile_lines]'
      ENDELSE
    ENDELSE
  ENDELSE
  IF tile_samples LT 10 OR tile_lines LT 10 THEN Message, 'Error: Tile size can not be smaller than 10p.'
  
  ntiles_s= LONG(CEIL(samples/DOUBLE(tile_samples_tmp)))
  ntiles_l= LONG(CEIL((lines/DOUBLE(tile_lines_tmp))))
  ntiles=ntiles_s*ntiles_l
  
  startx= LINDGEN(ntiles_s)*tile_samples
  endx= startx+tile_samples-1
  endx[ntiles_s-1]=samples-1
  all_samples= endx-startx+1
  
  starty= LINDGEN(ntiles_l)*tile_lines
  endy= starty+tile_lines-1
  endy[ntiles_l-1]=lines-1
  all_lines= endy-starty+1
  
  index= LINDGEN(ntiles_s, ntiles_l)
  
  fstruct= CREATE_STRUCT($
    'name'           , inputfile, $                      ; The input file name
    'samples'        , samples, $                        ; Samples of input file
    'lines'          , lines,$                           ; Lines of input file
    'tile_samples'   , tile_samples_tmp, $               ; Samples of a tile
    'tile_lines'     , tile_lines_tmp, $                 ; Lines of a tile
    'all_samples'    , all_samples, $                    ; Samples of all the tiles.
    'all_lines'      , all_lines, $                      ; Lines of all the tiles
    'ntiles'         , ntiles, $                         ; Number of the tiles.
    'ntiles_s'       , ntiles_s, $                       ; Number of tiles in sample direction.
    'ntiles_l'       , ntiles_l, $                       ; Number of tiles in line direction.
    'startx'         , startx, $                         ; All the start samples of the tiles.
    'starty'         , starty, $                         ; All the start lines of the tiles.
    'endx'           , endx, $                           ; All the end samples of the tiles.
    'endy'           , endy, $                           ; All the end lines of the tiles.
    'index'          , index)                            ; All the indices of the tiles.
    
  RETURN, fstruct
END