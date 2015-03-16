; Chapter07CheckButtonWidget.pro
PRO BeijingProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  MyString = STRARR(3)
  IF event.SELECT EQ 1 THEN BEGIN
     (*pState).MyBeijingButtonStatus = 1
     MyString[0] = 'Beijing is Selected!
  ENDIF ELSE BEGIN
     (*pState).MyBeijingButtonStatus = 0
     MyString[0] = 'Beijing is not Selected!
  ENDELSE
  IF (*pState).MyShanghaiButtonStatus EQ 1 THEN BEGIN
     MyString[1] = 'Shanghai is Selected!
  ENDIF ELSE BEGIN
     MyString[1] = 'Shanghai is not Selected!
  ENDELSE
  IF (*pState).MyHangzhouButtonStatus EQ 1 THEN BEGIN
     MyString[2] = 'Hangzhou is Selected!
  ENDIF ELSE BEGIN
     MyString[2] = 'Hangzhou is not Selected!
  ENDELSE
  Result = DIALOG_MESSAGE(MyString,/INFORMATION)
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO ShanghaiProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  MyString = STRARR(3)
  IF event.SELECT EQ 1 THEN BEGIN
     (*pState).MyShanghaiButtonStatus = 1
     MyString[0] = 'Shanghai is Selected!
  ENDIF ELSE BEGIN
     (*pState).MyShanghaiButtonStatus = 0
     MyString[0] = 'Shanghai is not Selected!
  ENDELSE
  IF (*pState).MyBeijingButtonStatus EQ 1 THEN BEGIN
     MyString[1] = 'Beijing is Selected!
  ENDIF ELSE BEGIN
     MyString[1] = 'Beijing is not Selected!
  ENDELSE
  IF (*pState).MyHangzhouButtonStatus EQ 1 THEN BEGIN
     MyString[2] = 'Hangzhou is Selected!
  ENDIF ELSE BEGIN
     MyString[2] = 'Hangzhou is not Selected!
  ENDELSE
  Result = DIALOG_MESSAGE(MyString,/INFORMATION)
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO HangzhouProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  MyString = STRARR(3)
  IF event.SELECT EQ 1 THEN BEGIN
     (*pState).MyHangzhouButtonStatus = 1
     MyString[0] = 'Hangzhou is Selected!
  ENDIF ELSE BEGIN
     (*pState).MyHangzhouButtonStatus = 0
     MyString[0] = 'Hangzhou is not Selected!
  ENDELSE
  IF (*pState).MyShanghaiButtonStatus EQ 1 THEN BEGIN
     MyString[1] = 'Shanghai is Selected!
  ENDIF ELSE BEGIN
     MyString[1] = 'Shanghai is not Selected!
  ENDELSE
  IF (*pState).MyBeijingButtonStatus EQ 1 THEN BEGIN
     MyString[2] = 'Beijing is Selected!
  ENDIF ELSE BEGIN
     MyString[2] = 'Beijing is not Selected!
  ENDELSE
  Result = DIALOG_MESSAGE(MyString,/INFORMATION)
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO ExitProcedure, event
  IF event.SELECT EQ 1 THEN BEGIN
    WIDGET_CONTROL, event.TOP, /DESTROY
  ENDIF
END
PRO Chapter07CheckButtonWidget
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase')
    MyButtonBase = Widget_Base(MyBase, FRAME=1, /BASE_ALIGN_CENTER $
      ,XOFFSET=50 ,YOFFSET=50 ,XSIZE=400 ,YSIZE=150, /NONEXCLUSIVE, /ROW)

    MyBeijingButton = WIDGET_BUTTON(MyButtonBase, VALUE='Bei Jing',      $
               EVENT_PRO='BeijingProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=100 )
    MyShanghaiButton = WIDGET_BUTTON(MyButtonBase, VALUE='Shang Hai',      $
               EVENT_PRO='ShanghaiProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=150 )
    MyGuangzhouButton = WIDGET_BUTTON(MyButtonBase, VALUE='Hang Zhou',      $
               EVENT_PRO='HangzhouProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=200 )
    MyExitButton = WIDGET_BUTTON(MyButtonBase, VALUE='EXIT',       $
               EVENT_PRO='ExitProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=250 )
    WIDGET_CONTROL, MyBase, /REALIZE
    pState = PTR_NEW({        $
        MyBeijingButton: MyBeijingButton,       $
        MyShanghaiButton: MyShanghaiButton,     $
        MyGuangzhouButton: MyGuangzhouButton,   $
        MyBeijingButtonStatus: 0,               $
        MyShanghaiButtonStatus: 0,              $
        MyHangzhouButtonStatus: 0               $
     })
    WIDGET_CONTROL, MyBase, SET_UVALUE=pState
    XMANAGER, 'Chapter07CheckButtonWidget', MyBase
END