; Chapter07ToolBarSystem1.pro
PRO Arrow_LeftProcedure, event
    Result = DIALOG_MESSAGE('Left Arrow Pressed!',/INFORMATION)
END
PRO Arrow_RightProcedure, event
    Result = DIALOG_MESSAGE('Right Arrow Pressed!',/INFORMATION)
END
PRO Arrow_UpProcedure, event
    Result = DIALOG_MESSAGE('Up Arrow Pressed!',/INFORMATION)
END
PRO Arrow_DownProcedure, event
    Result = DIALOG_MESSAGE('Down Arrow Pressed!',/INFORMATION)
END
PRO Arrow_ExitProcedure, event
    WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO Chapter07ToolBarSystem1
    MyTopBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase', /TOOLBAR, /ROW)
    MyBase = Widget_Base(MyTopBase, FRAME=1, /ROW)
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Left.bmp',      $
               EVENT_PRO='Arrow_LeftProcedure', XSIZE=50, YSIZE=30,$
               XOFFSET=200, YOFFSET=100, /BITMAP )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Right.bmp',       $
               EVENT_PRO='Arrow_RightProcedure', XSIZE=50, YSIZE=30,$
               XOFFSET=200, YOFFSET=150, /BITMAP )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Up.bmp',        $
               EVENT_PRO='Arrow_UpProcedure', XSIZE=50, YSIZE=30, $
               XOFFSET=200, YOFFSET=200, /BITMAP )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Down.bmp',        $
               EVENT_PRO='Arrow_DownProcedure', XSIZE=50, YSIZE=30, $
               XOFFSET=200, YOFFSET=250, /BITMAP )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Exit.bmp',        $
               EVENT_PRO='Arrow_ExitProcedure', XSIZE=50, YSIZE=30, $
               XOFFSET=200, YOFFSET=250, /BITMAP )
    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07ToolBarSystem1', MyBase
END
