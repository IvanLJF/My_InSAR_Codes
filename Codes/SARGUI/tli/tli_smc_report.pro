;
; Report the information provided by the pros.
;
; Parameters:
;   info
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20150105
;
PRO TLI_SMC_REPORT, info
  
  COMMON TLI_SMC_GUI, types, file, wid, config
  
  IF N_PARAMS(info) EQ 0 THEN RETURN
  
  txtid=wid.txt
  
  WIDGET_CONTROL, txtid, get_value=temp
  
  lines=N_ELEMENTS(temp)
  this_lines=N_ELEMENTS(info)
  
  WIDGET_CONTROL, txtid, set_value=info,/APPEND
  
  WIDGET_CONTROL, txtid, set_text_top_line=lines
  
;  WIDGET_CONTROL, txtid, scr_ysize=lines+this_lines

END