FUNCTION READ_SLCPAR,INFILE_PAR,READ_KW
;- 用来读取SLC的头文件中的指定内容
;- 输入参数：INFILE_PAR头文件全路径
;-         READ_KW指定的关键字
;- 输出参数：关键字所在行的信息
;- 用法示例：svp=read_slcpar('20090920.rslc','state_vector_position')
  infile_par=infile_par;- 设定要读取的头文件。
  read_kw=read_kw;- 设定要读取的关键字。
  temp='';- 定义空字符串，用来存储要读取的数据。
  kw_line=0;- 定义kw_line，用来存储关键字所在的行数。
  kw_lineinfo='';- 定义kw_lineinfo，用来存储行包含的信息。
  OPENR,lun,infile_par,/get_lun
  nlines=FILE_LINES(infile_par)
  for i=0,nlines-1 do begin
    readf,lun,temp
    kw_column=strpos(temp,read_kw)
    if kw_column gt -1 then begin
      kw_line=[kw_line,i]
      kw_lineinfo=[kw_lineinfo,temp]
    endif
  endfor
  FREE_LUN, lun
  if n_elements(kw_line) eq 1 then print,'No Such Keyword In SLC Par'
  if n_elements(kw_line) gt 1 then begin    
    IF (read_kw EQ 'range_samples') OR ((read_kw EQ 'azimuth_lines')) THEN BEGIN
      kw_lineinfo= STRSPLIT(kw_lineinfo(1), ' ',/EXTRACT)
      kw_lineinfo= DOUBLE(kw_lineinfo(1))
      RETURN, kw_lineinfo
    ENDIF ELSE BEGIN
      RETURN, kw_lineinfo(1:*)
    ENDELSE      
;    kw_number=n_elements(kw_line)-1
;    for i=1,kw_number do begin
;      print,'The'+string(i)+'keyword found is:'+kw_lineinfo(i)      
;    endfor    
  endif

END

;- 一个标准的SLC.par文件
;Gamma Interferometric SAR Processor (ISP) - Image Parameter File
;
;title:     SSC____SM_S
;sensor:    TSX-1
;date:      2009 9 20 22 2 31.6100
;start_time:             79355.103121   s
;center_time:            79355.414869   s
;end_time:               79355.726617   s
;azimuth_line_time:     2.7723245e-04  s
;line_header_size:                  0
;range_samples:                  3150
;azimuth_lines:                  2250
;range_looks:                       1
;azimuth_looks:                     1
;image_format:               SCOMPLEX
;image_geometry:             SLANT_RANGE
;range_scale_factor:     1.0000000e+00
;azimuth_scale_factor:   1.0000000e+00
;center_latitude:          31.2356746   degrees
;center_longitude:        121.5051487   degrees
;heading:                 190.7709114   degrees
;range_pixel_spacing:        0.909403   m
;azimuth_pixel_spacing:      1.966905   m
;near_range_slc:           562804.6249   m
;center_range_slc:         564236.4799   m
;far_range_slc:            565668.3350   m
;first_slant_range_polynomial:        0.00000      0.00000  0.00000e+00  0.00000e+00  0.00000e+00  0.00000e+00  s m 1 m^-1 m^-2 m^-3 
;center_slant_range_polynomial:       0.00000      0.00000  0.00000e+00  0.00000e+00  0.00000e+00  0.00000e+00  s m 1 m^-1 m^-2 m^-3 
;last_slant_range_polynomial:         0.00000      0.00000  0.00000e+00  0.00000e+00  0.00000e+00  0.00000e+00  s m 1 m^-1 m^-2 m^-3 
;incidence_angle:             26.4236   degrees
;azimuth_deskew:          ON
;azimuth_angle:               90.0000   degrees
;radar_frequency:        9.6500000e+09   Hz
;adc_sampling_rate:      1.6482919e+08   Hz
;chirp_bandwidth:        1.5000000e+08   Hz
;prf:                     3607.081408   Hz
;azimuth_proc_bandwidth:   2765.00000   Hz
;doppler_polynomial:         -3.78752  0.00000e+00  0.00000e+00  0.00000e+00  Hz     Hz/m     Hz/m^2     Hz/m^3
;doppler_poly_dot:        0.00000e+00  0.00000e+00  0.00000e+00  0.00000e+00  Hz/s   Hz/s/m   Hz/s/m^2   Hz/s/m^3
;doppler_poly_ddot:       0.00000e+00  0.00000e+00  0.00000e+00  0.00000e+00  Hz/s^2 Hz/s^2/m Hz/s^2/m^2 Hz/s^2/m^3
;receiver_gain:              -15.8770   dB
;calibration_gain:             0.0000   dB
;sar_to_earth_center:             6884232.8404   m
;earth_radius_below_sensor:       6372623.3859   m
;earth_semi_major_axis:           6378137.0000   m
;earth_semi_minor_axis:           6356752.3141   m
;number_of_state_vectors:                   12
;time_of_first_state_vector:      79305.000000   s
;state_vector_interval:              10.000000   s
;state_vector_position_1:  -3250782.5338    4704528.7179    3832074.3651   m   m   m
;state_vector_velocity_1:    -1064.67600      4362.70100     -6239.43700   m/s m/s m/s
;state_vector_position_2:  -3261199.8006    4747876.5060    3769446.6524   m   m   m
;state_vector_velocity_2:    -1018.77000      4306.75900     -6285.97900   m/s m/s m/s
;state_vector_position_3:  -3271157.7804    4790661.9041    3706357.3610   m   m   m
;state_vector_velocity_3:     -972.82000      4250.22400     -6331.75200   m/s m/s m/s
;state_vector_position_4:  -3280656.0803    4832879.0283    3642814.2065   m   m   m
;state_vector_velocity_4:     -926.83500      4193.10500     -6376.75100   m/s m/s m/s
;state_vector_position_5:  -3289694.3692    4874522.0636    3578824.9612   m   m   m
;state_vector_velocity_5:     -880.81900      4135.40700     -6420.96900   m/s m/s m/s
;state_vector_position_6:  -3298272.3832    4915585.2629    3514397.4508   m   m   m
;state_vector_velocity_6:     -834.78000      4077.13900     -6464.40300   m/s m/s m/s
;state_vector_position_7:  -3306389.9192    4956062.9512    3449539.5575   m   m   m
;state_vector_velocity_7:     -788.72500      4018.30600     -6507.04500   m/s m/s m/s
;state_vector_position_8:  -3314046.8433    4995949.5256    3384259.2163   m   m   m
;state_vector_velocity_8:     -742.65900      3958.91700     -6548.89100   m/s m/s m/s
;state_vector_position_9:  -3321243.0814    5035239.4520    3318564.4131   m   m   m
;state_vector_velocity_9:     -696.58900      3898.97800     -6589.93600   m/s m/s m/s
;state_vector_position_10:  -3327978.6276    5073927.2726    3252463.1880   m   m   m
;state_vector_velocity_10:     -650.52200      3838.49700     -6630.17500   m/s m/s m/s
;state_vector_position_11:  -3334253.5378    5112007.6011    3185963.6289   m   m   m
;state_vector_velocity_11:     -604.46300      3777.48100     -6669.60200   m/s m/s m/s
;state_vector_position_12:  -3340067.9341    5149475.1267    3119073.8739   m   m   m
;state_vector_velocity_12:     -558.42000      3715.93800     -6708.21300   m/s m/s m/s
