;- 
;- Purpose:
;-     Do coarse coregistration according to center longitude and latitude
;- Calling Sequence:
;-    result=COARSE_CORG_LL(master, slave)
;- Inputs:
;-    masterSLC, slaveSLC
;- Optional Input Parameters:
;-    None
;- Keyword Input Parameters:
;-    master, slave
;- Outputs:
;-    Offset_x, Offset_y
;- Commendations:
;-    None.
;- Example:
;-    master = 'D:\ForExperiment\TSX_TJ_1500\20090327.rslc'
;-    slave = 'D:\ForExperiment\TSX_TJ_1500\20090418.rslc'
;-    coffsets= COARSE_COREG_ll(master,slave)
;- Modification History:
;-    07/02/2012 First finish the pro. T. Li in CUHK.
;FUNCTION COARSE_COREG_LL, master, slave  
;  
;  IF N_PARAMS() NE 2 THEN result=DIALOG_MESSAGE('ERROR!'+STRING(13B)+ $
;                                                '      Usage:coffsets= COARSE_COREG_ll(master,slave)')
;  
 


PRO COARSE_COREG_LL
  ;- Check parameters
;  master = '/media/Software/ForExperiment/TSX_TJ_1500/20090327.rslc'
;  slave = '/media/Software/ForExperiment/TSX_TJ_1500/20090418.rslc'
;  master='/mnt/software/ForExperiment/TSX_JH_Original/20091113.slc'
;  slave= '/mnt/software/ForExperiment/TSX_JH_Original/20100107.slc'    
;  master= 'D:\ForExperiment\TSX_JH_Original_Sub1000\20091113.rslc'
;  slave= 'D:\ForExperiment\TSX_JH_Original_Sub1000\20100107.rslc'
  master = 'D:\ForExperiment\TSX_TJ_1500\20090327.rslc'
  slave = 'D:\ForExperiment\TSX_TJ_1500\20090418.rslc'
;  master='D:\ForExperiment\TSX_TJ_500\20090327.rslc'
;  slave= 'D:\ForExperiment\TSX_TJ_500\20090407.rslc'
;  master='D:\ForExperiment\TSX_TJ_Coreg_Sub1000_Off110-57\20090327.rslc'
;  slave='D:\ForExperiment\TSX_TJ_Coreg_Sub1000_Off110-57\20090407.rslc'
;  master='D:\ForExperiment\PALSAR_BJ_Coreg_Sub1000_off78-190\20090424.rslc'
;  slave='D:\ForExperiment\PALSAR_BJ_Coreg_Sub1000_off78-190\20090909.rslc'
  
  ;- Read params from headerfile
  master_h= master+'.par'
  slave_h= slave+'.par'
  IF ~FILE_TEST(master_h) THEN result= DIALOG_MESSAGE('ERROR!'+ STRING(13B) + '      Master head not found')
  IF ~FILE_TEST(slave_h) THEN result= DIALOG_MESSAGE('ERROR!'+ STRING(13B) + '      Slave head not found')
  ON_ERROR, 2
  
  m_ss= READ_PARAMS(master_h, 'range_samples')
  m_ls= READ_PARAMS(master_h, 'azimuth_lines')
  m_c_lat= READ_PARAMS(master_h, 'center_latitude')
  m_c_lon= READ_PARAMS(master_h, 'center_longitude')
  m_rspace= READ_PARAMS(master_h, 'range_pixel_spacing')
  m_aspace= READ_PARAMS(master_h, 'azimuth_pixel_spacing')
  m_earthr= READ_PARAMS(master_h, 'earth_radius_below_sensor')
  
  s_ss= READ_PARAMS(slave_h, 'range_samples')
  s_ls= READ_PARAMS(slave_h, 'azimuth_lines')
  s_c_lat= READ_PARAMS(slave_h, 'center_latitude')
  s_c_lon= READ_PARAMS(slave_h, 'center_longitude')
  s_rspace= READ_PARAMS(slave_h, 'range_pixel_spacing')
  s_aspace= READ_PARAMS(slave_h, 'azimuth_pixel_spacing')
  s_earthr= READ_PARAMS(slave_h, 'earth_radius_below_sensor')
  
  ;- Master center pixel's coordinate in master SLC.
  m_c_x= FLOOR(m_ss/2) & m_c_y= FLOOR(m_ls/2)
  ;- Master center pixel's coordinate in Slave SLC 
  d_lon= s_c_lon - m_c_lon
  d_lat= s_c_lat - m_c_lat

;  pixel_lon= s_aspace/(2*!PI*(s_earthr*sin(s_c_lon/180D*!PI)))*180/!PI
;  pixel_lat= s_rspace/(2*!PI*(s_earthr))*180D/!PI
  pixel_lon= s_aspace/(s_earthr)*180D/!PI
  pixel_lat= s_rspace/(s_earthr*COS(s_c_lat*!PI/180D))*180D/!PI

  dp_lon= d_lon/pixel_lon
  dp_lat= d_lat/pixel_lat
  coffsets= [dp_lon, dp_lat]
  print, coffsets
END