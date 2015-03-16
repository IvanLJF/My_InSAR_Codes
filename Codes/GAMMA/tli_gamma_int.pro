;-
;- Script that:
;-   Return all gamma interfermetric pairs.
;-
; Written by:
;   T.LI @ SWJTU
;
; History:
;   Add Keyword 'ignore_mask' to use itab mask column. T.LI @ SWJTU, 20140302.
;
FUNCTION TLI_GAMMA_INT, slctabfile, itabfile, onlymaster=onlymaster, onlyslave=onlyslave, $
          pair=pair, date= date,uniq=uniq, ignore_mask=ignore_mask

  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 2 THEN Message, 'TLI_GAMMA_INT: Usage error!'
  IF KEYWORD_SET(onlymaster)+KEYWORD_SET(onlyslave)+KEYWORD_SET(pair) NE 1 THEN pair=1
  
  nslcs= FILE_LINES(slctabfile)
  Print, 'Number of SLCs: ',STRCOMPRESS(nslcs)
  itab_stru=TLI_READMYFILES(itabfile, type='itab')
  nintf= itab_stru.nintf
  Print, 'Number of interferograms: ', STRCOMPRESS(nintf)
  
  slcs= STRARR(1,nslcs)
  OPENR,lun, slctabfile,/GET_LUN
  READF, lun, slcs
  FREE_LUN, lun
  
  FOR i=0, nslcs-1 DO BEGIN
    temp= slcs[i]
    temp= STRSPLIT(temp, ' ',/EXTRACT)
    slcs[i]= temp[0]
  ENDFOR
  
  itab= itab_stru.itab_valid
  
  nintf_valid=itab_stru.nintf_valid
  IF nintf_valid EQ 0 THEN Message, 'Error! You must be kidding me. Itab possesses no available int. pairs.'
  IF KEYWORD_SET(ignore_mask) THEN itab=itab_stru.itab_all
  
  Print, 'Number of available interferograms: ', nintf_valid
  
  m_ind= itab_stru.m_valid-1
  s_ind= itab_stru.s_valid-1
  m_ind_uniq= m_ind[UNIQ(m_ind)]
;  IF N_ELEMENTS(m_ind_uniq) EQ 1 THEN BEGIN
;    Print, 'Index of single master (Start from 1):', STRCOMPRESS(m_ind_uniq)
;  ENDIF ELSE BEGIN
;    Print, 'Indices of multiple master (Start from 1):', STRCOMPRESS(m_ind_uniq)
;  ENDELSE
  
  mslc= slcs[0, m_ind]
  sslc= slcs[0, s_ind]
  intf_pair= [mslc, sslc]
  IF KEYWORD_SET(date) THEN BEGIN
    mdate=0L
    sdate=0L
    FOR i=0, nintf_valid-1 DO BEGIN
      temp= TLI_GAMMA_FNAME(mslc[i], /date)
      mdate= [mdate, temp]
      temp= TLI_GAMMA_FNAME(sslc[i],/date)
      sdate= [sdate, temp]
    ENDFOR
    mdate= mdate[1:*]
    sdate= sdate[1:*]
    
    IF KEYWORD_SET(onlymaster) THEN BEGIN
      IF KEYWORD_SET(uniq) THEN RETURN, mdate[UNIQ(mdate)]
      RETURN, mdate
    ENDIF
    IF KEYWORD_SET(onlyslave) THEN BEGIN
      IF KEYWORD_SET(uniq) THEN RETURN, sdate[UNIQ(sdate)]
      RETURN, sdate
    ENDIF
    IF KEYWORD_SET(pair) THEN BEGIN
      intf_pair= [TRANSPOSE(mdate), TRANSPOSE(sdate)]
      RETURN, intf_pair
    ENDIF
  ENDIF ELSE BEGIN
    IF KEYWORD_SET(onlymaster) THEN BEGIN
      IF KEYWORD_SET(uniq) THEN RETURN, mslc[UNIQ(mslc)]
      RETURN, mslc
    ENDIF
    IF KEYWORD_SET(onlyslave) THEN BEGIN
      IF KEYWORD_SET(uniq) THEN RETURN, sslc[UNIQ(sslc)]
      RETURN, sslc
    ENDIF
    IF KEYWORD_SET(pair) THEN RETURN, intf_pair
  ENDELSE
  
END