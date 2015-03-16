FUNCTION TLI_INTEGRATED_PATH, ptattrfile, plistfile, pt_ind, refind
  ;- Purpose
  ;-     Extract integrated path from ptattrfile
  ;- ptattrfile: Our points attributes file.
  ;- plistfile : Our points coordinates file.
  ;- pt_ind    : Start point's index.
  ;- refind    : Reference point's index.
  ;- Return:
  ;-     [ind, x, y]
  npt=TLI_PNUMBER(plistfile)
  
  pt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
  pt_attr= REPLICATE(pt_attr, npt)
  
  OPENR, lun, ptattrfile,/GET_LUN
  READU, lun, pt_attr
  FREE_LUN, lun
  
  ptattr_ind= pt_attr[pt_ind]
  
  
  ; Find path from reference point to this point.
  path_ind=0
  pt_parent= ptattr_ind.parent
  While pt_parent NE -1 DO BEGIN
    path_ind=[path_ind, pt_parent]
    pt_parent= pt_attr[pt_parent].parent
  ENDWHILE
  IF path_ind[0] EQ 0 AND N_ELEMENTS(path_ind) EQ 1 THEN Message, 'This is a single point'
  
  path_ind=path_ind[1:*]
  
  ref_node= WHERE(path_ind EQ refind)
  IF ref_node[0] EQ -1 THEN BEGIN
    temp=N_ELEMENTS(path_ind)
    refind_n=path_ind[temp-1]
    Print, 'Reference point index can not be found. We guess you use another point with index:', refind_n
    Message, 'Error! Integrated from unknown start point.'
  ENDIF
  plist= TLI_READDATA(plistfile, samples=1, format='FCOMPLEX')
  plist= plist[*, path_ind]
  path_coor= [TRANSPOSE(path_ind), REAL_PART(plist), IMAGINARY(plist)]
  
  RETURN, path_coor
END
