@tli_updateptattr
@tli_pslc
@tli_hpa_da
PRO TLI_HPA_2LEVEL,workpath,coef=coef,$
    mask_pt_corr=mask_pt_corr, mask_arc=mask_arc,mask_pt_coh=mask_pt_coh,$
    tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
    v_acc=v_acc, dh_acc=dh_acc
    
  ; workpath        : path where all the files folded.
  ; coef            : coef of the points to process in this level.
  ; mask_pt_corr    : point correlation threshold
  ; mask_arc        : point correlation on arcs
  ; mask_pt_coh     : point's temporal coherence. Assessed from adjacent control points.
  ; tile_samples    :
  ; tile_lines      :
    
  ;  COMPILE_OPT idl2
    
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
  
  IF NOT TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
  resultpath=workpath+'HPA'+PATH_SEP()
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
  dvddhfile=resultpath+'dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
  vdhfile= resultpath+'vdh'
  ptattrfile= resultpath+'ptattr'
  
  mskfile= resultpath+'msk'
  
  lel1plistfile= plistfile+'update'
  lel1pbasefile= pbasefile+'update'
  lel1plafile= plafile+'update'
  lel1ptstructfile=resultpath+'lel1pstruct'
  lel1ptattrfile= ptattrfile+'update'
  lel1pdifffile= resultpath+'lel1pdiff'
  lel1pslcfile= resultpath+'lel1pslc'
  
  lel2plistfile= resultpath+'lel2plist'
  lel2pdifffile= resultpath+'lel2pdiff'
  lel2pbasefile= resultpath+'lel2pbase'
  lel2plafile= resultpath+'lel2pla'
  lel2ptattrfile= resultpath+'lel2ptattr'
  lel2ptstructfile= resultpath+'lel2ptstruct'
  lel2vdhfile= resultpath+'lel2vdh'
  lel2pslcfile=resultpath+'lel2pslc'
  
  lel2plistfile_update=lel2plistfile+'_update'
  lel2ptattrfile_update=lel2ptattrfile+'_update'
  lel2vdhfile_update=lel2vdhfile+'_update'
  lel2plistfile_merge=lel2plistfile_update+'_merge'
  lel2vdhfile_merge=lel2vdhfile+'_merge'
  lel2ptattrfile_merge=lel2ptattrfile_update+'_merge'
  
  sarlistfile= resultpath+'sarlist_Linux'
  pbasefile= resultpath+'pbase'
  plafile= resultpath+'pla'
  basepath= resultpath+'base'
  dafile=resultpath+'DA'
  
  dv_inc=3 ; Increased percent of v is not larger than dv_inc
  ddh_inc=10 ; Increased percent of dh is not larger thatn ddh_inc
  ;  mask_pt_corr=0.8
  ;  mask_arc= 0.8
  ;  mask_pt_coh= 0.8
  refind= refind
  IF ~KEYWORD_SET(v_acc) THEN v_acc= 5
  IF ~KEYWORD_SET(dh_acc) THEN dh_acc= 10
  adj_dist=10      ; Distance to locate adjacent points for consistency checking.
  search_radius=25 ; Search radius of the information expansion.
  
  OPENW, loglun, logfile,/GET_LUN
  PrintF, loglun, 'This is the log file for HPA test.'
  finfo= TLI_LOAD_MPAR(sarlistfilegamma, itabfile)
  ;  lel2npt= TLI_PNUMBER(lel2plistfile)
  ;  tile_samples=50
  ;  tile_lines=50
  coef=coef
  nintf= FILE_LINES(itabfile)
  
  mslc= TLI_GAMMA_INT(sarlistfilegamma,itabfile,/onlymaster)
  mslc= mslc[UNIQ(mslc)]
  
  master=TLI_GAMMA_FNAME(mslc,/date)
  
  ; Create da file
  TLI_HPA_DA, sarlistfile,outputfile=dafile
  
  IF 1 THEN BEGIN
    IF FILE_TEST(mskfile) THEN FILE_DELETE,mskfile
    ; Update the mask file
    TLI_UPDATEPLIST, vdhfile,lel1plistfile,/vdhfile
    TLI_UPDATEMSK, mskfile, vdhfile, finfo.range_samples, finfo.azimuth_lines
    TLI_UPDATEPTATTR, ptattrfile,  plistfile_orig=plistfile, plistfile_update=lel1plistfile, outputfile=lel1ptattrfile,/change_weight_to_level
    
    TLI_GAMMA_BP_LA_FUN, lel1plistfile, itabfile, sarlistfilegamma, basepath, lel1pbasefile, lel1plafile
    ; Change gamma's format to my own.
    TLI_GAMMA2MYFORMAT_SARLIST, sarlistfilegamma, sarlistfile
    
    TLI_HPA_PDIFF, resultpath, lel1plistfile, master, pdifffile=lel1pdifffile
    temp=TLI_PSLC(sarlistfile,lel1plistfile, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
      /swap_endian, outfile=lel1pslcfile)
      
    ; Choose the points to analysis. For simplicity, only the master image is used.
    ; in case of multi masters, arbitrarily choose one
    ; Use a mask file to make sure that the points in the aformentioned are not analyzed.
      
    lel2plist=TLI_PSSELECT_SINGLE(dafile, mskfile=mskfile, coef=coef, samples=finfo.range_samples, format='float') ;**************************
    PrintF, loglun, ''
    PrintF, loglun, 'Threshold of the PSC:'
    PrintF, loglun, STRCOMPRESS(coef)
    PrintF, loglun, ''
    
    ;  lel2pmask=BYTARR(N_ELEMENTS(lel2plist))  ; Mask file for lel2 points
    OPENW, lun, lel2plistfile,/GET_LUN
    WRITEU, lun, lel2plist
    FREE_LUN, lun
    
    lel2npt=TLI_PNUMBER(lel2plistfile)
    
    ; Sort out the points.
    ; Using a wonderful structure to maitain the data.
    ; Tile data
    
    ;  finfo= TLI_LOAD_SLC_PAR(mslc+'.par')
    lel2pt_struct= TLI_HPA_TILE_PT(lel2plist, finfo.range_samples, finfo.azimuth_lines, tile_samples, tile_lines, pt_structfile=lel2ptstructfile)
    lel1pt_struct= TLI_HPA_TILE_PT(lel1plistfile, finfo.range_samples, finfo.azimuth_lines, tile_samples, tile_lines, pt_structfile=lel1ptstructfile,/file)
    
    
    ; Extract SLC on the points.
    TLI_HPA_PDIFF, resultpath, lel2plistfile, master, pdifffile=lel2pdifffile
    temp=TLI_PSLC(sarlistfile,lel2plistfile, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
      /swap_endian, outfile=lel2pslcfile)
      
    PRINTF, loglun, 'Lel2 plistfile:'+lel2plistfile
    PrintF, loglun, 'Lel2 number of points:'+STRING(lel2npt)
    PrintF, loglun, ''
    ; Extract pbase and pslc on the lel2's points
    TLI_GAMMA_BP_LA_FUN, lel2plistfile, itabfile, sarlistfilegamma, basepath, lel2pbasefile, lel2plafile
  ENDIF
  
  
  
  ; A Great loop.
  ; Read lel1 points.
  ;  npt= TLI_PNUMBER(plistfile)******
  lel1npt= TLI_PNUMBER(lel1plistfile)
  lel1plist= TLI_READDATA(lel1plistfile, samples=1, format='FCOMPLEX')
  lel1pdiff= TLI_READDATA(lel1pdifffile, samples=lel1npt, format='FCOMPLEX')
  lel1pbase= TLI_READDATA(lel1pbasefile, samples=lel1npt, format='DOUBLE')
  lel1pla= TLI_READDATA(lel1plafile, samples= lel1npt, format='DOUBLE')
  lel2pt_struct= TLI_READDATA(lel2ptstructfile,lines=1, format='LONG')
  lel1pt_struct= TLI_READDATA(lel1ptstructfile, lines=1, format='LONG')
  ras_struct= TLI_HPA_TILE_DATA(mslc,finfo.range_samples, finfo.azimuth_lines,tile_samples=tile_samples, tile_lines=tile_lines)
  ind= ras_struct.index
  lel1pt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
  lel1pt_attr= REPLICATE(lel1pt_attr, lel1npt)
  OPENR, lun, lel1ptattrfile,/GET_LUN
  READU, lun, lel1pt_attr
  FREE_LUN, lun
  
  PrintF, loglun, 'Points in the first level:'+STRING(lel1npt)
  PrintF, loglun, 'This is a test, we apply the algorithm for each lel1point.'
  
  ; Prepare some params for calculation.
  nrs= finfo.near_range_slc
  rps= finfo.range_pixel_spacing
  wavelength= c/finfo.radar_frequency
  lel2plist= TLI_READDATA(lel2plistfile, samples=1, format='FCOMPLEX')
  lel2pbase= TLI_READDATA(lel2pbasefile, samples= lel2npt, format='DOUBLE')
  lel2pla= TLI_READDATA(lel2plafile,samples=lel2npt, format='DOUBLE')
  lel2pdiff= TLI_READDATA(lel2pdifffile, samples=lel2npt, format='FCOMPLEX')
  Tbase_old= TBASE_ALL(sarlistfile, itabfile); Backup Tbase
  lel2pt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
  lel2npt= TLI_PNUMBER(lel2plistfile)
  lel2pt_attr=REPLICATE(lel2pt_attr, lel2npt)
  
  ; Load pslc files
  lel1pslc=TLI_READDATA(lel1pslcfile, samples=lel1npt, format='FCOMPLEX')
  lel2pslc=TLI_READDATA(lel2pslcfile, samples=lel2npt, format='FCOMPLEX')
  corr_method=1  ; 0 : using original phase
  ;  corr_method=1  ; 1 : using diff. phase.
  For i=0D, lel1npt-1D DO BEGIN
  
    IF ~(i MOD 100) THEN BEGIN
      Print, STRCOMPRESS(i), '/', STRCOMPRESS(LONG(lel1npt)-1)
    ENDIF
    lel1slc_i_old=lel1pslc[i, *]
    lel1phi_old=ATAN(lel1slc_i_old,/PHASE)
    
    lel1pdiff_i_old= lel1pdiff[i, *]
    lel1pdiff_phi_old=ATAN(lel1pdiff_i_old, /PHASE)
    ; Find adjacent point for each ref. point. This is useful when using a mask file.
    ; Or find each adjacent point a ref. point.
    pscoor_i= lel1plist[i]
    
    
    ;    ; Adj. search, begin*********************************************
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
    ;    IF lel2pt_struct[psind] GE lel2pt_struct[psind+1]-1 THEN CONTINUE ; No adjacent points.
    ;    adj_pt= lel2pt_struct[lel2pt_struct[psind]:lel2pt_struct[psind+1]-1];**********************************
    ; Adj. search, end*************************************************
    adj_pt=TLI_ADJ_POINTS(pscoor_i,lel2plist, lel2pt_struct,ras_struct,radius=search_radius)
    IF adj_pt[0] EQ -1 THEN CONTINUE
    
    ;    Print,'Number of adjcent points of the'+STRING(i)+'th point:'+STRING(N_ELEMENTS(adj_pt))
    ;    IF N_ELEMENTS(adj_pt) NE 2638 THEN BEGIN
    ;
    ;      Print, i
    ;    ENDIF
    temp= WHERE(lel2pt_attr[adj_pt].accepted EQ 0) ; To calculate params on the uncalculated points.
    IF temp[0] EQ -1 THEN CONTINUE
    adj_pt= adj_pt[temp]
    temp=0
    
    ; Calculate correlation between the i-th point and its adj. points.
    ref_r=finfo.near_range_slc+REAL_PART(lel1plist[i])
    sinla= SIN(lel1pla[i])
    Bperp_old= lel1pbase[i, *]
    FOR j=0D, N_ELEMENTS(adj_pt)-1D DO BEGIN
      lel2pdiff_j_old=lel2pdiff[adj_pt[j], *]
      lel2pdiff_phi_old=ATAN(lel2pdiff_j_old,/PHASE)
      ;      plot,lel1pdiff_phi_old,color=100,title='Original phase' & oplot, lel2pdiff_phi_old,color=200
      
      IF corr_method EQ 1 THEN BEGIN ; Use the original phase.
        lel2slc_j_old=lel2pslc[adj_pt[j],*]
        lel2phi_old=ATAN(lel2slc_j_old,/PHASE)
        corr=ABS(CORRELATE(lel1phi_old, lel2phi_old))
        IF corr LT mask_pt_corr THEN BEGIN
          ; Refine data
          ; diffphi=ATAN(lel2pdiff_j*CONJ(lel1pdiff_i),/PHASE)
          diffphi=lel2phi_old-lel1phi_old
          refine_ind=TLI_REFINE_DATA(diffphi,delta=1)  ;******************************************************************
          IF N_ELEMENTS(refine_ind) LT nintf*0.5 THEN CONTINUE ; Too many errors,then quit
          lel2_phi=lel2phi_old[*,refine_ind]
          lel1_phi= lel1phi_old[*,refine_ind]
          corr=ABS(CORRELATE(lel1_phi, lel2_phi))
          IF corr LT mask_pt_corr THEN BEGIN
            ;          plot, diffphi
            ;          plot,lel1pdiff_phi,color=100,title='Original phase' & oplot, lel2pdiff_phi,color=200
            ; Give no result.
            CONTINUE
          ENDIF
          lel1pdiff_phi=lel1pdiff_phi_old[*, refine_ind]
          lel2pdiff_phi=lel2pdiff_phi_old[*, refine_ind]
          Tbase=Tbase_old[*, refine_ind]
          Bperp=Bperp_old[*, refine_ind]
          lel2pdiff_j=lel2pdiff_j_old[*, refine_ind]
          lel1pdiff_i=lel1pdiff_i_old[*, refine_ind]
        ENDIF ELSE BEGIN
          refine_ind=LONARR(nintf)
          lel2pdiff_j=lel2pdiff_j_old
          lel2pdiff_phi=lel2pdiff_phi_old
          lel1pdiff_i=lel1pdiff_i_old
          lel1pdiff_phi=lel1pdiff_phi_old
          Tbase=Tbase_old
          Bperp=Bperp_old
        ENDELSE
      ENDIF ELSE BEGIN ; Use the differential phase
      
      
        corr=ABS(CORRELATE(lel1pdiff_phi_old, lel2pdiff_phi_old))
        IF corr LT mask_pt_corr THEN BEGIN
          ; Refine data
          ; diffphi=ATAN(lel2pdiff_j*CONJ(lel1pdiff_i),/PHASE)
          diffphi=lel2pdiff_phi_old-lel1pdiff_phi_old
          refine_ind=TLI_REFINE_DATA(diffphi,delta=1)  ;******************************************************************
          IF N_ELEMENTS(refine_ind) LT nintf*0.5 THEN CONTINUE ; Too many errors,then quit
          lel2pdiff_phi=lel2pdiff_phi_old[*,refine_ind]
          lel1pdiff_phi= lel1pdiff_phi_old[*,refine_ind]
          corr=ABS(CORRELATE(lel1pdiff_phi, lel2pdiff_phi))
          IF corr LT mask_pt_corr THEN BEGIN
            ;          plot, diffphi
            ;          plot,lel1pdiff_phi,color=100,title='Original phase' & oplot, lel2pdiff_phi,color=200
            ; Give no result.
            CONTINUE
          ENDIF
          Tbase=Tbase_old[*, refine_ind]
          Bperp=Bperp_old[*, refine_ind]
          lel2pdiff_j=lel2pdiff_j_old[*, refine_ind]
          lel1pdiff_i=lel1pdiff_i_old[*, refine_ind]
        ENDIF ELSE BEGIN
          refine_ind=LONARR(nintf)
          lel2pdiff_j=lel2pdiff_j_old
          lel2pdiff_phi=lel2pdiff_phi_old
          lel1pdiff_i=lel1pdiff_i_old
          lel1pdiff_phi=lel1pdiff_phi_old
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
      dphi_j=ATAN(lel2pdiff_j*CONJ(lel1pdiff_i),/PHASE)
      result= coefs_n##dphi_j ; dv ddh
      ;      Print,result
      ls_phi= coefs##result
      temp=dphi_j-ls_phi
      ;      plot, dphi_j,color=100,title='Cal. phase' & oplot,ls_phi,color=200
      ls_coh= ABS(MEAN(e^COMPLEX(0,temp))) ; coherence
      ;            ls_err= SQRT(TOTAL((dphi_j-ls_phi)^2)/nintf) ; sigma
      IF ls_coh LT mask_arc THEN BEGIN
        lel2pt_attr[adj_pt[j]].calculated=lel2pt_attr[adj_pt[j]].calculated+1
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
        lel2pt_attr[adj_pt[j]].calculated=lel2pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      IF ABS(result[1]) GT ddh_inc THEN BEGIN ; Idem
        lel2pt_attr[adj_pt[j]].calculated=lel2pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      
      
      
      
      ; Using points in level 1 to assess the points quality
      ;      IF lel1pt_struct[psind] GE lel1pt_struct[psind+1] THEN BEGIN
      ;        ; No points in this area
      ;        ; In fact, this can never happen
      ;        CONTINUE
      ;      ENDIF
      ;      lel1_adj_pt= lel1pt_struct[lel1pt_struct[psind]:lel1pt_struct[psind+1]-1]
      ;      adj_coors= lel1plist[lel1_adj_pt]
      ;      adj_dist_j= ABS(adj_coors-lel2plist[adj_pt[j]])
      ;      adj_adj_pt= WHERE(adj_dist_j LT adj_dist)
      
      adj_adj_pt= TLI_ADJ_POINTS(lel2plist[adj_pt[j]],lel1plist, lel1pt_struct,ras_struct,radius=adj_dist)
      IF adj_adj_pt[0] EQ -1 THEN BEGIN
        ; Update the information
        lel2pt_attr[adj_pt[j]].accepted=1 ; Mask of the point is set to 1.
        lel2pt_attr[adj_pt[j]].parent=i
        lel2pt_attr[adj_pt[j]].steps=lel2pt_attr[adj_pt[j]].steps+1
        lel2pt_attr[adj_pt[j]].v=result[0]+lel1pt_attr[i].v
        lel2pt_attr[adj_pt[j]].dh= result[1]+lel1pt_attr[i].dh
        lel2pt_attr[adj_pt[j]].calculated=lel2pt_attr[adj_pt[j]].calculated+1
        lel2pt_attr[adj_pt[j]].v_acc=0
        lel2pt_attr[adj_pt[j]].dh_acc=0
        lel2pt_attr[adj_pt[j]].weight=lel1pt_attr[i].weight+1;//////////////////////////////////////////////////////////
        ;        values=[[values], [i, adj_pt[j], TRANSPOSE(result), ls_coh, ls_err]]
        CONTINUE
      ENDIF
      
      ; Finally, I decide to use the precision assessment described by
      ; difference between the observed data and the true data.
      ; First calculate the relative params between the j-th point and its adj. points.
      ref_r_j= finfo.near_range_slc+REAL_PART(adj_pt[j])*finfo.azimuth_pixel_spacing
      sinla_j= SIN(lel2pla[adj_pt[j]])
      Bperp_j= lel2pbase[adj_pt[j], refine_ind]
      dvddh_real=[0.0, 0.0]
      FOR k=0D, N_ELEMENTS(adj_adj_pt)-1D DO BEGIN
        lel1pdiff_k= lel1pdiff[adj_adj_pt[k], refine_ind]
        dphi_k= ATAN(lel1pdiff_k*CONJ(lel2pdiff_j),/PHASE)
        
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
      
      dvddh_obs_v=lel1pt_attr[adj_adj_pt].v-lel2pt_attr[adj_pt[j]].v
      dvddh_obs_dh=lel1pt_attr[adj_adj_pt].dh-lel2pt_attr[adj_pt[j]].dh
      v_cosis=MAX(ABS(dvddh_real_v-dvddh_obs_v))
      dh_cosis=MAX(ABS(dvddh_real_dh-dvddh_obs_dh))
      IF v_cosis GT v_acc THEN BEGIN
        lel2pt_attr[adj_pt[j]].calculated=lel2pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      IF dh_cosis GT dh_acc THEN BEGIN
        lel2pt_attr[adj_pt[j]].calculated=lel2pt_attr[adj_pt[j]].calculated+1
        CONTINUE
      ENDIF
      dv_acc=SQRT(MEAN(TOTAL(dvddh_real_v-dvddh_obs_v)^2))
      ddh_acc= SQRT(MEAN(TOTAL(dvddh_real_dh-dvddh_obs_dh)^2))
      lel2pt_attr[adj_pt[j]].v_acc=SQRT(dv_acc^2+lel1pt_attr[i].v_acc^2)
      lel2pt_attr[adj_pt[j]].dh_acc=SQRT(ddh_acc^2+lel2pt_attr[i].dh_acc^2)
      lel2pt_attr[adj_pt[j]].parent=i
      lel2pt_attr[adj_pt[j]].steps=1
      lel2pt_attr[adj_pt[j]].v=result[0]+lel1pt_attr[i].v
      lel2pt_attr[adj_pt[j]].dh= result[1]+lel1pt_attr[i].dh
      lel2pt_attr[adj_pt[j]].accepted=1
      lel2pt_attr[adj_pt[j]].weight=lel1pt_attr[i].weight+1;//////////////////////////////////////////////////////////
    ;    PRINTF, loglun, $
    ;            STRJOIN(STRCOMPRESS([lel2plist[adj_pt[j]], lel1plist[i], lel2pt_attr[adj_pt[j]].v,lel1pt_attr[i].v]))
      
      
      
    ENDFOR
    
    
  ENDFOR
  ; Output the result. Formats are referred to region growing.pro
  pt_calculated= WHERE(lel2pt_attr.accepted EQ 1, count)
  pt_coors= lel2plist[pt_calculated]
  v= lel2pt_attr[pt_calculated].v
  dh= lel2pt_attr[pt_calculated].dh
  result= [[pt_calculated],[REAL_PART(pt_coors)], [IMAGINARY(pt_coors)], [v], [dh]]
  result= TRANSPOSE(result)
  
  PrintF, loglun, ''
  PrintF, loglun, 'Statistics of the results.'
  PrintF, loglun, 'Max_v:'+STRING(MAX(v, min=min_v))
  PrintF, loglun, 'Min_v:'+STRING(min_v)
  PrintF, loglun, 'Max_dh:'+STRING(MAX(dh, min=min_dh))
  PrintF, loglun, 'Min_dh:'+STRING(min_dh)
  
  OPENW, lun, lel2vdhfile,/GET_LUN ; Index , x, y, v, dh
  WRITEU, lun, result
  FREE_LUN, lun
  PrintF, loglun, ''
  PRINTF, loglun, 'Points calculated:'+STRING(count)
  PrintF, loglun, 'Results of the points are stored in '+vdhfile
  PrintF, loglun, 'Formats are: [index x y v dh]'
  PrintF, loglun, 'For details, please read '+vdhfile+'.txt'
  OPENW, lun, lel2vdhfile+'.txt',/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun
  
  lel2pt_attr= lel2pt_attr[pt_calculated]
  OPENW,lun, lel2ptattrfile,/GET_LUN
  WRITEU, lun, lel2pt_attr
  FREE_LUN, lun
  PrintF, loglun, ''
  PrintF, loglun, 'All information of a point is contained in:'+lel2ptattrfile
  PrintF, loglun, 'Please be reminded that points with low quality are not printed.'
  
  
  ; update plist
  TLI_UPDATEPLIST, lel2vdhfile,lel2plistfile_update,/vdhfile
  ; update msk
  TLI_UPDATEMSK, mskfile, lel2vdhfile, finfo.range_samples, finfo.azimuth_lines
  ; update ptattr
  TLI_UPDATEPTATTR, lel2ptattrfile,  plistfile_orig=lel1plistfile_update, plistfile_update=lel2plistfile_update, outputfile=lel2ptattrfile_update
  ; merge vdh
  TLI_MERGE_RESULTS, vdhfile, lel2vdhfile,type='vdh'
  ; merge ptattr
  TLI_MERGE_RESULTS, lel1ptattrfile, lel2ptattrfile_update, type='ptattr'
  ; merge plist
  TLI_MERGE_RESULTS, lel1plistfile, lel2plistfile_update, type='plist'
  
  
  PrintF, loglun, 'Results of lel1 and lel2 are merged in:'
  PrintF, loglun, lel2vdhfile+'_merge.'
  time_end= SYSTIME(/SECONDS)
  time_consumed= (time_end-time_start)/3600D
  PrintF,loglun,  'Time consumed(h): ',STRCOMPRESS(time_consumed)
  
  
  PrintF,loglun, ''
  PrintF, loglun, 'Points analysis of the second level is finished.'
  FREE_LUN, loglun
  
  Print, 'TLI_HPA_2LEVEL:Main pro finished!'
  

END