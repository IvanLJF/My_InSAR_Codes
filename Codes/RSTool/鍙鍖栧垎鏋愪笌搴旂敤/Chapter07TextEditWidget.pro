; Chapter07TextEditWidget.pro
PRO Chapter07TextEditWidget_event, event
  COMMON Chapter07TextEditBlock, Message
  WIDGET_CONTROL, event.ID, GET_UVALUE = EventValue
  CASE EventValue OF
    "NAME" : BEGIN
       WIDGET_CONTROL, event.ID, GET_VALUE = NewName
       WIDGET_CONTROL, Message, SET_VALUE = NewName
     END
  ENDCASE
END
PRO Chapter07TextEditWidget
  COMMON Chapter07TextEditBlock, Message
  MyBase = WIDGET_BASE(TITLE = 'My Text Window', /COLUMN)
  MyRow1 = WIDGET_BASE(MyBase, /ROW, /FRAME)
  MyLabel = WIDGET_LABEL(MyRow1, VALUE = 'Name:')
  MyName = WIDGET_TEXT(MyRow1, /EDITABLE, XSIZE = 95, YSIZE = 1, $
    UVALUE = 'NAME')
  MyRow2 = WIDGET_BASE(MyBase, /ROW, /FRAME)
  MessageLabel = WIDGET_LABEL(MyRow2, VALUE = 'Message: ')
  Message = WIDGET_TEXT(MyRow2, $
    VALUE = 'Enter a name and press RETURN.', $
    XSIZE = 90, YSIZE = 1, UVALUE = 'MESSAGE')
  WIDGET_CONTROL, MyBase, /REALIZE
  XMANAGER, 'Chapter07TextEditWidget', MyBase, /NO_BLOCK
END




