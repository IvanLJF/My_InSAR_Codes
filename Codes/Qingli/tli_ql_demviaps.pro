PRO TLI_QL_DEMVIAPS
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  qlpath= workpath+PATH_SEP()+'Qingli'
  reporttxt= qlpath+PATH_SEP()+'Report.txt'
  
  ; Files to be used.
  sarlistfile= qlpath+PATH_SEP()+'sarlist_Linux'
  plistfile= qlpath+PATH_SEP()+'pt'
  pslcfile= qlpath+PATH_SEP()+'pslc'
  itabfile= qlpath+PATH_SEP()+'itab'
  pbasefile= qlpath+PATH_SEP()+'pbase'
  paramfile= qlpath+PATH_SEP()+'DataSet.txt'
  
  ; sigma_delta_h
  nslcs= FILE_LINES(sarlistfile)
  Print, 'Number of images:', STRCOMPRESS(nslcs)
  sarlist= STRARR(nslcs)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  nintf= FILE_LINES(itabfile)
  itab= LONARR(4, nintf)
  OPENR, lun, itabfile,/GET_LUN
  READF, lun, itab
  FREE_LUN, lun
  master_index= itab[0,0]-1
  master_fname= sarlist[master_index]
  Print, 'Master image is:', FILE_BASENAME(master_fname)
  
  master_par= master_fname+'.par'
  master_struct= TLI_LOAD_SLC_PAR(master_par)
  ia= master_struct.incidence_angle
  Print, 'Incidence angle of master image:', STRCOMPRESS(ia)
  
  pbase= TLI_READDATA(pbasefile,samples=13, format= 'DOUBLE',/SWAP_ENDIAN)
  IF TOTAL(pbase[6:8, *]) EQ 0 THEN BEGIN
    Print, '* Warning: No precision baseline available. *'
    Bperp= pbase[1, *]
  ENDIF ELSE BEGIN
    Bperp= pbase[7, *]
  ENDELSE
  Print, 'Baselines:', STRCOMPRESS(TRANSPOSE(Bperp))
  Print, 'Baseline dispersion:', STRCOMPRESS(dBn)
  
;  TLI_TBASELINE,
  
  
  

END