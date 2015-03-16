PRO TLI_SORTOUT_TXT, vdhfile, plistfile, itabfile, sarlistfile, final_resultfile,$
    time_seriestxtfile=time_seriestxtfile, dhtxtfile= dhtxtfile, vtxtfile= vtxtfile,$
    refind, ref_v, ref_dh
    
  ;  workpath='/mnt/software/myfiles/Software/experiment/TerraSARTestArea'
  ;  slcpath=workpath+'/Area_Management/Area_Processing/Area1'
  ;  diffpath=workpath+'/Basic_InSAR/Interferogram_Generation/Area1'
  ;  resultpath=workpath+'/PSI'
  ;
  ;  vdhfile= resultpath+'/vdh'
  ;  plistfile= resultpath+'/plist'
  ;  itabfile= resultpath+'/itab'
  ;  sarlistfile= resultpath+'/sarlist'
  ;  final_resultfile= resultpath+'/final_result'
  ;
  ;  time_seriestxtfile= resultpath+'/Deformation_Time_Series_Per_SLC_Acquisition_Date.txt'
  ;  dhtxtfile= resultpath+'/HeightError.txt'
  ;  vtxtfile= resultpath+'/Deformation_Average_Annual_Rate.txt'
  ;  refind=183
  ;  ref_v= 0
  ;  ref_dh=0
    
    
    
  npt= TLI_PNUMBER(plistfile)
  Print, 'PSC number:', STRCOMPRESS(npt)
  vdh= TLI_READDATA(vdhfile, samples= 5, format='DOUBLE')
  pt_final= vdh[0:2, *]
  sz= SIZE(vdh, /DIMENSIONS)
  npt_final= sz[1]
  Print, 'PS number:', STRCOMPRESS(npt_final)
  
  OPENW, lun_ts, time_seriestxtfile,/GET_LUN
  
  temp=['Number', 'of', 'Points:', STRCOMPRESS(LONG(npt_final))]
  temp= STRJOIN(temp, STRING(9B))
  PrintF, lun_ts, temp
  
  nintf= FILE_LINES(itabfile)
  temp=STRJOIN(['Number', 'of', 'Data:'],STRING(9B))
  temp= temp+STRCOMPRESS(nintf+1)
  PrintF, lun_ts, temp
  PrintF, lun_ts, 'Deformation Direction:  Upward From Ground To SAR'
  
  nslc= FILE_LINES(sarlistfile)
  sarlist= STRARR(nslc)
  OPENR, lun_sarlist, sarlistfile,/GET_LUN
  READF, lun_sarlist, sarlist
  FREE_LUN, lun_sarlist
  date=0L
  date_ann=STRARR(nslc)
  For i=0, nslc-1 DO BEGIN
  
  
    temp= sarlist[i]
    temp= FILE_BASENAME(temp)
    temp= STRSPLIT(temp, '.',/EXTRACT)
    temp= temp[0]
    temp= STRMID(temp,8, /REVERSE_OFFSET)
    
    y= STRMID(temp, 0,4)
    m= STRMID(temp, 4,2)
    d= STRMID(temp, 6,2)
    temp= JULDAY(LONG(m),LONG(d),LONG(y))
    date=[date, temp]
    temp= STRJOIN([y,m,d],'_')
    date_ann[i]= temp
  ENDFOR
  date= date[1:*]
  
  itab= LONARR(4, nintf)
  OPENR, lun_itab, itabfile,/GET_LUN
  READF, lun_itab, itab
  FREE_LUN, lun_itab
  master_ind= UNIQ(itab[0, *])
  IF N_ELEMENTS(master_ind) NE 1 THEN Message, 'Multi master SLCs not supported.'
  master_ind= itab[0,master_ind]
  slave_ind= itab[1, *]
  temp= WHERE(slave_ind EQ master_ind)
  IF temp NE 0 THEN BEGIN
    slave_ind= [[slave_ind], [master_ind]]
    sort_ind= SORT(slave_ind)
    slave_ind= slave_ind[0, sort_ind]
    m_m_include=0
  ENDIF ELSE BEGIN
    m_m_included=1 ; Master - master is included in itab.
  ENDELSE
  Bt= TRANSPOSE(date[slave_ind]- date[master_ind])
  temp= 'Day   Index'+STRING(9B)+STRJOIN(STRCOMPRESS(LONG(Bt)), STRING(9B))
  PrintF, lun_ts, temp
  temp='Index'+STRING(9B)+'Line'+STRING(9B)+'Sample'+STRING(9B)
  temp= temp+STRJOIN(date_ann, STRING(9B))
  PrintF, lun_ts, temp
  
  ; Read time_series values.
  temp_finalfile= final_resultfile+'.tmp'
  TLI_INSERT_MASTER, plistfile, itabfile, final_resultfile, temp_finalfile
  ts= TLI_READDATA(temp_finalfile, samples=npt, format='DOUBLE')
  ts_ind= WHERE(ts[*, 2] EQ 1)
  ts= ts[ts_ind, *]
  ts_val= TRANSPOSE(ts[*, 3:*])
  psval= [TRANSPOSE(LINDGEN(npt_final)+1), TRANSPOSE(ts[*,1]), TRANSPOSE(ts[*, 0]), ts_val ]
  fstrarr1= REPLICATE('I0', 3)
  fstrarr2= REPLICATE('D0', (SIZE(ts_val,/DIMENSIONS))[0])
  fstrarr=[fstrarr1, fstrarr2]
  sep=',"'+STRING(9B)+'",'
  fstring= '('+STRJOIN(fstrarr,sep)+')'
  
  PrintF, lun_ts, psval, format= fstring
  FREE_LUN, lun_ts
  
  ; Write hight error file.
  plist= TLI_READDATA(plistfile, samples=1, format='FCOMPLEX')
  refcoor= plist[refind]
  refind_final= WHERE(ts_ind EQ refind)
  OPENW, lun_dh, dhtxtfile,/GET_LUN
  PrintF, lun_dh, 'Data Type:   DEM Error  '
  PrintF, lun_dh, 'Number  of  Points: '+STRCOMPRESS(npt_final)
  PrintF, lun_dh, 'Error Direction:  Upward'
  ;  PrintF, lun_dh, 'Reference Point Index:'+STRCOMPRESS(refind_final+1) +'. Coordinates:'+STRCOMPRESS(refcoor)$
  ;                 +'. Height Error:'+STRCOMPRESS(ref_dh)
  PrintF, lun_dh, 'Index  Line  Sample  Data  '
  
  dh= vdh[4, *]
  dhval= [TRANSPOSE(LINDGEN(npt_final)+1), TRANSPOSE(ts[*,1]), TRANSPOSE(ts[*, 0]), dh]
  fstring= '('+STRJOIN(fstrarr1,sep)+sep+'D0'+')'
  PrintF, lun_dh, dhval, format= fstring
  FREE_LUN, lun_dh
  
  ; Write deformation velocity file.
  OPENW, lun_v, vtxtfile,/GET_LUN
  PrintF, lun_v, 'Number  of  Points: '+STRCOMPRESS(npt_final)
  PrintF, lun_v, 'Number  of  Data: 1'
  PrintF, lun_v, 'Deformation Direction:  Upward From Ground To SAR'
  ;  PrintF, lun_v, 'Reference Point Index:'+STRCOMPRESS(refind_final+1) +'. Coordinates:'+STRCOMPRESS(refcoor)$
  ;                 +'. Deformation Velocity:'+STRCOMPRESS(ref_v)
  PrintF, lun_v, 'Index  Line  Sample Rate (mm/y)'
  
  v= vdh[3, *]
  vval= [TRANSPOSE(LINDGEN(npt_final)+1), TRANSPOSE(ts[*,1]), TRANSPOSE(ts[*, 0]), v]
  fstring= '('+STRJOIN(fstrarr1,sep)+sep+'D0'+')'
  PrintF, lun_v, vval, format= fstring
  FREE_LUN, lun_v
  
  FILE_DELETE, temp_finalfile
END