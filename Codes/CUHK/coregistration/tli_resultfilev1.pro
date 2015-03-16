;+
; Name:
;  tli_resultfile.pro
; Purpose:
;   Generate some result files after co-reg.
; Calling Sequence:
;    result= TLI_RESULTFILE(master, slave, mlook_a, mlook_r,i_outfile=i_outfile,p_outfile=p_outfile, $
;                    c_outfile= c_outfile)
; Inputs:
;    master: Full path containing master slc.
;    slave: Full path containing slave slc.
;    mlook_a: Azimuth multi-look number.
;    mlook_r: Range multi-look number.
; Optional Input Parameters:
;    None
; Keyword Input Parameters:
;    i_outfile: Interferogram file path(complex array).
;    p_outfile: Phase file path.
;    c_outfile: Cross-correlation file path.
; Outputs:
;    Interferogram, Phase, Cross-correlation.
; Commendations:
;    None
; Example:
;    master= '/mnt/software/ForExperiment/ITF_ENVISAT/20070726.slc'
;    slave= '/mnt/software/ForExperiment/ITF_ENVISAT/20070830.registered.slc'
;    mlook_a= 5
;    mlook_r= 1
;    master_ss= READ_PARAMS(master+'.par', 'samples')
;    master_ls= READ_PARAMS(master+'.par', 'lines')
;    result= TLI_RESULTFILE(master, slave, mlook_a, mlook_r,i_outfile=i_outfile,p_outfile=p_outfile, $
;                          c_outfile= c_outfile,master_ss=master_ss, master_ls= master_ls)
; Modification History:
;-   06/03/2012: Written by T.Li @ InSAR Team in SWJTU & CUHK.
; 不多视则无意义，必须多视 ,5 1
FUNCTION TLI_RESULTFILEV1, master, slave, mlook_a, mlook_r,master_ss, master_ls, i_outfile=i_outfile,p_outfile=p_outfile, $
                    c_outfile= c_outfile

  COMPILE_OPT idl2
  ;------------------Initialization---------------------------
;  IF ~KEYWORD_SET(i_outfile) THEN $
;    i_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.int'
;  IF ~KEYWORD_SET(p_outfile) THEN $
;    p_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.phase'
;  IF ~KEYWORD_SET(c_outfile) THEN $
;    c_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.cc'
  master_ss= master_ss;READ_PARAMS(master+'.par', 'samples')
  master_ls= master_ls;READ_PARAMS(master+'.par', 'lines')
  IF ~KEYWORD_SET(mlook_a) OR ~KEYWORD_SET(mlook_r) THEN BEGIN
    IF master_ls GE master_ss THEN BEGIN
      mlook_r = 1
      mlook_a = FLOOR(master_ls/master_ss)
    ENDIF ELSE BEGIN
      mlook_a=1
      mlook_r= FLOOR(master_ss/master_ls)
    ENDELSE
  ENDIF

  IF mlook_a EQ 1 AND mlook_r EQ 1 THEN BEGIN
    result= DIALOG_MESSAGE('Multi number of azimuth and range can not both be 1.'$
                          +STRING(13B)+'I will not ouput .cc file.',/INFORMATION)
  ENDIF
  ;------------------Initialization---------------------------



;    master='/mnt/software/ForExperiment/TSX_TJ_Coreg_Sub1000_Off110-57/20090327.slc'
;    slave='/mnt/software/ForExperiment/TSX_TJ_Coreg_Sub1000_Off110-57/20090407.registered.slc'
;    mlook_a=3
;    mlook_r=3

;  IF FILE_TEST(i_outfile) THEN FILE_DELETE, i_outfile
;  IF FILE_TEST(p_outfile) THEN FILE_DELETE, p_outfile
;  IF FILE_TEST(c_outfile) THEN FILE_DELETE, c_outfile

