; Plot all the figures in Baoshan District, Shanghai.
;
; Written by T.LI @ ISEIS

@tli_readtxt
@tli_linear_solve_cuhk
@tli_vacuate
FUNCTION TLI_METRO_LINE_INFO, inputfile
  ; Extract the metro information by reading the inputfile.
  ; There should be 2 lines in the inputfile, they are something like:
  ;      Station name: lat lon
  ; I use ':' as the separator. So there should be such a character in each line.
  ;
  ; Return value:
  ;   mlinfo.station, mlinfo.lon, mlinfo.lat
  nstations=FILE_LINES(inputfile)
  ml=STRARR(1, nstations)
  
  OPENR, lun, inputfile,/GET_LUN
  READF, lun, ml
  FREE_LUN, lun
  
  ; Extract values
  ml=TLI_STRSPLIT(ml,pattern=':')
  sz=SIZE(ml,/DIMENSIONS)
  nstations=sz[1]
  sz=SIZE(ml,/DIMENSIONS)
  IF sz[0] NE 2 THEN Message, 'Format Error: Please use ":" to separate the station name and the lat&lon.'+$
    STRING(13b)+inputfile
    
  names=ml[0,*]
  lat_lon=ml[1,*]
  lat_lon=TLI_STRSPLIT(lat_lon)
  lon=lat_lon[0,*]
  lat=lat_lon[1,*]
  i=0
  mlinfo=CREATE_STRUCT('names', names[i], 'lon', DOUBLE(lon[i]), 'lat', DOUBLE(lat[i]))
  FOR i=0, nstations-1 DO BEGIN
    temp=CREATE_STRUCT('names', names[i], 'lon', DOUBLE(lon[i]), 'lat', DOUBLE(lat[i]))
    mlinfo=[[mlinfo], [temp]]
  ENDFOR
  mlinfo=mlinfo[1:*]
  
  ;  mlinfo=REPLICATE(create_struct('names',' ', 'lon', 0D, 'lat',0D ), nstations)
  ;  mlinfo.station=stations
  ;  mlinfo.lon=lon
  ;  mlinfo.lat=lat
  RETURN, mlinfo
END















