;
; Flattening the interferogram.
;
; Parameters:
;   intfile       : Interferogram.
;   samples       : Samples of the file.
;
; Keywords:
;   format        : Float, scomplex, fcomplex, or dcomplex.
;   fltfile       : Flattening phase.
;   outputfile    : Outputfile.
;
; Written by:
;   T.LI @ Sasmac, 20140730.
;   With reference to rm_flatearth_fft.pro(Please use tli_findpro to locate the pro file).

FUNCTION TLI_MAX_EXP, radix, number
  ; Find the maximum exponent that makes sure radix^exp <= number
  result=0
  
  goon=1
  WHILE goon DO BEGIN
    
    temp=radix^result
    
    IF temp GT number THEN BEGIN
      RETURN, result-1
      goon=0
    ENDIF ELSE BEGIN
      result=result+1
    ENDELSE
    
  ENDWHILE
  
END


PRO TLI_FLATTENNING, intfile, samples, format=format, fltfile=fltfile, outputfile=outputfile,swap_endian=swap_endian

  IF NOT KEYWORD_SET(format) THEN Message, 'Error! Please specify format.'
  IF NOT KEYWORD_SET(outputfile) THEN outputfile = intfile+'flt'
  
  sz=TLI_IMAGE_SIZE(intfile, samples=samples, format=format)
  samples=sz[0]
  lines=sz[1]
  
  int=TLI_READDATA(intfile, samples=sz[0],format=format, swap_endian=swap_endian)
  
  ; Convert to fcomplex
  format=STRLOWCASE(format)
  IF format EQ 'float' THEN int=TLI_E()^(COMPLEX(0, int))  
  
  ; Determine the block size.
  sz_new=2^[TLI_MAX_EXP(2, samples), TLI_MAX_EXP(2, lines)]
  
  ; Extract the optimal block to execute FFT.
  int=int[0: (sz_new[0]-1), 0:(sz_new[1]-1)]
  
  freq= MAX(ABS(FFT(int, -1)), pos)
  temp=ARRAY_INDICES(int, pos)
  freq_x=temp[0]
  freq_y=temp[1]
  
  STOP
  
  
  aux = max(abs(fft(arr,-1)),pos)   ; Here is the key script.
  fringex = pos mod bsx
  fringey = pos  /  bsx
  if fringex gt bsx/2 then fringex = fringex - bsx
  if fringey gt bsy/2 then fringey = fringey - bsy
  
  fringex *= (float(file.xdim)/bsx)
  fringey *= (float(file.xdim)/bsx)
  
END