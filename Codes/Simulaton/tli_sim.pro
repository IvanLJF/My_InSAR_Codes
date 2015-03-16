PRO TLI_SIM

  simfrompath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  simfrompath= simfrompath+PATH_SEP()
  sarlistfile= simfrompath+'SLC_tab'
  itabfile= simfrompath+'itab'
  simbasepath= simfrompath+'testforCUHK/base'
  
  workpath='/mnt/software/myfiles/Software/experiment/sim'
  workpath=workpath+PATH_SEP()
  logfile= workpath+'log.txt'
  ptfile= workpath+'pt'
  deffile= workpath+'def'
  maskfile= workpath+'mask'
  simlinfile= workpath+'simlin'  ; simulated linear deformation v
  simherrfile= workpath+'simherr'
  simph_unwfile= workpath+'simph_unw' ; Simulated unwrapped phase.
  simphfile= workpath+'simph'  ; simulated different phase
  pbasefile= workpath+'pbase'
  plafile= workpath+'pla'
  
  ; some params
  temp= ALOG(2)
  e= 2^(1/temp)
  c= 299792458D ; Speed light
  
  ; Load master image info
  finfo= TLI_LOAD_MPAR(sarlistfile,itabfile)
  
  IF FILE_TEST(logfile) THEN BEGIN
    OPENW, loglun, logfile,/GET_LUN;,/APPEND
  ENDIF ELSE BEGIN
    OPENW, loglun, logfile,/GET_LUN
  ENDELSE
  st= SYSTIME(/SECONDS)
  PrintF, loglun, 'Start at time (seconds):'+STRCOMPRESS(st)
  PrintF, loglun, 'Workpath:'+workpath
  
  samples=3000D
  lines=3000D
  area='urban'
  
  ; First sim a plist file. Uniformly distributed.
  Printf, loglun, ''
  PrintF,loglun, 'Simulate point list: '+ptfile
  st= SYSTIME(/SECONDS)
  PrintF, loglun, 'Start at time:'+STRCOMPRESS(st)
  Case area OF
    'urban': BEGIN
      percent_l=1/100D  ;low percentage ;Colesanti, Ferretti, etc, SAR monitoring of progressive...
      percent_h=3.2/100D  ;high percentage
    END
    'rural': BEGIN
      percent_l=0.12/100D  ;low percentage
      percent_h=0.4/100D  ;high percentage
    END
    ELSE: BEGIN
      percent_l=1/100D  ;low percentage
      percent_h=3.2/100D  ;high percentage
    END
  ENDCASE
  percent= ABS(RANDOMN(seed))
  percent= percent_l+(percent_h-percent_l)*percent
  percent=0.001
  PrintF, loglun, 'Percent of PSs:'+STRCOMPRESS(percent)
  Print, 'Percent of PSs:'+STRCOMPRESS(percent)
  npt= LONG(samples*lines*percent)
  PrintF, loglun, 'Number of PSs:'+strcompress(npt)
  Print, 'Number of PSs:'+strcompress(npt)
  x= LONG(RANDOMU(seed, 1, npt)*3000)
  y= LONG(RANDOMU(seed, 1, npt)*3000)
  ;  pt= COMPLEX(x, y)
  pt= [x, y]
  OPENW, lun, ptfile,/GET_LUN,/SWAP_ENDIAN
  WriteU, lun, pt
  FREE_lun, lun
  OPENW, lun, ptfile+'.txt',/GET_LUN
  PRINTF, lun, [(x), (y)]
  FREE_LUN, lun
  mask= BYTARR(3000,3000)
  mask[x, y]=1
  OPENW, lun, maskfile,/GET_LUN
  WRITEU, lun, mask
  FREE_LUN, lun
  
  
  ; Simulate a deformation velocity field.
  PrintF, loglun, ''
  PrintF, loglun, 'Simulate a deformation field: '+simlinfile
  
  IF 0 THEN BEGIN
    PrintF, loglun, 'We use a second-order polynomial to do simulation'
    PrintF, loglun, 'Coefficents are[x2, y2, xy, x,y,1]'
    coefs=[1,1,1,1,1,1]
    PrintF, loglun,coefs
    xt= TRANSPOSE(x)  ; n samples * 1 line
    yt= TRANSPOSE(y)
    loc= [[xt^2],[yt^2], [xt*yt], [xt], [yt], [1+FINDGEN(N_ELEMENTS(xt))]]
    simlin= coefs##(loc)
  ENDIF ELSE BEGIN
    PrintF, loglun, 'Use a Gaussian function to do simulation'
    simlin= SHIFT(DIST(samples), samples/2-600, lines/2)  ; Gaussian function
    simlin= EXP(-(simlin/samples/4D)^2)
    simlin= simlin[x, y]
    simlin= -TRANSPOSE(simlin)
  ENDELSE
;  simlin_range=[-50,55] ; simulated linear deformation vel. range
simlin_range=[-10,10]
  simlin= TLI_STRETCH_DATA(simlin, simlin_range)
  
  
  
