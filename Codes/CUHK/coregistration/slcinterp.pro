;+
; Purpose:
;    Do interpolation after fine-coreg
; Calling Sequence:
;    resutl= SLCINTERP(f_offset, master, slave, outfile= outfile, /sinc,tile_size=tile_size)
; Inputs:
;    f_offset    : Result of fine coregistraion
;    master      : Path of master SLC
;    slave       : Path of slave SLC
;    outfile     : Path of output file
; Optional Input Parameters:
;   None
; Keyword Input Parameters:
;    sinc        : Set this keyword to do interpolation using sinc function.Not suggested.
;    tile_size   : Lines of segment.
; Outputs:
;    Final co-registered slave SLC. And its parameters.
; Commendations:
;    /sinc       : Better not to do sinc interpolation, it's too slowly.
;    tile_size   : 3000. Can be set according to user's computer memory.
; Example:
;      master= 'D:\ForExperiment\TSX_TJ_Coreg_Sub1000_Off110-57\20090327.rslc'
;      slave= 'D:\ForExperiment\TSX_TJ_Coreg_Sub1000_Off110-57\20090407.rslc'
;      f_offset= 'D:\ForExperiment\TSX_TJ_Coreg_Sub1000_Off110-57\20090327-20090407.foff'
;      result= SLCINTERP(f_offset, master, slave, outfile= outfile,tile_size=tile_size)
; Modification History:
;     17/02/2012: Written by T. Li @ InSAR Team in SWJTU & CUHK
;     24/02/2012: Modified by T. Li @ InSAR Team in SWJTU & CUHK
FUNCTION SLCINTERP, f_offset, master, slave, outfile= outfile, sinc=sinc,tile_size=tile_size, $
                          mns=MNS, mnl=MNL, $
                          sns=SNS, snl=SNL, offs=offs

  IF ~KEYWORD_SET(outfile) THEN BEGIN
    outfile= FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(slave, '.slc')+'.registered.img'
  ENDIF
  IF ~KEYWORD_SET(tile_size) THEN BEGIN
    tile_size=1000D
  ENDIF

  result= DBLARR(6,2)
  OPENR, lun, f_offset,/GET_LUN
  READU, lun, result
  FREE_LUN, lun
;  result= f_offset
;  master_ss= READ_PARAMS(master+'.par', 'range_samples')
;  master_ls= READ_PARAMS(master+'.par', 'azimuth_lines')
;  slave_ss= READ_PARAMS(slave+'.par', 'range_samples')
;  slave_ls= READ_PARAMS(slave+'.par', 'azimuth_lines')
  master_ss = MNS ;READ_PARAMS(master_h, 'range_samples')-1
  master_ls = MNL ; READ_PARAMS(master_h, 'azimuth_lines')-1
  slave_ss = SNS ; READ_PARAMS(slave_h, 'range_samples')-1
  slave_ls= SNL ;READ_PARAMS(slave_h, 'azimuth_lines')-1
  outNs = MNS
  outNl = MNL

  ;-----------Calculate coordinates to be interpolated-------------
;  coor_o= INDEXARR(x=FINDGEN(master_ss), y= FINDGEN(master_ls))
;  coor= COORMTOS(result, coor_o)
;  slaveSLC= OPENSLC(slave)
  IF slave_ls LE tile_size THEN tile_size= slave_ls
  IF slave_ls MOD tile_size THEN BEGIN
    tile_l= FLOOR(slave_ls/tile_size)
  ENDIF ELSE BEGIN
    tile_l= FLOOR(slave_ls/tile_size)-1
  ENDELSE
  IF FILE_TEST(outfile) THEN FILE_DELETE, outfile
  OPENW, lun,outfile,/GET_LUN ; ,/SWAP_ENDIAN;-------------Ready to write the file------------------
  outNl = 0L
  FOR i= 0, tile_l DO BEGIN
