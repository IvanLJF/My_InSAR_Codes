PRO TLI_GAMMA_GEOMETRY
  COMPILE_OPT idl2
  
  workpath='D:\myfiles\Software\experiment\TSX_PS_Tianjin\piece'
  parfile=workpath+PATH_SEP()+'20091113.rslc.par'
  
  c=299792458D ; Light speed.
  radar_frequency= READ_PARAMS(parfile, 'radar_frequency')
  wl = c / radar_frequency ;米为单位
  rs= READ_PARAMS(parfile, 'range_samples')
  ls= READ_PARAMS(parfile, 'azimuth_lines')
  cl= READ_PARAMS(parfile, 'center_latitude')
  esmaa= READ_PARAMS(parfile, 'earth_semi_major_axis')
  esmia= READ_PARAMS(parfile, 'earth_semi_minor_axis')
  nrs= READ_PARAMS(parfile, 'near_range_slc')
  ia= READ_PARAMS(parfile, 'incidence_angle')
  rps= READ_PARAMS(parfile, 'range_pixel_spacing')
  crs= READ_PARAMS(parfile, 'center_range_slc')
  frs= READ_PARAMS(parfile, 'far_range_slc')
  erbs= READ_PARAMS(parfile, 'earth_radius_below_sensor')
  stec= READ_PARAMS(parfile, 'sar_to_earth_center')
  asr= READ_PARAMS(parfile, 'adc_sampling_rate')
  Print, 'According to the cosine thereom,'+STRING(13B)+$
         'We assume that the earth radiuses at the same latitude are all the same.'+STRING(13b)+$
         'So we can calculate the incident angle of the Near_Range_SLC point.'
  
  
  cosla= (stec^2+nrs^2-erbs^2)/(2*stec*nrs)
  la= ACOS(cosla) 
  la= DEGREE2RADIUS(la,/REVERSE)
  Print, 'Look angle of the sattelite:', la


  erbs_cal= SQRT(stec^2+crs^2-2*stec*nrs*COS(DEGREE2RADIUS(la)))
  Print, 'If we use GAMMA incident angle, then the earth radius below near range slc point is :', erbs_cal
  Print, 'Earth radius below sensor is:', erbs
  Print, 'The difference between the 2 erbs is:', erbs_cal-erbs
  
  cosia=(nrs^2+erbs_cal^2-stec^2)/(2*crs*erbs_cal)
  ia_cal= ACOS(cosia)
  ia_cal= DEGREE2RADIUS(ia_cal, /reverse)
  Print, 'Incidence angle calculated:', 180-ia_cal
  
  Print, 'GAMMA incident angle:', ia
  
  
  Print, 'Follows are kinds of sensitivitys of PHI at first slant range. Set perpendicular baseline to 200m'
  Bperp= 50
  dphidh= 4*!PI*Bperp/(wl*nrs*SIN(DEGREE2RADIUS(la)))
  Print, 'If DH=1, then DPHI=', dphidh
  Print, 'If DPHI=2PI, then DH=', 1/dphidh*2*!PI
  dnrs=100
  h=100
  dphidr= -4*!PI*Bperp*h/(wl*nrs^2*SIN(DEGREE2RADIUS(la)))*dnrs
  Print, 'If Dnrs=1, then DPHI=', dphidr
  
  rps_calc= c/asr/2
  Print, 'Range pixel spacing is calculated using rpc. We calculated rps as: ', rps_calc, '   True rpc is: ', rps
  
  IF LONG((frs-nrs)/rps+1) EQ LONG(rs) THEN Print,'Slant range is calculated using near_rang_slc, far_range_slc and pixel spacing.'
  
 
END