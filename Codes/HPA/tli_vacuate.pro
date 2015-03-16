@tli_ls_dvddh
PRO TLI_VACUATE, inputfile, type=type, outputfile=outputfile, finalnpt=finalnpt

  IF NOT KEYWORD_SET(type) THEN Message, 'Sorry. You have to set the param: type.'
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=TLI_FNAME(inputfile,/nosuffix)+'_vacuate'
  
  type=STRLOWCASE(type)
  
  IF type NE 'txt' THEN BEGIN
    data=TLI_READMYFILES(inputfile, type=type)
  ENDIF ELSE BEGIN
    data=TLI_READTXT(inputfile, /easy)
    txt=1
  ENDELSE
  
  IF NOT KEYWORD_SET(finalnpt) THEN BEGIN
    Print, 'No vacuation done for the input file. Return the original data.'
    TLI_WRITE, outputfile, data, txt=txt
    RETURN
  ENDIF
  
  sz=SIZE(data,/DIMENSIONS)
  npt=sz[1]
  
  IF finalnpt GE npt THEN BEGIN
    Print, 'Warning: The final number of point should not be greater than npt.'
    TLI_WRITE, outputfile, data, txt=txt
    RETURN
  END
  
  ; Get the vacuated index.
  ind=RANDOMU(seed,finalnpt)
  min_ind=MIN(ind, max=max_ind);////////////////////////
  ind=(ind-min_ind)/(max_ind-min_ind);/////////////////////////////
  ind=LONG(ind*(npt-1))
  ind=ind[SORT(ind)]
  ind=ind[UNIQ(ind)]
  finalnpt_real=N_ELEMENTS(ind)
  ; Judge if the final number of point is consistent with that of the final number of points or not.
  IF finalnpt_real NE finalnpt THEN BEGIN
    ; Calculate the complement of the vacuated index.
    comp_ind=TLI_IND_COMPLEMENT(ind, max_ind=npt-1)
    npt_lack=finalnpt-finalnpt_real
    ind_lack=comp_ind[DINDGEN(npt_lack)]
    ind=[ind, ind_lack]
    ind=ind[SORT(ind)]
    ind=ind[UNIQ(ind)]
    finalnpt_real=N_ELEMENTS(ind)
    IF finalnpt_real NE finalnpt THEN Message, 'Error: This should never happen.'
  ENDIF
  
  ; Return the result
  result=data[*, ind]
  TLI_WRITE, outputfile, result, txt=txt
  RETURN
  
END