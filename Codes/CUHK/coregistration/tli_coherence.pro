;+
; Name:
;   TLI_COHERENCE
; Purpose:
;    Calculate coherence if no multi_look is applyed.
; Calling Sequence:
;    result= TLI_COHERENCE(master, slave, master_ss, master_ls, win_r=win_r, win_azi=win_azi, $
;                          c_outpath=c_outpath, c_outname=c_outname)
; Inputs:
;    master        :  Master SLC.
;    slave         :  Slave SLC.
;    master_ss     :  Master samples.
;    master_ls     :  Master lines.
; Keyword Input Parameters:
;    win_r         :  Range window to calculate cc
;    win_azi       :  Azimuth window to calculate cc
;    c_outpath     :  Output file path for coherence
;    c_outname     :  Output file name for coherence
; Outputs:
;    Coherence file for cc. Same size as master file.
; Commendations:
;    c_outpath     :  Specify the work space to mantain the result files.
;    c_outname     :  Master-slave.cc
; Example:
;    master= 'D:\ISEIS\Data\Img\ASAR-20070726.img'
;    slave= 'D:\ISEIS\Data\Img\ASAR-20090205.img.registered.slc'
;    master_ss= 5195
;    master_ls= 27313
;    win_r=5
;    win_azi=25
;    result= TLI_COHRENCE(master, slave, master_ss, master_ls, win_r=win_r, win_azi=win_azi,$
;                        c_outpath=c_outpath,c_outname=c_outname)
; Modification History:
;    29/03/2012    :  Written by T.Li @ InSAR Team in SWJTU & CUHK.
;-
;PRO TLI_COHERENCE, master, slave, master_ss, master_ls, win_r=win_r, win_azi=win_azi, mask=mask
FUNCTION TLI_COHERENCE, master, slave, master_ss, master_ls, win_r=win_r, win_azi=win_azi,$
                        c_outpath=c_outpath,c_outname=c_outname

  COMPILE_OPT idl2

  t_start= SYSTIME(1)

  IF ~KEYWORD_SET(win_r) THEN BEGIN
    win_r=5
  ENDIF
  IF ~KEYWORD_SET(win_azi) THEN BEGIN
    win_azi= win_r*LONG(master_ls/master_ss)
  ENDIF

  IF win_azi LE 1 OR win_r LE 1 THEN Message, 'Window to calculate the cc can not be less than 2'

  IF ~KEYWORD_SET(c_outpath) THEN BEGIN
    c_outpath= FILE_DIRNAME(master)
  ENDIF
  IF ~KEYWORD_SET(c_outname) THEN BEGIN
    c_outname= FILE_BASENAME(master, '.img')+'-'+FILE_BASENAME(slave, '.img')+'.cc'
  ENDIF
  c_outfile= c_outpath + c_outname
  ;-------------------Start calculation---------------
  CLOSE,/ALL

  IF FILE_TEST(c_outfile) THEN FILE_DELETE, c_outfile

  OPENW, lunc, c_outfile,/GET_LUN

  tile_size= 1000D; Block size.

  IF (master_ss MOD tile_size) THEN BEGIN
    tile_l= FLOOR(master_ls/tile_size)
  ENDIF ELSE BEGIN
    tile_l= FLOOR(master_ls/tile_size)-1
  ENDELSE

  lines=0
  samples=0
  FOR k= 0, tile_l DO BEGIN;;;;;;;;;;;;;;;;;;;;;;;k=0, tile_l
    PRINT, k,'  /',tile_l
    ii_temp= FLOOR(win_r/2)
    jj_temp= FLOOR(win_azi/2)

    end_y= ((tile_size*(k+1)) GT master_ls)? (master_ls-1): (tile_size*(k+1)-1)
    IF k EQ 0 THEN BEGIN
      start_y= k*tile_size
    ENDIF ELSE BEGIN
      IF k LE tile_l THEN BEGIN
        start_y= k*tile_size-2*jj_temp
      ENDIF
    ENDELSE

    masterSLC= SUBSETSLC(master, 0, master_ss, start_y, end_y-start_y+1, filens= master_ss, filenl= master_ls)
    slaveSLC= SUBSETSLC(slave, 0, master_ss, start_y, end_y-start_y+1,filens= master_ss, filenl= master_ls)


    cc= FLTARR(SIZE(masterSLC,/DIMENSIONS))

    sz= SIZE(masterSLC,/DIMENSIONS)
    FOR i= ii_temp, master_ss-ii_temp-1 DO BEGIN
      FOR j= jj_temp, sz[1]-jj_temp-1 DO BEGIN
        large_sub= masterSLC[(i-ii_temp):(i+ii_temp), (j-jj_temp):(j+jj_temp)]
        small= slaveSLC[(i-ii_temp):(i+ii_temp), (j-jj_temp):(j+jj_temp)]
        numerator= large_sub* CONJ(small);;;;
        numerator= ABS(TOTAL(numerator));;;;
        denomilator= (TOTAL(ABS(large_sub)^2)*TOTAL(ABS(small)^2))^0.5
        cc[i,j]= numerator/denomilator
      ENDFOR
    ENDFOR

    IF k EQ 0 THEN BEGIN
      cc=cc[*, 0: sz[1]-jj_temp-1]
    ENDIF ELSE BEGIN
      IF k LT tile_l THEN BEGIN
        cc=cc[*, jj_temp: sz[1]-jj_temp-1]
      ENDIF ELSE BEGIN
        cc=cc[*, jj_temp: *]
      ENDELSE
    ENDELSE
    lines= lines+(SIZE(cc,/DIMENSIONS))[1]

