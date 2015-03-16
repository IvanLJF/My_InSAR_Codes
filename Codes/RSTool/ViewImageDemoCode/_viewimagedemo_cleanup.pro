;
;
PRO _Viewimagedemo_cleanup, tlb
  COMPILE_OPT idl2

  tlbUName = WIDGET_INFO(tlb, /UName)

  CASE tlbUName OF
    'wBase' : BEGIN
      WIDGET_CONTROL, tlb, Get_UValue = oSystem

      IF N_ELEMENTS(oSystem) EQ 0 THEN HEAP_GC ELSE OBJ_DESTROY, oSystem
    END
  ELSE :
ENDCASE
END