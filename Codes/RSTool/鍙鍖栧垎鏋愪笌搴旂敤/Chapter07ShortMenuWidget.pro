;Chapter07ShortMenuWidget.pro
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
PRO Chapter07ShortMenuWidget

    topLevelBase = WIDGET_BASE(/CONTEXT_EVENTS)
    contextBase = WIDGET_BASE(topLevelBase, /CONTEXT_MENU)
    button1 = WIDGET_BUTTON(contextBase, VALUE='First button')
    button2 = WIDGET_BUTTON(contextBase, VALUE='Second button')


    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07ModalWidget', MyBase
END