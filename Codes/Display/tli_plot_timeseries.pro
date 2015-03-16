FUNCTION TLI_PLOT_TIMESERIES, sarlistfile, itabfile, data, nosort=nosort,yrange=yrange,linestyle=linestyle,no_xtick=no_xtick

  tbaselines=TBASE_ALL(sarlistfile, itabfile,/years)
  nintf=FILE_LINES(itabfile)
  IF KEYWORD_SET(nosort) THEN BEGIN
    tb_ind=LINDGEN(nintf)
  ENDIF ELSE BEGIN
    tb_ind=SORT(tbaselines)
  ENDELSE
  IF NOT KEYWORD_SET(yrange) THEN BEGIN
    miny=MIN(data,max=maxy)
    yrange=[miny, maxy]
  ENDIF
  IF N_ELEMENTS(linestyle) EQ 0 THEN BEGIN
    linestyle=6
  ENDIF
  
  
  slavedate=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
  slavejul=DATE2JULDAT(slavedate)
  dummy=LABEL_DATE( date_format='%M. %Y')
  
  t=slavejul[tb_ind]
  data=data[tb_ind]
  
  t_min=MIN(t, max=t_max)
  IF NOT KEYWORD_SET(xrange) THEN BEGIN
    xrange=[t_min-3, t_max+3]
  ENDIF
  position=[0.13, 0.18, 0.93, 0.95]
  
  IF 0 THEN BEGIN
;    IF KEYWORD_SET(no_xtick) THEN BEGIN
;      result=PLOT(t, data,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
;        symbol='o',sym_size=1,sym_color='black', sym_filled=1, sym_fill_color='red',$
;        FONT_SIZE=18, xtickunits=['Time'], xstyle=1,$
;        linestyle=linestyle, sym_thick=0.3,ytitle='Subsidence (mm)',$
;        xticks=5, xmajor=5,xminor=0, ymajor=3, yminor=0,xtickformat='-w2+', thick=2)
;    ENDIF ELSE BEGIN
;      result=PLOT(t, data,yrange=yrange, xrange=xrange,dimensions=[800,300],position=position,$
;        symbol='o',sym_size=1,sym_color='black', sym_filled=1, sym_fill_color='red',$
;        FONT_SIZE=18, xtickunits=['Time'], xtickformat='label_date',xstyle=1,$
;        linestyle=linestyle, sym_thick=0.3,xtitle='Time',ytitle='Subsidence (mm)',$
;        xticks=5, xmajor=5,xminor=0, ymajor=3, yminor=0,thick=2)
;    ENDELSE
  ENDIF
  RETURN, result
  
END