 ;- 
;- Purpose:
;-     Do common test for the project
;- Calling Sequence:
;-    
;- Inputs:
;-    
;- Optional Input Parameters:
;- 
;- Keyword Input Parameters:
;-    
;- Outputs:
;-
;- Commendations:
;-
;- Modification History:
;-
PRO TESTIDL

  DEVICE, DECOMPOSED=0
  WINDOW, 5
  image5= LOADDATA(7)
  TV, image5
  XCOLORS, MOTIFYPRO='display', TITLE='Window 5 colors', image=image5, WID=5
  
  
END