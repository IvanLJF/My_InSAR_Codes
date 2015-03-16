; Chapter07DroplistWidget.pro
PRO Chapter07DroplistWidget_EVENT, event
  CASE event.INDEX OF
    0: MyTemp = DIALOG_MESSAGE('Item One Selcted',/INFORMATION)
    1: MyTemp = DIALOG_MESSAGE('Item Two Selcted',/INFORMATION)
    2: MyTemp = DIALOG_MESSAGE('Item Three Selcted',/INFORMATION)
    3: MyTemp = DIALOG_MESSAGE('Item Four Selcted',/INFORMATION)
    4: MyTemp = DIALOG_MESSAGE('Item Five Selcted',/INFORMATION)
    5: MyTemp = DIALOG_MESSAGE('Item Six Selcted',/INFORMATION)
  ENDCASE
END
PRO Chapter07DroplistWidget
  MyBase = WIDGET_BASE(TITLE='My Droplist', XSIZE = 500, /COLUMN)
  ListItems = ['Item One',  'Item Two',  'Item Three', $
               'Item Four', 'Item Five', 'Item Six' ]
  MyLabel = WIDGET_LABEL(MyBase,VALUE='Please Select: ', XSIZE = 100)
  MyDList = WIDGET_DROPLIST(MyBase, VALUE = ListItems, $
            XSIZE=400, YSIZE = 100)
  WIDGET_CONTROL, MyBase, /REALIZE
  XMANAGER, 'Chapter07DroplistWidget', MyBase
END







