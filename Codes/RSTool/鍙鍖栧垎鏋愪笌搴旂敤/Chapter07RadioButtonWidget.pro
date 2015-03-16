; Chapter07RadioButtonWidget.pro
PRO BeijingProcedure, event
  IF event.SELECT EQ 1 THEN BEGIN
    Result = DIALOG_MESSAGE('Welcome to Beijing!',/INFORMATION)
  ENDIF
END
PRO ShanghaiProcedure, event
  IF event.SELECT EQ 1 THEN BEGIN
    Result = DIALOG_MESSAGE('Welcome to Shanghai!',/INFORMATION)
  ENDIF
END
PRO HangzhouProcedure, event
  IF event.SELECT EQ 1 THEN BEGIN
    Result = DIALOG_MESSAGE('Welcome to Hangzhou!',/INFORMATION)
  ENDIF
END
PRO ExitProcedure, event
  IF event.SELECT EQ 1 THEN BEGIN
    WIDGET_CONTROL, event.TOP, /DESTROY
  ENDIF
END
PRO Chapter07RadioButtonWidget
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase')
    MyButtonBase = Widget_Base(MyBase, FRAME=1, /BASE_ALIGN_CENTER $
      ,XOFFSET=50 ,YOFFSET=50 ,XSIZE=400 ,YSIZE=150, /EXCLUSIVE, /ROW)

    MyButton = WIDGET_BUTTON(MyButtonBase, VALUE='Bei Jing',      $
               EVENT_PRO='BeijingProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=100 )
    MyButton = WIDGET_BUTTON(MyButtonBase, VALUE='Shang Hai',      $
               EVENT_PRO='ShanghaiProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=150 )
    MyButton = WIDGET_BUTTON(MyButtonBase, VALUE='Hang Zhou',      $
               EVENT_PRO='HangzhouProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=200 )
    MyButton = WIDGET_BUTTON(MyButtonBase, VALUE='EXIT',       $
               EVENT_PRO='ExitProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=250 )
    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07RadioButtonWidget', MyBase
END