PRO RES_REMOVAL

COMPILE_OPT idl2

;  ; Define the number of points and the interval:
;  N = 100
;  T = 0.1
;  
;  ; Midpoint+1 is the most negative frequency subscript:
;  N21 = N/2 + 1
;  ; The array of subscripts:
;  F = INDGEN(N)
;  ; Insert negative frequencies in elements F(N/2 +1), ..., F(N-1):
;  F[N21] = N21 -N + FINDGEN(N21-2)
;  
;  ; Compute T0 frequency:
;  F = F/(N*T)
;  
;  ; Shift so that the most negative frequency is plotted first:
;;  PLOT, /YLOG, SHIFT(F, -N21), SHIFT(ABS(FFT(F, -1)), -N21)
;  PLOT, /YLOG, SHIFT(F, -N21), (ABS(FFT(F,-1,/CENTER)))



;      ; Create a cosine wave damped by an exponential.
;      n = 256
;      x = FINDGEN(n)
;      y = COS(x*!PI/6)*EXP(-((x - n/2)/30)^2/2)
;      
;      ; Construct a two-dimensional image of the wave.
;      z = REBIN(y, n, n)
;      ; Add two different rotations to simulate a crystal structure.
;      z = ROT(z, 10) + ROT(z, -45)
;      WINDOW, XSIZE=540, YSIZE=540
;      LOADCT, 39
;      TVSCL, z, 10, 270
;      
;      ; Compute the two-dimensional FFT.
;      f = FFT(z)
;      logpower = ALOG10(ABS(f)^2) ; log of Fourier power spectrum.
;      TVSCL, logpower, 270, 270
;      
;      ; Compute the FFT only along the first dimension.
;      f = FFT(z, DIMENSION=1)
;      logpower = ALOG10(ABS(f)^2) ; log of Fourier power spectrum.
;      TVSCL, logpower, 10, 10
;      
;      ; Compute the FFT only along the second dimension.
;      f = FFT(z, DIMENSION=2)
;      logpower = ALOG10(ABS(f)^2) ; log of Fourier power spectrum.
;      TVSCL, logpower, 270, 10

;--------------lena-------------------
;path= SOURCEROOT()
;infile=path+PATH_SEP()+'lena_horiz_lines.png'
;result= READ_PNG(infile)
;sz= SIZE(result,/DIMENSIONS)
;LOADCT, 0
;WINDOW,0, XSIZE=sz[0], YSIZE=sz[1]
;TV, result
;phase= result

;;---------Simulate Flattening Phase----------
;  phase= FINDGEN(500)*0.1
;  phase= SIN(phase)*!PI;8-9ÆµÂÊ
;  fft_result= FFT(phase,/CENTER)
;  temp= MAX(ABS(fft_result), index)
;  temp= fft_result[index]
;  PRINT, REAL_PART(temp)*500, IMAGINARY(temp)*500
;;  WINDOW,0, XSIZE=500, YSIZE=500, TITLE='Original Image'
;;  PLOT, ABS(FFT(phase,/CENTER))
;  WINDOW,1, XSIZE=500, YSIZE=500, TITLE='Original Image'
;  PLOT, phase

  phase= FINDGEN(500)*0.1
  phase= SIN(phase)*!PI
  phase= REBIN(phase,500,500 )
;  phase= ROT(phase, -45)
;  WINDOW,0, XSIZE=500, YSIZE=500, TITLE='Original Image'
;  DEVICE, DECOMPOSED=0
;  LOADCT, 25
;  TVSCL, phase
;  path= SOURCEROOT()
;  outfile= path+'sim_flt.phase'
;  OPENW, lun, outfile,/GET_LUN
;  WRITEU, lun, phase
;  FREE_LUN, lun
;;----------------FFT-----------------
;;phase= phase[*,0]
;phase= phase[1,*]
  result_fft= FFT(phase,1,/CENTER)
  max_amp= MAX(ABS(result_fft), index)
  result= result_fft[index]
  PRINT, result
  
;  amp= DOUBLE(ALOG(ABS(result_fft)))
;  WINDOW,1, XSIZE=500, YSIZE=500, TITLE='FFT amplitude'
;  LOADCT, 0
;  TVSCL, amp
  
END