PRO TEST_DECOMP

  y= RANDOMN(3, 20)
  coef= DIGITAL_FILTER(0.2,0.3, 50, 2)
  
  y_filter= CONVOL(y, coef)
  
  WINDOW,/FREE 
  Plot, y
  oPlot, y_filter

END