;-
;- Calculate the 3-rd level for the input data. Using HPA.
;-
;- Written by
;-   T.LI @ ISEIS, 08/04/2013
;-

@tli_hpa_1level.pro ; Compile the functions here. Case sensitive.
@tli_hpa_2level.pro
PRO TLI_HPA_3LEVEL,workpath,coef=coef,$
    mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
    tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
    v_acc=v_acc,dh_acc=dh_acc
    
  COMPILE_OPT idl2
  DEVICE,DECOMPOSED=1
  !P.BACKGROUND='FFFFFF'XL
  !P.COLOR='000000'XL
  time_start= SYSTIME(/SECONDS)
  
  c= 299792458D ; Speed light
  CLOSE,/ALL
  temp= ALOG(2)
  e= 2^(1/temp)
  ; Use GAMMA input files.
  ; Only support single master image.
  
  ;  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023'
  ;  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  workpath=workpath+PATH_SEP()
  resultpath=workpath+'HPA'
  resultpath=resultpath+PATH_SEP()
  ; Input files
  logfile= resultpath+'log.txt'
  sarlistfilegamma= workpath+'SLC_tab'
  itabfile= workpath+'itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=resultpath+'arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
  
  mskfile= resultpath+'msk'
  
  ;  lel1plistfile= plistfile+'update'
  ;  lel1pbasefile= pbasefile+'update'
  ;  lel1plafile= plafile+'update'
  ;  lel1ptstructfile=resultpath+'lel1pstruct'
  ;  lel1ptattrfile= ptattrfile+'update'
  
  lel2plistfile= resultpath+'lel2plist'
  lel2pdifffile= resultpath+'lel2pdiff'
  lel2pbasefile= resultpath+'lel2pbase'
  lel2plafile= resultpath+'lel2pla'
  lel2ptattrfile= resultpath+'lel2ptattr'
  lel2ptstructfile= resultpath+'lel2ptstruct'
  lel2vdhfile= resultpath+'lel2vdh'
  lel2pslcfile_update=resultpath+'lel2pslc_update'
  
  lel2ptstructfile_update=lel2ptstructfile+'_update'
  lel2vdhfile_merge= resultpath+'lel2vdh_merge'
  lel2plistfile_update= resultpath+'lel2plist_update'
  lel2ptattrfile_update= resultpath+'lel2ptattr_update'
  lel2pbasefile_update= resultpath+'lel2pbase_update'
  lel2plafile_update= resultpath+'lel2pla_update'
  lel2pdifffile_update= resultpath+'lel2pdiff_update'
  
  lel2plistfile_merge=lel2plistfile_update+'_merge';///////////////////////////////////////////////////////
  lel2ptattrfile_merge=lel2ptattrfile_update+'_merge';///////////////////////////////////////////////////////
  lel2plistfile_update=lel2plistfile_merge ;///////////////////////////////////////////////////////
  lel2ptattrfile_update=lel2ptattrfile_merge;///////////////////////////////////////////////////////
  
  
  lel3plistfile=resultpath+'lel3plist'
  lel3ptstructfile=resultpath+'lel3ptstruct'
  lel3pdifffile= resultpath+'lel3pdiff'
  lel3pbasefile= resultpath+'lel3pbase'
  lel3plafile= resultpath+'lel3pla'
  lel3vdhfile= resultpath+'lel3vdh'
  lel3ptattrfile=resultpath+'lel3ptattr'
  lel3pslcfile=resultpath+'lel3pslc'
  
  lel3plistfile_update=lel3plistfile+'_update';///////////////////////////////////////////////////////
  lel3ptattrfile_update=lel3ptattrfile+'_update';///////////////////////////////////////////////////////
  
  sarlistfile= resultpath+'sarlist_Linux'
  pbasefile= resultpath+'pbase'
  plafile= resultpath+'pla'
  basepath= resultpath+'base'
  dafile=resultpath+'DA'
  
  dv_inc=3 ; Increased percent of v is not larger than dv_inc
  ddh_inc=10 ; Increased percent of dh is not larger thatn ddh_inc
  ;  mask_pt_corr=0.85
  ;  mask_arc= 0.85
  ;  mask_pt_coh= 0.85
  refind= refind
  IF ~KEYWORD_SET(v_acc) THEN v_acc= 5
  IF ~KEYWORD_SET(dh_acc) THEN dh_acc= 10
  adj_dist=10      ; Distance to locate adjacent points for consistency checking.
