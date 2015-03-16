;- Find the prox point index for coor in plist.
FUNCTION TLI_PROX_PT_SINGLE, coor, plist, ind=ind
  COMPILE_OPT idl2
  dis=ABS(plist-coor)
  dis_min=MIN(dis, ind)
  RETURN, plist[ind]
END