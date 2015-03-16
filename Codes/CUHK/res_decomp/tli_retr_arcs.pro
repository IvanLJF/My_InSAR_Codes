;-
;- Purpose:
;-     Retrieve arcs from the network.
;-     Result is organized as [startind endind]
;-     Start point index is the point that near the reference point

PRO TLI_RETR_ARCS, plistfile, ptattrfile, refind, arcs_resfile=arcs_resfile
  
  ; Read some params from file info.
  npt= TLI_PNUMBER(plistfile)
  plist= TLI_READDATA(plistfile, samples=1, FORMAT='FCOMPLEX')
  
  ; Read ptattr file
  ptattr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
  ptattr= REPLICATE(ptattr, npt)
  OPENR, lun, ptattrfile,/GET_LUN
  READU, lun, ptattr
  FREE_LUN, lun
  
; Reconstruct the connectivities. Organized as [parentnode, childnode]
  pt_msk= BYTARR(npt)
  
  OPENW, lun, arcs_resfile,/GET_LUN
  arcs= COMPLEXARR(3) ; [start_coor, end_coor, COMPLEX(start_ind, end_ind)]
  FOR i=0D, npt-1D DO BEGIN
    
    parent= ptattr[i].parent
    IF parent EQ -1 THEN CONTINUE
    start_coor= plist[parent]
    end_coor= plist[i]
    pairind= COMPLEX(parent, i)
    arcs_i= [start_coor, end_coor, pairind]
    arcs= [[arcs], [arcs_i]]
    IF NOT(i MOD 1000) THEN BEGIN
      Print, STRCOMPRESS(i),'/',STRCOMPRESS(npt-1D)
      arcs=arcs[*, 1:*]
      WriteU, lun, arcs
      arcs=complexarr(3)
    ENDIF
    
  ENDFOR
  ; npt is exactly a multiple of 1000
  IF N_ELEMENTS(arcs) EQ 2 THEN BEGIN
  
  ENDIF ELSE BEGIN
    arcs=arcs[*,1:*]
    WriteU, lun, arcs
  ENDELSE
  
  FREE_LUN, lun
  
END