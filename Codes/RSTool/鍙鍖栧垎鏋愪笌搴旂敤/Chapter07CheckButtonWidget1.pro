; Chapter07CheckButtonWidget1.pro
PRO Chapter07CheckButtonWidget1_EVENT, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  MyString = STRARR(3)
  IF MyBeijingButton.SELECT EQ 1 THEN BEGIN
    MyString[0] = 'Bei Jing is Selected'
  ENDIF ELSE BEGIN
    MyString[0] = 'Bei Jing is not Selected'
  ENDELSE
  IF MyShanghaiButton.SELECT EQ 1 THEN BEGIN
    MyString[1] = 'Shang Hai Selected'
  ENDIF ELSE BEGIN
    MyString[1] = 'Shang Hai is not Selected'
  ENDELSE
  IF MyHangzhouButton.SELECT EQ 1 THEN BEGIN
    MyString[2] = 'Hang Zhou Selected'
  ENDIF ELSE BEGIN
    MyString[2] = 'Hang Zhou is not Selected'
  ENDELSE
  Result = DIALOG_MESSAGE(MyString,/INFORMATION)
END
PRO Chapter07CheckButtonWidget1
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase')
    MyButtonBase = Widget_Base(MyBase, FRAME=1, /BASE_ALIGN_CENTER $
      ,XOFFSET=50 ,YOFFSET=50 ,XSIZE=400 ,YSIZE=300, /NONEXCLUSIVE, /ROW)

    MyBeijingButton = WIDGET_BUTTON(MyButtonBase, VALUE='Bei Jing',      $
               XSIZE=100, YSIZE=30, XOFFSET=150, YOFFSET=100 )
    MyShanghaiButton = WIDGET_BUTTON(MyButtonBase, VALUE='Shang Hai',      $
               XSIZE=100, YSIZE=30, XOFFSET=150, YOFFSET=150 )
    MyGuangzhouButton = WIDGET_BUTTON(MyButtonBase, VALUE='Hang Zhou',      $
               XSIZE=100, YSIZE=30, XOFFSET=150, YOFFSET=200 )
    MyExitButton = WIDGET_BUTTON(MyButtonBase, VALUE='EXIT',       $
               XSIZE=100, YSIZE=30, XOFFSET=150, YOFFSET=250 )
    WIDGET_CONTROL, MyBase, /REALIZE
    pState = PTR_NEW({        $
        MyBeijingButton: MyBeijingButton,       $
        MyShanghaiButton: MyShanghaiButton,     $
        MyGuangzhouButton: MyGuangzhouButton    $
        MyBeijingButtonStatus:0                 $
        MyShanghaiButtonStatus:0                $
        MyHangzhouButtonStatus:0                $
     })
    WIDGET_CONTROL, MyBase, SET_UVALUE=pState
    XMANAGER, 'Chapter07CheckButtonWidget1', MyBase
END