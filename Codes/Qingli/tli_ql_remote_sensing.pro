;
; Script that:
;   Extract data from the input roi file.
;
; Written by:
;   T.LI @ SWJTU, 20140603
;
; Written for:
;   Qingli Luo @ Tianjin Univ.
;
@tli_read_envi_rois
PRO TLI_QL_REMOTE_SENSING

    workpath='D:\myfiles\参与事项\审稿\RemoteSensing-Qingli\'
;  workpath='/mnt/software/myfiles/参与事项/审稿/RemoteSensing-Qingli/'
  inputfile=workpath+'GPS-b.roi.txt'
  itabfile=workpath+'itab'
  sarlistfile=workpath+'SLC_tab'
  
  ;-----------------------------------------------------
  ; Read ROIS
  roi_stru=TLI_READ_ENVI_ROIS(inputfile)
  
  ;-----------------------------------------------------
  ; Read baselines
  t_base=TBASE_ALL(sarlistfile, itabfile)
  t_base=t_base*365D
  ;-----------------------------------------------------
  ; Linear stretch.
  
  GPS='b'
  Case GPS OF
    'a': BEGIN
    
      OPENW, lun, inputfile+'.txt',/GET_LUN
      
      ; Y-values: (Deformation values)
      ;  39 - -40
      ;  107 - -50
      ;  174 - -60
      ;  242 - -70
      ;  310 - -80
      ;  377 - -90
      
      ; X-values:
      ;  129 - tbase[0]
      ;  603 - tbase[nintf-1]
      
      ; Stretch axis
      nintf=FILE_LINES(itabfile)
      
      roi0=roi_stru.roi0
      roi0.y=-40D +(-90D -(-40D))/(377D -39D) * (roi0.y-39D)
      roi0.x=t_base[0]+(t_base[nintf-1]-t_base[0])/(603D -129D ) * (roi0.x-129D)
      PRINTF, lun, 'Grid data'
      PRINTF, lun, [roi0.x, roi0.y]
      
      roi1=roi_stru.roi1
      roi1.y=-40D +(-90D -(-40D))/(377D -39D) * (roi1.y-39D)
      roi1.x=t_base[0]+(t_base[nintf-1]-t_base[0])/(603D - 129D ) * (roi1.x-129D)
      PrintF, lun, 'PS Time Series'
      PrintF, lun, [roi1.x, roi1.y]
      
      roi2=roi_stru.roi2
      roi2.y=-40D +(-90D -(-40D))/(377D -39D) * (roi2.y-39D)
      roi2.x=t_base[0]+(t_base[nintf-1]-t_base[0])/(603D -129D ) * (roi2.x-129D)
      PrintF, lun, 'Fitted GPS'
      PrintF, lun, [roi2.x, roi2.y]
      
      ; Report some quality assessments.
      x=roi2.x
      y=roi2.y
      
      GPS_v=(y[1]-y[0])/(x[1]-x[0])
      GPS_v=GPS_v*365D
      ps_v=REGRESS(TRANSPOSE(roi1.x), TRANSPOSE(roi1.y))
      ps_v=ps_v*365D
      
      PrintF, lun, 'GPS deformation velocity:'+STRCOMPRESS(GPS_v)
      PrintF, lun, 'PS deformation velocity:'+STRCOMPRESS(ps_v)


      GPS_interp=(y[1]-y[0])/(x[1]-x[0])*(roi1.x-x[0])+y[0]
      ps=roi1.y
      
      corr=CORRELATE(ps, GPS_interp)
      RMSE=SQRT(MEAN((GPS_interp-ps)^2))
      
      PRINTF, lun, ''
      PrintF, lun, 'The correlation between two kinds of measurements:'+STRCOMPRESS(corr)
      PrintF, lun, 'The corresponding RMSE is:'+STRCOMPRESS(RMSE)
      
      FREE_LUN, lun
    END
    
    'b': BEGIN
      OPENW, lun, inputfile+'.txt',/GET_LUN
      
      ; Y-values: (Deformation values)
      ;  22 - -50
      ;  6 - -55
      ;  389 - -95
      
      ; X-values:
      ;  121 - tbase[0]
      ;  583 - tbase[nintf-1]
      
      ; Stretch axis
      nintf=FILE_LINES(itabfile)
      
      roi0=roi_stru.roi0
      roi0.y=-50D +(-95D -(-50D))/(389D -22D) * (roi0.y-22D)
      roi0.x=t_base[0]+(t_base[nintf-1]-t_base[0])/(583D -121D ) * (roi0.x-121D)
      PRINTF, lun, 'Grid data'
      PRINTF, lun, [roi0.x, roi0.y]
      
      roi1=roi_stru.roi1
      roi1.y=-50D +(-95D -(-50D))/(389D -22D) * (roi1.y-22D)
      roi1.x=t_base[0]+(t_base[nintf-1]-t_base[0])/(583D -121D ) * (roi1.x-121D)
      PrintF, lun, 'PS Time Series'
      PrintF, lun, [roi1.x, roi1.y]
      
      roi2=roi_stru.roi2
      roi2.y=-50D +(-95D -(-50D))/(389D -22D) * (roi2.y-22D)
      roi2.x=t_base[0]+(t_base[nintf-1]-t_base[0])/(583D -121D ) * (roi2.x-121D)
      PrintF, lun, 'Fitted GPS'
      PrintF, lun, [roi2.x, roi2.y]
      
      
      ; Report some quality assessments.
      x=roi2.x
      y=roi2.y
      
      
      GPS_v=(y[1]-y[0])/(x[1]-x[0])
      GPS_v=GPS_v*365D
      ps_v=REGRESS(TRANSPOSE(roi1.x), TRANSPOSE(roi1.y))
      ps_v=ps_v*365D
      
      PrintF, lun, 'GPS deformation velocity:'+STRCOMPRESS(GPS_v)
      PrintF, lun, 'PS deformation velocity:'+STRCOMPRESS(ps_v)
      
      
      GPS_interp=(y[1]-y[0])/(x[1]-x[0])*(roi1.x-x[0])+y[0]
      ps=roi1.y
      
      corr=CORRELATE(ps, GPS_interp)
      RMSE=SQRT(MEAN((GPS_interp-ps)^2))
      
      PRINTF, lun, ''
      PrintF, lun, 'The correlation between two kinds of measurements:'+STRCOMPRESS(corr)
      PrintF, lun, 'The corresponding RMSE is:'+STRCOMPRESS(RMSE)
      
      
      
      FREE_LUN, lun
    END
  ENDCASE
  STOP
  
END