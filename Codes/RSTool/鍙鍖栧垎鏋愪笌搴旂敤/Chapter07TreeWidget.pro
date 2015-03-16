; Chapter07TreeWidget.pro
PRO Chapter07TreeWidget_event, ev
  WIDGET_CONTROL, ev.ID, GET_UVALUE=uName
  IF (N_ELEMENTS(uName) NE 0) THEN BEGIN
    IF (uName EQ 'LEAF') THEN BEGIN
      IF (ev.CLICKS EQ 2) THEN TWE_ToggleValue, ev.ID
    ENDIF
    IF (uName EQ 'DONE') THEN WIDGET_CONTROL, ev.TOP, /DESTROY
  ENDIF
END
PRO TWE_ToggleValue, widID
  WIDGET_CONTROL, widID, GET_VALUE=curVal
  full_string = STRSPLIT(curVal, ':', /EXTRACT)
  full_string[1] = (full_string[1] EQ ' Off') ? ': On' : ': Off'
  WIDGET_CONTROL, widID, SET_VALUE=STRJOIN(full_string)
END
PRO Chapter07TreeWidget
  wTLB = WIDGET_BASE(/COLUMN,TITLE=' My Tree',XSIZE=600,YSIZE=160 )
  wTree = WIDGET_TREE(wTLB)
  wtRoot = WIDGET_TREE(wTree, VALUE='Root', /FOLDER, /EXPANDED)
  wtLeaf11 = WIDGET_TREE(wtRoot, VALUE='Setting 1-1: Off', $
    UVALUE='LEAF')
  wtBranch12 = WIDGET_TREE(wtRoot,VALUE='Branch 1-2', /FOLDER,/EXPANDED)
  wtLeaf121 = WIDGET_TREE(wtBranch12, VALUE='Setting 1-2-1: Off', $
    UVALUE='LEAF')
  wtLeaf122 = WIDGET_TREE(wtBranch12, VALUE='Setting 1-2-2: Off', $
    UVALUE='LEAF')
  wtLeaf13 = WIDGET_TREE(wtRoot, VALUE='Setting 1-3: Off', $
    UVALUE='LEAF')
  wtLeaf14 = WIDGET_TREE(wtRoot, VALUE='Setting 1-4: Off', $
    UVALUE='LEAF')
  wDone = WIDGET_BUTTON(wTLB, VALUE="Done", UVALUE='DONE')
  WIDGET_CONTROL, wTLB, /REALIZE
  XMANAGER, 'Chapter07TreeWidget', wTLB, /NO_BLOCK
END

