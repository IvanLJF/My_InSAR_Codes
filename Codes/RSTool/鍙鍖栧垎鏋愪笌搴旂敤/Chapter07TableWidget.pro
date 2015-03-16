; Chapter07TableWidget.pro
PRO Chapter07TableWidget_event, ev
  WIDGET_CONTROL, ev.top, GET_UVALUE=stash
  disjoint = WIDGET_INFO(stash.table, /TABLE_DISJOINT_SELECTION)
  selection = WIDGET_INFO(stash.table, /TABLE_SELECT)
  IF (selection[0] ne -1) THEN hasSelection=1 ELSE hasSelection = 0
  IF (hasSelection) THEN $
    WIDGET_CONTROL, stash.table,GET_VALUE=value, /USE_TABLE_SELECT
  IF ((ev.ID eq stash.table) AND hasSelection) THEN BEGIN
    WSET, stash.draw
    PLOT, value
  ENDIF
  IF ((ev.ID eq stash.b_value) AND hasSelection) THEN BEGIN
    IF (disjoint eq 0) THEN BEGIN
      WIDGET_CONTROL, stash.text, SET_VALUE=STRING(value, /PRINT)
    ENDIF ELSE BEGIN
      WIDGET_CONTROL, stash.text, SET_VALUE=STRING(value)
    ENDELSE
  ENDIF
  IF ((ev.ID eq stash.b_select) AND hasSelection) THEN BEGIN
    IF (disjoint eq 0) THEN BEGIN
      list0 = 'Standard Selection'
      list1 = 'Left:   ' + STRING(selection[0])
      list2 = 'Top:    ' + STRING(selection[1])
      list3 = 'Right:  ' + STRING(selection[2])
      list4 = 'Bottom: ' + STRING(selection[3])
      list = [list0, list1, list2, list3, list4]
    ENDIF ELSE BEGIN
      n = N_ELEMENTS(selection)
      list = STRARR(n/2+1)
      list[0] = 'Disjoint Selection'
      FOR j=0,n-1,2 DO BEGIN
        list[j/2+1] = 'Column: ' + STRING(selection[j]) + $
           ', Row: ' + STRING(selection[j+1])
      ENDFOR
    ENDELSE
    WIDGET_CONTROL, stash.text, SET_VALUE=list
  ENDIF
  IF (ev.ID eq stash.b_change) THEN BEGIN
    IF (disjoint eq 0) THEN BEGIN
      WIDGET_CONTROL, stash.table, TABLE_DISJOINT_SELECTION=1
      WIDGET_CONTROL, stash.b_change, $
        SET_VALUE='Change to Standard Selection Mode'
    ENDIF ELSE BEGIN
      WIDGET_CONTROL, stash.table, TABLE_DISJOINT_SELECTION=0
      WIDGET_CONTROL, stash.b_change, $
        SET_VALUE='Change to Disjoint Selection Mode'
    ENDELSE
  ENDIF
  IF (ev.ID eq stash.b_quit) THEN WIDGET_CONTROL, ev.TOP, /DESTROY
END
PRO Chapter07TableWidget
  data = DIST(7)
  help = ['Select data from the table below using the mouse.']
  base = WIDGET_BASE(/COLUMN)
  subbase1 = WIDGET_BASE(base, /ROW)
  draw = WIDGET_DRAW(subbase1, XSIZE=250, YSIZE=250)
  subbase2 = WIDGET_BASE(subbase1, /COLUMN)
  text = WIDGET_text(subbase2, XS=50, YS=8, VALUE=help, /SCROLL)
  b_value = WIDGET_BUTTON(subbase2, VALUE='Show Selected Data')
  b_select = WIDGET_BUTTON(subbase2, VALUE='Show Selected Cells')
  b_change = WIDGET_BUTTON(subbase2, $
    VALUE='Change to Disjoint Selection Mode')
  b_quit = WIDGET_BUTTON(subbase2, VALUE='Quit')
  table = WIDGET_TABLE(base, VALUE=data, /ALL_EVENTS)
  WIDGET_CONTROL, base, /REALIZE
  WIDGET_CONTROL, draw, GET_VALUE=drawID
  stash = {draw:drawID, table:table, text:text, b_value:b_value, $
           b_select:b_select, b_change:b_change, b_quit:b_quit}
  WIDGET_CONTROL, base, SET_UVALUE=stash
  XMANAGER, 'Chapter07TableWidget', base
END

