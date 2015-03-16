;-
;- Functions that:
;-   Partition the large data according to the given information.
;- Parameters:
;-   inputfile      : Full path of the input file.
;-   samples        : Samples of the input file.
;-   lines          : Lines of the input file.
;-   format         : Format of the data element.
;-                    samples+lines+format are used to read data arrays.
;-   border_s       : Border samples
;-   border_l       : Border lines
;-
;-   nblocks        : Number of blocks
;-   nblocks_s      : Blocks in sample direction (x direction).
;-   nblocks_l      : Blocks in line direction (y dir.)
;-   block_samples  : Samples of each block
;-   block_lines    : Lines of each block
;------------------------------------------------------------------------------------------------------------------------------------
FUNCTION TLI_FILE_DIMENSIONS, inputfile, samples=samples, lines=lines, format=format
  ; Return the dimensions of the inputfile.
  IF NOT FILE_TEST(inputfile) THEN Message, 'TLI_PARTITION_DATA: File not found:'+inputfile
  IF KEYWORD_SET(samples)+KEYWORD_SET(lines) NE 1 THEN Message, 'Must specify either samples or lines.'
  IF NOT KEYWORD_SET(format) THEN Message, 'TLI_PARTITION_DATA: format must be specified.'
  format_c=STRUPCASE(format)
  Case format_c OF
    'BYTE': ele_bytes=1
    'INT': ele_bytes=2
    'LONG':  ele_bytes=4
    'FLOAT': ele_bytes=4
    'DOUBLE': ele_bytes=8
    'SCOMPLEX': ele_bytes=4
    'FCOMPLEX': ele_bytes=8
    ELSE: Message, 'TLI_READDATA: Format Error! This keyword is case sensitive.'
  ENDCASE
  
  finfo=FILE_INFO(inputfile)
  IF KEYWORD_SET(samples) THEN lines=finfo.size/samples/ele_bytes
  IF KEYWORD_SET(lines) THEN samples=finfo.size/lines/ele_bytes
  result=[samples, lines]
  RETURN, result
  
END
;------------------------------------------------------------------------------------------------------------------------------------
FUNCTION TLI_CREATE_ARRAY,samples=samples, lines=lines, format=format
  format_c=STRUPCASE(format)
  Case format_c OF
    'BYTE': BEGIN
      lines= finfo.size/samples
      result= BYTARR(samples, lines)
    END
    'INT': BEGIN
      lines= finfo.size/samples/2
      result= INTARR(samples, lines)
    END
    'LONG':  BEGIN
      lines= finfo.size/samples/4
      result= LONARR(samples, lines)
    END
    'FLOAT': BEGIN
      lines= finfo.size/samples/4
      result= FLTARR(samples, lines)
    END
    'DOUBLE': BEGIN
      lines= finfo.size/samples/8
      result= DBLARR(samples, lines)
    END
    'SCOMPLEX': BEGIN
      lines= finfo.size/samples/4
      result= INTARR(samples*2, lines)
    END
    'FCOMPLEX': BEGIN
      lines= finfo.size/samples/8
      result= COMPLEXARR(samples, lines)
    END
    ELSE: BEGIN
      Message, 'TLI_PARTITION_DATA: Format Error! This keyword is case sensitive.'
    END
  ENDCASE
