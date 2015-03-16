;
; Generate dummy information.
;
; Parameters:
;
; Keywords:
;   inputstr    : Input string to display;
;   err         : Set this keyword to 1 as an error.
;   info        : Set this kkeyword to 1 as an info
; Example:
;
; Written by:
;   T.LI @ Sasmac, 20141224
;
PRO TLI_SMC_DUMMY, inputstr=inputstr, error=error, information=information
  
  COMMON TLI_SMC_GUI, types, file, wid, config
  
  IF NOT KEYWORD_SET(error) AND NOT KEYWORD_SET(information) THEN information=1
  
  IF NOT KEYWORD_SET(inputstr) THEN inputstr='An error was encountered.'
  
  info= ['',$
    inputstr,$
    '',$
    tli_egg(), $
    '',$
    ' InSAR Tools Using GAMMA Software ', $
    ' For development users only.',$
    ' R&D Dept., Sasmac',$
    '',$
    'Press OK to Quit.']
  void=DIALOG_MESSAGE(info, DIALOG_PARENT = wid.base,TITLE='Exit Sasmac InSAR',INFORMATION=information,/CENTER, error=error)
  
END