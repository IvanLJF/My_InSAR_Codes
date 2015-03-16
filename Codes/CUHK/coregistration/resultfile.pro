PRO RESULTFILE
;  master= '/mnt/software/ForExperiment/ITF_ENVISAT/20070726.slc'
;  slave= '/mnt/software/ForExperiment/ITF_ENVISAT/20070830.registered.slc'
;  mlook_a= 5
;  mlook_r= 1

    master='/mnt/software/ForExperiment/TSX_TJ_Coreg_Sub1000_Off110-57/20090327.slc'
    slave='/mnt/software/ForExperiment/TSX_TJ_Coreg_Sub1000_Off110-57/20090407.registered.slc'
    mlook_a=1
    mlook_r=1
  
  i_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.int'
  p_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.phase'
  c_outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.slc')+'-'+FILE_BASENAME(slave, '.slc')+'.cc'
  IF FILE_TEST(i_outfile) THEN FILE_DELETE, i_outfile
  IF FILE_TEST(p_outfile) THEN FILE_DELETE, p_outfile
  IF FILE_TEST(c_outfile) THEN FILE_DELETE, c_outfile
  close,/all
  OPENW, luni, i_outfile, /GET_LUN
  OPENW, lunp, p_outfile,/GET_LUN
  OPENW, lunc, c_outfile,/GET_LUN
  
  tile_size= 100D
  tile_size= tile_size*mlook_a
  master_ss= READ_PARAMS(master+'.par', 'samples')
  master_ls= READ_PARAMS(master+'.par', 'lines')
  IF (master_ss MOD tile_size) THEN BEGIN
    tile_l= FLOOR(master_ls/tile_size)
  ENDIF ELSE BEGIN
    tile_l= FLOOR(master_ls/tile_size)-1
  ENDELSE
  
  lines=0
  FOR k= 0, tile_l DO BEGIN
  PRINT, k,'  /',tile_l
    end_y= ((tile_size*(k+1)+mlook_a) GT master_ls)? (master_ls-1): (tile_size*(k+1)+mlook_a-1)
    start_y= k*tile_size
    masterSLC= SUBSETSLC(master, 0, master_ss, start_y, end_y-start_y)
    slaveSLC= SUBSETSLC(slave, 0, master_ss, start_y, end_y-start_y)
    
    ii= FLOOR(master_ss/mlook_r)-1
    jj= FLOOR(end_y-start_y)/mlook_a-1
    inter= COMPLEXARR(ii+1,jj+1)
    phase= FLTARR(ii+1,jj+1)
    cc= FLTARR(ii+1,jj+1)
    FOR i= 0, ii DO BEGIN
      FOR j=0, jj DO BEGIN
;      IF i EQ 500 AND j EQ 80 THEN STOP
        large_sub= masterSLC(i*mlook_r:((i+1)*mlook_r-1), j*mlook_a:((j+1)*mlook_a-1))
        small= slaveSLC(i*mlook_r:((i+1)*mlook_r-1), j*mlook_a:((j+1)*mlook_a-1))
        numerator= large_sub* CONJ(small);;;;
        inter(i,j)= MEAN(numerator)
        phase(i,j)= ATAN(inter(i,j),/PHASE)
        numerator= ABS(TOTAL(numerator));;;;
        denomilator= (TOTAL(ABS(large_sub)^2)*TOTAL(ABS(small)^2))^0.5
        cc(i,j)= numerator/denomilator

      ENDFOR
    ENDFOR
    WRITEU, luni, inter
    WRITEU, lunp, phase
    WRITEU, lunc, cc
    lines=lines+jj
    PRINT, ii, jj
  ENDFOR
  FREE_LUN, luni
  FREE_LUN, lunp
  FREE_LUN, lunc
  PRINT, 'range_samples:  ', master_ss
  PRINT, 'azimuth_lines:  ', lines
  
END