END
;------------------------------------------------------------------------------------------------------------------------------------
FUNCTION TLI_PARTITION_DATA, inputfile, samples=samples, lines=lines, format=format, border_s=border_s,border_l=border_l, $
    nblocks_all=nblocks_all,nblocks_s=nblocks_s, nblocks_l=nblocks_l,block_samples=block_samples, block_lines=block_lines
  ; See also: tli_pa_block_data.pro
  ; Check the input params.
  IF NOT FILE_TEST(inputfile) THEN Message, 'TLI_block_DATA: Error! File not found: '+STRING(13b) $
    + inputfile
  IF KEYWORD_SET(samples)+KEYWORD_SET(lines) EQ 0 THEN Message, 'TLI_block_DATA: Please specify either samples or lines.'
  IF NOT KEYWORD_SET(format) THEN Message, 'TLI_block_DATA: Please specify the data format for input file.'
  sz=TLI_FILE_DIMENSIONS(inputfile, samples=samples, lines=lines, format=format)
  samples=sz[0]
  lines=sz[1]
  
  IF KEYWORD_SET(nblocks) THEN BEGIN
    Print, 'Keyword nblocks is set to ', STRCOMPRESS(nblocks), 'Other keywords are neglected.'
    IF SQRT(DOUBLE(nblocks)) NE LONG(SQRT(nblocks)) THEN BEGIN
      Message, 'Error: nblocks ~= n^2!'
    ENDIF
    nblocks_s_tmp= LONG(SQRT(nblocks))
    nblocks_l_tmp= nblocks_s_tmp
    block_samples_tmp= LONG(samples/nblocks_s_tmp)
    block_lines_tmp= LONG(lines/nblocks_l_tmp)
  ENDIF ELSE BEGIN
  
    IF KEYWORD_SET(nblocks_s)+KEYWORD_SET(nblocks_l) EQ 2 THEN BEGIN
      Print, 'Keyword nblocks_s and nblocks_l are set.'
      block_samples_tmp= LONG(samples/nblocks_s)
      block_lines_tmp= LONG(lines/nblocks_l)
    ENDIF ELSE BEGIN
      IF KEYWORD_SET(block_samples)+ KEYWORD_SET(block_lines) EQ 2 THEN BEGIN
        block_samples_tmp= LONG(block_samples)
        block_lines_tmp= LONG(block_lines)
      ENDIF ELSE BEGIN
        Message, 'Input keywords error. You must specify either nblocks or [nblocks_s, nblocks_l], or [block_samples, block_lines]'
      ENDELSE
    ENDELSE
  ENDELSE
  IF block_samples LT 10 OR block_lines LT 10 THEN Message, 'Error: block size can not be smaller than 10p.'
  
  nblocks_s= LONG(CEIL(samples/DOUBLE(block_samples_tmp)))
  nblocks_l= LONG(CEIL(lines/DOUBLE(block_lines_tmp)))
  nblocks_all=nblocks_s*nblocks_l
  
  startx= LINDGEN(nblocks_s)*block_samples
  endx= startx+block_samples-1
  endx[nblocks_s-1]=samples-1
  all_samples= endx-startx+1
  
  starty= LINDGEN(nblocks_l)*block_lines
  endy= starty+block_lines-1
  endy[nblocks_l-1]=lines-1
  all_lines= endy-starty+1
  
  ; All the coordinates shoule be changed by considerring the borders. (border_s, border_l)
  startx=(startx-border_s)>0
  endx=(endx+border_s)<samples
  starty=(starty-border_l)>0
  endy=(endy+border_s)<lines
  
  ; Provide some useful information
  index= LINDGEN(nblocks_s, nblocks_l)  
  is_edge= BYTARR(nblocks_s, nblocks_l)
  edge_info=REPLICATE('0000', nblocks_s, nblocks_l)  ; Left, upper, right, down. 
  
  ; The first line is an edge.
  is_edge[*, 0]=1
  edge_info[*, 0]=TLI_STRREPLACE_ALL(edge_info[*,0], '1',pos=1)  ; Upper middle
  ; The last line is an edge
  is_edge[*, nblocks_l-1]=1
  edge_info[*, nblocks_l-1]=TLI_STRREPLACE_ALL(edge_info[*, nblocks_l-1], '1',pos=3)  ; Down middle
  ; The first sample is an edge
  is_edge[0, *]=1
  edge_info[0, *]=TLI_STRREPLACE_ALL(edge_info[0, *], '1',pos=0)  ; Center lefe
  ; The last sample is an edge
  is_edge[nblocks_s-1, *]=1
  edge_info[nblocks_s-1, *]=TLI_STRREPLACE_ALL(edge_info[nblocks_s-1, *], '1',pos=2)  ; Center right

  
  fstruct= CREATE_STRUCT($
    'filename'           , inputfile, $                      ; The input file name
    'samples'        , samples, $                        ; Samples of input file
    'format'         , format, $                         ; Format of the input file.
    'lines'          , lines,$                           ; Lines of input file
    'block_samples'   , block_samples_tmp, $             ; Samples of a block
    'block_lines'     , block_lines_tmp, $               ; Lines of a block
    'all_samples'    , all_samples, $                    ; Samples of all the blocks.
    'all_lines'      , all_lines, $                      ; Lines of all the blocks
    'nblocks_all'    , nblocks_all, $                       ; Number of the blocks.
    'nblocks_s'       , nblocks_s, $                     ; Number of blocks in sample direction.
    'nblocks_l'       , nblocks_l, $                     ; Number of blocks in line direction.
    'startx'         , startx, $                         ; All the start samples of the blocks.
    'starty'         , starty, $                         ; All the start lines of the blocks.
    'endx'           , endx, $                           ; All the end samples of the blocks.
    'endy'           , endy, $                           ; All the end lines of the blocks.
    'index'          , index,$                           ; All the indices of the blocks.
    'is_edge'        , is_edge, $                        ; If the block is located at the edge part.
    'edge_info'      , edge_info $                      ; Upper, Center, Down; Left, Middle, Right.  
    )
  RETURN, fstruct
END