; Chapter07ButtonMenu.pro
PRO OpenProcedure, event
  Result = DIALOG_MESSAGE('File -> Open Selected!', /INFORMATION)
END
PRO SaveProcedure, event
  Result = DIALOG_MESSAGE('File -> Save Selected!', /INFORMATION)
END
PRO CopyProcedure, event
  Result = DIALOG_MESSAGE('Edit -> Copy Selected!', /INFORMATION)
END
PRO PasteProcedure, event
  Result = DIALOG_MESSAGE('Edit -> Paste Selected!', /INFORMATION)
END
PRO ContentsProcedure, event
  Result = DIALOG_MESSAGE('Help -> Contents Selected!', /INFORMATION)
END
PRO FunctionProcedure, event
  Result = DIALOG_MESSAGE('Help -> Topic -> Function Selected!', /INFORMATION)
END
PRO AboutProcedure, event
  Result = DIALOG_MESSAGE('Help -> Topic -> About Selected!', /INFORMATION)
END
PRO ExitProcedure, event
  WIDGET_CONTROL, event.TOP, /DESTROY
END
PRO Chapter07ButtonMenu
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase')
    MyButton = WIDGET_BUTTON(MyBase, XSIZE=100,YSIZE=60, $
               XOFFSET = 200, YOFFSET = 60,VALUE='Menu Systemm', /MENU)
    FileMenu = WIDGET_BUTTON(MyButton, VALUE='File', /MENU)
    MyOpen = WIDGET_BUTTON(FileMenu, VALUE='Open', EVENT_PRO='OpenProcedure')
    MySave = WIDGET_BUTTON(FileMenu, VALUE='Save', EVENT_PRO='SaveProcedure')
    MyExit = WIDGET_BUTTON(FileMenu, VALUE='Exit', EVENT_PRO='ExitProcedure')
    EditMenu = WIDGET_BUTTON(MyButton, VALUE='Edit', /MENU)
    Mycopy = WIDGET_BUTTON(EditMenu, VALUE='Copy', EVENT_PRO='CopyProcedure')
    MyPaste = WIDGET_BUTTON(EditMenu, VALUE='Paste', EVENT_PRO='PasteProcedure')
    HelpMenu = WIDGET_BUTTON(MyButton, VALUE='Help', /MENU)
    MyContents = WIDGET_BUTTON(HelpMenu, VALUE='C&ontents', EVENT_PRO='ContentsProcedure')
    MyTopic = WIDGET_BUTTON(HelpMenu, VALUE='Topic', /MENU)
    MyFunction = WIDGET_BUTTON(MyTopic, VALUE='Function', EVENT_PRO='FunctionProcedure')
    MyAbout = WIDGET_BUTTON(MyTopic, VALUE='About', EVENT_PRO='AboutProcedure')

    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07ButtonMenu', MyBase
END