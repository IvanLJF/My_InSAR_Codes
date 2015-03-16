;Chapter07BaseWidget.pro
PRO SubProcedure, event
    Result = DIALOG_MESSAGE('Happy You!',/INFORMATION)
END
PRO Chapter07BaseWidget
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400)
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Welcome',    $
               EVENT_PRO='SubProcedure', XSIZE=100, YSIZE=60, $
               XOFFSET=200, YOFFSET=160 )
    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07ModalWidget', MyBase
END