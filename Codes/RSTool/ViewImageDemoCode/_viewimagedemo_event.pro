;
;
PRO _Viewimagedemo_event, event
  COMPILE_OPT idl2

  tlbUName = WIDGET_INFO(event.top, /UName)
   
  CASE tlbUName OF
    'wBase' : BEGIN
      WIDGET_CONTROL, event.top, Get_UValue = oSystem
      oSystem->Handleevent, event
    END

  ELSE :
ENDCASE
END
