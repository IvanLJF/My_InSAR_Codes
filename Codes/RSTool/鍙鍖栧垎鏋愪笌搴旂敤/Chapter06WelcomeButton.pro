; Chapter06WelcomeButton.pro

pro Welcome, Event

  Result = DIALOG_MESSAGE('ª∂”≠ π”√IDL6.0!' , /INFORMATION , TITLE='My Welcome Window' )

end

pro MyCancel, Event

  WIDGET_CONTROL, Event.top, /DESTROY

end

pro Chapter06WelcomeButton

  WID_BASE_0 = Widget_Base( GROUP_LEADER=wGroup, UNAME='WID_BASE_0'  $
      ,XOFFSET=5 ,YOFFSET=5 ,SCR_XSIZE=300 ,SCR_YSIZE=200  $
      ,TITLE='My Button Window' ,SPACE=3 ,XPAD=3 ,YPAD=3)

  Welcome = Widget_Button(WID_BASE_0, UNAME='Welcome' ,XOFFSET=75  $
      ,YOFFSET=35 ,SCR_XSIZE=136 ,SCR_YSIZE=36 ,/ALIGN_CENTER  $
      ,VALUE='Welcome' , EVENT_PRO='welcome', /PUSHBUTTON_EVENTS)

  MyCancel = Widget_Button(WID_BASE_0, UNAME='MyCancel' ,XOFFSET=75  $
      ,YOFFSET=85 ,SCR_XSIZE=136 ,SCR_YSIZE=36 ,/ALIGN_CENTER  $
      ,VALUE='Cancel' , EVENT_PRO='MyCancel', /PUSHBUTTON_EVENTS)


  Widget_Control, /REALIZE, WID_BASE_0

  XManager, 'WID_BASE_0', WID_BASE_0, /NO_BLOCK

end
