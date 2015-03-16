PRO TLI_INSERT_MASTER,plistfile, itabfile, inputfile, outputfile
  IF ~KEYWORD_SET(outputfile) THEN BEGIN
    outputfile= inputfile+'_inserted'
  ENDIF
  npt= TLI_PNUMBER(plistfile)
  nintf= FILE_LINES(itabfile)
  
  inputdata= TLI_READDATA(inputfile, samples= npt, format='DOUBLE')
  
  sz= SIZE(inputdata, /DIMENSIONS)
  IF nintf+3 NE sz[1] THEN Message, 'TLI_INSERT_MASTER: input file type error.'
  
  itab= LONARR(4, nintf)
  OPENR, lun, itabfile,/GET_LUN
  READF, lun, itab
  FREE_LUN, lun
  
  master_ind= UNIQ(itab[0, *])
  master_ind= itab[0,master_ind]
  IF N_ELEMENTS(master_ind) NE 1 THEN BEGIN
    Message, 'Multiple master SLCs not supported.'
  ENDIF
  
  s_ind= itab[1, *]
  ;check s_ind
  sort_ind= SORT(s_ind)
  IF TOTAL(sort_ind - LINDGEN(nintf)) NE 0 THEN Message, 'Wrong input file: itab!!'
  d_ind= s_ind-master_ind ; Indices differences
  temp= MIN(ABS(d_ind), insert_ind)
  
  IF temp EQ 0 THEN BEGIN
    Print, 'Information of the master image is already contained in the original file.'
    FILE_COPY, inputfile, outputfile,/OVERWRITE
    RETURN
  ENDIF
  
  IF insert_ind NE nintf-1 THEN BEGIN
    val= [[inputdata[*,0:(3+insert_ind-1)]], [DBLARR(npt)], [inputdata[*, (3+insert_ind):(nintf-1+3)]]]
  ENDIF ELSE BEGIN
    val=[[inputdata], [DBLARR(npt)]]
  ENDELSE
  
  OPENW, lun, outputfile,/GET_LUN
  WRITEU, lun, val
  FREE_LUN, lun
  
  
  
  
  
END