;  simlin= DBLARR(npt)  ; Do not simulate a deformation velocity field
  
  
  
  OPENW, lun, simlinfile,/GET_LUN
  WRITEU, lun, simlin
  FREE_LUN, lun
  OPENW, lun, simlinfile+'.txt',/GET_LUN
  PRINTF, lun, [x, y, TRANSPOSE(simlin)]
  FREE_LUN, lun
  ; Call gmt to plot def. field.
  CD, workpath
  cmd=workpath+'plot_linear_sim.sh'
  SPAWN, cmd
  PRINTF, loglun, ''
  PrintF, loglun, 'Plot deformation field use '+cmd
  PrintF, loglun, ''
  
  
  ; Simulate height error.
  simherr= RANDOMN(seed, 1, npt)
  simherr_range=[-10,10]; Simulated height error.
  simherr= TLI_STRETCH_DATA(simherr, simherr_range)
  
    simherr= DBLARR(1, npt)  ; Do not simulate height error.
    
    
  OPENW, lun, simherrfile,/GET_LUN
  WRITEU, lun, simherr
  FREE_LUN, lun
  OPENW, lun, simherrfile+'.txt',/GET_LUN
  PRINTF, lun, [x,y, (simherr)]
  FREE_LUN, lun
  cd , workpath
  cmd= workpath+'plot_herr_sim.sh'
  SPAWN, cmd
  
  PRINTF, loglun, ''
  PrintF, loglun, 'Plot height error use '+cmd
  PrintF, loglun, ''
  
  
  ; Get pbase and pla.
  slctabfile= sarlistfile
  basepath=simbasepath
  TLI_GAMMA_BP_LA_FUN, ptfile, itabfile, slctabfile, basepath, pbasefile, plafile
  nintf= FILE_LINES(itabfile)
  
  ; Simulate pdiff
  ; First calculate phase of each point
  pla= TLI_READDATA(plafile,samples=npt, FORMAT='DOUBLE')
  pbase= TLI_READDATA(pbasefile,samples=npt, format='DOUBLE')
  bt=TBASE_ALL(sarlistfile, itabfile)
  
  wavelength= c/finfo.radar_frequency
  ref_r= finfo.near_range_slc+finfo.range_pixel_spacing*x
  sinla= SIN(pla)
  
  K1= -4*(!PI)/(wavelength*ref_r*sinla) ;GX Liu && Lei Zhang均使用這種計算方法 Please be reminded that K1 and K2 are both negative.
  K2= -4*(!PI)/(wavelength*1000) ;毫米为单位---对应形变
  
  coefs_v=K2*bt
  coefs_dh= pbase*REBIN(TRANSPOSE(K1), npt, nintf)
  
  simph_unw= coefs_v##simlin+coefs_dh*REBIN(TRANSPOSE(simherr),npt, nintf)
  
  
  ; Simulate noise
  noise= RANDOMN(seed, npt, nintf)
  ; Change the mean value to 15 degrees, dev to 5 degrees.
  noise= noise*(SQRT(5))+15
  noise= DEGREE2RADIUS(noise)
  
  
  noise=noise*0 ; Do not simulate noise
  
  
  
  ; Add noise
  simph_unw= simph_unw+noise
  
  
  OPENW, lun, simph_unwfile,/GET_LUN
  WRITEU, lun, simph_unw
  FREE_LUN, lun
  ; Wrap the phase
  simph= simph_unw MOD (!PI)
  simph_slc= COMPLEX(cos(simph), sin(simph))
  OPENW, lun, simphfile,/GET_LUN,/SWAP_ENDIAN
  WRITEU,lun, simph_slc
  FREE_LUN, lun
  OPENW, lun, simphfile+'.txt',/GET_LUN
  fstrarr1= REPLICATE('I0', 2)
  fstrarr2= REPLICATE('D0', (SIZE(simph,/DIMENSIONS))[1])
  fstrarr=[fstrarr1, fstrarr2]
  sep=',"'+STRING(9B)+'",'
  fstring= '('+STRJOIN(fstrarr,sep)+')'
  PRINTF, lun, [x, y, TRANSPOSE(simph)], format= fstring
  FREE_LUN, lun
  
  if 0 THEN BEGIN
    ; Plot all diff figures.
    Print, 'Plotting all diff images...'
    cmd= workpath+'plot_simph.sh'
    CD, workpath
    SPAWN, cmd
    PrintF, loglun, 'Formats are referred to GAMMA.'
    PrintF, loglun, 'All .jpg are put into plotdata folder.'
  ENDIF
  
  
  
  
  
  
  
  
  ;  ; 自动选择影像中心点作为参考点，仅作测试用...
  ;  plist= TLI_READDATA(plistfile,samples=1, format='FCOMPLEX')
  ;  IF 0 THEN BEGIN
  ;    samples= DOUBLE(finfo.range_samples)
  ;    lines= DOUBLE(finfo.azimuth_lines)
  ;    plist_dist= ABS(plist-COMPLEX(samples/2, lines/2))
  ;    min_dist= MIN(plist_dist, refind)
  ;  ENDIF
  ;  Print, 'Reference point index:', STRCOMPRESS(refind), '.   Coordinates:',STRCOMPRESS( plist[refind]) ; Reference point index: 183.   Coordinates:( 465.000, 508.000)
  ;  PrintF, loglun,  'Reference point index:'+STRCOMPRESS(refind)+'. Coordinates:'+STRCOMPRESS(plist[refind])
  ;
  PrintF, loglun, ''
  PRINTF, loglun, 'End at time'+STRCOMPRESS(SYSTIME(/SECONDS))
  FREE_lun, loglun
  
  Print, 'Main pro. finished.'
END