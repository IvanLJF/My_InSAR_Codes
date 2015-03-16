;- 
;- Purpose:
;-    Strech input data according to the given method
;- Calling Sequence:
;-    result=TLI_STRETCH_DATA( inData, outRange, method)
;- Inputs:
;-    inData   : Input array.
;-    outRange : Data range of output data.
;-    method   : Stretch method.
;- Optional Input Parameters:
;-    method
;- Keyword Input Parameters:
;-    inData, outRange
;- Outputs:
;-    Streched array.
;- Commendations:
;-    None
;- Modification History:
;-    24/10/2012: Written by T. Li @ InSAR Group in CUHK

FUNCTION TLI_STRETCH_DATA, inData, outRange, method=method
  COMPILE_OPT idl2
  ; Check input
  IF N_PARAMS() NE 2 THEN Message, 'Usage Error.'
  IF N_ELEMENTS(outRange) NE 2 Then Message, 'Output data range error.'
  IF ~Keyword_set(method) THEN method= 'LINE'
  
  ; Data strech
  minData= MIN(inData)
  maxData= MAX(inData)
  
  outRange=DOUBLE(outRange)
  minOut= outRange[0]
  maxOut= outRange[1]
  
  Case method of
    'LINE': BEGIN
      result= minOut+ (maxOut-minOut)/(maxData-minData)*(inData-minData)
    END
    
    ELSE: BEGIN
      Message, 'Stretch method not supported!'  
    END
  ENDCASE

  Return, result
END