;  	if i eq 26 then begin
;		help, 'a'
;	endif

    end_y= ((tile_size*(i+1)) GT master_ls)? master_ls: tile_size*(i+1)
    coor_o= INDEXARR(x=FINDGEN(master_ss),y=i*tile_size+FINDGEN(end_y-tile_size*i))
    coor= COORMTOS(result,coor_o,offs=offs)
    start_x= FLOOR(MIN(REAL_PART(coor)))
    end_x= CEIL(MAX(REAL_PART(coor)))
    start_y= FLOOR(MIN(IMAGINARY(coor)))
    if start_y ge (SNL-1) then begin
    	; 如果Y方向超限, 填NAN
    	_lines = MNL - outNl
    	slave_interp = COMPLEXARR(outNs, _lines)
    	slave_interp[*, *] = Complex(!VALUES.F_NAN, !VALUES.F_NAN)
    	outNl = outNl + (SIZE(slave_interp,/DIMENSIONS))[1];*******************************************************************
    	WRITEU, lun, slave_interp;----------------------------write SLC--------------------
    	BREAK
    endif else begin
	    end_y= CEIL(MAX(IMAGINARY(coor)))
	    _lines = (end_y-start_y+1)
	    slaveSLC= SUBSETSLC(slave,start_x, end_x-start_x+1, start_y, _lines, $
	  							fileNs=SNS, fileNl=SNL)
		index= WHERE((REAL_PART(coor) LT 0) OR (REAL_PART(coor) GT slave_ss) OR (IMAGINARY(coor) LT 0) OR (IMAGINARY(coor) GT slave_ls));********************

	    coor= coor-COMPLEX(start_x, start_y)
	    IF KEYWORD_SET(sinc) THEN BEGIN
	      slave_interp= SLCINTERP_SINC(slaveSLC, REAL_PART(coor), IMAGINARY(coor))
	    ENDIF ELSE BEGIN

	      slave_interp= INTERPOLATE(slaveSLC, REAL_PART(coor), IMAGINARY(coor))
	    ENDELSE

		IF index(0) NE -1 THEN slave_interp(index) = COMPLEX(!VALUES.F_NAN,!VALUES.F_NAN)
;	    index= WHERE((REAL_PART(coor) LT 0) OR (REAL_PART(coor) GT slave_ss) OR (IMAGINARY(coor) LT 0) OR (IMAGINARY(coor) GT slave_ls))
;	    IF index(0) NE -1 THEN slave_interp(index) = COMPLEX(!VALUES.F_NAN,!VALUES.F_NAN)
	;    IF index(0) NE -1 THEN slave_interp(index) = COMPLEX(!VALUES.F_INFINITY,!VALUES.F_INFINITY)
	;    IF index(0) NE -1 THEN slave_interp(index) = COMPLEX(0, 0)
		;--------Write SLC-----------
	    outNl = outNl + (SIZE(slave_interp,/DIMENSIONS))[1];*******************************************************************
	    WRITEU, lun, slave_interp;----------------------------write SLC--------------------
	endelse
    PRINT, i, '    / ', tile_l
  ENDFOR
  FREE_LUN, lun;------------------------free lun-------------------
  PRINT, 'file written successfully! Follows are some params to be adjusted.'
  WAIT, 1
  ;
  ; 执行slave数据头文件迁移, 仅迁移CUHK RS COMM以下的部分。常规部分自定义。
;  slavehdr = Fw_RemovePostfix(slave) + '.hdr'
;  HH_SetupCU_Head, fname=outfile, $
;                        bnames='RSLC', $
;                        ns=outNs, $
;                        nl=Long(outNl), $
;                        nb=1, $
;                        sensor_type = 'Unknown', $
;	                    data_type=Size(slave_interp[0], /type), $ ; Float
;	                    file_type='Envi Standard', $
;	                    prod_type='norm', $ ; registerd slc data,  是常规数据
;                        interleave='bsq', $ ; BSQ BIL BIP
;                        offset=0, $
;                        appendMeta=1, $ ; 执行头文件迁移
;                        metaFile=slavehdr, $ ; 头文件为slave数据的头文件
;                        /write

 ; 执行完头文件迁移后，如果部分参数与原来不一致，需要更新部分参数。
