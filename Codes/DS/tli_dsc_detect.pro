;
; Detect DS using KS test method.
; And provide the filtered image.
;
PRO TLI_DSC_DETECT,imlistfile, dspath=dspath, win_r=win_r, win_azi=win_azi, nshp_thresh=nshp_thresh, $
  logfile=logfile, dslkupfile=dslkupfile, dsmaskfile=dsmaskfile, start_sectionfile=start_sectionfile, $
  end_sectionfile=end_sectionfile, dslistfile=dslistfile
  
  workpath=FILE_DIRNAME(imlistfile)+PATH_SEP()
  IF NOT KEYWORD_SET(dspath) THEN dspath=workpath+'DS/'
  IF NOT KEYWORD_SET(logfile) THEN logfile=dspath+'log.txt'
  IF NOT KEYWORD_SET(dslkupfile) THEN dslkupfile=dspath+'dsc.lookup'
  IF NOT KEYWORD_SET(dsmaskfile) THEN dsmaskfile=dspath+'dsc.mask'
  IF NOT KEYWORD_SET(start_sectionfile) THEN start_sectionfile=dspath+'start_section'
  IF NOT KEYWORD_SET(end_sectionfile) THEN end_sectionfile=dspath+'end_section'
  IF NOT KEYWORD_SET(dslistfile) THEN dslistfile=dspath+'dsclist'
  
  IF NOT KEYWORD_SET(win_r) THEN win_r=15        ; Window size in range direction
  IF NOT KEYWORD_SET(win_azi) THEN win_azi=15      ; Window size in azimuth direction
  IF NOT KEYWORD_SET(nshp_thresh) THEN nshp_thresh=20   ; Number of SHPs to accept/reject a DS, 20 was suggested by Ferretti.
  
  TLI_LOG, logfile, 'Detecting DS. Task started at:'+TLI_TIME(/str)
  
  IF NOT FILE_TEST(dspath,/directory) THEN FILE_MKDIR, dspath
  nfiles=FILE_LINES(imlistfile)
  imlist=STRARR(1, nfiles)
  OPENR, lun, imlistfile,/GET_LUN
  READF, lun, imlist
  FREE_LUN, lun
  TLI_LOG, logfile, 'No of images:'+STRCOMPRESS(nfiles),/PRT
  finfo=TLI_LOAD_SLC_PAR(imlist[0]+'.par')
  ; Read the images
  images=FLTARR(finfo.range_samples, finfo.azimuth_lines, nfiles)
  FOR i=0, nfiles-1 DO BEGIN
    images[*, *, i]=TLI_READDATA(imlist[i], format='float', samples=finfo.range_samples, /swap_endian)
  ENDFOR
  
  prob_thresh=0.05   ; Confidential level.
  half_winr=FLOOR(win_r/2)
  half_winazi=FLOOR(win_azi/2)
  start_r=half_winr       & end_r=finfo.range_samples-1-half_winr     & start_r=double(start_r) & end_r=double(end_r)
  start_azi=half_winazi   & end_azi=finfo.azimuth_lines-1-half_winazi & start_azi=double(start_azi) & end_azi=double(end_azi)
  ds_mask=BYTARR(finfo.range_samples, finfo.azimuth_lines)        ; Mask of DS.
  start_section=DBLARR(finfo.range_samples, finfo.azimuth_lines)  ; Section of the lookup file - start position
  end_section=DBLARR(finfo.range_samples, finfo.azimuth_lines)    ; Section of the lookup file - end position
  start_pos=0D  ; Start pos of the specified DS.
  end_pos=0D    ; End pos of the specified DS.
  
  ; For loops.
  OPENW, lun, dslkupfile,/GET_LUN  ; Ready to write the ds lookup file.
  FOR i=start_r, end_r DO BEGIN
    Print, i, '/', end_r
    Print, TLI_TIME(/str)
    FOR j=start_azi, end_azi DO BEGIN
    
      pwr_ij=images[i,j, *]  ; pwr of this point
      pwr_ij=REFORM(pwr_ij, nfiles)
      
      nshp=0D  ; Number of shp
      xcoors_shp=-1  ; X coordinates of SHP
      ycoors_shp=-1  ; Y coordinates of SHP
      
      FOR m=i-half_winr, i+half_winr DO BEGIN  ; Adj. points
        FOR n=j-half_winazi, j+half_winazi DO BEGIN
          pwr_mn=images[m,n, *]
          pwr_mn=REFORM(pwr_mn, nfiles)
          ; KS test
          stats=IMSL_KOLMOGOROV2(pwr_ij, pwr_mn)
          
          ; one sided prob
          IF stats[1] GE prob_thresh THEN BEGIN  ; They are a pair of SHP.
            nshp=nshp+1
            xcoors_shp=[xcoors_shp, m]
            ycoors_shp=[ycoors_shp, n]
          ENDIF
          
        ENDFOR
      ENDFOR
      ; Process the information.
      IF nshp GE nshp_thresh THEN BEGIN  ; This is a DS
      
        ; update the ds_mask file
        ds_mask[i,j]=1
        
        ; update the start_section
        start_section[i,j]=start_pos
        ; update the end_section
        end_pos=start_pos+nshp-1D
        end_section[i,j]=end_pos
        ; Write the coordinates of SHPs.
        xcoors_shp=xcoors_shp[1:*]
        ycoors_shp=ycoors_shp[1:*]
        WriteU, lun, COMPLEX(xcoors_shp, ycoors_shp)
        
        ; Update the params
        start_pos=start_pos+nshp
      ENDIF
      
    ENDFOR
  ENDFOR
  FREE_LUN, lun
  
  ds_ind=WHERE(ds_mask EQ 1)
  ds_coors=ARRAY_INDICES(ds_mask, ds_ind)
  dslist=COMPLEX(ds_coors[0,*], ds_coors[1,*])
  
  ; Write the DS mask, start_section and end_section files.
  TLI_WRITE, dsmaskfile, ds_mask
  TLI_WRITE, start_sectionfile, start_section
  TLI_WRITE, end_sectionfile, end_section
  TLI_WRITE, dslistfile, dslist
  
  ; Log
  TLI_LOG, logfile, 'DS detection, task ended at:'+TLI_TIME(/str),/prt
  
  
END