PRO TLI_hpa_sh_plot_all_figures

  ; Information of Shanghai Metro Lines 1 & 3 within the Baoshan District.

  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_SH_3/'
  hpapath=workpath+'HPA/'
  resultpath=hpapath+'figures/'
  geocodepath=workpath+'geocode/'
  IF 0 THEN BEGIN
    ; Files
    ml1file=resultpath+'Metro_Line1_Stations.txt'
    ml3file=resultpath+'Metro_Line3_Stations.txt'
    ml1outfile=FILE_BASENAME(ml1file, '.txt')+'_info.txt'
    ml3outfile=FILE_BASENAME(ml3file, '.txt')+'_info.txt'
    
    plistfile=hpapath+'lel8plist_update_merge'
    llfile=geocodepath+'lel8plist_update_merge.ll'
    vdhfile=hpapath+'lel8vdh_merge'; Maybe the final vdh file will provide a robust result.
    itabfile=hpapath+'itab'
    sarlistfile=hpapath+'sarlist'
    mparfile=TLI_GAMMA_INT(sarlistfile, itabfile,/onlymaster,/uniq)+'.par'
    finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
    shfile=resultpath+'plot_metro_stations.sh'
    
    ; Read the data
    ml1info=TLI_METRO_LINE_INFO(ml1file)
    ml3info=TLI_METRO_LINE_INFO(ml3file)
    
    
    ; Find the coordinates of the metro stations
    
    vdh=TLI_READMYFILES(vdhfile, type='vdh')
    sz=SIZE(vdh,/DIMENSIONS)
    IF N_ELEMENTS(ll) NE sz[1] THEN Message, 'Error: The file sizes are not consistent.'$
      +STRING(13B)+'File 1:'+llfile $
      +STRING(13B)+'File 2:'+vdhfile
      
    ; Output the coordinates infomation.
    ml_ll=TRANSPOSE(ml_ll)
    TLI_WRITE,resultpath+'ml_ll.txt',[REAL_PART(ml_ll), IMAGINARY(ml_ll)],/txt
    TLI_GAMMA_GEO2PT, resultpath+'ml_ll.txt', mparfile,outputfile=resultpath+'ml_coord.txt'
    
    ml_coord=TLI_READTXT(resultpath+'ml_coord.txt',/easy)
    ml_coord=[finfo.range_samples-ml_coord[0,*], finfo.azimuth_lines-ml_coord[1, *]]
    
    TLI_WRITE, resultpath+'ml1_coor.txt', ml_coord[*, 0:ml1_nstations-1],/txt
    TLI_WRITE, resultpath+'ml3_coor.txt', ml_coord[*, ml1_nstations: *],/txt
    names=TRANSPOSE([ml1info.names, ml3info.names])
    result=[names, STRCOMPRESS(ml_coord)]
    ;  TLI_WRITE, resultpath+'ml_name_coor.txt', result,/txt
    ;  TLI_WRITE, resultpath+'ml_coor.txt', ml_coord,/txt
    
    ; Output the annotation
    TLI_WRITE, resultpath+'ml_anno_lel8', names,/txt
    TLI_FIX_TXT, resultpath+'ml_anno_lel8', prefix=(STRCOMPRESS(ml_coord[0,*]-100)+STRCOMPRESS(ml_coord[1,*])+' 7 0 5 RM ')
    
    ; Plot the stations
    CD, current=currpath
    CD, resultpath
    SPAWN, shfile
    CD, currpath
  ENDIF
  
  IF 0 THEN BEGIN
    ; Vacuate the points in order to maintain a sparse point list.
    TLI_VACUATE, vdhfile, type='vdh',outputfile=vdhfile+'_vacuate',finalnpt=10000
    vdh_vac=TLI_READMYFILES(vdhfile+'_vacuate',type='vdh')
    result=vdh_vac[1:3, *]
    TLI_WRITE, vdhfile+'_vacuate.txt',result,/txt
    
    ; Use the vacuated information to generate a contour map.
    Print, 'Please use marine & surfer to finish this.'
    
    
    ; Extract the deformation velocity on the points.
    ; Locate the points. Just find the indices.
    ll=TLI_READDATA(llfile, samples=1, format='FCOMPLEX',/swap_endian)
    ml1_nstations=N_ELEMENTS(ml1info)
    ml3_nstations=N_ELEMENTS(ml3info)
    all_nstations=ml1_nstations+ml3_nstations
    ml_lon=[ml1info.lon,ml3info.lon]
    ml_lat=[ml1info.lat,ml3info.lat]
    ml_ll=DCOMPLEX(ml_lon, ml_lat)
    
    indices=DBLARR(all_nstations)
    FOR i=0, all_nstations-1 DO BEGIN
      ml_ll_i=ml_ll[i]
      min_dis=MIN(ABS(ll-ml_ll_i), ind_i)
      indices[i]=ind_i
    ENDFOR
    
    TLI_PROCESS_VDHFILE, vdhfile, sarlistfile, outputfile=vdhfile+'.changed', /minus, /los_to_v,vdhinfo=vdhinfo
    vdh=TLI_READMYFILES(vdhfile+'.changed', type='vdh')
    ml_v=[vdh[3, indices]]
    fnames=TRANSPOSE([ml1info.names, ml3info.names])
    result=fnames+':'+STRCOMPRESS(ml_v)
    TLI_WRITE,resultpath+'velocity_ML_1_3_name.txt',fnames,/txt
    TLI_WRITE, resultpath+'velocity_ML_1_3_value.txt',ml_v,/TXT
    Print, 'Main pro finished.'
    STOP
    
    
    STOP
    
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_SH_3/HPA/nonlinear/'
    hpapath=FILE_DIRNAME(workpath)+PATH_SEP()
    figpath=hpapath+'figures/'
    
    ; Files
    plistfile=workpath+'lel8plist_update_merge'
    nlfile=plistfile+'.arcnl.unw'
    sarlistfile=workpath+'sarlist_X'
    itabfile=workpath+'itab'
    rasfile=workpath+'ave.ras'
    outputfile=nlfile+'.bmp'
    ;  atmfile=plistfile+'.arcaps.unw'
    
    ; params
    vfile=figpath+'velocity_ML_1_3.txt'
    temp=TLI_READTXT(vfile,/EASY)
    indices=temp[0,*]
    npt_ind=N_ELEMENTS(indices)
    inputfile=nlfile
    swap_endian=0
    
    
    ; Readdata
    npt=TLI_PNUMBER(plistfile)
    data=TLI_READDATA(inputfile, samples=npt, format='FLOAT',swap_endian=swap_endian)
    
    ; Prepare the data for the points.
    pdata=data[indices, *]
    
    ; Write the nonlinear def. values.
    TLI_WRITE, figpath+'Metro_Lines_1_3_nonliear.txt',TRANSPOSE(pdata),/TXT
  ENDIF
  
  
  stations=['Fujin Road', 'Hulan Road', 'Jiangwan Town','Dabaishu']
  workpath='D:\myfiles\相关论文\Modern_Transportation\图表 - 20130711\'
  file=workpath+'Metro_lines_1_3_nonlinear_all.txt'
  data=TLI_READTXT(file,/easy)
  sz=SIZE(data,/DIMENSIONS)
  npt=sz[0]-2
  nintf=sz[1]
  dates=LONG(data[0,*])
  tb=data[1,*]
  nl=data[2:*, *]
  
  nl_v=nl/(4*!PI)*(0.3/9.65*1000)  ;mm
  
  TLI_WRITE, file+'_vert.txt', nl_v,/txt
  STOP
  
  pt_l_start_jul=DATE2JULDAT(dates[0])
  pt_l_end_jul=DATE2JULDAT(dates[nintf-1])
  
  slavedate=dates
  slavejul=DATE2JULDAT(slavedate)
  dummy=LABEL_DATE( date_format='%M. %D, %Y')
  t=slavejul
  t_min=MIN(t, max=t_max)
  
  xrange=[t_min-3, t_max+3]
  yrange=[-11, 7]
  position=[0.1, 0.18, 0.93, 0.95]
  
  FOR i=0, npt-1 DO BEGIN
  
    outputfile=workpath+stations[i]+'.emf'
    
    nl_i=nl[i,*]/(4*!PI)*(0.3/9.65*1000)  ;mm
    temp=PLOT(t, nl_i,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
      symbol='o',sym_size=0.7,sym_color='black', sym_filled=1, sym_fill_color='red',$
      FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
      linestyle=0, sym_thick=0.3,xtitle='Acquisition date',ytitle='Nonlinear Deformation (mm)',$
       xmajor=5,name=stations[i])
