;
; Calculate the relative deformation velocity and the relative DEM error.
;    With reference to
;     sol_space_search (tli_linear_solve_cuhk.pro)
;     ls (tli_linear_solve_cuhk.pro)
;
; Parameters:
;   def_params        : Parameters created by tli_relative_params.
;   dphi              : The differential phase between two points. With all data in a single column.
;
; Keywords:
;   ls_simple         : Least squares estimation.
;   ls_robust         : Robust LS estimation.
;   psd               : Power Spectral Density estimation. The same as periodogram.
;   grd               : Phase GRaDient based algorithm.
;
;   -- Keywords set for PSD --
;   dv_range          : Range to search the true dv value.
;   ddh_range         : Range to search the true ddh value.
;   dv_iter           : Iterations for dv.
;   ddh_iter          : Iterations for ddh.
;   dv_acc            : Accuracy of dv. Also considered as the satisfied threshold to stop iteration.
;   ddh_acc           : Accuracy of ddh. ...
;   -- Keywords set for PSD --
;
;   ind               : Interferogram index to use, if not set, then use all.
; 
; Writtey by:
;   T.LI @ ISEIS, 20131227
;   20140519:  Add keyword "ind". T.LI @ SWJTU.
;
FUNCTION TLI_GRADIENT, inputarr
  ; Calculate the gradient for the input array (Should be in a single line or a single column.)
  sz=SIZE(inputarr,/DIMENSIONS)
  IF sz[0] EQ 1 THEN BEGIN
    result=SHIFT(inputarr, 0, 1)-inputarr
    result[0]=0
  ENDIF ELSE BEGIN
    result=SHIFT(inputarr, 1)-inputarr
    result[0]=0
  ENDELSE
  
  RETURN, result
END

