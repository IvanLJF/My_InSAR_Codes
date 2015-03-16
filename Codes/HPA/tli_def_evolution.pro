;-
;- Calculate the full resolution deformation values.
;-
;- def_v     : deformation velocity. [1 x npt]
;- tbaseline : temporal baselines, [1 x nintf]
;- nonlinear : nonlinear deformation components, [npt x nintf]
;-
;- Written by T.LI @ ISEIS, 20130728

FUNCTION TLI_DEF_EVOLUTION,def_v, tbaselines, nonlinear
  COMPILE_OPT idl2
  
  ; Check the inpur arrays.
  sz1=SIZE(def_v,/DIMENSIONS)
  sz2=SIZE(tbaselines,/DIMENSIONS)
  sz3=SIZE(nonlinear,/DIMENSIONS)
  IF sz1[0] NE 1 THEN Message, 'Def_v should be a one column array.'
  IF sz2[0] NE 1 THEN Message, 'baselines should be a one column array.'
  IF sz3[0] NE sz1[1] OR sz3[1] NE sz2[1] THEN Message,$
   'Nonlinear components seems to be wrong. Its size is'+STRJOIN(STRCOMPRESS(sz3))+'.'+$
   'It should be :'+STRJOIN(STRCOMPRESS([sz1[1], sz2[1]]))
 
  ; calculate the full resolution result
  result= tbaselines##(TRANSPOSE(def_v))+nonlinear 
  RETURN, result
END