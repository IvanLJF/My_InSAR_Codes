;+ 
; Name:
;    TLI_SpreadPoints
; Purpose:
;    Spread points in the given area.
; Calling Sequence:
;    Result= TLI_SpreadPoints(Range,pointsperl=pointsperl, pointspers=pointspers, allpoints=allpoints)
; Inputs:
;    Range      :  Area to spread points. [pixel low, pixel high, line low, line high]
; Keyword Input Parameters:
;    pointsperl :  Points per line
;    pointspers :  Points per sample
;    allpoints  :  All points distributed here. If keywords opintsperl & pointspers are set, then this keyword is ignored.
; Outputs:
;    Well-distributed points in the region.
; Commendations:
;    Better use pointsperl & poiintspers.
; Example:
;    range=[0,1050,600,1007]
;    pointsperl= 10
;    pointspers= 11
;    allpoints=11
;    result=TLI_SPREADPOINTS(Range, pointsperl=pointsperl, pointspers=pointspers, allpoints=allpoints)
; Modification History:
;    03/05/2012        :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;-  
Function TLI_SpreadFromCenter, vector,n

  COMPILE_OPT idl2 
  ; Extract n elements from center of vector
  sz= Double(N_ELEMENTS(vector))
  If n GT sz THEN Message, 'ERROR!'
  IF sz MOD 2 THEN BEGIN;Not devisible by 2
    cter= CEIL(sz/2)
    IF n MOD 2 THEN BEGIN; Not devisible by 2. Good!
      r= FLOOR(n/2)
      res= vector[(cter-1-r):(cter-1+r)]
      help, res
      print, res
      RETURN, res
    ENDIF ELSE BEGIN
      r= (n/2)
      res= vector[(cter-1-r):(cter-1+r-1)]
      RETURN, res      
    ENDELSE
  ENDIF ELSE BEGIN
    cter= sz/2
    IF n MOD 2 THEN BEGIN; Not devisible by 2. Good!
      r= FLOOR(n/2)
      res= vector[(cter-1-r):(cter-1+r)]
      RETURN, res
    ENDIF ELSE BEGIN
      r= (n/2)
      res= vector[(cter-1-r+1):(cter-1+r)]
      RETURN, res
    ENDELSE
  ENDELSE
END
Function TLI_SPREADPOINTS, Range, pointsperl=pointsperl, pointspers=pointspers, allpoints=allpoints
  
  compile_opt idl2
  
  IF n_elements(range) NE 4 then begin
    message, 'Range must contains for elements!'
  endif
  
  IF keyword_set(pointsperl) AND keyword_set(pointspers) THEN BEGIN ;Points number= pointsperl*pointspers
    step_perl= (range[1]-range[0]+1)/(pointsperl-1)
    step_pers= (range[3]-range[2]+1)/(pointspers-1)
    
    x= FINDGEN(pointsperl)*step_perl+range[0]-1
    y= FINDGEN(pointspers)*step_pers+range[2]-1
    
    x[0]=x[0]+1 & x[pointsperl-1]=range[1]
    y[0]=y[0]+1 & y[pointspers-1]=range[3]
    result= indexarr(x=Long(x), y=Long(y))
    result= reform(result,1,N_elements(result))
    return, result
  endif else begin
    IF ~keyword_set(allpoints) Then message, 'ERROR! Keyword allpoints not set!';Well-distribute points
    
    input_lines= DOUBLE(range[3]-range[2])
    input_samples= DOUBLE(range[1]-range[0])
    IF input_lines/input_samples GE 1 THEN BEGIN
      ratio= FLOOR(input_lines/input_samples)
      pointsperl_n= FLOOR(SQRT(allpoints/ratio))
      IF ~(allpoints MOD pointsperl_n) THEN BEGIN
        pointspers_n= allpoints/pointsperl_n
        
        step_perl= (range[1]-range[0]+1)/(pointsperl_n-1)
        step_pers= (range[3]-range[2]+1)/(pointspers_n-1)
        
        x= FINDGEN(pointsperl_n)*step_perl+range[0]-1
        y= FINDGEN(pointspers_n)*step_pers+range[2]-1
        
        x[0]=x[0]+1 & x[pointsperl_n-1]=range[1]
        y[0]=y[0]+1 & y[pointspers_n-1]=range[3]
        result= indexarr(x=Long(x), y=Long(y))
        result= reform(result,1,N_elements(result))
        return, result
      ENDIF ELSE BEGIN
        pointspers_n= FLOOR(allpoints/pointsperl_n)+1
        
        step_perl= (range[1]-range[0]+1)/(pointsperl_n-1)
        step_pers= (range[3]-range[2]+1)/(pointspers_n-1)
        
        x= FINDGEN(pointsperl_n)*step_perl+range[0]-1
        y= FINDGEN(pointspers_n)*step_pers+range[2]-1
        
        x[0]=x[0]+1 & x[pointsperl_n-1]=range[1]
        y[0]=y[0]+1 & y[pointspers_n-1]=range[3]
        result= indexarr(x=Long(x),y=Long(y))
        sz= SIZE(result)
        
        remain_no= allpoints-(pointspers_n-1)*pointsperl_n
        remain= result[*,sz[2]-1]

        remain= Tli_spreadfromcenter(remain, remain_no)
        
        result= result[*, 0:(sz[2]-2)]
        result= reform(result,N_elements(result),1)
        result= [result, remain]
        result= Transpose(result)

        return, result
      ENDELSE
    ENDIF ELSE BEGIN
        
        ratio= FLOOR(input_samples/input_lines)
        pointsperl_n= FLOOR(SQRT(allpoints*ratio))
      IF ~(allpoints MOD pointsperl_n) THEN BEGIN
        pointspers_n= allpoints/pointsperl_n
        
        step_perl= (range[1]-range[0]+1)/(pointsperl_n-1)
        step_pers= (range[3]-range[2]+1)/(pointspers_n-1)
        
        x= FINDGEN(pointsperl_n)*step_perl+range[0]-1
        y= FINDGEN(pointspers_n)*step_pers+range[2]-1
        
        x[0]=x[0]+1 & x[pointsperl_n-1]=range[1]
        y[0]=y[0]+1 & y[pointspers_n-1]=range[3]
        result= indexarr(x=Long(x), y=Long(y))
        result= reform(result,1,N_elements(result))
        return, result
      ENDIF ELSE BEGIN
        pointspers_n= FLOOR(allpoints/pointsperl_n)+1
        
        step_perl= (range[1]-range[0]+1)/(pointsperl_n-1)
        step_pers= (range[3]-range[2]+1)/(pointspers_n-1)
        
        x= FINDGEN(pointsperl_n)*step_perl+range[0]-1
        y= FINDGEN(pointspers_n)*step_pers+range[2]-1
        
        x[0]=x[0]+1 & x[pointsperl_n-1]=range[1]
        y[0]=y[0]+1 & y[pointspers_n-1]=range[3]
        result= indexarr(x=Long(x),y=Long(y))
        sz= SIZE(result)
        
        remain_no= allpoints-(pointspers_n-1)*pointsperl_n
        remain= result[*,sz[2]-1]
        remain= Tli_spreadfromcenter(remain, remain_no)
        
        result= result[*, 0:(sz[2]-2)]
        result= reform(result,N_elements(result),1)
        result= [result, remain]
        result= Transpose(result)
        return, result
      ENDELSE
    
    ENDELSE
  endelse
END