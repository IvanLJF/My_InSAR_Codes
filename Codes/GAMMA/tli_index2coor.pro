FUNCTION TLI_INDEX2COOR, index, samples

  x= index MOD (samples-1)
  y= FLOOR(index /(samples-1))
  RETURN, COMPLEX(x, y)
END