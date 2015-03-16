;Chapter07DrawWidget.pro
PRO CDE_LoadCTEvent, event
  XLOADCT, /BLOCK, GROUP = event.ID
  imageDraw = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'imageDisplay')
  WIDGET_CONTROL, imageDraw, GET_VALUE = windowDraw
  WIDGET_CONTROL, event.TOP, GET_UVALUE = image
  WSET, windowDraw
  TV, image
END
PRO CDE_PaletteEvent, event
  XPALETTE, /BLOCK, GROUP = event.ID
  imageDraw = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'imageDisplay')
  WIDGET_CONTROL, imageDraw, GET_VALUE = windowDraw
  WIDGET_CONTROL, event.TOP, GET_UVALUE = image
  WSET, windowDraw
  TV, image
END
PRO CDE_DoneEvent, event
  WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO CDE_DrawEvents, event
  WIDGET_CONTROL, event.TOP, GET_UVALUE = image
  PRINT, 'Column:', event.X
  PRINT, '   Row:', event.Y
  PRINT, ' Value:  ', image[event.X, event.Y]
  IF (event.RELEASE EQ 4) THEN BEGIN
    contextBase = WIDGET_INFO(event.TOP, FIND_BY_UNAME = 'drawContext')
    WIDGET_DISPLAYCONTEXTMENU, event.ID, event.X, event.Y, contextBase
  ENDIF
END
PRO Chapter07DrawWidget
  file = FILEPATH('worldelv.dat', SUBDIRECTORY = ['examples', 'data'])
  imageSize = [360, 360]
  image = READ_BINARY(file, DATA_DIMS = imageSize)
  topLevelBase = WIDGET_BASE(/COLUMN)
  imageDraw = WIDGET_DRAW(topLevelBase, /BUTTON_EVENTS, XSIZE = imageSize[0], $
    YSIZE = imageSize[1], EVENT_PRO = 'CDE_DrawEvents', UNAME = 'imageDisplay')
  contextBase = WIDGET_BASE(topLevelBase, /CONTEXT_MENU, UNAME = 'drawContext')
  loadCTButton = WIDGET_BUTTON(contextBase, VALUE = 'XLOADCT', $
    EVENT_PRO = 'CDE_LoadCTEvent')
  paletteButton = WIDGET_BUTTON(contextBase, VALUE = 'XPALETTE', $
    EVENT_PRO = 'CDE_PaletteEvent')
  doneButton = WIDGET_BUTTON(contextBase, VALUE = 'Done', $
    /SEPARATOR, EVENT_PRO = 'CDE_DoneEvent')
  WIDGET_CONTROL, topLevelBase, /REALIZE
  WIDGET_CONTROL, topLevelBase, SET_UVALUE = image
  WIDGET_CONTROL, imageDraw, GET_VALUE = windowDraw
  WSET, windowDraw
  DEVICE, DECOMPOSED = 0
  LOADCT, 5
  TV, image
  column = imageSize[0]/2
  row = imageSize[1]/2
  TVCRS, column, row
  XMANAGER, 'Chapter07DrawWidget', topLevelBase, /NO_BLOCK
END