;  search_radius=10 ; Search radius of the information expansion.
  
  IF FILE_TEST(logfile) THEN BEGIN
    OPENW, loglun, logfile,/GET_LUN,/APPEND
    PRINTF, loglun, '*********************************'
  ENDIF ELSE BEGIN
    OPENW, loglun, logfile,/GET_LUN
    PrintF, loglun, 'This is the log file for HPA test.'
  ENDELSE
  PrintF, loglun, 'The 3-rd level of HPA.'
  PrintF, loglun, 'Starts on:'+STRCOMPRESS(STRJOIN(TLI_TIME()))
  
  finfo= TLI_LOAD_MPAR(sarlistfilegamma, itabfile)
  lel2npt= TLI_PNUMBER(lel2plistfile_update);///////////////////////////////////////////////////////
;  lel2npt= TLI_PNUMBER(lel2plistfile_merge);///////////////////////////////////////////////////////
  ;  tile_samples=50
  ;  tile_lines=50
  nintf= FILE_LINES(itabfile)
  
  mslc= TLI_GAMMA_INT(sarlistfilegamma,itabfile,/onlymaster)
  mslc= mslc[UNIQ(mslc)]
  
  master=TLI_GAMMA_FNAME(mslc, /date)
  
  IF 1 THEN BEGIN
    ; Update the mask file
;    TLI_UPDATEPLIST, lel2vdhfile,lel2plistfile_update,/vdhfile
;    TLI_UPDATEMSK, mskfile, lel2vdhfile, finfo.range_samples, finfo.azimuth_lines, lel=3 ;********************************pls be reminded here.********************************
;    TLI_UPDATEPTATTR, lel2ptattrfile, outputfile=lel2ptattrfile_update
    
    TLI_GAMMA_BP_LA_FUN, lel2plistfile_update, itabfile, sarlistfilegamma, basepath, lel2pbasefile_update, lel2plafile_update
    ; Change gamma's format to my own.
    TLI_GAMMA2MYFORMAT_SARLIST, sarlistfilegamma, sarlistfile
    
    TLI_HPA_PDIFF, resultpath, lel2plistfile_update, master, pdifffile=lel2pdifffile_update
    temp=TLI_PSLC(sarlistfile,lel2plistfile_update, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
      /swap_endian, outfile=lel2pslcfile_update)
    ;    lel2pdiff_update=TLI_PSLC(sarlistfile,lel2plistfile_update, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
    ;      swap_endian=1, outfile=lel2pdifffile_update)
      
    ; Choose the points to be analysis. For simplicity, only the master image is used.
    ; in case of multi masters, arbitrarily choose one
    ; Use a mask file to make sure that the points in the aformentioned are not analyzed.
    TLI_HPA_DA, sarlistfile,outputfile=dafile
    ;    lel3plist=TLI_PSSELECT_AMP(sarlistfile, itabfile, mskfile, coef=coef)
    lel3plist=TLI_PSSELECT_SINGLE(dafile, mskfile=mskfile, coef=coef, samples=finfo.range_samples, format='float') ;**************************
    PrintF, loglun, ''
    PrintF, loglun, 'Threshold of the PSC:'
    PrintF, loglun, STRCOMPRESS(coef)
    PrintF, loglun, ''
    
    OPENW, lun, lel3plistfile,/GET_LUN
    WRITEU, lun, lel3plist
    FREE_LUN, lun
    lel3npt= TLI_PNUMBER(lel3plistfile)
    
    ; Sort out the points.
    ; Using a wonderful structure to maitain the data.
    ; Tile data
    
    ;  finfo= TLI_LOAD_SLC_PAR(mslc+'.par')
    lel3pt_struct= TLI_HPA_TILE_PT(lel3plist, finfo.range_samples, finfo.azimuth_lines, tile_samples, tile_lines, pt_structfile=lel3ptstructfile)
    lel2pt_struct= TLI_HPA_TILE_PT(lel2plistfile_update, finfo.range_samples, finfo.azimuth_lines, tile_samples, tile_lines, pt_structfile=lel2ptstructfile_update,/file)
    
    ; Extract SLC on the 3-rd level points.
    TLI_HPA_PDIFF, resultpath, lel3plistfile, master,  pdifffile=lel3pdifffile 
    temp=TLI_PSLC(sarlistfile,lel3plistfile, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
      /swap_endian, outfile=lel3pslcfile)
    ;    lel3pdiff=TLI_PSLC(sarlistfile,lel3plistfile, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
    ;      /swap_endian, outfile=lel3pdifffile)
      
    PRINTF, loglun, 'Lel3 plistfile:'+lel3plistfile
    PrintF, loglun, 'Lel3 number of points:'+STRING(lel3npt)
    PrintF, loglun, ''
    ; Extract pbase and pslc on the lel3's points
    TLI_GAMMA_BP_LA_FUN, lel3plistfile, itabfile, sarlistfilegamma, basepath, lel3pbasefile, lel3plafile
  ENDIF
  
  
  ; A Great loop.
  ; Read lel2 points.
  lel2npt= TLI_PNUMBER(lel2plistfile_update)
  lel2plist= TLI_READDATA(lel2plistfile_update, samples=1, format='FCOMPLEX')
  lel2pdiff= TLI_READDATA(lel2pdifffile_update, samples=lel2npt, format='FCOMPLEX')
  lel2pbase= TLI_READDATA(lel2pbasefile_update, samples=lel2npt, format='DOUBLE')
  lel2pla= TLI_READDATA(lel2plafile_update, samples= lel2npt, format='DOUBLE')
  lel2pt_struct= TLI_READDATA(lel2ptstructfile_update,lines=1, format='LONG')
  lel2pslc=TLI_READDATA(lel2pslcfile_update, samples=lel2npt, format='FCOMPLEX')
  
  ras_struct= TLI_HPA_TILE_DATA(mslc,finfo.range_samples, finfo.azimuth_lines,tile_samples=tile_samples, tile_lines=tile_lines)
  ind= ras_struct.index
  lel2pt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
  lel2pt_attr= REPLICATE(lel2pt_attr, lel2npt)
  OPENR, lun, lel2ptattrfile_update,/GET_LUN
  READU, lun, lel2pt_attr
  FREE_LUN, lun
  
