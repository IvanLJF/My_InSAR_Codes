PRO TLI_QL_DEMVIAPS_DANPARAM
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/Qingli'
  danparamfile= workpath+PATH_SEP()+'allparfiles'+PATH_SEP()+'DataSet.txt'; params from Daniele
  dopplerfile=workpath+PATH_SEP()+'allparfiles'+PATH_SEP()+'Doppler.txt'; params from Daniele
  reportfile= workpath+PATH_SEP()+'Report.txt'
  
  ; Input params
  gama= 0.8 ; gamma
  temp= ALOG(2)
  e= 2^(1/temp)
  c= 299792458D ; Speed of light
  
  nintf= FILE_LINES(danparamfile)
  danparam= DBLARR(4, nintf)
  OPENR, lun, danparamfile,/GET_LUN
  READF, lun, danparam
  FREE_LUN, lun
  
  ; Find master file
  Bt= danparam[3, *]
  Bperp= danparam[2, *] ; Perpendicular baseline
;  Bperp= ABS(Bperp)
  date= danparam[1, *]
  master_ind= WHERE(Bt EQ 0.0)
  master_date= (date[0, master_ind])[0]
  master_fname= workpath+PATH_SEP()+'allparfiles'+PATH_SEP()+STRMID(STRCOMPRESS(master_date),1,8)+'.rslc.par'
  master_fname= STRTRIM(master_fname)
  master_fstru= TLI_LOAD_SLC_PAR(master_fname)
  
  lamda= c/DOUBLE(master_fstru.radar_frequency)
  R0= master_fstru.near_range_slc
  theta= DEGREE2RADIUS(master_fstru.incidence_angle)
  dev_dphi= -2*ALOG(gama) ; deviation of dphi 
  N= nintf
  
  dev_dh= (lamda*R0*SIN(theta)/4/!PI)^2*(dev_dphi)/(N*(STDDEV(Bperp)^2))
  sigma_dh= SQRT(dev_dh)
  
;  df= 0
;  dev_dr= (c/(4*!PI*)) ; This is nonsense.
  
  PRF= master_fstru.prf
  delta_az= master_fstru.azimuth_pixel_spacing
  doppler= DBLARR(2, nintf)
  OPENR, lun, dopplerfile,/GET_LUN
  READF, lun, doppler
  FREE_LUN, lun
  sigma_dfdc= STDDEV(doppler[1, *])
;  sigma_dfdc= 300 ;*********************************WTF?************
  sigma_dy= (PRF*delta_az/(2*!PI))^2*(dev_dphi)/(N*sigma_dfdc^2)
  
  OPENW, rep_lun, reportfile,/GET_LUN
  PrintF, rep_lun, 'Standard deviation of Bperp is:', STRCOMPRESS(STDDEV(Bperp)), ' m.'
  PrintF, rep_lun, ''
  PrintF, rep_lun, 'For a multitemporal data of N='+STRCOMPRESS(N)+' images with incidence angle theta='$
            +STRCOMPRESS(theta)+'('+STRCOMPRESS(master_fstru.incidence_angle)+' degree) and baseline dispersion sigma_Bn='$
            +STRCOMPRESS(STDDEV(Bperp))+' m. A PS with coherence gamma='$
            +STRCOMPRESS(gama)+' is localized with about'+STRCOMPRESS(sigma_dh*100)+' cm of elevation dispersion.'
  PrintF, rep_lun, ''
  PrintF, rep_lun, 'No second sensor is used, thus there is no position variance in range direction.'
  PrintF, rep_lun, ''
  PrintF, rep_lun, 'Assuming a DC standard deviation sigma_delta(fdc)='+STRCOMPRESS(sigma_dfdc)+' Hz, pulse repetition frequency PRF='$
              +STRCOMPRESS(PRF)+' Hz, N='+STRCOMPRESS(N)+' images, and azimuth sampling interval delta_az='$
              +STRCOMPRESS(delta_az)+', a PS with coherence gamma='+STRCOMPRESS(gama)+' can be positioned in azimuth with a'$
              +STRCOMPRESS(sigma_dy*100)+'-cm dispersion.'
  
  
  FREE_LUN, rep_lun
  
  STOP
  
  
  
END