;      temp=PLOT(t, nl_i,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
;      symbol='o',sym_size=0.7,sym_color='black', sym_filled=1, sym_fill_color='red',$
;      FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
;      linestyle=0, sym_thick=0.3,xtitle='Acquisition date',ytitle='Nonlinear Deformation (mm)',$
;      xticks=6, xmajor=5,name=stations[i])
    temp.save, outputfile, border=10,resolution=50,/TRANSPARENT
    temp.close
    
  ENDFOR
;    Case i OF
;      0: BEGIN
;        a=PLOT(t, nl_i,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
;          symbol='o',sym_size=0.8,sym_color='black', sym_filled=1, sym_fill_color='red',$
;          FONT_SIZE=13, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
;          linestyle=0, sym_thick=0.3,xtitle='Aquisition date',ytitle='Nonlinear Deformation (mm)',$
;          xticks=6, xmajor=5,name=stations[i])
;      END
;
;      1: BEGIN
;        b=PLOT(t, nl_i,symbol='o',sym_size=0.8,sym_color='black', sym_filled=1, sym_fill_color='green',$
;          linestyle=1, sym_thick=0.3,name=stations[i],/overplot)
;      END
;
;      2: BEGIN
;        c=PLOT(t, nl_i,symbol='o',sym_size=0.8,sym_color='black', sym_filled=1, sym_fill_color='blue',$
;          linestyle=2, sym_thick=0.3,name=stations[i],/overplot)
;      END
;
;      3: BEGIN
;        d=PLOT(t, nl_i,symbol='o',sym_size=0.8,sym_color='black', sym_filled=1, sym_fill_color='yellow',$
;          linestyle=3, sym_thick=0.3,name=stations[i],/overplot)
;      END
;
;      4: BEGIN
;
;      END
;    ENDCASE
;
;  ENDFOR
;
  
  
  
  
END