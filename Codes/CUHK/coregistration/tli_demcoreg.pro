FUNCTION TLI_DEMCOREG, master, slave, mns, mnl, sns, snl, degree=degree, DEMCoregFile= DEMCoregFile
  
  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 6 THEN Message, 'TLI_DEMCOREG: Usage Error!'
  
  IF ~N_Elements(degree) THEN degree=1

  IF ~KEYWORD_SET(DemCoregFile) THEN $
    DEMCoregFile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.demoff'
    
  ; Coarse Coreg
  s_offset= 0
  l_offset= 0
  winsearch_r= 32
  winsearch_azi= 32
  winsub_r= 1024;大于300
  winsub_azi= 1024;大于600
  c_outfile= DEMCoregFile
  master_ss=mns
  master_ls=mnl
  slave_ss=sns
  slave_ls=snl
  result= TLI_COARSE_COREG_CORR(master, slave, master_ss, master_ls, slave_ss, slave_ls, $
                            s_offset, l_offset, c_outfile= c_outfile, $
                            winsearch_r=winsearch_r,winsearch_azi=winsearch_azi, $
                            winsub_r=winsub_r,winsub_azi=winsub_azi,/master_swap_endian)
  PRINT, '***********************************************'
  PRINT, '***          Coarse Coreg Finished!         ***'
  PRINT, '***********************************************'
  
  ; Fine coreg.
  coarse_result= DEMCoregFile
  winsearch_r= 3
  winsearch_azi= 10
  winsub_r= 512;大于300
  winsub_azi= 512;大于600
  outfile= DEMCoregFile
  result=TLI_FINE_COREG_CORR( coarse_result, master, slave, $ 
                          master_ss, master_ls, slave_ss, slave_ls,outfile= outfile,   $
                            winsearch_r=winsearch_r,winsearch_azi= winsearch_azi, $
                            winsub_r=winsub_r, winsub_azi=winsub_azi, $
                            /master_swap_endian, slave_swap_endian=slave_swap_endian)
  PRINT, '***********************************************'
  PRINT, '***           Fine Coreg Finished!          ***'
  PRINT, '***********************************************'
  
  ; Polyfit
  fine_result= DEMCoregFile
  finfo= FILE_INFO(fine_result)
  nlines= (finfo.SIZE)/8/5
  foffs= DBLARR(5, nlines)
  OPENR, lun, fine_result,/GET_LUN
  READU, lun, foffs
  FREE_LUN, lun
  
  coefs= DBLARR(6,4)
  coefs[*,0:1]= TLI_POLYFIT(foffs,degree=degree)
  
  foffs_c= foffs
  foffs[0:1,*]= foffs_c[2:3,*]
  foffs[2:3,*]= foffs_c[0:1,*]
  coefs[*,2:3]= TLI_POLYFIT(foffs,degree=degree)
  
  coefs_c=coefs
  coefs[1,*]=coefs_c[2,*]
  coefs[2,*]=coefs_c[1,*]
  coefs[3,*]=coefs_c[5,*]
  coefs[5,*]=coefs_c[3,*]
  
  coefs_c=coefs
  coefs[*,0]=coefs_c[*,1]
  coefs[*,1]=coefs_c[*,0]
  coefs[*,2]=coefs_c[*,3]
  coefs[*,3]=coefs_c[*,2]
  
  PRINT, '***********************************************'
  PRINT, '***             Poly Fit Finished!          ***'
  PRINT, '***********************************************'
  
  RETURN, coefs
  
END