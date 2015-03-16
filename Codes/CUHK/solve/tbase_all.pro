@tli_linear_solve_cuhk
Function TBASE, masterdate, slavedate
  ; Calculate temporal baseline between masterdate and slavedate
  ; tbase= slavedate-masterdate
  result= DATE2JULDAT(slavedate)-DATE2JULDAT(masterdate)
  RETURN, result
END

Function TBASE_ALL, sarlistfile, itabfile, ignore_mask=ignore_mask

  ; Calculate temporal baseline using the input files.
  ; Unit: year
  ON_ERROR, 2
  nslc= FILE_LINES(sarlistfile)
  sarlist=STRARR(1, nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  itab_stru=TLI_READMYFILES(itabfile, type='itab')
  itab=itab_stru.itab_valid
  IF KEYWORD_SET(ignore_mask) THEN itab=itab_stru.itab_all
  
  slave_index=itab[1, *]-1
  master_index=itab[0, *]-1
  
  date=0
  FOR i=0, nslc-1 DO BEGIN
    fname= FILE_BASENAME(sarlist[i])
    temp= STRSPLIT(fname, '.',/EXTRACT)
    fname_no_suffix= temp[0]
    temp= STRMID(fname_no_suffix, 8,/REVERSE_OFFSET)
    
;    temp= STRSPLIT(sarlist[i], '-',/EXTRACT)
;    sz= N_ELEMENTS(temp)
;    temp= temp[sz-1]
;    temp= STRMID(temp,0, 8)
    
    temp= LONG(temp)
    year= FLOOR(temp/10000D)
    month= FLOOR((temp- year*10000) / 100)
    day= temp-year*10000-month*100
    temp= JULDAY(month, day, year)
    date= [date, temp]
  ENDFOR
  date= date[1:*]
  Tbase= (date[slave_index]-date[master_index])/365D;时间基线是以年为单位的
  
  RETURN, Tbase

END