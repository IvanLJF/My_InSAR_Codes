;Chapter07ModalWidget.pro
PRO SubSubProcedure, event
    WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO SubProcedure, event
    MySubBase =WIDGET_BASE(GROUP_LEADER=event.TOP, /MODAL, XSIZE=300,YSIZE=200)
    MySubButton = WIDGET_BUTTON(MySubBase, VALUE='CANCEL', /PUSHBUTTON_EVENTS,  $
               EVENT_PRO='SubSubProcedure',XSIZE=100,YSIZE=40, $
               XOFFSET=100, YOFFSET=60)
    WIDGET_CONTROL, MySubBase, /REALIZE
END
PRO Chapter07ModalWidget
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400)
    MyButton = WIDGET_BUTTON(MyBase, VALUE='Welcome',    $
               EVENT_PRO='SubProcedure', XSIZE=100, YSIZE=50, $
               XOFFSET=200, YOFFSET=20 )
    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07ModalWidget', MyBase
END