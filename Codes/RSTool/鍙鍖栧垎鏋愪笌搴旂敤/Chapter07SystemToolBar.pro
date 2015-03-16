PRO Chapter07SystemToolBar
    MyBase =WIDGET_BASE(XSIZE=500,YSIZE=400, TITLE='MyBase', /ToolBar)
    MyButtonBase = Widget_Base(MyBase, FRAME=1, /BASE_ALIGN_CENTER $
      ,XOFFSET=50 ,YOFFSET=50 ,XSIZE=400 ,YSIZE=300, /NONEXCLUSIVE, /ROW)

    MyBeijingButton = WIDGET_BUTTON(MyButtonBase, VALUE='Bei Jing',      $
               EVENT_PRO='BeijingProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=100 )
    MyShanghaiButton = WIDGET_BUTTON(MyButtonBase, VALUE='Shang Hai',    $
               EVENT_PRO='ShanghaiProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=150 )
                MyGuangzhouButton = WIDGET_BUTTON(MyButtonBase, VALUE='Hang Zhou',  $
               EVENT_PRO='HangzhouProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=200 )
    MyExitButton = WIDGET_BUTTON(MyButtonBase, VALUE='EXIT',       $
               EVENT_PRO='ExitProcedure', XSIZE=100, YSIZE=30, $
               XOFFSET=150, YOFFSET=250 )
    WIDGET_CONTROL, MyBase, /REALIZE
    XMANAGER, 'Chapter07CheckButtonWidget', MyBase
END