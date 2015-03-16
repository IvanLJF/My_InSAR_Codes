;- 
;- Purpose:
;-     Extract points' look angle file from a simulated look angle file.
;-
PRO TLI_PLOOKANGLE, sarlistfile, itabfile, plistfile, samples, plafile

  COMPILE_OPT idl2
  
  ; Read sarlistfile
  nslc= file_lines(sarlistfile)
  sarlist= STRARR(nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  ; Read itabfile
  nintf= FILE_LINES(itabfile)
  itab= LONARR(4, nintf)
  OPENR, lun, itabfile,/GET_LUN
  READF, lun, itab
  FREE_LUN, lun
  
  ; Locate master file
  m_ind= itab[0, *]
  m_ind_uniq= UNIQ(m_ind)
  IF N_ELEMENTS(m_ind_uniq) NE 1 THEN BEGIN
    Print, 'Multi master images is not supported now.'
  ENDIF
  m_ind= m_ind[m_ind_uniq]-1
  mslcfile= sarlist[m_ind]
  
  mslcdir= FILE_BASENAME(mslcfile)
  m_date= STRSPLIT(mslcfile, '-',/EXTRACT)
  sz= N_ELEMENTS(m_date)
  m_prefix= STRJOIN(m_date[0:sz-2], '-')
  m_date= m_date[sz-1]
  m_date= STRMID(m_date, 0,8)
  m_lafile= m_prefix+'-'+m_date+'_Sim_Angl'
  
  IF ~FILE_TEST(m_lafile) THEN BEGIN
    Message, 'Look angle file not found:'+m_lafile
  ENDIF
  
  m_la= TLI_READDATA(m_lafile, samples=samples, format='FLOAT')
  plist= TLI_READDATA(plistfile, samples=1, format='FCOMPLEX')
  
  plist_x= REAL_PART(plist)
  plist_y= IMAGINARY(plist)
  
  pla= DOUBLE(m_la[plist_x, plist_y])
  
  OPENW, lun, plafile,/GET_LUN
  WRITEU, lun, pla
  FREE_LUN, lun

END