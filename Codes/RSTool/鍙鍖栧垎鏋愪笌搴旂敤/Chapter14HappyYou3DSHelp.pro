; Chapter14HappyYou3DSHelp.pro
PRO Chapter14HappyYou3DSHelp, fileName, TITLE = title
  Device, GET_SCREEN_SIZE = screenSize
  width = 480  &  height = 320
  windowStartx = (screenSize[0] - width)/2.0
  windowStarty = (screenSize[1] - height)/2.0
  OPENR, unit, fileName, /GET_LUN
  maxLines = 160
  infoText = STRARR(MAXLINES)
  lineNumber = 0
  lineOfText = ''
  lineLength  = 0
  WHILE NOT EOF(unit) DO BEGIN
    READF, unit, lineOfText
    lineLength = lineLength > STRLEN(lineOfText)
    infoText[lineNumber] = lineOfText
    lineNumber = lineNumber + 1
  ENDWHILE
  FREE_LUN, unit
  wInfoWindow = WIDGET_BASE(TITLE=title,XOFFSET=windowStartx, YOFFSET=windowStarty, $
           SCR_XSIZE=width, SCR_YSIZE=height, /SCROLL, /TLB_SIZE_EVENTS)
  wInfoText = WIDGET_TEXT(wInfoWindow, XSIZE=width, YSIZE=height, $
                          VALUE=infoText, NO_NEWLINE=0, /WRAP)
  WIDGET_CONTROL, wInfoWindow, /REALIZE
  Xmanager, "Chapter14HappyYou3DSHelp", wInfoWindow
END