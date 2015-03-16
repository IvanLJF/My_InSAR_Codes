;
; Chapter07Chapter07MRTSlider.pro
;
pro ContrastEnhancement, Event

  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState

  IF Event.SELECT EQ 0 THEN BEGIN

     widget_control, (*pState).Mslider, SENSITIVE = 0
     widget_control, (*pState).Rslider, SENSITIVE = 0
     widget_control, (*pState).Tslider, SENSITIVE = 0

  ENDIF ELSE BEGIN

     widget_control, (*pState).Mslider, SENSITIVE = 1
     widget_control, (*pState).Rslider, SENSITIVE = 1
     widget_control, (*pState).Tslider, SENSITIVE = 1

  ENDELSE

  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState

end
pro MSliderChangeValue, Event

  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState

  widget_control, (*pState).Mslider, get_value=TempMsliderValue
  widget_control, (*pState).Rslider, get_value=TempRsliderValue
  widget_control, (*pState).Tslider, get_value=TempTsliderValue

  M = TempMsliderValue                           ; You need !!
  R = TempRsliderValue                           ; You need !!
  T = TempTsliderValue                           ; You need !!

  PRINT, M, R, T                                 ; Output  Result !!

  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState

end

pro RSliderChangeValue, Event

  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState

  widget_control, (*pState).Mslider, get_value=TempMsliderValue
  widget_control, (*pState).Rslider, get_value=TempRsliderValue
  widget_control, (*pState).Tslider, get_value=TempTsliderValue

  CASE TempRsliderValue OF

     1: BEGIN

          widget_control, (*pState).Tslider, set_slider_min = 1
          widget_control, (*pState).Tslider, set_slider_max = 1

          widget_control, (*pState).Tslider, set_value=1

          widget_control, (*pState).Tslider, SENSITIVE = 0

          M = TempMsliderValue         ; You need !!
          R = TempRsliderValue         ; You need !!
          T = 0.25                     ; You need !!

          PRINT, M, R, T               ; Output  Result !!

        END

     2: BEGIN

          widget_control, (*pState).Tslider, set_slider_min = 1
          widget_control, (*pState).Tslider, set_slider_max = 1

          widget_control, (*pState).Tslider, set_value=1

          widget_control, (*pState).Tslider, SENSITIVE = 0

          M = TempMsliderValue         ; You need !!
          R = TempRsliderValue         ; You need !!
          T = 0.5                      ; You need !!

          PRINT, M, R, T               ; Output  Result !!

        END

     3: BEGIN

          widget_control, (*pState).Tslider, set_slider_min = 1
          widget_control, (*pState).Tslider, set_slider_max = 1

          widget_control, (*pState).Tslider, set_value=1

          widget_control, (*pState).Tslider, SENSITIVE = 0

          M = TempMsliderValue         ; You need !!
          R = TempRsliderValue         ; You need !!
          T = 0.75                     ; You need !!

          PRINT, M, R, T               ; Output  Result !!

        END

     ELSE: BEGIN

          widget_control, (*pState).Tslider, SENSITIVE = 1

          widget_control, (*pState).Tslider, set_slider_min = 1
          widget_control, (*pState).Tslider, set_slider_max = TempRsliderValue / 2

          IF TempTsliderValue LE FIX(TempRsliderValue / 2) THEN BEGIN

             widget_control, (*pState).Tslider, set_value=TempTsliderValue

          ENDIF ELSE BEGIN

             widget_control, (*pState).Tslider, set_value=TempRsliderValue / 2

          ENDELSE

          M = TempMsliderValue                           ; You need !!
          R = TempRsliderValue                           ; You need !!
          T = TempTsliderValue < TempRsliderValue / 2    ; You need !!

          PRINT, M, R, T                                 ; Output  Result !!

        END

  ENDCASE

  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState

end

pro TSliderChangeValue, Event

  WIDGET_CONTROL, Event.Top, GET_UVALUE= pState

  widget_control, (*pState).Mslider, get_value=TempMsliderValue
  widget_control, (*pState).Rslider, get_value=TempRsliderValue
  widget_control, (*pState).Tslider, get_value=TempTsliderValue

  M = TempMsliderValue                           ; You need !!
  R = TempRsliderValue                           ; You need !!
  T = TempTsliderValue                           ; You need !!

  PRINT, M, R, T                                 ; Output  Result !!

  WIDGET_CONTROL, Event.Top, SET_UVALUE= pState

end
;
; Empty stub procedure used for autoloading.
;
pro Chapter07MRTSlider_eventcb
end


