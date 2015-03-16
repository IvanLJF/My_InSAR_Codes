; Chapter07WidgetInfo.pro
pro OK, Event
    WIDGET_CONTROL, Event.TOP, /DESTROY
end
pro RColor, Event
    WIDGET_CONTROL, Event.ID, GET_VALUE = RValue
    MyTemp = DIALOG_MESSAGE('R Color: '+STRING(RValue),/INFORMATION)
end
pro GColor, Event
    WIDGET_CONTROL, Event.ID, GET_VALUE = RValue
    MyTemp = DIALOG_MESSAGE('G Color: '+STRING(RValue),/INFORMATION)
end
pro BColor, Event
    WIDGET_CONTROL, Event.ID, GET_VALUE = RValue
    MyTemp = DIALOG_MESSAGE('B Color: '+STRING(RValue),/INFORMATION)
end
pro RGBEnable, Event
    RColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_0')
    GColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_1')
    BColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_2')
    IF Event.SELECT EQ 1 THEN BEGIN
       WIDGET_CONTROL, RColorID, SENSITIVE = 1
       WIDGET_CONTROL, GColorID, SENSITIVE = 1
       WIDGET_CONTROL, BColorID, SENSITIVE = 1
    ENDIF ELSE BEGIN
       WIDGET_CONTROL, RColorID, SENSITIVE = 0
       WIDGET_CONTROL, GColorID, SENSITIVE = 0
       WIDGET_CONTROL, BColorID, SENSITIVE = 0
    ENDELSE
end
pro MyBase_event, Event
  wTarget = (widget_info(Event.id,/NAME) eq 'TREE' ?  $
      widget_info(Event.id, /tree_root) : event.id)
  wWidget =  Event.top
  case wTarget of
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_0'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        OK, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_0'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_SLIDER' )then $
        RColor, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_1'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_SLIDER' )then $
        GColor, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_2'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_SLIDER' )then $
        BColor, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_1'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        RGBEnable, Event
    end
    else:
  endcase
end
pro MyBase, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
  MyBase = Widget_Base( GROUP_LEADER=wGroup, UNAME='MyBase'  $
      ,XOFFSET=5 ,YOFFSET=5 ,SCR_XSIZE=600 ,SCR_YSIZE=198 ,TITLE='My'+ $
      ' Window' ,SPACE=3 ,XPAD=3 ,YPAD=3)
  WID_BUTTON_0 = Widget_Button(MyBase, UNAME='WID_BUTTON_0'  $
      ,XOFFSET=173 ,YOFFSET=118 ,SCR_XSIZE=214 ,SCR_YSIZE=29  $
      ,/ALIGN_CENTER ,VALUE='OK')
  WID_SLIDER_0 = Widget_Slider(MyBase, UNAME='WID_SLIDER_0'  $
      ,XOFFSET=33 ,YOFFSET=16 ,SCR_XSIZE=223 ,SCR_YSIZE=41  $
      ,TITLE='R')
  WID_SLIDER_1 = Widget_Slider(MyBase, UNAME='WID_SLIDER_1'  $
      ,XOFFSET=33 ,YOFFSET=63 ,SCR_XSIZE=223 ,SCR_YSIZE=41  $
      ,TITLE='G')
  WID_SLIDER_2 = Widget_Slider(MyBase, UNAME='WID_SLIDER_2'  $
      ,XOFFSET=313 ,YOFFSET=15 ,SCR_XSIZE=223 ,SCR_YSIZE=41  $
      ,TITLE='B')
  WID_BASE_0 = Widget_Base(MyBase, UNAME='WID_BASE_0'  $
      ,XOFFSET=316 ,YOFFSET=72 ,SCR_XSIZE=229 ,SCR_YSIZE=22  $
      ,TITLE='IDL' ,COLUMN=1 ,/NONEXCLUSIVE)
  WID_BUTTON_1 = Widget_Button(WID_BASE_0, UNAME='WID_BUTTON_1'  $
      ,/ALIGN_LEFT ,VALUE='  R G B  Color  Enable / Disable')
  Widget_Control, /REALIZE, MyBase
  WIDGET_CONTROL, WID_BUTTON_1, SET_BUTTON = 1
  XManager, 'MyBase', MyBase, /NO_BLOCK
end
pro Chapter07WidgetInfo, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
  MyBase, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
end
