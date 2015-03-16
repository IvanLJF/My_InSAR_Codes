PRO REC_FILL, XStart, YStart, width, height, color 
   ; Call POLYFILL: 
   POLYFILL, [XStart, XStart, XStart+width, XStart+width], [YStart, YStart+height, YStart+height, YStart], COL = color 
END

PRO SHOW_TIME_INTERVAL
  
  COMPILE_OPT idl2
  DEVICE, DECOMPOSED=1
  DEVICE, SET_FONT='隶书'
  !P.Font=0
  !P.BACKGROUND= 'FFFFFF'XL
  !P.COLOR= '000000'XL
  
  sarlist='D:\ForExperiment\TSX_PS_Tianjin\piece\sarlist.txt'
  nlines= FILE_LINES(sarlist)
  slcs=STRARR(nlines)
  OPENR, lun, sarlist,/GET_LUN
  READF, lun, slcs
  FREE_LUN, lun
  
  ;Change filename to imaging date.
  dates=0
  FOR i=0, nlines-1 DO BEGIN
    temp= FILE_BASENAME(slcs[i], 'rslc')
    dates=[dates, LONG(temp)]
  ENDFOR
  dates=dates[1:*]
  
  ;Set Axis
  xval= FINDGEN(2)/3+1/3D
  xnames=['使用振幅离差', '使用配准偏移量']
  
  interval= 5
  index= N_ELEMENTS(dates)
  ynames= dates[0:*:5]
  ynames= [ynames, dates[nlines-1]]
  yticks= LONG(index/interval)
  yval= (INDGEN(nlines+1))[0:*:5]
  yval= [yval, 38]
  PLOT, xval,[0,nlines],XTICKS=1,XTICKV=xval, XTICKNAME=xnames,XRANGE=[0,1],$
        YTICKS=8,YTICKV=yval,YTICKNAME=ynames,YRANGE=[0,40] , $
        FONT=0,/NODATA,/YNOZERO,TITLE='使用的影像序列'

  ; Create my own colorbar
  DEVICE, DECOMPOSED=0
  myr= INTARR(256)
  myg= INTARR(256)
  myb= 255-BINDGEN(256)
  MODIFYCT, 35, 'MyColorTable', myr, myg, myb
  LOADCT, 39
  colors=100+INDGEN(nlines)*(256-100)/nlines
  
  ;Plot Rectangular for PSI Using DA
  width=0.007D
  height=40
  REC_FILL, xval[0]-width/2, 0, width, height, colors[height-1]
  
  ;Select data whose total number is below nlines.
  length=[5,1,6,8,9,15,10,20]
  interval=[2,2,5,3,2,6,2,5,8]
  sz_small= MIN([N_ELEMENTS(length),N_ELEMENTS(interval)])
  sum=0
  FOR i =0, sz_small-1 DO BEGIN
    IF length[i]+sum GE nlines THEN BEGIN
      length[i]=nlines-sum
      BREAK
    ENDIF ELSE BEGIN
      sum= sum+length[i]
      IF sum+interval[i] GE nlines THEN BEGIN
        interval[i]=nlines-sum
        BREAK
      ENDIF
      sum=sum+interval[i]
    ENDELSE  
  ENDFOR
  ;Plot Rectangular for PSI Using Offset 2
  y_start=0
  FOR j=0, i DO BEGIN
  PRINT, y_start,length[j], interval[j]
    REC_FILL, xval[1]-width/2, y_start, width, length[j], colors[length[j]-1]
    y_start= y_start+length[j]+interval[j]
  ENDFOR
  
  
  
  
  ;Select data whose total number is below nlines.
  length=[15,17,3,2,4,5]
  interval=[2,2,2,2,2]
  sz_small= MIN([N_ELEMENTS(length),N_ELEMENTS(interval)])
  sum=0
  FOR i =0, sz_small-1 DO BEGIN
    IF length[i]+sum GE nlines THEN BEGIN
      length[i]=nlines-sum
      BREAK
    ENDIF ELSE BEGIN
      sum= sum+length[i]
      IF sum+interval[i] GE nlines THEN BEGIN
        interval[i]=nlines-sum
        BREAK
      ENDIF
      sum=sum+interval[i]
    ENDELSE  
  ENDFOR
  ;Plot Rectangular for PSI Using Offset 2
  y_start=0
  FOR j=0, i DO BEGIN
  PRINT, y_start,length[j], interval[j]
    REC_FILL, xval[1]-width/2-0.05, y_start, width, length[j], colors[length[j]-1]
    y_start= y_start+length[j]+interval[j]
  ENDFOR
  
  
  ;Select data whose total number is below nlines.
  length=[3,3,3,3,3,3,3,3,3]
  interval=[2,2,2,2,2,2,2,2,2,2]
  sz_small= MIN([N_ELEMENTS(length),N_ELEMENTS(interval)])
  sum=0
  FOR i =0, sz_small-1 DO BEGIN
    IF length[i]+sum GE nlines THEN BEGIN
      length[i]=nlines-sum
      BREAK
    ENDIF ELSE BEGIN
      sum= sum+length[i]
      IF sum+interval[i] GE nlines THEN BEGIN
        interval[i]=nlines-sum
        BREAK
      ENDIF
      sum=sum+interval[i]
    ENDELSE  
  ENDFOR
  ;Plot Rectangular for PSI Using Offset 2
  y_start=0
  FOR j=0, i DO BEGIN
  PRINT, y_start,length[j], interval[j]
    REC_FILL, xval[1]-width/2+0.05, y_start, width, length[j], colors[length[j]-1]
    y_start= y_start+length[j]+interval[j]
  ENDFOR
  

  color_bottom= MIN(colors)
  color_head= MAX(colors)
  temparr= INDGEN(color_head-color_bottom)+color_bottom
  TV, REBIN(temparr,N_ELEMENTS(temparr), 15), 150,250,/DEVICE
  

