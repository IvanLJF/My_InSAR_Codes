; Chapter07ListWidget.pro
PRO Chapter07ListWidget_EVENT, event
  CASE event.INDEX OF
    0: MyTemp = DIALOG_MESSAGE('Item One Selcted',/INFORMATION)
    1: MyTemp = DIALOG_MESSAGE('Item Two Selcted',/INFORMATION)
    2: MyTemp = DIALOG_MESSAGE('Item Three Selcted',/INFORMATION)
    3: MyTemp = DIALOG_MESSAGE('Item Four Selcted',/INFORMATION)
    4: MyTemp = DIALOG_MESSAGE('Item Five Selcted',/INFORMATION)
    5: MyTemp = DIALOG_MESSAGE('Item Six Selcted',/INFORMATION)
    6: MyTemp = DIALOG_MESSAGE('Item Seven Selcted',/INFORMATION)
    7: MyTemp = DIALOG_MESSAGE('Item Eight Selcted',/INFORMATION)
    8: MyTemp = DIALOG_MESSAGE('Item Nine Selcted',/INFORMATION)
    9: MyTemp = DIALOG_MESSAGE('Item Ten Selcted',/INFORMATION)
  ENDCASE
END
PRO Chapter07ListWidget
  MyBase = WIDGET_BASE(TITLE='My Droplist', XSIZE = 500, /COLUMN)
  ListItems = ['Item One',  'Item Two',  'Item Three', $
               'Item Four', 'Item Five', 'Item Six',   $
               'Item Seven','Item Eight','Item Nine','Item Ten']
  MyLabel = WIDGET_LABEL(MyBase,VALUE='Please Select: ', XSIZE = 100)
  MyDList = WIDGET_LIST(MyBase, VALUE = ListItems, $
            XSIZE=400, YSIZE = 8)
  WIDGET_CONTROL, MyBase, /REALIZE
  XMANAGER, 'Chapter07ListWidget', MyBase
END