;  if N_Elements(i_outfile) then begin
;  	IF FILE_TEST(i_outfile) THEN FILE_DELETE, i_outfile
;  	OPENW, luni, i_outfile, /GET_LUN;,/SWAP_ENDIAN
;  endif
;  if N_Elements(p_outfile) then begin
;  	IF FILE_TEST(p_outfile) THEN FILE_DELETE, p_outfile
;  	OPENW, lunp, p_outfile,/GET_LUN;,/SWAP_ENDIAN
;  endif
  if N_Elements(c_outfile) then begin
  	IF FILE_TEST(c_outfile) THEN FILE_DELETE, c_outfile
  	OPENW, lunc, c_outfile,/GET_LUN;,/SWAP_ENDIAN
  endif
  tile_size= 300D
  tile_size= tile_size*mlook_a

  IF (master_ss MOD tile_size) THEN BEGIN
    tile_l= FLOOR(master_ls/tile_size)
  ENDIF ELSE BEGIN
    tile_l= FLOOR(master_ls/tile_size)-1
  ENDELSE

  lines=0
  samples=0
  FOR k= 0, tile_l DO BEGIN
  PRINT, k,'  /',tile_l
    end_y= ((tile_size*(k+1)+mlook_a) GT master_ls)? (master_ls-1): (tile_size*(k+1)+mlook_a-2)
    start_y= k*tile_size
    masterSLC= SUBSETSLC(master, 0, master_ss, start_y, end_y-start_y+1, fileNs=master_ss, fileNl=master_ls)
    slaveSLC= SUBSETSLC(slave, 0, master_ss, start_y, end_y-start_y+1, fileNs=master_ss, fileNl=master_ls)



    ii= FLOOR(master_ss/mlook_r)-1
    jj= FLOOR(end_y-start_y+1)/mlook_a-1
;   if N_Elements(i_outfile) then  inter= COMPLEXARR(ii+1,jj+1)
;   if N_Elements(p_outfile) then  phase= FLTARR(ii+1,jj+1)
    cc= FLTARR(ii+1,jj+1)
    FOR i= 0, ii DO BEGIN
      FOR j=0, jj DO BEGIN
        large_sub= masterSLC[i*mlook_r:[[i+1]*mlook_r-1], j*mlook_a:[[j+1]*mlook_a-1]]
        small= slaveSLC[i*mlook_r:[[i+1]*mlook_r-1], j*mlook_a:[[j+1]*mlook_a-1]]
        numerator= large_sub* CONJ(small);;;;
;        if N_Elements(i_outfile) then inter[i,j]= MEAN(numerator)
;        if N_Elements(p_outfile) then phase[i,j]= ATAN(inter[i,j],/PHASE)
        numerator= ABS(TOTAL(numerator));;;;
        denomilator= (TOTAL(ABS(large_sub)^2)*TOTAL(ABS(small)^2))^0.5
;        PRINT, numerator/denomilator
        cc[i,j]= numerator/denomilator
      ENDFOR
    ENDFOR
    ;----------------------------------
;    sz= SIZE(phase,/DIMENSIONS)
;    scale= 0.5
;    sz= sz*scale
;    show= CONGRID(phase,sz[0], sz[1])
;    DEVICE, DECOMPOSED=0
;    LOADCT, 25
;    WINDOW, XSIZE=sz[0], YSIZE=sz[1]
;    TVSCL, show,/NAN
;    STOP
    ;----------------------------------
;    if N_Elements(i_outfile) then WRITEU, luni, inter
;    if N_Elements(p_outfile) then WRITEU, lunp, phase
    WRITEU, lunc, cc

    sz= SIZE(cc,/DIMENSIONS)
    lines=lines+sz[1]
;    PRINT, sz
  ENDFOR
  PRINT, 'range_samples:  ', sz[0]
  PRINT, 'azimuth_lines:  ', lines
;  if N_Elements(i_outfile) then FREE_LUN, luni
;  if N_Elements(p_outfile) then FREE_LUN, lunp
  FREE_LUN, lunc

  RETURN, 1

END