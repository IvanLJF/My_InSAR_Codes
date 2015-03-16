
@tli_psselect
PRO TLI_HPA_INFOEXPAND
;Resolve_All

c= 299792458D ; Speed light
  
  ; Use GAMMA input files.
  ; Only support single master image.
  
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  resultpath=workpath+'/HPA'
  ; Input files
  sarlistfilegamma= workpath+'/SLC_tab'
  pdifffile= workpath+'/pdiff0'
  plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
  plistfile= workpath+'/HPA/plist'
  itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=workpath+'/HPA/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  pbasefile=workpath+'/HPA/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
  plafile=workpath+'/HPA/pla'
  dvddhfile=workpath+'/HPA/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
  vdhfile= workpath+'/HPA/vdh'
  ptattrfile= workpath+'/HPA/ptattr'
  plistfile= resultpath+PATH_SEP()+'plist'                            ; PS点列表
  sarlistfile= resultpath+PATH_SEP()+'sarlist_Linux'                        ; 文件列表
  arcsfile= resultpath+PATH_SEP()+'arcs'                              ; 网络弧段列表
  pslcfile= resultpath+PATH_SEP()+'pslc'                              ; 点位上的SLC
  interflistfile= resultpath+PATH_SEP()+'Interf.list'                 ; 干涉列表
  pbasefile=resultpath+PATH_SEP()+'pbase'                             ; 点位基线文件
  dvddhfile=resultpath+PATH_SEP()+'dvddh'                             ; 弧段相对形变速率以及相对高程误差
  vdhfile= resultpath+PATH_SEP()+'vdh'                                ; 点位形变速率以及高程误差
  ptattrfile= resultpath+PATH_SEP()+'ptattr'                          ; 点位信息文件(包含结算过程中所有有用信息)
  plafile= resultpath+PATH_SEP()+'pla'                                ; 点位侧视角文件
  arcs_resfile= resultpath+PATH_SEP()+'arcs_res'                      ; 弧段残差
  res_phasefile= resultpath+PATH_SEP()+'res_phase'                    ; 点位残差
  time_series_linearfile= resultpath+PATH_SEP()+'time_series_linear'  ; 线性形变
  res_phase_slfile= resultpath+PATH_SEP()+'res_phase_sl'              ; 空间滤波结果
  res_phase_tlfile= resultpath+PATH_SEP()+'res_phase_tl'              ; 时间滤波结果
  final_resultfile= resultpath+PATH_SEP()+'final_result'              ; 形变时间序列
  nonlinearfile= resultpath+PATH_SEP()+'nonlinear'                    ; 非线性形变序列
  atmfile= resultpath+PATH_SEP()+'atm'                                ; 大气残差
  time_seriestxtfile= resultpath+PATH_SEP()+'Deformation_Time_Series_Per_SLC_Acquisition_Date.txt'
  dhtxtfile= resultpath+PATH_SEP()+'HeightError.txt'                  ; 最终产品：高程误差
  vtxtfile= resultpath+PATH_SEP()+'Deformation_Average_Annual_Rate.txt' ; 最终产品：点位年形变速率
  logfile= resultpath+PATH_SEP()+'log'+STRCOMPRESS(SYSTIME(/SECONDS),/REMOVE_ALL)+'.txt'     ; Log file.
  ; If logfile already exist, then append. If not, create a new one.
  IF FILE_TEST(logfile) THEN BEGIN
    OPENW, loglun, logfile,/GET_LUN,/APPEND
  ENDIF ELSE BEGIN
    OPENW, loglun, logfile,/GET_LUN
  ENDELSE
  

END