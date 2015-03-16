PRO TEST_CINT
  infile= 'D:\ISEIS\Data\Img\master_slave_defo.uint'
  samples= 5195*2
  lines= 5462
  window, xsize=1000,ysize=1000
  result= TLI_SUBSETDATA(infile,samples,lines,5180,1000,0,1000,/float)
  DEVICE, DECOMPOSED=0
  LOADCT,0
  TVSCL, result
END