END


;PRO SHOW_TIME_INTERVAL
;  
;  COMPILE_OPT idl2
;  DEVICE, DECOMPOSED=1
;  !P.BACKGROUND= 'FFFFFF'XL
;  !P.COLOR= '000000'XL
;  
;  sarlist='D:\myfiles\Software\TSX_PS_Tianjin\sarlist.txt'
;  nlines= FILE_LINES(sarlist)
;  slcs=STRARR(nlines)
;  OPENR, lun, sarlist,/GET_LUN
;  READF, lun, slcs
;  FREE_LUN, lun
;  
;  ;Change filename to imaging date.
;  dates=0
;  FOR i=0, nlines-1 DO BEGIN
;    temp= FILE_BASENAME(slcs[i], 'rslc')
;    dates=[dates, LONG(temp)]
;  ENDFOR
;  dates=dates[1:*]
;  
;  ;Set Axis
;  xval= FINDGEN(2)/3+1/3D
;  xnames=['PSI Using DA', 'PSI Using Offset']
;  
;  interval= 5
;  index= N_ELEMENTS(dates)
;  ynames= dates[0:*:5]
;  ynames= [ynames, dates[nlines-1]]
;  yticks= LONG(index/interval)
;  yval= (INDGEN(nlines+1))[0:*:5]
;  yval= [yval, 38]
;  PLOT, xval,[0,nlines],XTICKS=1,XTICKV=xval, XTICKNAME=xnames,XRANGE=[0,1],$
;        YTICKS=8,YTICKV=yval,YTICKNAME=ynames,YRANGE=[0,40] , $
;        FONT=0,/NODATA,/YNOZERO,TITLE='Images used for analysis'
;
;
;  ; Create my own colorbar
;  DEVICE, DECOMPOSED=0
;  myr= INTARR(256)
;  myg= INTARR(256)
;  myb= 255-BINDGEN(256)
;  MODIFYCT, 35, 'MyColorTable', myr, myg, myb
;  LOADCT, 39
;  colors=100+INDGEN(nlines)*(256-100)/nlines
;  
;  ;Plot Rectangular for PSI Using DA
;  width=0.007D
;  height=40
;  REC_FILL, xval[0]-width/2, 0, width, height, colors[height-1]
;  
;  ;Select data whose total number is below nlines.
;  length=[5,1,6,8,9,15,10,20]
;  interval=[2,2,5,3,2,6,2,5,8]
;  sz_small= MIN([N_ELEMENTS(length),N_ELEMENTS(interval)])
;  sum=0
;  FOR i =0, sz_small-1 DO BEGIN
;    IF length[i]+sum GE nlines THEN BEGIN
;      length[i]=nlines-sum
;      BREAK
;    ENDIF ELSE BEGIN
;      sum= sum+length[i]
;      IF sum+interval[i] GE nlines THEN BEGIN
;        interval[i]=nlines-sum
;        BREAK
;      ENDIF
;      sum=sum+interval[i]
;    ENDELSE  
;  ENDFOR
;  ;Plot Rectangular for PSI Using Offset 2
;  y_start=0
;  FOR j=0, i DO BEGIN
;  PRINT, y_start,length[j], interval[j]
;    REC_FILL, xval[1]-width/2, y_start, width, length[j], colors[length[j]-1]
;    y_start= y_start+length[j]+interval[j]
;  ENDFOR
;  
;  
;  
;  
;  ;Select data whose total number is below nlines.
;  length=[15,17,3,2,4,5]
;  interval=[2,2,2,2,2]
;  sz_small= MIN([N_ELEMENTS(length),N_ELEMENTS(interval)])
;  sum=0
;  FOR i =0, sz_small-1 DO BEGIN
;    IF length[i]+sum GE nlines THEN BEGIN
;      length[i]=nlines-sum
;      BREAK
;    ENDIF ELSE BEGIN
;      sum= sum+length[i]
;      IF sum+interval[i] GE nlines THEN BEGIN
;        interval[i]=nlines-sum
;        BREAK
;      ENDIF
;      sum=sum+interval[i]
;    ENDELSE  
;  ENDFOR
;  ;Plot Rectangular for PSI Using Offset 2
;  y_start=0
;  FOR j=0, i DO BEGIN
;  PRINT, y_start,length[j], interval[j]
;    REC_FILL, xval[1]-width/2-0.05, y_start, width, length[j], colors[length[j]-1]
;    y_start= y_start+length[j]+interval[j]
;  ENDFOR
;  
;  
;  ;Select data whose total number is below nlines.
;  length=[3,3,3,3,3,3,3,3,3]
;  interval=[2,2,2,2,2,2,2,2,2,2]
;  sz_small= MIN([N_ELEMENTS(length),N_ELEMENTS(interval)])
;  sum=0
;  FOR i =0, sz_small-1 DO BEGIN
;    IF length[i]+sum GE nlines THEN BEGIN
;      length[i]=nlines-sum
;      BREAK
;    ENDIF ELSE BEGIN
;      sum= sum+length[i]
;      IF sum+interval[i] GE nlines THEN BEGIN
;        interval[i]=nlines-sum
;        BREAK
;      ENDIF
;      sum=sum+interval[i]
;    ENDELSE  
;  ENDFOR
;  ;Plot Rectangular for PSI Using Offset 2
;  y_start=0
;  FOR j=0, i DO BEGIN
;  PRINT, y_start,length[j], interval[j]
;    REC_FILL, xval[1]-width/2+0.05, y_start, width, length[j], colors[length[j]-1]
;    y_start= y_start+length[j]+interval[j]
;  ENDFOR
;  
;
;  color_bottom= MIN(colors)
;  color_head= MAX(colors)
;  temparr= INDGEN(color_head-color_bottom)+color_bottom
;  TV, REBIN(temparr,N_ELEMENTS(temparr), 15), 150,250,/DEVICE
;
;END

