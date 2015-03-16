;
; Calculate the relative deformation rate as well as the DEM error.
;
; Parameters:
;
; Keywords:
;   PSD   : Peridogram (Period Spectral D...)
;   LS    : Least-squared estimation
;   COCO  : Baseine combinations (Proposed by Hongguo Jia).
;   pbase_thresh: Perpendicular baseline threshold.
;   ignore_def  : Set this keyword to 1 to ignore deformation-related information.
;
; Written by :
;   T.LI @ ISEIS, CUHK.
;
; History:
;   20140709: Add keyword 'ignore_def'. T.LI @ SWJTU.
;
PRO TLI_LINEAR_SOLVE_GAMMA, sarlistfile,pdifffile,plistfile,itabfile,arcsfile,pbasefile,plafile,dvddhfile, $
    wavelength, deltar, R1, method=method, pbase_thresh=pbase_thresh,ignore_def=ignore_def
    
  COMPILE_OPT idl2
  
  outfile= dvddhfile
  
  temp= ALOG(2)
  e= 2^(1/temp)
  c= 299792458D ; Speed light
  IF NOT KEYWORD_SET(method) THEN method='PSD'
  log=0
  
  ; File info.
  plistinfo= FILE_INFO(plistfile)
  npt= (plistinfo.size)/8
  pdiffinfo= FILE_INFO(pdifffile)
  nintf= (pdiffinfo.size)/npt/8
  
  ; Read sarlist
  nlines= FILE_LINES(sarlistfile)
  sarlist= STRARR(nlines)
  OPENR, lun, sarlistfile,/GET_LUN
  READF, lun, sarlist
  FREE_LUN, lun
  
  ; Read plist
  plist=TLI_READMYFILES(plistfile, type='plist')
  
  ; Read pdiff
  pdiff= TLI_READDATA(pdifffile, samples=npt, format='FCOMPLEX',/swap_endian)
  
  ; Read itab
  itab_stru=TLI_READMYFILES(itabfile, type='itab')
  nintf_itab=itab_stru.nintf_valid
  IF nintf NE nintf_itab THEN Message, 'ERROR! TLI_LINEAR_SOLVE: pdiff0 and itab are inconsistent!'
  Print, '* There are', STRCOMPRESS(nintf_itab), ' interferograms. *'
  itab=itab_stru.itab_valid
  itab= itab[*, 1:*]
  master_index= itab[0, *]-1
  slave_index= itab[1, *]-1
  master_index= (master_index[UNIQ(master_index)])[0]
  
  ; Calculate temporal baseline for each pair.
  Tbase= TBASE_ALL(sarlistfile,itabfile)
  
  ; Read arcs
  file_structure= FILE_INFO(arcsfile)
  arcs_no=file_structure.size/24
  PRINT, '* There are', STRCOMPRESS(arcs_no),' arcs in the network. *'
  arcs= TLI_READDATA(arcsfile, samples=3, format='FCOMPLEX')
  
  ; Read pbase
  pbase= TLI_READDATA(pbasefile, samples= npt, format='DOUBLE')
  
  ; Read look angle
  pla= TLI_READDATA(plafile, samples=npt, format='DOUBLE')
  
  ;- dphi for one arc in all the interferograms.
  Print, '* Extracting delta phase for every single arc. Start. *'
  startind= REAL_PART(arcs[2, *])
  endind= IMAGINARY(arcs[2, *])
  startslc= pdiff[startind, *]
  endslc= pdiff[endind, *]
  dphi=ATAN(endslc*CONJ(startslc),/PHASE)   ;end-start [small_ind - greater_ind]
  dphi= TRANSPOSE(dphi)  ; npt*nitab
  
  
  ; Construct equations for each point.
  start_index= REAL_PART(arcs[2, *]) ;弧段起点索引
  end_index= IMAGINARY(arcs[2, *])  ;弧段终点索引
  
  values= DBLARR(6) ;起点索引，终点索引，dv ddh coh sigma
  time_start=SYSTIME(/SECONDS)
  
  OPENW, lun, outfile,/GET_LUN ; Ready to write file
  
  IF log then BEGIN
    OPENW, loglun, dvddhfile+'.log',/GET_LUN
  ENDIF
  FOR i=0, arcs_no-1 DO BEGIN
    ref_p= start_index[i]
    ref_coor= plist[ref_p]
    ref_x= REAL_PART(ref_coor)
    ; Slant range of ref. p
    ref_r= R1+(ref_x)*deltar
    ; Look angle of ref. p
    la= pla[ref_p]
    sinla= SIN(la)
    
    ; Bperp
    Bperp= pbase[ref_p, *]
    
    ; Need to be modified.
    IF ~(i MOD 10000) THEN BEGIN
      time_end= SYSTIME(/SECONDS)
      time_consume= (time_end-time_start)/1000D*(arcs_no-1-i)
      h= FLOOR(time_consume/3600L)
      m= FLOOR((time_consume- 3600*h)/60)
      s= time_consume-3600*h-60*m
      Print, 'Calculating linear deformation and height error for each arc: ',$
        StrCOMPRESS(i), '/', STRCOMPRESS(arcs_no-1);, $
      ;' Time left:', STRCOMPRESS(h), 'h', STRCOMPRESS(m), 'm', STRCOMPRESS(s), 's'
      time_start= SYSTIME(/SECONDS)
    ENDIF
    
    ; dphi for the i-th arc (n pairs)
    dphi_i= dphi[*, i]
    
    ;    K1= 4*(!PI)/(wavelength*Ri[start_index[i]]*sinthetai[start_index[i]]) ;米为单位---对应高程
    K1= -4D *(!PI)/(wavelength*ref_r*sinla) ;GX Liu && Lei Zhang均使用這種計算方法 Please be reminded that K1 and K2 are both negative.
    K2= -4D *(!PI)/(wavelength*1000D) ;毫米为单位---对应形变
    
    
    
    IF KEYWORD_SET(ignore_def) THEN K2=0D   
    
    
    ; If v is negative, then the land surface is subsiding.
    ; Hslave-Hmaster=dh
    
    ;----------开始解空间搜索-------------------
    iter=10
    IF TOTAL(dphi_i) EQ 0 THEN Begin
    ;      Print, 'Warning! No information on the',STRCOMPRESS(i),' th arc was extracted.'
    ;      WriteU, lun, values=[[values], [0,0,0]]
    
    ;      +result=[0,0,0]
    ;      values= [[values], [result]]
    ENDIF ELSE BEGIN
      method=STRUPCASE(method)
      Case method OF
        'PSD': BEGIN
        
          IF 0 THEN BEGIN ; Robust estimation
            coef=1
            m= MEAN(dphi_i)
            std= STDDEV(dphi_i)
            ind= WHERE(dphi_i GT m-coef*std AND dphi_i LT m+coef*std)
            dphi_i= dphi_i[ind]
            
            tbase_new= tbase[ind]
          ENDIF
          IF 0 THEN BEGIN
            bthresh=80
            ind= WHERE(ABS(Bperp) LT bthresh)
            dphi_i= dphi_i[ind]
            
          ENDIF
          
          
          dv_low= -50 ;毫米为单位
          dv_up=50
          ddh_low=-100 ;米为单位
          ddh_up=100
          dv_iter=20
          ddh_iter=20
          result= SOL_SPACE_SEARCH(dphi_i, K1, Bperp, K2, Tbase, $
            dv_low, dv_up, ddh_low, ddh_up, dv_iter, ddh_iter)
          result_old=result
          FOR j=0, iter-1 DO BEGIN
            dv_inc= (dv_up-dv_low)/(dv_iter-1D)
            ddh_inc= (ddh_up-ddh_low)/(ddh_iter-1D)
            dv_low= result[0]- dv_inc
            dv_up= result[0]+ dv_inc
            ddh_low= result[1]- ddh_inc
            ddh_up= result[1]+ ddh_inc
            dv_iter=10
            ddh_iter=10
            result= SOL_SPACE_SEARCH(dphi_i, K1, Bperp, K2, Tbase, $
              dv_low, dv_up, ddh_low, ddh_up, dv_iter, ddh_iter)
            IF ABS(result[0]-result_old[0]) LE 0.001 AND ABS(result[1]-result_old[1]) LE 0.001 THEN Break
            ;            IF result[2] GE 0.98 THEN Break
            result_old=result
            
          ;            Print, result
          ENDFOR
          ; cal. sigma for PSD
          psd_phi= K1*Bperp*result[1]+K2*Tbase*result[0]
          psd_phi= TLI_WRAP_PHASE(psd_phi)                    ; Modified by T.LI, 20140707.
          psd_err= TOTAL((psd_phi-dphi_i)^2)/nintf
          values= [[values], [start_index[i],end_index[i],result, psd_err]]
          IF 0 THEN BEGIN
            temp=[start_index[i],end_index[i],result, psd_err]
            Print, "The result is:"+STRJOIN(temp)
            workpath='/mnt/data_tli/ForExperiment/Lemon_gg/'
            TLI_REPORT_DVDDH, workpath+'simlin', workpath+'simherr', start_index[i], end_index[i]
            Print, 'The result should be:',temp
          ENDIF
        END
        'LS': BEGIN
        
        
          ;          coefs_v=REPLICATE(K2, 1, nintf)
          coefs_v= (K2*Tbase)
          coefs_dh= K1*Bperp
          
          
          IF KEYWORD_SET(pbase_thresh) THEN BEGIN
          
            ind= WHERE(ABS(Bperp) LT pbase_thresh)
            dphi_i= dphi_i[ind]
            
            coefs_v= coefs_v[*, ind]
            coefs_dh= coefs_dh[*, ind]
          ENDIF
          
          
          coefs=[coefs_v, coefs_dh]
          coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
          result= coefs_n##dphi_i ; dv ddh
          ls_phi= coefs##result
          temp=dphi_i-ls_phi
          ls_coh= ABS(MEAN(e^COMPLEX(0,temp))) ; coherence
          ls_err= SQRT(TOTAL((dphi_i-TLI_WRAP_PHASE(ls_phi))^2)/nintf) ; sigma   ; Add TLI_WRAP_PHASE, by T.LI, 20140707.
          ;          Print, 'Least square error:', ls_err
          ;          IF ls_coh LT 0.8 THEN BEGIN
          ;            ind_s= SORT(tbase_new)
          ;            tbase_new= tbase_new[ind_s]
          ;            dhpi_i= dphi_i[ind_s]
          ;            WINDOW,/FREE & Plot, dphi_i & OPLOT ,  ls_phi
          ;            Print, 'Here comes the error!!', 'arc number:', i
          ;            Print, result
          ;          ENDIF
          
          values=[[values], [start_index[i], end_index[i], TRANSPOSE(result), ls_coh, ls_err]]
          if log then begin
            PrintF, loglun, 'This is the first arc, its info is:'
            PrintF, loglun, arcs[*, i]
            PrintF, loglun, ''
            PrintF, loglun, 'Params set for TLI_LINEAR_SOLVE_GAMMA'
            PrintF, loglun, 'ref_p:'+STRING(ref_p)
            PrintF, loglun, 'ref_coor:'+STRING(ref_coor)
            PrintF, loglun, 'ref_r:'+STRING(ref_r)
            PrintF, loglun, 'la:'+STRING(la)
            PrintF, loglun, 'sinla:'+STRING(sinla)
            PrintF, loglun, 'Bperp:'+STRING(Bperp)
            PrintF, loglun,''
            PrintF, loglun, 'Input data:'
            PrintF, loglun, 'delta phi of the arc:'
            PrintF, loglun, dphi_i
            PrintF, loglun, ''
            PrintF, loglun, 'K1= -4*(!PI)/(wavelength*ref_r*sinla): '+STRING(K1)
            PrintF, loglun, 'K2= -4*(!PI)/(wavelength*1000): '+string(K2)
            PrintF, loglun, 'coefs_v:  coefs_dh'
            PrintF, loglun, coefs_v
            PrintF, loglun, ''
            
            PrintF, loglun, coefs_dh
            PrintF, loglun, ''
            PrintF, loglun, 'result: [dv ddh]'
            PrintF, loglun, result
            PrintF, loglun, ''
            PrintF, loglun, 'LS phi:'
            PrintF, loglun, [ls_phi, TRANSPOSE(dphi_i)]
            PrintF, loglun, ''
            PrintF, loglun, 'That is all for the first arc.'
            FREE_LUN, loglun
          ENDIF
        END
        ;                  WINDOW,/FREE & Plot, dphi_i & OPLOT , ls_phi
        ;------------------------------------------------------------------------------------------
        'COCO': BEGIN  ; Short-and-long baseline combinations.
                       ; The phase values are all wrapped, but we consider that there are no phase ambigiuties.
                       ; So DO NOT apply TLI_WRAP_PHASE to assess the phase residues.
        
          iter_end=0
          
          coefs_v= (K2*Tbase)
          coefs_dh= K1*Bperp
          
          ; Step 1.
          ; Step 1.1. Give initial deformation parameters.
          dv_thresh=10
          ddh_thresh=30
          result=coefs_v*dv_thresh+coefs_dh*ddh_thresh
          ind=WHERE(result GE -!PI AND result LT !PI)
          
          coefs_v= K2*Tbase
          coefs_dh= K1*Bperp
          coefs_all=[coefs_v, coefs_dh]  ; All the information
          
          coefs=coefs_all[*, ind]
          coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
          result_first= coefs_n##dphi_i[ind] ; dv ddh   ; The demanded information
          
          ;          ls_phi= coefs##result
          ;          residues_valid=dphi_i[ind]-ls_phi
          ;          ls_coh= ABS(MEAN(e^COMPLEX(0,residues_valid))) ; coherence
          ;          ls_err= SQRT(TOTAL((residues_valid)^2)/nintf) ; sigma  ; Quality assessment 1. Assess the used data.
          
          ls_phi= coefs_all##result_first
          residues_all=dphi_i-ls_phi
          ls_coh_first= ABS(MEAN(e^COMPLEX(0,residues_all))) ; coherence
          ls_err_first= SQRT(TOTAL(residues_all^2)/nintf) ; sigma  ; Quality assessment 2. Assess all data.
          
          ; Step 1.2. Determine the precise deformation params thresholds, using the first result.
          dv_thresh=result_first[0]
          ddh_thresh=result_first[1]
          result=coefs_v*dv_thresh+coefs_dh*ddh_thresh
          ind=WHERE(result GE -!PI AND result LT !PI)
          
          coefs_v= K2*Tbase
          coefs_dh= K1*Bperp
          coefs_all=[coefs_v, coefs_dh]  ; All the information
          
          coefs=coefs_all[*, ind]
          coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
          result_second= coefs_n##dphi_i[ind] ; dv ddh   ; The demanded information
          
          ;          ls_phi= coefs##result
          ;          residues_valid=dphi_i[ind]-ls_phi
          ;          ls_coh= ABS(MEAN(e^COMPLEX(0,residues_valid))) ; coherence
          ;          ls_err= SQRT(TOTAL(residues_valid^2)/nintf) ; sigma  ; Quality assessment 1. Assess the used data.
          
          ls_phi= coefs_all##result_second
          residues_all_first=dphi_i-ls_phi
          ls_coh_second= ABS(MEAN(e^COMPLEX(0,residues_all_first))) ; coherence
          ls_err_second= SQRT(TOTAL(residues_all_first^2)/nintf) ; sigma  ; Quality assessment 2. Assess all data.
          
          IF ls_coh_second LE ls_coh_first THEN BEGIN
            result=result_first
            ls_coh=ls_coh_first
            ls_err=ls_err_first
            iter_end=1
          ENDIF ELSE BEGIN
            result_first=result_second
            ls_coh_first=ls_coh_second
            ls_err_first=ls_err_second
          ENDELSE
          
          
          
          WHILE NOT iter_end DO BEGIN
            ; Step 2.
            ; Step 2.1. Give the initial deformation params threshold.
            dv_thresh=result_second[0]
            ddh_thresh=result_second[1]
            result=coefs_v*dv_thresh+coefs_dh*ddh_thresh
            ind=WHERE(result GE -!PI AND result LT !PI)
            coefs_v= K2*Tbase
            coefs_dh= K1*Bperp
            coefs_all=[coefs_v, coefs_dh]  ; All the information
            
            coefs=coefs_all[*, ind]
            coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
            
            result_second= coefs_n##residues_all_first[ind] ; dv ddh   ; The demanded information
            
            ;            ls_phi= coefs##result
            ;            residues_valid=residues_all_first[ind]-ls_phi
            ;            ls_coh= ABS(MEAN(e^COMPLEX(0,residues_valid))) ; coherence
            ;            ls_err= SQRT(TOTAL(residues_valid^2)/nintf) ; sigma  ; Quality assessment 1. Assess the used data.
            
            ls_phi= coefs_all##result_second
            residues_all_second=residues_all_first-ls_phi
            ls_coh_second= ABS(MEAN(e^COMPLEX(0,residues_all_second))) ; coherence
            ls_err_second= SQRT(TOTAL(residues_all_second^2)/nintf) ; sigma  ; Quality assessment 2. Assess all data.
            
            IF ls_coh_second LE ls_coh_first THEN BEGIN
              result=result_first
              ls_coh=ls_coh_first
              ls_err=ls_err_first
              iter_end=1
              BREAK
            ENDIF ELSE BEGIN

              result_first=result_first+result_second
              ls_coh_first=ls_coh_second
              ls_err_first=ls_err_second
              residues_all_first=residues_all_second
              
            ENDELSE
            
            
            ; Step 2.2. Determine the precise deformation params thresholds, using the 2.1 result.
            dv_thresh=result[0]
            ddh_thresh=result[1]
            result=coefs_v*dv_thresh+coefs_dh*ddh_thresh
            ind=WHERE(result GE -!PI AND result LT !PI)
            
            coefs_v= K2*Tbase
            coefs_dh= K1*Bperp
            coefs_all=[coefs_v, coefs_dh]  ; All the information
            
            coefs=coefs_all[*, ind]
            coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
            result_second= coefs_n##residues_all_first[ind] ; dv ddh   ; The demanded information
            
            ;            ls_phi= coefs##result
            ;            residues_valid=residues_all_first[ind]-ls_phi
            ;            ls_coh= ABS(MEAN(e^COMPLEX(0,residues_valid))) ; coherence
            ;            ls_err= SQRT(TOTAL(residues_valid^2)/nintf) ; sigma  ; Quality assessment 1. Assess the used data.
            
            ls_phi= coefs_all##result_second
            residues_all_second=residues_all_first-ls_phi
            ls_coh_second= ABS(MEAN(e^COMPLEX(0,residues_all_second))) ; coherence
            ls_err_second= SQRT(TOTAL(residues_all^2)/nintf) ; sigma  ; Quality assessment 2. Assess all data.
            
            IF ls_coh_second LE ls_coh_first THEN BEGIN
              result=result_first
              ls_coh=ls_coh_first
              ls_err=ls_err_first
              iter_end=1
              BREAK
            ENDIF ELSE BEGIN
              result_first=result_first+result_second
              ls_coh_first=ls_coh_second
              ls_err_first=ls_err_second
              residues_all_first=residues_all_second
            ENDELSE
            
            
          ENDWHILE
          values=[[values], [start_index[i], end_index[i], TRANSPOSE(result), ls_coh, ls_err]]
          
        END
        
        ELSE: Message, 'Method not supported!'
        
      ENDCASE
    ENDELSE
    
    ;- Write File
    IF ~(i MOD 10000) THEN BEGIN
      IF i EQ 0 THEN CONTINUE
      values= values[*, 1:*]
      WriteU, lun, values
      values= DBLARR(6) ;起点索引，终点索引，dv ddh coh sigma
    ENDIF
  ENDFOR
  values=values[*, 1:*]
  WriteU, lun, values
  Free_lun, lun
  
  Print, 'Calculations done successfully!'
  
END