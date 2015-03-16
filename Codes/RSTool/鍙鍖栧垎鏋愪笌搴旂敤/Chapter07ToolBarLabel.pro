; Chapter07ToolBarLabel.pro
PRO Arrow_LeftProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  WIDGET_CONTROL, (*pState).MyLabel, SET_VALUE='Left Arrow Pressed!'
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO Arrow_RightProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  WIDGET_CONTROL, (*pState).MyLabel, SET_VALUE='Right Arrow Pressed!'
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO Arrow_UpProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  WIDGET_CONTROL, (*pState).MyLabel, SET_VALUE='Up Arrow Pressed!'
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO Arrow_DownProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  WIDGET_CONTROL, (*pState).MyLabel, SET_VALUE='Down Arrow Pressed!'
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO Arrow_ExitProcedure, event
    WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO Chapter07ToolBarLabel
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=236, TITLE='MyBase')
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
    MyLabel = WIDGET_LABEL(MyBase, XOFFSET=10, SCR_XSIZE=480, $
               YOFFSET=200,SCR_YSIZE=20,/SUNKEN_FRAME,        $
               VALUE='Happy You!', /ALIGN_CENTER)
    WIDGET_CONTROL, MyBase, /REALIZE
    pState = PTR_NEW({ MyLabel: MyLabel })
    WIDGET_CONTROL, MyBase, SET_UVALUE=pState
        XMANAGER, 'Chapter07ToolBarLabel', MyBase
END
