;
; Test the phase-gradient based subsidence rate algorithm.
;
; Written by :
;   T.LI @ ISEIS, 20131223
;
PRO TEST_PHASE_GRD_SUB_RATE

  ; Pre-defined params.
  workpath='/mnt/backup/ExpGroup/TSX_PS_HK_Airport'
  workpath=workpath+PATH_SEP()
  resultpath=workpath+'Phase_GRD_SUB'
  basepath=resultpath+'base'   ; Generated using base_all.sh
  sarlistfile_GAMMA=workpath+'SLC_tab'
  itabfile=workpath+'itab'
  plistfile_GAMMA=workpath+'pt'
  pdifffile_GAMMA=workpath+'pdiff0'
  
  itabstr=TLI_READMYFILES(itabfile,type='itab')
  
  Print, itabstr.valid_itab
  STOP
  
END