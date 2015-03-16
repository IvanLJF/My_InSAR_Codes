; Chapter07TextContextWidgetTT.pro
PRO CTE_ColumnEvent, event
  titleLabel = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'xyLabel')
  WIDGET_CONTROL, titleLabel, SET_VALUE = 'Column:  '
END
PRO CTE_RowEvent, event
  titleLabel = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'xyLabel')
  WIDGET_CONTROL, titleLabel, SET_VALUE = 'Row:  '
END
PRO CTE_DoneEvent, event
  WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO CTE_TextEvents, event
  IF (TAG_NAMES(event,/STRUCTURE_NAME) EQ 'WIDGET_CONTEXT') THEN BEGIN
    contextBase = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'contextMenu')
    WIDGET_DISPLAYCONTEXTMENU, event.ID, event.X, event.Y, contextBase
  ENDIF ELSE BEGIN
    WIDGET_CONTROL, event.ID, GET_VALUE = textString
    ON_IOERROR, badnum
    IF ((FIX(textString) GE 0) AND (FIX(textString) LE 360)) THEN BEGIN
      textValue = FIX(textString)
    ENDIF ELSE BEGIN
      badnum:
      dialog=DIALOG_MESSAGE('Please enter a number between 0 and 360')
      WIDGET_CONTROL, event.ID, SET_VALUE=''
      RETURN
    ENDELSE
    titleLabel = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'xyLabel')
    WIDGET_CONTROL, titleLabel, GET_VALUE = MyLabel
    MyMessage = MyLabel + textString
    Result = DIALOG_MESSAGE( MyMessage, /INFORMATION)
  ENDELSE
END
PRO Chapter07TextContextWidgetTT
  topLevelBase = WIDGET_BASE(/COLUMN)
  bigBase = WIDGET_BASE(topLevelBase, /COLUMN, /FRAME)
  bigLabel = WIDGET_LABEL(bigBase,VALUE='Enter a number between 1-360',$
    /DYNAMIC_RESIZE)
  textBase = WIDGET_BASE(bigBase, /ROW)
  titleLabel = WIDGET_LABEL(textBase, VALUE = 'My Title: ', $
    /DYNAMIC_RESIZE, UNAME = 'xyLabel')
  locationText = WIDGET_TEXT(textBase, VALUE = '180', $
    /EDITABLE, UNAME = 'xyText', /CONTEXT_EVENTS, $
    UVALUE = location, EVENT_PRO = 'CTE_TextEvents',XSIZE = 80)
  contextBase = WIDGET_BASE(topLevelBase, /CONTEXT_MENU, UNAME = 'contextMenu')
  columnButton = WIDGET_BUTTON(contextBase, $
    VALUE = 'Column', EVENT_PRO = 'CTE_ColumnEvent')
  rowButton = WIDGET_BUTTON(contextBase, $
    VALUE = 'Row', EVENT_PRO = 'CTE_RowEvent')
  doneButton = WIDGET_BUTTON(contextBase, VALUE = 'Done', $
    /SEPARATOR, EVENT_PRO = 'CTE_DoneEvent')
  WIDGET_CONTROL, topLevelBase, /REALIZE
  XMANAGER, 'Chapter07TextContextWidgetTT', topLevelBase
END

