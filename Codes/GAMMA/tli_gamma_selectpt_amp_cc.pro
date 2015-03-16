; 
; - Select PS using DA & amp & cc
;

PRO TLI_GAMMA_SELECTPT_AMP_CC
  
  workpath='/mnt/software/myfiles/Software/experiment/GAMMA/IPTA_demo/select_PS'
  cc_thresh=0.5
  samples=400
  
  workpath=workpath+PATH_SEP()
  plist_finalfile=workpath+'plist_final'
  ptfile=workpath+'pt'
  cc_avefile=workpath+'cc_ave'
  cc_listfile=workpath+'cc_list'
  itabfile=workpath+'itab'
  sarlistfile=workpath+'SLC_tab'
  
  plist=TLI_READDATA(ptfile, samples=2, format='LONG',/swap_endian)
  x=plist[0, *]
  y=plist[1, *]
  ; Read cc file
  cc=TLI_READDATA(cc_avefile, samples=samples, format='FCOMPLEX',/swap_endian)
  
  ; Extract cc on the given point
  cc_pt= cc[x, y]
  Print, cc_pt[0:3]
  Print, MAX(cc, min=mincc)
  Print, mincc
  ; Using threshold to maitain good points.
  ind=WHERE(cc_pt GE cc_thresh)
  new_x= x[*,ind]
  new_y= y[*,ind]
  new_pt=[x,y]
  
  ; Write file
  OPENW, lun, plist_finalfile,/GET_LUN
  WRITEU, lun, new_pt
  FREE_LUN, lun
  OPENW, lun, plist_finalfile+'.txt',/GET_LUN
  PrintF, lun, new_pt
  FREE_LUN, lun
  
END