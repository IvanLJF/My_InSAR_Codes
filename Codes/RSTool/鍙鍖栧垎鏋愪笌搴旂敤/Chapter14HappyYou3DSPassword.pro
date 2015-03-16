; Chapter14HappyYou3DSPassword.pro
PRO Chapter14HappyYou3DSPassword_event, ev
  WIDGET_CONTROL, ev.id, GET_UVALUE=uval
  CASE uval OF
    'ENTER' : begin
      WIDGET_CONTROL, ev.top, GET_UVALUE=StateUvalue
      WIDGET_CONTROL, StateUvalue.text, GET_VALUE=textValue
      IF STRTRIM(STRUPCASE(textValue),2) EQ 'HAPPYYOU' THEN BEGIN
        WIDGET_CONTROL, ev.top, /DESTROY
        Chapter14HappyYou3DSControl
      ENDIF ELSE BEGIN
        Result = DIALOG_MESSAGE('√‹¬Î¥ÌŒÛ£¨«Î ‰»Î’˝»∑√‹¬Î£°', /ERROR)
        WIDGET_CONTROL, StateUvalue.text, SET_VALUE=STRJOIN(STRARR(20))
      ENDELSE
    END
    'DONE': BEGIN
        WIDGET_CONTROL, ev.top, /DESTROY
    END
    ELSE :
  ENDCASE
END
PRO Chapter14HappyYou3DSPassword
  DEVICE, GET_SCREEN_SIZE=scr_size
  xwidth=scr_size[0]
  ywidth=scr_size[1]
  xBaseWidth=800
  yBaseWidth=600
  MainBase = WIDGET_BASE(XSize=xBaseWidth, YSize=yBaseWidth, TITLE='Happy You 3DS', $
        XOFFSET=(xwidth-xBaseWidth)/2, YOFFSET=(ywidth-yBaseWidth)/2,TLB_FRAME_ATTR=1)
  Button1 =WIDGET_BUTTON(MainBase, VALUE='«Î ‰»Î√‹¬Î',  $
        XSize=90, YSize=30, XOFFSET=600,YOFFSET=300, UVALUE=' ')
  Text =WIDGET_TEXT(MainBase, VALUE= STRJOIN(STRARR(20)), UVALUE='PASSWORD', $
        /EDITABLE, XSize=13, YSize=1, XOFFSET=600,YOFFSET=350 )
  Button2 =WIDGET_BUTTON(MainBase, VALUE='Ω¯»Î', UVALUE='ENTER',  $
        XSize=90, YSize=30, XOFFSET=600,YOFFSET=400)
  Button3 =WIDGET_BUTTON(MainBase, VALUE='ÕÀ≥ˆ', UVALUE='DONE',  $
        XSize=90, YSize=30, XOFFSET=600,YOFFSET=450)
  logo = READ_BMP('D:\myfiles\My_InSAR_Tools\IDL_BOOK\password.bmp', /rgb)
  logoSize = SIZE(logo)
  MainDraw = WIDGET_DRAW(MainBase, XSIZE=logoSize[2], YSIZE=logoSize[3], RETAIN = 2)
  WIDGET_CONTROL, MainBase, /REALIZE
  TV, logo,/true
  state = {text : text}
  WIDGET_CONTROL, MainBase, set_uvalue = state
  XMANAGER, 'Chapter14HappyYou3DSPassword',MainBase
END