PRO TEST_DELAUNAY

  ; Simulate some regular points.
  x= FINDGEN(10)*10
  y= x
  coors=indexarr(x=x, y=y)
  
  TRIANGULATE, x,y, connectivity=list
  
END