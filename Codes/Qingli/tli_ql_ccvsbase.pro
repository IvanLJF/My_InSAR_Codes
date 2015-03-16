PRO TLI_QL_CCVSBASE

  workpath='/mnt/backup/experiment/Qingli_all/test1'
  resultpath=workpath
  workpath=workpath+PATH_SEP()
  ccpath='/mnt/backup/experiment/Qingli_all/test1/cc_ras'
  ccpath=ccpath+PATH_SEP()
  sarlistfile=workpath+'SLC_tab'
  itabfile= workpath+'itab'
  plistfile= workpath+'coors.dat'
  difsuffix='.cc'
  pcohfile=workpath+'p_coh'
  basefile= workpath+'base.list'
  cctxt= workpath+'p_cohvsbase.txt'
  logfile= workpath+'log.txt'
  OPENW, loglun, logfile,/GET_LUN
  PrintF, loglun, 'File written for Qingli'
  PrintF, loglun, '    -Calculate [Bperp T Coh.] for each point.'
  
  nintf= FILE_LINES(itabfile)
  intpair= TLI_GAMMA_INT(sarlistfile,itabfile,/date)
  finfo= TLI_LOAD_MPAR(sarlistfile,itabfile)
  finfo= finfo[0]
  
  plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
  npt= TLI_PNUMBER(plistfile)
  PrintF, loglun, ''
  PrintF, loglun, 'Number of points:'+STRCOMPRESS(npt)
;  OPENW,lun, pcohfile, /GET_LUN 
;  FOR  i=0, nintf-1 DO BEGIN
;    Print, i,'/', nintf-1
;    ccfile= ccpath+STRING(intpair[0, i])+'-'+STRING(intpair[1, i])+'.cc'
;    ccfile= STRCOMPRESS(ccfile,/REMOVE_ALL)
;    cc= TLI_READDATA(ccfile,samples= finfo.range_samples, format='FLOAT',/SWAP_ENDIAN)
;    result= cc[REAL_PART(plist), IMAGINARY(plist)]
;    WRITEU, lun, result
;  ENDFOR
;  FREE_LUN, lun
  pcoh= TLI_READDATA(pcohfile, samples=npt, format='FLOAT')
  PrintF, loglun, ''
  PrintF, loglun, 'Mean coherence of each point in time series(window size: 5*5):'
  temp= [[INDGEN(npt)+1], [TOTAL(pcoh, 2)/nintf]]
  temp= TRANSPOSE(temp)
  PrintF, loglun, temp
  ; Bperp
  ; Read base.list
  nlines= FILE_LINES(basefile)
  base=DBLARR(5)
  OPENR, lun, basefile,/GET_LUN
  For i=0, nlines-1 DO BEGIN
    temp=''
    READF, lun, temp
    temp= STRSPLIT(temp, ' ',/EXTRACT)
    base=[[base], [DOUBLE(temp)]]
  ENDFOR
  FREE_LUN, lun
  base= base[*, 1:*]
  base[3:4, *]= ABS(base[3:4, *])
  maxbperp= MAX((base[3,*]),MIN=minbperp)
  PrintF, loglun, ''
  PrintF, loglun, 'Statistics of ABS(Bperp):'
  PrintF, loglun, 'min_bperp:'+STRING(minbperp)
  PrintF, loglun, 'max_berp:'+STRING(maxbperp)
  
  maxbt= MAX((base[4, *]), MIN=minbt)
  PrintF, loglun, ''
  PrintF, loglun, 'Statistics of ABS(BT):'
  PrintF, loglun, 'min_bt:'+STRING(minbt)
  PrintF, loglun, 'max_bt:'+STRING(maxbt)
  
  txtdata= DOUBLE([base, pcoh])
  
  annos= ['Index','master','slave','ABS(Bperp)','ABS(BT)',STRCOMPRESS(INDGEN(npt)+1,/REMOVE_ALL)]
  temp= REPLICATE('A5', npt)
  temp= STRJOIN(temp, ',')
  annosformat='(A6, A11, A11, A13,"'+ STRING(9B)+'", A13,'+temp+ ')'
  temp= REPLICATE('A5', npt)
  sep=',"'+STRING(9B)+'",'
  temp= STRJOIN(temp,sep)
  txtformat='(I6, I11, I11, A11,"'+STRING(9B)+'",A5,"'+STRING(9B)+'",'+temp+')'
  
  OPENW, lun, cctxt,/GET_LUN
  PrintF, lun, annos,FORMAT=annosformat
  PRINTF, lun, STRCOMPRESS(txtdata,/REMOVE_ALL), FORMAT=txtformat
  FREE_LUN, lun
  
  Print, 'Analyzing the correlation between b_combine and coh'
  pindex=46
  bperp=base[3,*] ; Perpendicular baseline
  bt= base[4,*]   ; Temporal baseline
  ; Assume that criticals of bperp is 10% larger that max_bperp, bt idem.
  bperp_c=MAX(bperp)*1.1
  bt_c=MAX(bt)*1.1
  b_combine= (1-bperp/bperp_c)*(1-bt/bt_c)
  sort_b= SORT(b_combine)
  b_new= b_combine[sort_b]
  ;  pcoh - Coherence on each point.
;  pcoh_ave= TOTAL(pcoh, 2)/nintf
  pcoh_index= pcoh[pindex, *]
  pcoh_new= pcoh_index[sort_b]
  
  y= pcoh_new/b_combine
  x= bt[sort_b]
  
  
  
  iPLOT, x, y,linestyle=6, sim_size=1.0,sym_index=5
  
  
  FREE_LUN, loglun
END