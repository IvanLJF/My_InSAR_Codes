;- Return master SLC's info.
;
; Written by
;   T.LI @ SWJTU, 20140302
; 
; History
;   Add keyword 'load_all' to activate the mask column in itab. T.LI @ swjtu, 20140302.
; 
FUNCTION TLI_LOAD_MPAR, sarlistfile, itabfile, load_all=load_all

  COMPILE_OPT idl2
  
  itab_stru=TLI_READMYFILES(itabfile, type='itab')
  nintf= itab_stru.nintf
  nslc= FILE_LINES(sarlistfile)
  itab=itab_stru.itab_all  
  itab[0:1, *]=itab[0:1, *]-1
  
  slc= STRARR(nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, slc
  FREE_LUN, lun
  
  ; Judge if slc is column-single
  temp= STRSPLIT(slc[0],' ',/EXTRACT)
  IF N_ELEMENTS(temp) GT 2 THEN Message, 'ERROR: Do not add a blank in file path.'
  IF N_ELEMENTS(temp) EQ 2 THEN BEGIN
    FOR i=0, nslc-1 DO BEGIN
      temp= slc[i]
      temp= STRSPLIT(temp, ' ',/EXTRACT)
      slc[i]= temp[0]
    ENDFOR
  ENDIF
  
  ; Get the master indices
  mind=itab_stru.m_valid
  mind=mind[UNIQ(mind[SORT(mind)])]  ; Uniq master indices
  
  IF NOT KEYWORD_SET(load_all) THEN BEGIN
    mpar= slc[mind[0]]+'.par'
    minfo= TLI_LOAD_SLC_PAR(mpar)
  ENDIF ELSE BEGIN
    nmpar= N_ELEMENTS(mind)
    FOR i=0, nmpar-1 DO BEGIN
      mpar= slc[mind[i]]+'.par'
      IF i EQ 0 THEN BEGIN
        minfo=TLI_LOAD_SLC_PAR(mpar)
      ENDIF ELSE BEGIN
        temp= TLI_LOAD_SLC_PAR(mpar)
        minfo= [minfo,temp]
      ENDELSE
    ENDFOR
  ENDELSE
  
  RETURN, minfo
END