;  HH_UpdateCU_Head, outfile, $
;                      center_time=center_time, $
;                      center_range=center_range, $
;                      top_left_time=top_left_time, $
;                      top_left_range=top_left_range, $
;                      top_right_time=top_right_time, $
;                      top_right_range=top_right_range, $
;                      bottom_left_time=bottom_left_time, $
;                      bottom_left_range=bottom_left_range, $
;                      bottom_right_time=bottom_right_time, $
;                      bottom_right_range=bottom_right_range, $
;                      doppler_polynomial_range_0=doppler_polynomial_range_0


  ;-------------Ajust the Params--------------
  ;Find min coor and max coor
;  outfile_par= outfile+'.par'
;  OPENW, lun, outfile_par,/GET_LUN
;  PRINTF, lun, outfile_par
;  STOP


;  coor = COMPLEX([0,0,master_ss-1, master_ss-1],[0,master_ls-1,0,master_ls-1])
;  coor= COORMTOS(result, coor)
;  min_s= MIN(REAL_PART(coor))
;  max_s= MAX(REAL_PART(coor))
;  min_l= MIN(IMAGINARY(coor))
;  max_l= MAX(IMAGINARY(coor))
;
;  slave_par= slave+'.par'
;  master_par= master+'.par'
;
;  start_time= READ_PARAMS(slave_par, 'start_time')
;  azimuth_line_time= READ_PARAMS(slave_par, 'azimuth_line_time')
;  start_time_s= start_time+ azimuth_line_time*min_l
;  PRINT, 'start_time',start_time_s
;
;  end_time_s= start_time + max_l*azimuth_line_time
;  center_time_s= (start_time_s+end_time_s)/2
;  PRINT, 'center_time', center_time_s
;
;  PRINT, 'end_time', end_time_s
;
;  range_samples_s= READ_PARAMS(master_par, 'samples')
;  PRINT, 'range_samples', range_samples_s
;;  PRINTF, lun, 'range_samples:   '+STRING(range_samples_s)
;
;  azimuth_lines_s= READ_PARAMS(master_par, 'lines')
;  PRINT, 'azimuth_lines', azimuth_lines_s
;;  PRINTF, lun, 'azimuth_lines:   '+STRING(azimuth_lines_s)
;;  PRINTF, lun, 'image_format:   '+'FCOMPLEX'
;
;  center_latitude= READ_PARAMS(slave_par, 'center_latitude')
;  center_longitude= READ_PARAMS(slave_par, 'center_longitude')
;  s_rspace= READ_PARAMS(slave_par, 'range_pixel_spacing')
;  s_aspace= READ_PARAMS(slave_par, 'azimuth_pixel_spacing')
;  s_earthr= READ_PARAMS(slave_par, 'earth_radius_below_sensor')
;  pixel_lon= s_aspace/(s_earthr)*180D/!PI
;  pixel_lat= s_rspace/(s_earthr*COS(center_latitude*!PI/180D))*180D/!PI
;  center_latitude_s= center_latitude+ pixel_lat*min_l
;  PRINT, 'center_latitude', center_latitude_s
;
;  center_longitude_s= center_longitude+ pixel_lon* min_s
;  PRINT, 'center_longitude', center_longitude_s
;
;  near_range_slc= READ_PARAMS(slave_par, 'near_range_slc')
;  far_range_slc= READ_PARAMS(slave_par, 'far_range_slc')
;  dr= (far_range_slc-near_range_slc)/slave_ss
;  near_range_slc_s= near_range_slc + dr*min_s
;  PRINT, 'near_range_slc', near_range_slc_s
;
;  far_range_slc_s= near_range_slc_s+ dr*max_s
;  center_range_slc_s= (near_range_slc_s+far_range_slc_s)/2
;  PRINT, 'center_range_slc', center_range_slc_s
;
;  PRINT, 'far_range_slc', far_range_slc_s

  RETURN, 1

END