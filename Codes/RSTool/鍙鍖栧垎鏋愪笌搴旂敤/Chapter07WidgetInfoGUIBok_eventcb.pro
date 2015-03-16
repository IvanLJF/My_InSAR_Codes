;
; IDL Event Callback Procedures
; Chapter07WidgetInfoGUIB_eventcb
;
; Generated on: 03/07/2005 08:51.03
;
;-----------------------------------------------------------------
; Activate Button Callback Procedure.
; Argument:
;   Event structure:
;
;   {WIDGET_BUTTON, ID:0L, TOP:0L, HANDLER:0L, SELECT:0}
;
;   ID is the widget ID of the component generating the event. TOP is
;       the widget ID of the top level widget containing ID. HANDLER
;       contains the widget ID of the widget associated with the
;       handler routine.

;   SELECT is set to 1 if the button was set, and 0 if released.
;       Normal buttons do not generate events when released, so
;       SELECT will always be 1. However, toggle buttons (created by
;       parenting a button to an exclusive or non-exclusive base)
;       return separate events for the set and release actions.

;   Retrieve the IDs of other widgets in the widget hierarchy using
;       id=widget_info(Event.top, FIND_BY_UNAME=name)

;-----------------------------------------------------------------
pro OK, Event
    WIDGET_CONTROL, Event.TOP, /DESTROY
end
;-----------------------------------------------------------------
; Slider Value Changed Callback Procedure.
; Argument:
;   Event structure:
;
;   {WIDGET_SLIDER, ID:0L, TOP:0L, HANDLER:0L, VALUE:0L, DRAG:0}
;
;   ID is the widget ID of the component generating the event. TOP is
;       the widget ID of the top level widget containing ID. HANDLER
;       contains the widget ID of the widget associated with the
;       handler routine.

;   VALUE returns the new value of the slider. DRAG returns integer 1
;       if the slider event was generated as part of a drag
;       operation, or zero if the event was generated when the user
;       had finished positioning the slider.

;   Retrieve the IDs of other widgets in the widget hierarchy using
;       id=widget_info(Event.top, FIND_BY_UNAME=name)

;-----------------------------------------------------------------
pro RColor, Event
    WIDGET_CONTROL, Event.ID, GET_VALUE = RValue
    MyTemp = DIALOG_MESSAGE('R Color: '+STRING(RValue),/INFORMATION)
end
;-----------------------------------------------------------------
; Slider Value Changed Callback Procedure.
; Argument:
;   Event structure:
;
;   {WIDGET_SLIDER, ID:0L, TOP:0L, HANDLER:0L, VALUE:0L, DRAG:0}
;
;   ID is the widget ID of the component generating the event. TOP is
;       the widget ID of the top level widget containing ID. HANDLER
;       contains the widget ID of the widget associated with the
;       handler routine.

;   VALUE returns the new value of the slider. DRAG returns integer 1
;       if the slider event was generated as part of a drag
;       operation, or zero if the event was generated when the user
;       had finished positioning the slider.

;   Retrieve the IDs of other widgets in the widget hierarchy using
;       id=widget_info(Event.top, FIND_BY_UNAME=name)

;-----------------------------------------------------------------
pro GColor, Event
    WIDGET_CONTROL, Event.ID, GET_VALUE = RValue
    MyTemp = DIALOG_MESSAGE('G Color: '+STRING(RValue),/INFORMATION)
end
;-----------------------------------------------------------------
; Slider Value Changed Callback Procedure.
; Argument:
;   Event structure:
;
;   {WIDGET_SLIDER, ID:0L, TOP:0L, HANDLER:0L, VALUE:0L, DRAG:0}
;
;   ID is the widget ID of the component generating the event. TOP is
;       the widget ID of the top level widget containing ID. HANDLER
;       contains the widget ID of the widget associated with the
;       handler routine.

;   VALUE returns the new value of the slider. DRAG returns integer 1
;       if the slider event was generated as part of a drag
;       operation, or zero if the event was generated when the user
;       had finished positioning the slider.

;   Retrieve the IDs of other widgets in the widget hierarchy using
;       id=widget_info(Event.top, FIND_BY_UNAME=name)

;-----------------------------------------------------------------
pro BColor, Event
    WIDGET_CONTROL, Event.ID, GET_VALUE = RValue
    MyTemp = DIALOG_MESSAGE('B Color: '+STRING(RValue),/INFORMATION)
end
;-----------------------------------------------------------------
; Activate Button Callback Procedure.
; Argument:
;   Event structure:
;
;   {WIDGET_BUTTON, ID:0L, TOP:0L, HANDLER:0L, SELECT:0}
;
;   ID is the widget ID of the component generating the event. TOP is
;       the widget ID of the top level widget containing ID. HANDLER
;       contains the widget ID of the widget associated with the
;       handler routine.

;   SELECT is set to 1 if the button was set, and 0 if released.
;       Normal buttons do not generate events when released, so
;       SELECT will always be 1. However, toggle buttons (created by
;       parenting a button to an exclusive or non-exclusive base)
;       return separate events for the set and release actions.

;   Retrieve the IDs of other widgets in the widget hierarchy using
;       id=widget_info(Event.top, FIND_BY_UNAME=name)

;-----------------------------------------------------------------
pro RGBEnable, Event
    WIDGET_CONTROL, Event.TOP, GET_UVALUE=State
    RColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_0')
    GColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_1')
    BColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_2')
    IF Event.SELECT EQ 1 THEN BEGIN
       State.CheckStatus = 1
       WIDGET_CONTROL, RColorID, SENSITIVE = 1
       WIDGET_CONTROL, GColorID, SENSITIVE = 1
       WIDGET_CONTROL, BColorID, SENSITIVE = 1
    ENDIF ELSE BEGIN
       State.CheckStatus = 1
       WIDGET_CONTROL, RColorID, SENSITIVE = 0
       WIDGET_CONTROL, GColorID, SENSITIVE = 0
       WIDGET_CONTROL, BColorID, SENSITIVE = 0
    ENDELSE
    WIDGET_CONTROL, Event.TOP, SET_UVALUE=State
end
pro RGBEnable1, Event
    WIDGET_CONTROL, Event.TOP, GET_UVALUE=State
    RColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_0')
    GColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_1')
    BColorID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_SLIDER_2')
    ButtonID = Widget_Info(Event.TOP, FIND_BY_UNAME='WID_BUTTON_1')
    IF State.CheckStatus EQ 1 THEN BEGIN
       State.CheckStatus = 0
       WIDGET_CONTROL, RColorID, SENSITIVE = 0
       WIDGET_CONTROL, GColorID, SENSITIVE = 0
       WIDGET_CONTROL, BColorID, SENSITIVE = 0
       WIDGET_CONTROL, ButtonID, SET_BUTTON = 0
    ENDIF ELSE BEGIN
       State.CheckStatus = 1
       WIDGET_CONTROL, RColorID, SENSITIVE = 1
       WIDGET_CONTROL, GColorID, SENSITIVE = 1
       WIDGET_CONTROL, BColorID, SENSITIVE = 1
       WIDGET_CONTROL, ButtonID, SET_BUTTON = 1
    ENDELSE
    WIDGET_CONTROL, Event.TOP, SET_UVALUE=State
end
;
; Empty stub procedure used for autoloading.
;
pro Chapter07WidgetInfoGUIB_eventcb
end