FUNCTION TLI_DVDDH, def_params, dphi, ls_simple=ls_simple, ls_robust=ls_robust, psd=psd, grd=grd, lamda=lamda, $
    dv_range=dv_range, ddh_range=ddh_range, dv_iter=dv_iter, ddh_iter=ddh_iter, dv_acc=dv_acc, ddh_acc=ddh_acc, $
    ind=ind
    
  COMPILE_OPT idl2
  
  IF NOT KEYWORD_SET(dv_acc) THEN dv_acc=0.001
  IF NOT KEYWORD_SET(ddh_acc) THEN ddh_acc=0.001
  nintf=N_ELEMENTS(dphi)
  IF NOT KEYWORD_SET(ind) THEN BEGIN
    ind=LINDGEN(nintf)
  ENDIF
  
  
  ; To assure the calculation speed, we do not check the input params.
  
  ref_r= def_params.ref_r
  ;  Tbase= def_params.tbase
  ;  Bperp= def_params.bperp
  wavelength= def_params.wavelength
  sinla= (SIN(def_params.pla))
  
  Case 1 OF
  
    KEYWORD_SET(ls_simple): BEGIN
      K1= -4*(!PI)/(wavelength*ref_r*sinla)
      K2= -4*(!PI)/(wavelength*1000)
      coefs_v= (K2*def_params.tbase)[*, ind]
      coefs_dh= (K1[0]*def_params.bperp)[*, ind]
      coefs=[coefs_v, coefs_dh]
      coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
      result= coefs_n##dphi[ind] ; dv ddh
      
      phi_inc=TLI_PHASE_INCREMENT(def_params, result[0], result[1],ind=ind)
      phi_noise=dphi[ind]-phi_inc
      g=TLI_TCORR(phi_noise)
      
      RETURN, [Transpose(result), g]
    END
    
    KEYWORD_SET(psd): BEGIN
      niter=10          ; Iterations of the kernal function.
      g_thresh=0.75     ; Threshold of gamma.
      IF NOT KEYWORD_SET(dv_range) THEN dv_range=[-1,1]
      IF NOT KEYWORD_SET(ddh_range) THEN ddh_range=[-20,20]
      IF NOT KEYWORD_SET(dv_iter) THEN dv_iter=20
      IF NOT KEYWORD_SET(ddh_iter) THEN ddh_iter=20
      IF NOT KEYWORD_SET(dv_acc) THEN dv_acc=0.01
      IF NOT KEYWORD_SET(ddh_acc) THEN ddh_acc=0.01
      
      K1= -4*(!PI)/(def_params.wavelength*def_params.ref_r*SIN(def_params.pla))
      K2= -4*(!PI)/(def_params.wavelength*1000)
      FOR i=0, niter DO BEGIN
        dv_inc= (dv_range[1]-dv_range[0])/(DOUBLE(dv_iter))
        ddh_inc= (ddh_range[1]-ddh_range[0])/(DOUBLE(ddh_iter))
        dv_all= dv_range[0]+DINDGEN(dv_iter)*dv_inc
        ddh_all= ddh_range[0]+DINDGEN(ddh_iter)*ddh_inc
        space= INDEXARR(x= dv_all, y= ddh_all)
        dv_all= REAL_PART(space)
        ddh_all= IMAGINARY(space)
        ; 与其做解空间循环，不如做干涉对数目的循环
        nint= N_ELEMENTS(dphi)
        gamma= COMPLEXARR(dv_iter,ddh_iter); 每一对(dv, ddh)都有对应的残差
        FOR j=0, nint-1 DO BEGIN
          ;    phi_resi=deltaphi[i]-K1*Bperp[i]*ddh_all-K2*T[i]*dv_all
          coef1=K1*def_params.bperp[j]
          coef2=K2*def_params.tbase[j]
          
          phi_resi=dphi[j]-coef1*ddh_all-coef2*dv_all
          ; 目标函数
          temp= COMPLEX(COS(phi_resi),SIN(phi_resi))
          gamma= gamma+temp
        ENDFOR
        gamma= ABS(gamma/nint)
        ;  WINDOW, /FREE &
        ;  TVSCL,CONGRID(gamma, 100,100) ;作图显示
        coh= MAX(gamma, ind)
        ind= IND2XY(ind, dv_iter)
        dv= dv_all[ind[0], ind[1]]
        ddh= ddh_all[ind[0], ind[1]]
        Print, dv, ddh, coh
        IF i EQ 0 THEN BEGIN
          dv_p=dv  ; Previous dv.
          ddh_p=ddh; Previous ddh.
          dv_range=[dv-dv_inc, dv+dv_inc]
          ddh_range=[ddh-ddh_inc, ddh+ddh_inc]
        ENDIF ELSE BEGIN
          IF ABS(dv_p-dv) LE dv_acc AND ABS(ddh_p-ddh) LE ddh_acc THEN BEGIN
            IF coh GE g_thresh THEN RETURN, [dv, ddh, coh]
          ENDIF ELSE BEGIN
            dv_range=[dv-dv_inc, dv+dv_inc]
            ddh_range=[ddh-ddh_inc, ddh+ddh_inc]
            dv_p=dv
            ddh_p=ddh
          ENDELSE
        ENDELSE
      ENDFOR
      Return, !values.F_NAN*FINDGEN(3)
    END
    
    KEYWORD_SET(grd): BEGIN
      ; The phase gradient based algorithm.---------------------This method is wrong.
      K1= -4*(!PI)/(wavelength*ref_r*sinla)
      K2= -4*(!PI)/(wavelength*1000)
      ; Phase gradients
      phi_vs_t=dphi[SORT(def_params.tbase)]
      phi_t_g=TLI_GRADIENT(phi_vs_t)
      phi_vs_b=dphi[SORT(def_params.bperp)]
      phi_b_g=TLI_GRADIENT(phi_vs_b)
      ; t and b gradients
      t_g=TLI_GRADIENT(def_params.tbase[SORT(def_params.tbase)])
      b_g=TLI_GRADIENT(def_params.bperp[SORT(def_params.bperp)])
      
      ; K1 and K2 are the corresponding coefs for def. v and DEM, respectively.
      temp=phi_t_g/(K1*t_g)
      v=MEAN(temp[1:*])
      temp=phi_b_g/(K2*b_g)
      h=MEAN(temp[1:*])
      
      STOP
    
    END
   
    KEYWORD_SET(ls_robust): BEGIN
      K1= -4*(!PI)/(wavelength*ref_r*sinla)
      K2= -4*(!PI)/(wavelength*1000)
      coefs_v= K2*def_params.tbase
      coefs_dh= K1[0]*def_params.bperp
      
      ind=TLI_REFINE_DATA(dphi,delta=1, refined_data=dphi)
      dphi=TRANSPOSE(dphi)
      
      coefs_v=coefs_v[*,ind]
      coefs_dh=coefs_dh[*,ind]
      coefs=[coefs_v, coefs_dh]
      
      coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
      result= coefs_n##dphi ; dv ddh
      
      def_params_new=TLI_PROCESSDEFPARAMS(def_params, ind=ind)
      
      phi_inc=TLI_PHASE_INCREMENT(def_params_new, result[0], result[1])
      phi_noise=dphi-phi_inc
      g=TLI_TCORR(phi_noise)
      
      RETURN, [Transpose(result), g]
    END
    
    
    KEYWORD_SET(lamda): BEGIN
      ; Lamda method to calculate the relative subsidence rate and DEM error.
      ; With reference to Kampes, 2004.
      
    
    END
    
    ELSE: BEGIN
    
    END
  ENDCASE
  
  
END