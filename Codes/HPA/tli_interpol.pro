; Interpolate the values at the given time.
; tbaselines  : temporal baselines of the array.
; tbaseline   : Temporal baselines to use.
; ind         : Index of the nearest Temporal baselines.
; method      : The method to use.
FUNCTION TLI_INTERPOL, array, tbaselines, tbaseline,ind=ind, method=method
  COMPILE_OPT idl2
  
  sz=SIZE(array,/DIMENSIONS)
  lines=sz[1]
  IF lines NE N_ELEMENTS(tbaselines) THEN Message, 'Error: The baselines are not consistent with array size.'
  IF NOT KEYWORD_SET(method) THEN method='linear'
  
  CASE STRLOWCASE(method) OF
    'linear': BEGIN
      nearest_tbase=TLI_NEAREST_DATA(tbaseline, tbaselines,ind=ind)
      IF ind[0] EQ -1 THEN BEGIN
        Print, 'Warning: The given tbaseline is smaller than any element of tbaselines.'
        Print, '         Return the values with reference to the smallest baseline.'
        result=array[*,ind[1]]
        RETURN, result
      ENDIF
      
      IF ind[1] EQ -1 THEN BEGIN
        Print, 'Warning: The given tbaseline is greater than any element of tbaselines.'
        Print, '         Return the values with reference to the greatest baseline.'
        result=array[*,ind[0]]
        RETURN, result
      ENDIF
      
      IF ind[0] EQ ind[1] THEN BEGIN
        result=array[*, ind[0]]
        RETURN, result
      ENDIF
      
      coef=(tbaseline-nearest_tbase[0])/(nearest_tbase[1]-nearest_tbase[0])
      result=array[*, ind[0]]+(array[*,ind[1]]-array[*, ind[0]])*coef
      RETURN, result
      
    END
    
  ENDCASE
  
END