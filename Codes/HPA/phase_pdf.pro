PRO Phase_PDF
  COMPILE_OPT idl2
  phi= -0.1 ;Range from -pi to pi
  rou= 0.5 ;Complex correlate coefficience.
  theta= 0
  step= 0.01
  start_x = -!PI
  end_x= !PI
  x=start_x+step*FINDGEN((end_x-start_x)/step)
  y1= CALCULATE_PHASE_PDF(x,0.9, 0)
  y2= CALCULATE_PHASE_PDF(x,0.5, 0)
  y3= CALCULATE_PHASE_PDF(x,0.2, 0)
  iPLOT,x, y1, Linestyle= 1,NAME='!Mr=0.9, !Mq=0',FONT_SIZE=5,insert_legend=[0.392,0.63]
  iPLOT,x, y2, /Overplot, Linestyle= 2,NAME='!Mr=0.5, !Mq=0' ,FONT_SIZE=11,/insert_legend
  iPLOT,x, y3, /OVERPLOT, Linestyle= 3, NAME='!Mr=0.2, !Mq=0' ,FONT_SIZE=11,TITLE='', XTICKFONT_SIZE=11, YTICKFONT_SIZE=11, $
        XTITLE= '干涉相位（!MY）', YTITLE='概率（!NP ）',FONT_NAME='STSong', XTICKLEN=0.03, XSUBTICKLEN= 0.5, $
        YTICKLEN=0.03, YSUBTICKLEN= 0.5,/insert_legend
;  XYOUTS, 0,0.2, '!MI !S !A !E !8x !R !B !Ip !N !7s !Ii !N !8U !S !E2 !R !Ii !Ndx', SIZE=3,/NORMAL

END

FUNCTION CALCULATE_PHASE_PDF, phase, rou, theta
  IF (MAX(phase) GT !pi) OR (MIN(phase) LT -!pi) THEN BEGIN
    MESSAGE, 'Phase range: (-pi, pi]'
  ENDIF
  IF ~KEYWORD_SET(phase) THEN $
    phase= -0.1 ;Range from -pi to pi
  IF ~KEYWORD_SET(rou) THEN $
    rou= 0.5 ;Complex correlate coefficience.
  IF ~KEYWORD_SET(theta) THEN $
    theta= 0
  sz= SIZE(phase,/N_ELEMENTS)
;  result=0
;  FOR i=0, sz-1 DO BEGIN
    belta= rou*COS(phase- theta)
    numerator1= (1-rou^2)*SQRT(1-belta^2)
    numerator2= belta*(!pi-ACOS(belta))
    denumerator= 2*!pi*(1-belta^2)^0.5
    result=(numerator1+numerator2)/denumerator
;    result=[result, (numerator1+numerator2)/denumerator]
;    
;  ENDFOR
;  result= result[1:*]
  RETURN, result

END