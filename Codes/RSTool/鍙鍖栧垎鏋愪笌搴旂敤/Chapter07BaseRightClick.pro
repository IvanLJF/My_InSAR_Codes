; Chapter07BaseRightClick.pro
PRO CBE_FirstEvent, event
  Result = DIALOG_MESSAGE('Selection 1 Pressed',/INFORMATION)
END
PRO CBE_SecondEvent, event
  Result = DIALOG_MESSAGE('Selection 2 Pressed',/INFORMATION)
END
PRO CBE_DoneEvent, event
  Result = DIALOG_MESSAGE('Done Pressed and Cancel!',/INFORMATION)
  WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO Chapter07BaseRightClick_event, event
  contextBase = WIDGET_INFO(event.ID, FIND_BY_UNAME = 'contextMenu')
  WIDGET_DISPLAYCONTEXTMENU, event.ID, event.X, event.Y, contextBase
END
PRO Chapter07BaseRightClick
  topLevelBase = WIDGET_BASE(/COLUMN, XSIZE = 500, YSIZE = 300, /CONTEXT_EVENTS)
  contextBase = WIDGET_BASE(topLevelBase, /CONTEXT_MENU, UNAME = 'contextMenu')
  firstButton = WIDGET_BUTTON(contextBase, $
    VALUE = 'Selection 1', EVENT_PRO = 'CBE_FirstEvent')
  secondButton = WIDGET_BUTTON(contextBase, $
    VALUE = 'Selection 2', EVENT_PRO = 'CBE_SecondEvent')
  doneButton = WIDGET_BUTTON(contextBase, VALUE = 'Done', $
    /SEPARATOR, EVENT_PRO = 'CBE_DoneEvent')
  WIDGET_CONTROL, topLevelBase, /REALIZE
  XMANAGER, 'Chapter07BaseRightClick', topLevelBase
END

