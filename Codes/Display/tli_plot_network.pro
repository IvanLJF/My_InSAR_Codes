;
; Plot the delaunay triangulates for the input file.
;
; Written by:
;   T.LI @ SWJTU, 20140318
;
PRO TLI_PLOT_NETWORK, bmpfile, arcsfile, outputfile=outputfile, show=show

  COMPILE_OPT idl2
  
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=arcsfile+'.bmp'
  
  
  arcs=TLI_READMYFILES(arcsfile, type='arcs')
  narcs=(SIZE(arcs,/DIMENSIONS))[1]
  avepwr= READ_IMAGE(bmpfile)
  sz=SIZE(avepwr,/DIMENSIONS)
  
  
  
  maxdim=800D
  maxxy=sz[0]>sz[1]
  scale=maxdim/maxxy          ;  Strech scale for all the coordinates
  sz=sz*scale
  
  
  avepwr=CONGRID(avepwr, sz[0], sz[1])
  WINDOW, XSIZE=sz[0], YSIZE=sz[1]
  TV, avepwr
  DEVICE, DECOMPOSED=0
  TVLCT, 0,255,0,1
  TVSCL, avepwr
  
  FOR i=0D, narcs-1D DO BEGIN
    coor= arcs[*, i]
    PLOTS, [REAL_PART(coor[0])*scale,REAL_PART(coor[1])*scale], $
      [(sz[1]-IMAGINARY(coor[0])*scale), (sz[1]-IMAGINARY(coor[1])*scale)], $
      color=1,/DEVICE
    IF ~(i MOD 40000) THEN BEGIN
      Print, i
    ENDIF
  ENDFOR
  result= TVRD(/true)
  ; Get suffix
  temp=TLI_FNAME(outputfile, format=format)
  WRITE_IMAGE, outputfile,format, result
  STOP
END