;    cc[*, 0:jj_temp-1]=REBIN(cc[*, jj_temp], sz[0], jj_temp)
;    cc[*, sz[1]-jj_temp:*]=REBIN(cc[*,  sz[1]-jj_temp-1], sz[0], jj_temp)
;    cc[0:ii_temp-1, *]=REBIN(cc[ii_temp, *], ii_temp,sz[1])
;    cc[sz[0]-ii_temp:*, *]=REBIN(cc[sz[0]- ii_temp-1, *], ii_temp, sz[1])
    WRITEU, lunc, cc
    IF k EQ 2 THEN TVSCL, cc,/NAN

  ENDFOR
  PRINT, 'range_samples:  ', master_ss
  PRINT, 'azimuth_lines:  ', lines
  FREE_LUN, lunc
  t_end= SYSTIME(1)
  PRINT, 'Time cost:', t_end-t_start
;  IF win_r MOD 2 THEN BEGIN
;    length_r=win_r
;  ENDIF ELSE BEGIN
;    length_r= win_r+1
;  ENDELSE
;  IF win_azi MOD 2 THEN BEGIN
;    length_azi=win_azi
;  ENDIF ELSE BEGIN
;    length_azi= win_azi+1
;  ENDELSE
;  OPENW, lun, c_outfile,/GET_LUN
;  FOR i=0, master_ss-1 DO BEGIN
;  PRINT, i , 'OF', master_ss
;    FOR j=0, master_ls-1 DO BEGIN
;      master_subset= SUBSETSLC(master, i-FLOOR(win_r/2), length_r, j-FLOOR(win_azi/2), length_azi, filens= master_ss, filenl= master_ls)
;      slave_subset= SUBSETSLC(slave, i-FLOOR(win_r/2), length_r, j-FLOOR(win_azi/2), length_azi,filens= master_ss, filenl= master_ls)
;      numerator= master_subset* CONJ(slave_subset)
;      numerator= ABS(TOTAL(numerator))
;      denomilator= (TOTAL(ABS(master_subset)^2)*TOTAL(ABS(slave_subset)^2))^0.5
;      cc= numerator/denomilator
;      WRITEU, lun, cc
;    ENDFOR
;  ENDFOR
;  FREE_LUN, lun
  RETURN, 1

END

