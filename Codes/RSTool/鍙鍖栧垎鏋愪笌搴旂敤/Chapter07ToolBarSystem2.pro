; Chapter07ToolBarSystem2.pro
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
PRO Chapter07ToolBarSystem2
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase')
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Left.bmp',      $
               EVENT_PRO='Arrow_LeftProcedure', XSIZE=30, YSIZE=30, $
               XOFFSET=10, YOFFSET=10, /BITMAP )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Right.bmp',        $
               EVENT_PRO='Arrow_RightProcedure', XSIZE=30, YSIZE=30, $
               XOFFSET=50, YOFFSET=10, /BITMAP )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Up.bmp',        $
               EVENT_PRO='Arrow_UpProcedure', XSIZE=30, YSIZE=30, $
               XOFFSET=90, YOFFSET=10, /BITMAP )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Down.bmp',        $
               EVENT_PRO='Arrow_DownProcedure', XSIZE=30, YSIZE=30, $
               XOFFSET=130, YOFFSET=10, /BITMAP )
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Arrow_Exit.bmp',        $
               EVENT_PRO='Arrow_ExitProcedure', XSIZE=30, YSIZE=30, $
               XOFFSET=170, YOFFSET=10, /BITMAP )
    MyText1 = WIDGET_TEXT( MyBase, XOFFSET=0, SCR_XSIZE=500, YOFFSET=4, SCR_YSIZE=4 )
    MyText2 = WIDGET_TEXT( MyBase, XOFFSET=0, SCR_XSIZE=500, YOFFSET=42, SCR_YSIZE=4 )
    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07ToolBarSystem2', MyBase
END
