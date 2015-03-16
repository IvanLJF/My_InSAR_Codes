; 
; IDL Event Callback Procedures
; Chapter07WidgetInfo_eventcb
; 
; Generated on:	03/06/2005 09:36.16
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

end
; 
; Empty stub procedure used for autoloading.
; 
pro Chapter07WidgetInfo_eventcb
end
