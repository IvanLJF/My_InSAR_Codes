PRO TLI_T_S_BASELINE

; Calculate the temporal and spatial baselines.

; Input files
  ;
  workpath='K:\Software\ForExperiment\TSX_PS_Tianjin'
  workpath=workpath+PATH_SEP()
  hpapath=workpath+'HPA'+PATH_SEP()
  pbasefile= hpapath+'pbase'
  itabfile= workpath+'itab'
  sarlistfile= hpapath+'sarlist_Win'
  plistfile= workpath+'pt'
  
  Tbase= TBASE_ALL(sarlistfile, itabfile)
  Tbase=ROUND(Tbase*365)
  
  files= FILE_SEARCH(workpath+'*.rslc')
  
  finfo= TLI_LOAD_MPAR(sarlistfile, itabfile)
  
  npt= TLI_PNUMBER(plistfile)
  
  pbase= TLI_READDATA(pbasefile, samples=npt, format='DOUBLE')
  bperp= ROUND(pbase[0, *])
  
  int= TLI_GAMMA_INT(sarlistfile, itabfile,/ONLYSLAVE,/DATE)
  ind= SORT(LONG(int))
  int= TRANSPOSE(int[ind])
  Tbase= Tbase[*, ind]
  bperp= bperp[*, ind]
  
  nintf= FILE_LINES(itabfile)
  result=[INDGEN(1,nintf)+1,int, Tbase, bperp]
  result= TRANSPOSE(result)
  
  basefile= hpapath+'base.xls'
  status= WRITE_SYLK(basefile, result)
;  OPENW, lun, basefile,/GET_LUN
;  PrintF, lun, 'Index Temporal_baseline Spatial_baseline'
;  PrintF, lun, result
;  FREE_LUN, lun

END