pro WID_BASE_0_event, Event

  wTarget = (widget_info(Event.id,/NAME) eq 'TREE' ?  $
      widget_info(Event.id, /tree_root) : event.id)

  wWidget =  Event.top

  case wTarget of

    Widget_Info(wWidget, FIND_BY_UNAME='WID_BUTTON_0'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_BUTTON' )then $
        ContrastEnhancement, Event
    end

    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_0'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_SLIDER' )then $
        MSliderChangeValue, Event
    end

    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_1'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_SLIDER' )then $
        RSliderChangeValue, Event
    end

    Widget_Info(wWidget, FIND_BY_UNAME='WID_SLIDER_2'): begin
      if( Tag_Names(Event, /STRUCTURE_NAME) eq 'WIDGET_SLIDER' )then $
        TSliderChangeValue, Event
    end
    else:
  endcase

end

pro WID_BASE_0, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_

  Resolve_Routine, 'Chapter07MRTSlider_eventcb',/COMPILE_FULL_FILE  ; Load event callback routines

  WID_BASE_0 = Widget_Base( GROUP_LEADER=wGroup, UNAME='WID_BASE_0'  $
      ,XOFFSET=5 ,YOFFSET=5 ,SCR_XSIZE=483 ,SCR_YSIZE=302  $
      ,TITLE='IDL' ,SPACE=3 ,XPAD=3 ,YPAD=3)


  Mslider = Widget_Slider(WID_BASE_0, UNAME='WID_SLIDER_0'  $
      ,XOFFSET=132 ,YOFFSET=44 ,SCR_XSIZE=242 ,SCR_YSIZE=37  $
      ,MINIMUM=1 ,MAXIMUM=127, VALUE=100)


  Rslider = Widget_Slider(WID_BASE_0, UNAME='WID_SLIDER_1'  $
      ,XOFFSET=131 ,YOFFSET=101 ,SCR_XSIZE=242 ,SCR_YSIZE=37  $
      ,MINIMUM=1 ,MAXIMUM=100, VALUE=50)


  Tslider = Widget_Slider(WID_BASE_0, UNAME='WID_SLIDER_2'  $
      ,XOFFSET=132 ,YOFFSET=165 ,SCR_XSIZE=242 ,SCR_YSIZE=37  $
      ,MINIMUM=1 ,MAXIMUM=25, VALUE=15)


  WID_LABEL_0 = Widget_Label(WID_BASE_0, UNAME='WID_LABEL_0'  $
      ,XOFFSET=99 ,YOFFSET=63 ,SCR_XSIZE=33 ,SCR_YSIZE=20  $
      ,/ALIGN_LEFT ,VALUE='M')


  WID_BASE_1 = Widget_Base(WID_BASE_0, UNAME='WID_BASE_1'  $
      ,XOFFSET=120 ,YOFFSET=13 ,TITLE='IDL' ,COLUMN=1 ,/NONEXCLUSIVE)


  WID_BUTTON_0 = Widget_Button(WID_BASE_1, UNAME='WID_BUTTON_0'  $
      ,/ALIGN_LEFT ,VALUE='Contrast Enhancement')


  WID_LABEL_1 = Widget_Label(WID_BASE_0, UNAME='WID_LABEL_1'  $
      ,XOFFSET=101 ,YOFFSET=123 ,SCR_XSIZE=28 ,SCR_YSIZE=20  $
      ,/ALIGN_LEFT ,VALUE='R')


  WID_LABEL_2 = Widget_Label(WID_BASE_0, UNAME='WID_LABEL_2'  $
      ,XOFFSET=103 ,YOFFSET=186 ,SCR_XSIZE=30 ,SCR_YSIZE=18  $
      ,/ALIGN_LEFT ,VALUE='T')


  Widget_Control, /REALIZE, WID_BASE_0
  pState = PTR_NEW({        $

        WID_BASE_0:WID_BASE_0,        $
        WID_BUTTON_0: WID_BUTTON_0,   $
        Mslider: Mslider,             $
        Rslider: Rslider,             $
        Tslider: Tslider              $

    })

  WIDGET_CONTROL, WID_BASE_0, SET_UVALUE=pState

  widget_control, (*pState).Mslider, SENSITIVE = 0
  widget_control, (*pState).Rslider, SENSITIVE = 0
  widget_control, (*pState).Tslider, SENSITIVE = 0

  XManager, 'WID_BASE_0', WID_BASE_0, /NO_BLOCK

end
;
; Empty stub procedure used for autoloading.
;
pro Chapter07MRTSlider, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
  WID_BASE_0, GROUP_LEADER=wGroup, _EXTRA=_VWBExtra_
end
