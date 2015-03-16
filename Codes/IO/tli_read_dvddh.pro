PRO TLI_READ_DVDDH
  ptfile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
  dvddhfile='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/tli_rg_dvddh_result.20.178012'
  
  npt= TLI_PNUMBER(ptfile)
  pt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B)
  pt_attr= REPLICATE(pt_attr, npt)
  
  OPENR, lun, dvddhfile,/GET_LUN
  READU, lun, pt_attr
  FREE_LUN, lun
  
  STOP
  

END