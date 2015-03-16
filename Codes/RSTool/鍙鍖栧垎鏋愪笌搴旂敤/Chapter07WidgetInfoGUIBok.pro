;
; IDL Widget Interface Procedures. This Code is automatically
;     generated and should not be modified.

;
; Generated on: 03/07/2005 08:51.03
;
pro WID_BASE_3_event, Event

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
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_1'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        OK, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='W_MENU_4'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        RGBEnable1, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_2'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        RGBEnable1, Event
    end
    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_3'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        OK, Event
    end
    else:
  endcase

end

pro WID_BASE_3, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_

  Resolve_Routine, 'Chapter07WidgetInfoGUIB_eventcb',/COMPILE_FULL_FILE  ; Load event callback routines

  WID_BASE_3 = Widget_Base( GROUP_LEADER=wGroup, UNAME='WID_BASE_3'  $
      ,XOFFSET=5 ,YOFFSET=5 ,SCR_XSIZE=600 ,SCR_YSIZE=249 ,TITLE='My'+ $
      ' Window' ,SPACE=3 ,XPAD=3 ,YPAD=3 ,MBAR=WID_BASE_3_MBAR)


  WID_BUTTON_0 = Widget_Button(WID_BASE_3, UNAME='WID_BUTTON_0'  $
      ,XOFFSET=182 ,YOFFSET=155 ,SCR_XSIZE=214 ,SCR_YSIZE=29  $
      ,/ALIGN_CENTER ,VALUE='OK')


  WID_SLIDER_0 = Widget_Slider(WID_BASE_3, UNAME='WID_SLIDER_0'  $
      ,XOFFSET=30 ,YOFFSET=62 ,SCR_XSIZE=223 ,SCR_YSIZE=41  $
      ,TITLE='R')


  WID_SLIDER_1 = Widget_Slider(WID_BASE_3, UNAME='WID_SLIDER_1'  $
      ,XOFFSET=29 ,YOFFSET=107 ,SCR_XSIZE=223 ,SCR_YSIZE=41  $
      ,TITLE='G')


  WID_SLIDER_2 = Widget_Slider(WID_BASE_3, UNAME='WID_SLIDER_2'  $
      ,XOFFSET=313 ,YOFFSET=61 ,SCR_XSIZE=223 ,SCR_YSIZE=41  $
      ,TITLE='B')


  WID_BASE_0 = Widget_Base(WID_BASE_3, UNAME='WID_BASE_0'  $
      ,XOFFSET=314 ,YOFFSET=116 ,SCR_XSIZE=229 ,SCR_YSIZE=22  $
      ,TITLE='IDL' ,COLUMN=1 ,/NONEXCLUSIVE)


  WID_BUTTON_1 = Widget_Button(WID_BASE_0, UNAME='WID_BUTTON_1'  $
      ,/ALIGN_LEFT ,VALUE='  R G B  Color  Enable / Disable')


  W_MENU_0 = Widget_Button(WID_BASE_3_MBAR, UNAME='W_MENU_0' ,/MENU  $
      ,VALUE='&File')


  W_MENU_1 = Widget_Button(W_MENU_0, UNAME='W_MENU_1' ,VALUE='OK')

  W_MENU_3 = Widget_Button(WID_BASE_3_MBAR, UNAME='W_MENU_3' ,/MENU  $
      ,VALUE='&RGB')


  W_MENU_4 = Widget_Button(W_MENU_3, UNAME='W_MENU_4' ,VALUE='RGB'+ $
      ' Color Enable / Disable')


  WID_BASE_1 = Widget_Base(WID_BASE_3, UNAME='WID_BASE_1' ,FRAME=1  $
      ,XOFFSET=6 ,YOFFSET=3 ,SCR_XSIZE=574 ,SCR_YSIZE=50 ,TITLE='IDL'  $
      ,SPACE=3 ,XPAD=3 ,YPAD=3)


  WID_BUTTON_2 = Widget_Button(WID_BASE_1, UNAME='WID_BUTTON_2'  $
      ,XOFFSET=13 ,YOFFSET=6 ,SCR_XSIZE=36 ,SCR_YSIZE=36  $
      ,/ALIGN_CENTER ,VALUE='Chapter07WidgetInfoGUIB1.bmp' ,/BITMAP)


  WID_BUTTON_3 = Widget_Button(WID_BASE_1, UNAME='WID_BUTTON_3'  $
      ,XOFFSET=62 ,YOFFSET=6 ,SCR_XSIZE=36 ,SCR_YSIZE=36  $
      ,/ALIGN_CENTER ,VALUE='Chapter07WidgetInfoGUIB2.bmp' ,/BITMAP)

  Widget_Control, /REALIZE, WID_BASE_3

  State = {CheckStatus : 1}

  WIDGET_CONTROL, WID_BUTTON_1, SET_BUTTON = 1

  WIDGET_CONTROL, WID_BASE_3, SET_UVALUE = State

  XManager, 'WID_BASE_3', WID_BASE_3, /NO_BLOCK

end
;
; Empty stub procedure used for autoloading.
;
pro Chapter07WidgetInfoGUIB, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
  WID_BASE_3, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
end
