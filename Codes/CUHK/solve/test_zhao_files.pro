PRO TEST_ZHAO_FILES

  ; Do not forget to check the pdiff file.
  
  gamma_dir= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Kowloon'
  cuhk_dir='/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Kowloon_CUHK'
  diff_dir= cuhk_dir+'/Basic_InSAR/Interferogram_Generation/Area1'
  
  gamma_itabfile= gamma_dir+'/itab'
  gamma_pbasefile= gamma_dir+'/testforCUHK/pbase'
  gamma_sarlistfile= gamma_dir+'/SLC_tab'

   ;********* First check plist file, find points that can be detected both in CUHK and GAMMA*****
   gamma_plistfile='/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Kowloon/testforCUHK/plist'
   cuhk_plistfile= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Kowloon_CUHK/PSI/plist'
   gamma_plist= TLI_READDATA(gamma_plistfile,samples=1, format='FCOMPLEX')
   cuhk_plist= TLI_READDATA(cuhk_plistfile,samples=1, format='FCOMPLEX')
   

  intf_ind=0
  ; **********************Zhao**************************
  cu_npt= TLI_PNUMBER(cuhk_plistfile)
  blfile= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Kowloon_CUHK/PSI/pla'
  bl= TLI_READDATA(blfile, samples=cu_npt,format='DOUBLE')
;  cu_bl= bl[WHERE(bl NE 0)]
  cu_bl= bl[*, intf_ind]
  Print, 'Zhao:',MEAN(DOUBLE(cu_bl)), 'MAX MIN:', MAX(cu_bl), MIN(cu_bl)
  ;************************GAMMA**********************
  g_npt= TLI_PNUMBER(gamma_plistfile)
  nintf= FILE_LINES(gamma_itabfile)
  gamma_itab= LONARR(4, nintf)
  OPENR, lun, gamma_itabfile,/GET_LUN
  READF, lun, gamma_itab
  FREE_LUN, lun
  
  nslc= FILE_LINES(gamma_sarlistfile)
  slc= STRARR(1, nslc)
  OPENR, lun, gamma_sarlistfile,/GET_LUN
  READF, lun, slc
  FREE_LUN, lun
  
  mslc= slc[gamma_itab[0]-1]
  Print, 'GAMMA master file:', mslc
  
  blfile= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Kowloon/testforCUHK/pla'
  g_bl= TLI_READDATA(blfile,samples= g_npt, format='DOUBLE')
  g_bl= g_bl[*, intf_ind]
  Print, 'GAMMA:',MEAN(DOUBLE(g_bl)), 'MAX MIN:', MAX(g_bl), MIN(g_bl)
  
  STOP

END