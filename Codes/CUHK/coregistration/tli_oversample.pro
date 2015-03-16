;+
; Name:
;    TLI_OVERSAMPLE
; Purpose:
;    Oversample input array.
; Calling Sequence:
;    result= TLI_OVERSAMPLE(arr, ovs_factor_l, ovs_factor_p)
; Inputs:
;    arr           :  Input array to be oversampledl
;    ovs_factor_l  :  Over sample factor in line direction.
;                     New lines= old lines* ovs_factor_l.
;    ovs_factor_p  :  Over sample factor in pixel/sample direction.
;                     New pixels= old pixels* ovs_factor_p.
; Keyword Input Parameters:
;   Rebin         : Use inner function "Rebin"
;   Congrid       : Use inner function "Congrid"
;   Expand        : Use inner pro "Expand"
;   odd           : Keep the dimensions odd. E.g. 3*3 -> 5*5 instead of 3*3 -> 6*6
; Outputs:
;    Oversampled array.
; Commendations:
;    arr           :  Size of arr MUST be (2^n * 2^n).
;    ovs_factor_l  :  MUST be 2^n.
;    ovs_factor_p  :  MUST be 2^n.
; Example:
;    arr= DIST(64)
;    ovs_factor_l=4
;    ovs_factor_p=4
;    result= TLI_OVERSAMPLE(arr, ovs_factor_l, ovs_factor_p)
; Modification History:
;    05/01/2012    :  Written by T.Li @ InSAR Team in SWTJU & CUHK.
;-

FUNCTION TLI_OVERSAMPLE, arr, ovs_factor_l, ovs_factor_p, rebin=rebin, congrid=congrid, expand=expand, odd=odd

  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 3 THEN Message, 'Usage: result= TLI_OVERSAMPLE(arr, ovs_factor_l, ovs_factor_p)'
  
  ; Define Params
  sz= SIZE(arr,/DIMENSIONS)
  
  l=sz[1]
  p=sz[0]
  halfl= l/2
  halfp= p/2
  l2= ovs_factor_l*l
  p2= ovs_factor_p*p
  
  
  IF NOT KEYWORD_SET(rebin) AND NOT KEYWORD_SET(congrid) AND NOT KEYWORD_SET(expand) THEN BEGIN
    a=arr
    
    ; Chek params
    IF (~TLI_ISPOWER2(l) AND (ovs_factor_l NE 1)) THEN BEGIN
      Message, 'TLI_OVERSAMPLE ERROR: Size of input arr should be of 2^n!'
    ENDIF
    IF (~TLI_ISPOWER2(p) AND (ovs_factor_p NE 1)) THEN BEGIN
      Message, 'TLI_OVERSAMPLE ERROR: Size of input arr should be of 2^n!'
    ENDIF
    
    sz= SIZE(arr)
    type= sz[3]
    IF type EQ 6 THEN BEGIN
      half= COMPLEX(0.5)
    ENDIF ELSE BEGIN
      half= 0.5
    ENDELSE
    
    ; oversample
    res=COMPLEXARR(p2,l2)
    ;  IF ovs_factor_l EQ 1 THEN BEGIN
    ;
    ;    a= FFT(a, -1,DIMENSION=2) ; FFT in line direction.
    ;    a[halfp,0:(l-1)]=a[halfp,0:(l-1)];*half
    ;    res[0:(halfp), 0:(l-1)]= a[0:(halfp), 0:(l-1)]
    ;    res[(p2-halfp):(p2-1),0:(l-1)]=a[(halfp):(p-1),0:(l-1)]
    ;    res= FFT(res,1,DIMENSION=2)
    ;    stop
    ;  ENDIF ELSE BEGIN
    ;    IF ovs_factor_p EQ 1 THEN BEGIN
    ;      a= FFT(a,-1,DIMENSION=1); FFT in pixel direction
    ;      a[0:(p-1),halfl]=a[0:(p-1),halfl];*half
    ;      res[0:(p-1),0:(halfl)]=a[0:(p-1),0:(halfl)]
    ;      res[0:(p-1),halfl:(l-1)]=a[0:(p-1),halfl:(l-1)]
    ;      res= FFT(res, 1, DIMENSION=1)
    ;
    ;    ENDIF ELSE BEGIN
    a=FFT(a, -1);
    a[halfp,0:(l-1)]=a[halfp,0:(l-1)]*half
    a[0:(p-1),halfl]=a[0:(p-1),halfl]*half
    res[0:halfp, 0:halfl]= a[0:halfp, 0:halfl]
    res[(p2-halfp):(p2-1), 0:halfl]=a[halfp:(p-1),0:halfl]
    res[0:halfp, (l2-halfl):(l2-1)]=a[0:halfp, halfl:(l-1)]
    res[(p2-halfp):(p2-1), (l2-halfl):(l2-1)]= a[halfp:(p-1),halfl:(l-1)]
    res= FFT(res, 1)
    ;    ENDELSE
    ;  ENDELSE
    ;  res= res*(ovs_factor_l*ovs_factor_p)
    
    t_code=SIZE(arr, /TYPE)
    IF t_code NE 6 AND t_code NE 9 THEN BEGIN
      RETURN, ABS(res)  ; Not complex data, return the amplitude
    ENDIF ELSE BEGIN
      RETURN, res
    ENDELSE
  ENDIF ELSE BEGIN
  
    IF KEYWORD_SET(odd) THEN BEGIN
      IF TLI_ISODD(p) AND TLI_ISODD(l) THEN BEGIN
        p2=p2-1
        l2=l2-1
        
        IF KEYWORD_SET(rebin) THEN BEGIN
          rebin=0     ; Rebin does't work in this circumstance.
          congrid=1
        ENDIF
        
      ENDIF
    ENDIF
    
    Case 1 OF
      KEYWORD_SET(congrid): BEGIN
        RETURN, CONGRID(arr, p2, l2)
      END
      
      KEYWORD_SET(rebin): BEGIN
        IF TLI_ISINTEGER(ovs_factor_l,/convert) AND TLI_ISINTEGER(ovs_factor_p,/convert) THEN BEGIN
          RETURN, REBIN(arr, p2, l2)
        ENDIF ELSE BEGIN
          RETURN, CONGRID(arr, p2, l2,/INTERP)
        ENDELSE
      END
      
      KEYWORD_SET(expand): BEGIN
        Expand, arr, p2, l2, result
        RETURN, result
      END
      
      ELSE: Message, 'Error! TLI_OVERSAMPLE: Interpolate method not supported!'
      
    ENDCASE
    
    
  ENDELSE
  
END