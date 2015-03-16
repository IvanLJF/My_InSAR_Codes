; Chapter07SliderWidget.pro
PRO RProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  WIDGET_CONTROL, (*pState).MySliderR, GET_VALUE=RValue
  WIDGET_CONTROL, (*pState).MySliderG, GET_VALUE=GValue
  WIDGET_CONTROL, (*pState).MySliderB, GET_VALUE=BValue
  MyStatus = 'RColor:'+ STRTRIM(STRING(RValue),2) +'  '+ $
             'GColor:'+ STRTRIM(STRING(GValue),2) +'  '+ $
             'BColor:'+ STRTRIM(STRING(BValue),2)
  WIDGET_CONTROL, (*pState).MyLabel, SET_VALUE=MyStatus
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO GProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  WIDGET_CONTROL, (*pState).MySliderR, GET_VALUE=RValue
  WIDGET_CONTROL, (*pState).MySliderG, GET_VALUE=GValue
  WIDGET_CONTROL, (*pState).MySliderB, GET_VALUE=BValue
  MyStatus = 'RColor:' + STRTRIM(STRING(RValue),2) +'  '+ $
             'GColor:' + STRTRIM(STRING(GValue),2) +'  '+ $
             'BColor:' + STRTRIM(STRING(BValue),2)
  WIDGET_CONTROL, (*pState).MyLabel, SET_VALUE=MyStatus
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO BProcedure, event
  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState
  WIDGET_CONTROL, (*pState).MySliderR, GET_VALUE=RValue
  WIDGET_CONTROL, (*pState).MySliderG, GET_VALUE=GValue
  WIDGET_CONTROL, (*pState).MySliderB, GET_VALUE=BValue
  MyStatus = 'RColor:' + STRTRIM(STRING(RValue),2) +'  '+ $
             'GColor:' + STRTRIM(STRING(GValue),2) +'  '+ $
             'BColor:' + STRTRIM(STRING(BValue),2)
  WIDGET_CONTROL, (*pState).MyLabel, SET_VALUE=MyStatus
  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState
END
PRO ExitProcedure, event
    WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO Chapter07SliderWidget
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=236, TITLE='MyBase')
    MySliderR = WIDGET_SLIDER(MyBase, MINIMUM = 0, $
              MAXIMUM = 255, TITLE = 'R Color', $
              /FRAME, UVALUE = 'SLIDE', XSIZE = 300, $
              XOFFSET=100, YOFFSET=20,EVENT_PRO='RProcedure')
    MySliderG = WIDGET_SLIDER(MyBase, MINIMUM = 0, $
              MAXIMUM = 255, TITLE = 'G Color', $
              /FRAME, UVALUE = 'SLIDE', XSIZE = 300, $
              XOFFSET=100, YOFFSET=60,EVENT_PRO='GProcedure')
    MySliderB = WIDGET_SLIDER(MyBase, MINIMUM = 0, $
              MAXIMUM = 255, TITLE = 'B Color', $
              /FRAME, UVALUE = 'SLIDE', XSIZE = 300, $
              XOFFSET=100, YOFFSET=100,EVENT_PRO='BProcedure')
    MyExit = WIDGET_BUTTON(MyBase, VALUE='Exit',        $
               EVENT_PRO='ExitProcedure', XSIZE=100, YSIZE=30,$
               XOFFSET=200, YOFFSET=150 )
    MyLabel = WIDGET_LABEL(MyBase, XOFFSET=10, SCR_XSIZE=480, $
               YOFFSET=200,SCR_YSIZE=20,/SUNKEN_FRAME,        $
               VALUE='Happy You!', /ALIGN_CENTER)
    WIDGET_CONTROL, MyBase, /REALIZE
    pState = PTR_NEW({ MyLabel: MyLabel,       $
                       MySliderR: MySliderR,   $
                       MySliderG: MySliderG,   $
                       MySliderB: MySliderB    $
                    })
    WIDGET_CONTROL, MyBase, SET_UVALUE=pState
    XMANAGER, 'Chapter07SliderWidget', MyBase
END
