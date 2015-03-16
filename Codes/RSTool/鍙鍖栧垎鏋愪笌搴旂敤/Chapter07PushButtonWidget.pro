; Chapter07PushButtonWidget.pro
PRO BeijingProcedure, event
    Result = DIALOG_MESSAGE('Welcome to Beijing!',/INFORMATION)
END
PRO ShanghaiProcedure, event
    Result = DIALOG_MESSAGE('Welcome to Shanghai!',/INFORMATION)
END
PRO HangzhouProcedure, event
    Result = DIALOG_MESSAGE('Welcome to Hangzhou!',/INFORMATION)
END
PRO ExitProcedure, event
    WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO Chapter07PushButtonWidget
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase')
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Bei Jing',        $
               EVENT_PRO='BeijingProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=200, YOFFSET=50 )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Shang Hai',        $
               EVENT_PRO='ShanghaiProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=200, YOFFSET=100 )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Hang Zhou',        $
               EVENT_PRO='HangzhouProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=200, YOFFSET=150 )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='EXIT',        $
               EVENT_PRO='ExitProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=200, YOFFSET=200 )
    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07PushButtonWidget', MyBase
END