;  PrintF, loglun, 'Points in the Second level:'+STRING(lel2npt);///////////////////////////////////////////////////////
  PrintF, loglun, 'Points already processed:'+STRING(lel2npt)
  PrintF, loglun, 'We apply the algorithm for each lel2point.'
  
  ; Prepare some params for calculation.
  nrs= finfo.near_range_slc
  rps= finfo.range_pixel_spacing
  wavelength= c/finfo.radar_frequency
  lel3plist= TLI_READDATA(lel3plistfile, samples=1, format='FCOMPLEX')
  lel3pbase= TLI_READDATA(lel3pbasefile, samples= lel3npt, format='DOUBLE')
  lel3pla= TLI_READDATA(lel3plafile,samples=lel3npt, format='DOUBLE')
  lel3pdiff= TLI_READDATA(lel3pdifffile, samples=lel3npt, format='FCOMPLEX')
  Tbase_old= TBASE_ALL(sarlistfile, itabfile); Backup Tbase
  lel3pt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
  lel3npt= TLI_PNUMBER(lel3plistfile)
  lel3pt_attr=REPLICATE(lel3pt_attr, lel3npt)
  lel3pslc=TLI_READDATA(lel3pslcfile,samples=lel3npt, format='FCOMPLEX')
  
  corr_method=1  ; 0 : using original phase
  ;  corr_method=1  ; 1 : using diff. phase.
  
  For i=0D, lel2npt-1D DO BEGIN
    IF ~ (i MOD 100) THEN Print, STRCOMPRESS(i), '/', STRCOMPRESS(LONG(lel2npt)-1)
    
    lel2slc_i_old=lel2pslc[i, *]
    lel2phi_old=ATAN(lel2slc_i_old,/PHASE)
    
    lel2pdiff_i_old= lel2pdiff[i, *]
    lel2pdiff_phi_old=ATAN(lel2pdiff_i_old, /PHASE)
    ; Find adjacent point for each ref. point. This is useful when using a mask file.
    ; Or find each adjacent point a ref. point.
    pscoor_i= lel2plist[i]
    
    ;    psx= REAL_PART(pscoor_i)
    ;    psy= IMAGINARY(pscoor_i)
    ;
    ;    indx= FLOOR(psx/tile_samples)
    ;    indy= FLOOR(psy/tile_lines)
    ;    ;    Print,'indx, indy', indx, indy, 'pscoor:', pscoor_i
    ;    ; Locate the point.
    ;    psind= ind[indx, indy]
    ;
    ;    ; Load adjacent points
    ;    IF lel3pt_struct[psind] GE lel3pt_struct[psind+1]-1 THEN CONTINUE ; No adjacent points.
    ;    adj_pt= lel3pt_struct[lel3pt_struct[psind]:lel3pt_struct[psind+1]-1];**********************************Find lel2's adj. points in lel3
    
    adj_pt=TLI_ADJ_POINTS(pscoor_i,lel3plist, lel3pt_struct,ras_struct,radius=search_radius)
    IF adj_pt[0] EQ -1 THEN CONTINUE
    
    ;    Print,'Number of adjcent points of the'+STRING(i)+'th point:'+STRING(N_ELEMENTS(adj_pt))
    ;    IF N_ELEMENTS(adj_pt) NE 2638 THEN BEGIN
    ;
    ;      Print, i
    ;    ENDIF
    temp= WHERE(lel3pt_attr[adj_pt].accepted EQ 0) ; To calculate params on the uncalculated points.
    IF temp[0] EQ -1 THEN CONTINUE
    adj_pt= adj_pt[temp]
    temp=0
    
    ; Calculate correlation between the i-th point and its adj. points.
    ref_r=finfo.near_range_slc+REAL_PART(lel2plist[i])
    sinla= SIN(lel2pla[i])
    Bperp_old= lel2pbase[i, *]
    FOR j=0D, N_ELEMENTS(adj_pt)-1D DO BEGIN
      lel3pdiff_j_old=lel3pdiff[adj_pt[j], *]
      lel3pdiff_phi_old=ATAN(lel3pdiff_j_old,/PHASE)
      ;      plot,lel1pslc_phi_old,color=100,title='Original phase' & oplot, lel2pdiff_phi_old,color=200
      
      
      IF corr_method EQ 1 THEN BEGIN ; Use the original phase.
        lel3slc_j_old=lel3pslc[adj_pt[j],*]
        lel3phi_old=ATAN(lel3slc_j_old,/PHASE)
        corr=ABS(CORRELATE(lel2phi_old, lel3phi_old))
        IF corr LT mask_pt_corr THEN BEGIN
          ; Refine data
          ; diffphi=ATAN(lel2pdiff_j*CONJ(lel1pdiff_i),/PHASE)
          diffphi=lel3phi_old-lel2phi_old
          refine_ind=TLI_REFINE_DATA(diffphi,delta=1)  ;******************************************************************
          IF N_ELEMENTS(refine_ind) LT nintf*0.5 THEN CONTINUE ; Too many errors,then quit
          lel3_phi=lel3phi_old[*,refine_ind]
          lel2_phi= lel2phi_old[*,refine_ind]
          corr=ABS(CORRELATE(lel2_phi, lel3_phi))
          IF corr LT mask_pt_corr THEN BEGIN
            ;          plot, diffphi
            ;          plot,lel1pdiff_phi,color=100,title='Original phase' & oplot, lel2pdiff_phi,color=200
            ; Give no result.
            CONTINUE
          ENDIF
          lel2pdiff_phi=lel2pdiff_phi_old[*, refine_ind]
          lel3pdiff_phi=lel3pdiff_phi_old[*, refine_ind]
          Tbase=Tbase_old[*, refine_ind]
          Bperp=Bperp_old[*, refine_ind]
          lel3pdiff_j=lel3pdiff_j_old[*, refine_ind]
          lel2pdiff_i=lel2pdiff_i_old[*, refine_ind]
        ENDIF ELSE BEGIN
          refine_ind=LONARR(nintf)
          lel3pdiff_j=lel3pdiff_j_old
          lel3pdiff_phi=lel3pdiff_phi_old
          lel2pdiff_i=lel2pdiff_i_old
          lel2pdiff_phi=lel2pdiff_phi_old
          Tbase=Tbase_old
          Bperp=Bperp_old
        ENDELSE
      ENDIF ELSE BEGIN ; Use the differential phase
      
      
      
      
      
        corr=ABS(CORRELATE(lel2pdiff_phi_old, lel3pdiff_phi_old))
        IF corr LT mask_pt_corr THEN BEGIN
          ; Refine data
          ; diffphi=ATAN(lel2pdiff_j*CONJ(lel1pslc_i),/PHASE)
          diffphi=lel3pdiff_phi_old-lel2pdiff_phi_old
          refine_ind=TLI_REFINE_DATA(diffphi,delta=1)  ;******************************************************************
          IF N_ELEMENTS(refine_ind) LT nintf*0.5 THEN CONTINUE ; Too many errors,then quit
          lel3pdiff_phi=lel3pdiff_phi_old[*,refine_ind]
          lel2pdiff_phi= lel2pdiff_phi_old[*,refine_ind]
          corr=ABS(CORRELATE(lel2pdiff_phi, lel3pdiff_phi))
          IF corr LT mask_pt_corr THEN BEGIN
            ;          plot, diffphi
            ;          plot,lel1pslc_phi,color=100,title='Original phase' & oplot, lel2pdiff_phi,color=200
            ; Give no result.
            CONTINUE
          ENDIF
          Tbase=Tbase_old[*, refine_ind]
          Bperp=Bperp_old[*, refine_ind]
          lel3pdiff_j=lel3pdiff_j_old[*, refine_ind]
          lel2pdiff_i=lel2pdiff_i_old[*, refine_ind]
        ENDIF ELSE BEGIN
          refine_ind=LONARR(nintf)
          lel3pdiff_j=lel3pdiff_j_old
          lel3pdiff_phi=lel3pdiff_phi_old
          lel2pdiff_i=lel2pdiff_i_old
          lel2pdiff_phi=lel2pdiff_phi_old
          Tbase=Tbase_old
          Bperp=Bperp_old
        ENDELSE
        
      ENDELSE
      ; Calculate the parameters for each point.
      
      ; First calculate the relative dv&ddh for each i-j pair.
      K1= -4*(!PI)/(wavelength*ref_r*sinla)
      K2= -4*(!PI)/(wavelength*1000)
      coefs_v= (K2*Tbase)
      coefs_dh= K1*Bperp
      coefs=[coefs_v, coefs_dh]
      coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
      dphi_j=ATAN(lel3pdiff_j*CONJ(lel2pdiff_i),/PHASE)
      result= coefs_n##dphi_j ; dv ddh
      ;      Print,result
      ls_phi= coefs##result
      temp=dphi_j-ls_phi
      ;      plot, dphi_j,color=100,title='Cal. phase' & oplot,ls_phi,color=200
      ls_coh= ABS(MEAN(e^COMPLEX(0,temp))) ; coherence
      ;            ls_err= SQRT(TOTAL((dphi_j-ls_phi)^2)/nintf) ; sigma
      IF ls_coh LT mask_arc THEN BEGIN
        lel3pt_attr[adj_pt[j]].calculated=lel3pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      ;      IF ABS(result[0]) GT ABS(lel1pt_attr[i].v)*dv_inc THEN BEGIN ; It is assumed that (delta vel.)% is not greater than dv_inc
      ;        lel2pt_attr[adj_pt[j]].calculated=lel2pt_attr[adj_pt[j]].calculated+1
      ;        CONTINUE
      ;      ENDIF
      ;      IF ABS(result[1]) GT ABS(lel1pt_attr[i].dh)*ddh_inc THEN BEGIN ; Idem
      ;        lel2pt_attr[adj_pt[j]].calculated=lel2pt_attr[adj_pt[j]].calculated+1
      ;        CONTINUE
      ;      ENDIF
      IF ABS(result[0]) GT dv_inc THEN BEGIN ; It is assumed that (delta vel.)% is not greater than dv_inc
        lel3pt_attr[adj_pt[j]].calculated=lel3pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      IF ABS(result[1]) GT ddh_inc THEN BEGIN ; Idem
        lel3pt_attr[adj_pt[j]].calculated=lel3pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      
      
      
      
      ;      ; Using points in level 1 to assess the points quality
      ;      IF lel2pt_struct[psind] GE lel2pt_struct[psind+1] THEN BEGIN
      ;        ; No points in this area
      ;        ; In fact, this can never happen
      ;        CONTINUE
      ;      ENDIF
      ;      lel2_adj_pt= lel2pt_struct[lel2pt_struct[psind]:lel2pt_struct[psind+1]-1]
      
      
      adj_adj_pt= TLI_ADJ_POINTS(lel3plist[adj_pt[j]],lel2plist, lel2pt_struct,ras_struct,radius=adj_dist)
      IF adj_adj_pt[0] EQ -1 THEN BEGIN
        ; Update the information
        lel3pt_attr[adj_pt[j]].accepted=1 ; Mask of the point is set to 1.
        lel3pt_attr[adj_pt[j]].parent=i
        lel3pt_attr[adj_pt[j]].steps=lel3pt_attr[adj_pt[j]].steps+1
        lel3pt_attr[adj_pt[j]].v=result[0]+lel2pt_attr[i].v
        lel3pt_attr[adj_pt[j]].dh= result[1]+lel2pt_attr[i].dh
        lel3pt_attr[adj_pt[j]].calculated=lel3pt_attr[adj_pt[j]].calculated+1
        lel3pt_attr[adj_pt[j]].v_acc=0
        lel3pt_attr[adj_pt[j]].dh_acc=0
        lel3pt_attr[adj_pt[j]].weight=lel2pt_attr[i].weight+1;//////////////////////////////////////////////////////////
        ;        values=[[values], [i, adj_pt[j], TRANSPOSE(result), ls_coh, ls_err]]
        CONTINUE
      ENDIF
      
      ; Finally, I decide to use the precision assessment described by
      ; difference between the observed data and the true data.
      ; First calculate the relative params between the j-th point and its adj. points.
      ref_r_j= finfo.near_range_slc+REAL_PART(adj_pt[j])*finfo.azimuth_pixel_spacing
      sinla_j= SIN(lel3pla[adj_pt[j]])
      Bperp_j= lel3pbase[adj_pt[j], refine_ind]
      dvddh_real=[0.0, 0.0]
      FOR k=0, N_ELEMENTS(adj_adj_pt)-1 DO BEGIN
        lel2pdiff_k= lel2pdiff[adj_adj_pt[k], refine_ind]
        dphi_k= ATAN(lel2pdiff_k*CONJ(lel3pdiff_j),/PHASE)
        
        K1= -4*(!PI)/(wavelength*ref_r_j*sinla_j) ;Please be reminded that K1 and K2 are both negative.
        K2= -4*(!PI)/(wavelength*1000)
        coefs_v= (K2*Tbase)
        coefs_dh= K1*Bperp_j
        coefs=[coefs_v, coefs_dh]
        coefs_n=idl_pseudo_inverse(TRANSPOSE(coefs)##coefs)##TRANSPOSE(coefs)
        result_k= coefs_n##dphi_k ; dv ddh
        dvddh_real=[[dvddh_real], [TRANSPOSE(result_k)]]
      ENDFOR
      dvddh_real=dvddh_real[*, 1:*] ; Params calculated are used as true value.
      dvddh_real_v=dvddh_real[0, *]
      dvddh_real_dh=dvddh_real[1, *]
      
      dvddh_obs_v=lel2pt_attr[adj_adj_pt].v-lel3pt_attr[adj_pt[j]].v
      dvddh_obs_dh=lel2pt_attr[adj_adj_pt].dh-lel3pt_attr[adj_pt[j]].dh
      v_cosis=MAX(ABS(dvddh_real_v-dvddh_obs_v))
      dh_cosis=MAX(ABS(dvddh_real_dh-dvddh_obs_dh))
      IF v_cosis GT v_acc THEN BEGIN
        lel3pt_attr[adj_pt[j]].calculated=lel3pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      IF dh_cosis GT dh_acc THEN BEGIN
        lel3pt_attr[adj_pt[j]].calculated=lel3pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      dv_acc=SQRT(MEAN(TOTAL(dvddh_real_v-dvddh_obs_v)^2))
      ddh_acc= SQRT(MEAN(TOTAL(dvddh_real_dh-dvddh_obs_dh)^2))
      lel3pt_attr[adj_pt[j]].v_acc=SQRT(dv_acc^2+lel2pt_attr[i].v_acc^2)
      lel3pt_attr[adj_pt[j]].dh_acc=SQRT(ddh_acc^2+lel3pt_attr[i].dh_acc^2)
      lel3pt_attr[adj_pt[j]].parent=i
      lel3pt_attr[adj_pt[j]].steps=1
      lel3pt_attr[adj_pt[j]].v=result[0]+lel2pt_attr[i].v
      lel3pt_attr[adj_pt[j]].dh= result[1]+lel2pt_attr[i].dh
      lel3pt_attr[adj_pt[j]].accepted=1
      lel3pt_attr[adj_pt[j]].weight=lel2pt_attr[i].weight+1;//////////////////////////////////////////////////////////
    ;    PRINTF, loglun, $
    ;            STRJOIN(STRCOMPRESS([lel2plist[adj_pt[j]], lel1plist[i], lel2pt_attr[adj_pt[j]].v,lel1pt_attr[i].v]))
      
      
      
      
      
      
      
    ENDFOR
    
    
  ENDFOR
  ; Output the result. Formats are referred to region growing.pro
  pt_calculated= WHERE(lel3pt_attr.accepted EQ 1, count)
  pt_coors= lel3plist[pt_calculated]
  v= lel3pt_attr[pt_calculated].v
  dh= lel3pt_attr[pt_calculated].dh
  result= [[pt_calculated],[REAL_PART(pt_coors)], [IMAGINARY(pt_coors)], [v], [dh]]
  result= TRANSPOSE(result)
  
  PrintF, loglun, ''
  PrintF, loglun, 'Statistics of the results.'
  PrintF, loglun, 'Max_v:'+STRING(MAX(v, min=min_v))
  PrintF, loglun, 'Min_v:'+STRING(min_v)
  PrintF, loglun, 'Max_dh:'+STRING(MAX(dh, min=min_dh))
  PrintF, loglun, 'Min_dh:'+STRING(min_dh)
  
  OPENW, lun, lel3vdhfile,/GET_LUN ; Index , x, y, v, dh
  WRITEU, lun, result
  FREE_LUN, lun
  PrintF, loglun, ''
  PRINTF, loglun, 'Points calculated:'+STRING(count)
  PrintF, loglun, 'Results of the points are stored in '+lel3vdhfile
  PrintF, loglun, 'Formats are: [index x y v dh]'
  PrintF, loglun, 'For details, please read '+lel3vdhfile+'.txt'
  OPENW, lun, lel3vdhfile+'.txt',/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun
  
  lel3pt_attr= lel3pt_attr[pt_calculated]
  OPENW,lun, lel3ptattrfile,/GET_LUN
  WRITEU, lun, lel3pt_attr
  FREE_LUN, lun
  PrintF, loglun, ''
  PrintF, loglun, 'All information of a point is contained in:'+lel3ptattrfile
  PrintF, loglun, 'Please be reminded that points with low quality is not output.'
  
  ;///////////////////////////////////////////////////////
  ; update plist
  TLI_UPDATEPLIST, lel3vdhfile,lel3plistfile_update,/vdhfile
  ; update msk
  TLI_UPDATEMSK, mskfile, lel3vdhfile, finfo.range_samples, finfo.azimuth_lines
  ; update ptattr
  TLI_UPDATEPTATTR, lel3ptattrfile,  outputfile=lel3ptattrfile_update
  ; merge vdh
  TLI_MERGE_RESULTS, lel2vdhfile_merge, lel3vdhfile,type='vdh'
  ; merge ptattr
  TLI_MERGE_RESULTS, lel2ptattrfile_merge, lel3ptattrfile_update, type='ptattr'
  ; merge plist
  TLI_MERGE_RESULTS, lel2plistfile_merge, lel3plistfile_update, type='plist';///////////////////////////////////////////////////////
;  TLI_MERGE_RESULTS, lel2vdhfile_merge, lel3vdhfile;///////////////////////////////////////////////////////
  
  PrintF, loglun, 'Results of lel1 and lel3 are merged in:'
  PrintF, loglun, lel3vdhfile+'_merge.'
  
  time_end= SYSTIME(/SECONDS)
  time_consumed= (time_end-time_start)/3600D
  PrintF,loglun,  'Time consumed(h): ',STRCOMPRESS(time_consumed)
  
  
  PrintF,loglun, ''
  PrintF, loglun, 'Points analysis of the second level is finished.'
  FREE_LUN, loglun
  
  Print, 'TLI_HPA_3LEVEL:Main pro finished!'
  
END