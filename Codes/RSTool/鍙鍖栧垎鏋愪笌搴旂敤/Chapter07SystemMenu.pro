; Chapter07SystemMenu.pro
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
PRO Chapter07SystemMenu
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase', MBAR = SystemMenuBase)
    FileMenu = WIDGET_BUTTON(SystemMenuBase, VALUE='&File', /MENU)
    MyOpen = WIDGET_BUTTON(FileMenu, VALUE='&Open', EVENT_PRO='OpenProcedure')
    MySave = WIDGET_BUTTON(FileMenu, VALUE='&Save', EVENT_PRO='SaveProcedure')
    MyExit = WIDGET_BUTTON(FileMenu, VALUE='&Exit', EVENT_PRO='ExitProcedure', /SEPARATOR)
    EditMenu = WIDGET_BUTTON(SystemMenuBase, VALUE='&Edit', /MENU)
    Mycopy = WIDGET_BUTTON(EditMenu, VALUE='&Copy', EVENT_PRO='CopyProcedure')
    MyPaste = WIDGET_BUTTON(EditMenu, VALUE='&Paste', EVENT_PRO='PasteProcedure')
    HelpMenu = WIDGET_BUTTON(SystemMenuBase, VALUE='&Help', /MENU)
    MyContents = WIDGET_BUTTON(HelpMenu, VALUE='C&ontents', EVENT_PRO='ContentsProcedure')
    MyTopic = WIDGET_BUTTON(HelpMenu, VALUE='&Topic', /MENU)
    MyFunction = WIDGET_BUTTON(MyTopic, VALUE='&Function', EVENT_PRO='FunctionProcedure')
    MyAbout = WIDGET_BUTTON(MyTopic, VALUE='&About', EVENT_PRO='AboutProcedure')

    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07SystemMenu', MyBase
END