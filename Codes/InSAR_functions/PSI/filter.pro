;LP_filter.pro
Function filter, imagine
  kernelSize=[2.3,2.3]   
  kernel=REPLICATE((1./(kernelSize[0]*kernelSize[1])),kernelSize[0],kernelSize[1]) 

  filteredIm=CONVOL(float(imagine),kernel,/CENTER,/EDGE_TRUNCATE)
  
  return, filteredIm
End
