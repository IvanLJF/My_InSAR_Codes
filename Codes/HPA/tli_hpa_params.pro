PRO TLI_HPA_PARAMS
  time_start= SYSTIME(/SECONDS)
  
  c= 299792458D ; Speed light
  CLOSE,/ALL
  temp= ALOG(2)
  e= 2^(1/temp)
  ; Use GAMMA input files.
  ; Only support single master image.
  
  ;  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023'
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  workpath=workpath+PATH_SEP()
  resultpath=workpath+'/HPA'
  resultpath=resultpath+PATH_SEP()
  ; Input files
  logfile= resultpath+'log.txt'
  sarlistfilegamma= workpath+'SLC_tab'
  pdifffile= workpath+'pdiff0'
  plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
  plistfile= resultpath+'plist'
  itabfile= workpath+'itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=resultpath+'arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  pbasefile=resultpath+'pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
  plafile=resultpath+'pla'
  pslcfile= resultpath+'pslc'
  dvddhfile=resultpath+'dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
  vdhfile= resultpath+'vdh'
  ptattrfile= resultpath+'ptattr'
  
  mskfile= resultpath+'msk'
  
  lel1plistfile= plistfile+'update'
  lel1pbasefile= pbasefile+'update'
  lel1plafile= plafile+'update'
  lel1ptstructfile=resultpath+'lel1pstruct'
  lel1ptattrfile= ptattrfile+'update'
  
  lel2plistfile= resultpath+'lel2plist'
  lel2pslcfile= resultpath+'lel2pslc'
  lel2pbasefile= resultpath+'lel2pbase'
  lel2plafile= resultpath+'lel2pla'
  lel2ptattrfile= resultpath+'lel2ptattr'
  lel2ptstructfile= resultpath+'lel2ptstruct'
  lel2vdhfile= resultpath+'lel2vdh'
  
  lel2ptstructfile_update=lel2ptstructfile+'_update'  
  lel2vdhfile_merge= resultpath+'lel2vdh_merge'
  lel2plistfile_update= resultpath+'lel2plist_update'
  lel2ptattrfile_update= resultpath+'lel2ptattr_update'
  lel2pbasefile_update= resultpath+'lel2pbase_update'
  lel2plafile_update= resultpath+'lel2pla_update'
  lel2pslcfile_update= resultpath+'lel2pslc_update'
  
  lel3plistfile=resultpath+'lel3plist'
  lel3ptstructfile=resultpath+'lel3ptstruct'
  lel3pslcfile= resultpath+'lel3pslc'
  lel3pbasefile= resultpath+'lel3pbase'
  lel3plafile= resultpath+'lel3pla'
  
  sarlistfile= resultpath+'sarlist_Linux'
  pbasefile= resultpath+'pbase'
  plafile= resultpath+'pla'
  basepath= resultpath+'base'
  
  dv_inc=1 ; Increased percent of v is not larger than dv_inc
  ddh_inc=10 ; Increased percent of dh is not larger thatn ddh_inc
  mask_pt_corr=0.8
  mask_arc= 0.8
  mask_pt_coh= 0.8
  refind= refind
  v_acc= 3
  dh_acc= 10
  adj_dist=10      ; Distance to locate adjacent points for consistency checking.
END