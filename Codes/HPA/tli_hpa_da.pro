; Calculate the Amplitude dispersion map for the input sarlistfile.

; No optimazation is applied, so much memory may be used. At least 2 * SLC_file_size will be occupied.

PRO TLI_HPA_DA, sarlistfile, samples=samples, format=format,swap_endian=swap_endian, outputfile=outputfile,force=force

  ; Check the input params.

  nslc=FILE_LINES(sarlistfile)
  sarlist=STRARR(nslc)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  temp=STRSPLIT(sarlist[0], ' ',/EXTRACT)
  sz=SIZE(temp,/DIMENSIONS)
  IF sz GT 1 THEN BEGIN
    FOR i=0, nslc-1 DO BEGIN
      temp=STRSPLIT(sarlist[i], ' ',/EXTRACT)
      names=sz/2-1
      sarlist[i]=STRJOIN(temp[0:names],' ')
    ENDFOR
  ENDIF
  
  
  parfile=sarlist[0]+'.par'
  IF FILE_TEST(parfile) THEN BEGIN
    Print, 'The input sarlistfile is generated from GAMMA files.'
    finfo=TLI_LOAD_SLC_PAR(parfile)
    samples=finfo.range_samples
    lines=finfo.azimuth_lines
    format=finfo.image_format
    swap_endian=1
  ENDIF ELSE BEGIN
    IF NOT KEYWORD_SET(samples) THEN BEGIN
      Message, 'Error, please specify the samples and format.'
    ENDIF
  ENDELSE
  IF ~KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=FILE_DIRNAME(parfile)+PATH_SEP()+'DA'
  ENDIF
  IF FILE_TEST(outputfile) THEN BEGIN
    IF FILE_TEST(outputfile+'_mean_amp') THEN BEGIN
      temp=FILE_INFO(outputfile)
      temp=temp.size
      fsize=finfo.range_samples*finfo.azimuth_lines*4
      IF temp EQ fsize AND NOT KEYWORD_SET(force) THEN BEGIN
        Print, 'DA file already exist. No duplicate file is generated.'
        Print, 'Please check the files:'
        Print, outputfile
        Print, outputfile+'_mean_amp'
        RETURN
      ENDIF
    ENDIF
    
    
  ENDIF
  
  
  slc_means=DBLARR(nslc)
  
  FOR i=0, nslc-1 DO BEGIN
    Print, 'Determining the radiometric correction factor for each image...', STRCOMPRESS(i),'/', STRCOMPRESS(nslc-1)
    slc=TLI_READDATA(sarlist[i], samples=samples,format=format, swap_endian=swap_endian)
    datatype=SIZE(slc[0],/type)
    IF datatype NE 6 AND datatype NE 9 THEN BEGIN
      slc_means[i]=MEAN(slc) ; Just for efficiency.
    ENDIF ELSE BEGIN
      slc_means[i]=MEAN(ABS(slc))
    ENDELSE
  ENDFOR
  amp_rc_f=slc_means/slc_means[0] ; Use the first image as the reference image and set its radiometric correction factor to 1.
  

  sz=SIZE(slc,/DIMENSIONS)
  mean_map=FLTARR(sz[0], sz[1])
  FOR i=0, nslc-1 DO BEGIN
    Print, 'Calculating the mean amplitude for each point.',strcompress(i), '/', strcompress(nslc-1)
    slc=TLI_READDATA(sarlist[i], samples=samples, format=format, swap_endian=swap_endian)
    IF datatype NE 6 AND datatype NE 9 THEN BEGIN
      mean_map=mean_map+slc*amp_rc_f[i]/FLOAT(nslc) ; Just for efficiency.
    ENDIF ELSE BEGIN
      mean_map=mean_map+ABS(slc)*amp_rc_f[i]/FLOAT(nslc)
    ENDELSE
  ENDFOR
  OPENW, lun, outputfile+'_mean_amp'
  WRITEU, lun, FLOAT(mean_map)
  FREE_LUN, lun
  

  da_sqr=FLTARR(sz[0],sz[1])
  FOR i=0, nslc-1 DO BEGIN
    Print,'Calculating the DA map for the input sarlist', strcompress(i), '/', strcompress(nslc-1)
    slc=TLI_READDATA(sarlist[i], samples=samples, format=format, swap_endian=swap_endian)
    IF datatype NE 6 AND datatype NE 9 THEN BEGIN
      da_sqr=da_sqr+(slc*amp_rc_f[i]-mean_map)^2D / FLOAT(nslc) ; Just for efficiency.
    ENDIF ELSE BEGIN
      da_sqr=da_sqr+(ABS(slc)*amp_rc_f[i]-mean_map)^2/FLOAT(nslc)
    ENDELSE
  ENDFOR
  da=SQRT(da_sqr)/mean_map ; Float
  
  OPENW, lun, outputfile,/GET_LUN
  WRITEU, lun, FLOAT(da)
  FREE_LUN, lun
  
END