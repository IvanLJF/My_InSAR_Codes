  @tli_hpa_1level ; Compile the functions here. Case sensitive.
  @tli_hpa_2level
  @tli_hpa_checkfiles
  PRO TLI_HPA_LOOP,workpath, coef=coef, level=level,force=force,$
      mask_pt_corr=mask_pt_corr, mask_arc=mask_arc, mask_pt_coh=mask_pt_coh,$
      tile_samples=tile_samples, tile_lines=tile_lines,search_radius=search_radius,$
      v_acc=v_acc, dh_acc=dh_acc
      
    ;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
      
    COMPILE_OPT idl2
    ;  IF N_PARAMS() NE 1 THEN Message, 'Error: Usage: TLI_HPA_LOOP, workpath, coef=coef, level=level'
    ; Set som params
    ; Input files
    IF ~TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
    ;workpath=workpath+PATH_SEP()
    resultpath=workpath+'HPA'
    resultpath=resultpath+PATH_SEP()
    logfile= resultpath+'log.txt'
    IF NOT KEYWORD_SET(coef) THEN coef=0.5 ; This is the threshold for PSC.**********
    ; Find which HPA level is in this loop.
    hpafiles= FILE_SEARCH(resultpath+'lel*ptattr', count=nfiles)
    hpafiles= FILE_BASENAME(hpafiles)
    IF nfiles EQ -1 THEN Message, 'Please first run the 1st and 2nd level.'
    
    endpos=STRPOS(hpafiles, 'ptattr')
    levels=0
    FOR i=0, nfiles-1 DO BEGIN
      levels= [levels,STRMID(hpafiles[i], 3,endpos[i])]
    ENDFOR
    levels= LONG(levels[1:*])
    templevel= MAX(levels)
    IF NOT KEYWORD_SET(level) THEN BEGIN
      level=templevel
      
    ENDIF ELSE BEGIN
      ; Check the level
      IF level GT templevel+1 THEN BEGIN
        Message, 'ERROR! Level'+STRCOMPRESS(templevel)+' is not finished yet.'
      ENDIF
      IF level LT templevel+1 THEN BEGIN
        Print, '*** Warning! You are trying to repeat an step that has already be finished! ***'
        Print, '*** Warning! This will spend you another hours! ***'
        temp=''
        IF NOT KEYWORD_SET(force) THEN BEGIN
          READ, temp,PROMPT='Please type Y to confirm or N to cancle: ***'
        ENDIF
        temp= STRLOWCASE(temp)
        IF temp EQ 'n' THEN BEGIN
          Print, '*** Processing is cancled. ***'
          RETURN
        ENDIF
      ENDIF
    ENDELSE
    
    
    
    IF FILE_TEST(logfile) THEN BEGIN
      OPENW, loglun, logfile,/GET_LUN,/APPEND
      PRINTF, loglun, '*********************************'
    ENDIF ELSE BEGIN
      OPENW, loglun, logfile,/GET_LUN
      PrintF, loglun, 'This is the log file for HPA test.'
      PrintF, loglun, ''
      PrintF, loglun, '*********************************'
    ENDELSE
    PrintF, loglun, 'This is level:'+STRCOMPRESS(level)
    
    
    sarlistfilegamma= workpath+'SLC_tab'
    pdifffile= workpath+'pdiff0'
    plistfilegamma= workpath+'pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/plist'
    plistfile= resultpath+'plist'
    itabfile= workpath+'itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
    arcsfile=resultpath+'arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/arcs'
    pbasefile=resultpath+'pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
    plafile=resultpath+'pla'
    pdifffile= resultpath+'pslc'
    dvddhfile=resultpath+'dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/dvddh'
    vdhfile= resultpath+'vdh'
    ptattrfile= resultpath+'ptattr'
    mskfile= resultpath+'msk'
    
    lelaplistfile= resultpath+'lel'+STRCOMPRESS(level-1,/REMOVE_ALL)+'plist'
    lelapdifffile= resultpath+'lel'+STRCOMPRESS(level-1,/REMOVE_ALL)+'pdiff'
    lelapslcfile_update= resultpath+'lel'+STRCOMPRESS(level-1,/REMOVE_ALL)+'pslc_update'
    lelapbasefile= resultpath+'lel'+STRCOMPRESS(level-1,/REMOVE_ALL)+'pbase'
    lelaplafile= resultpath+'lel'+STRCOMPRESS(level-1,/REMOVE_ALL)+'pla'
    lelaptattrfile= resultpath+'lel'+STRCOMPRESS(level-1,/REMOVE_ALL)+'ptattr'
    lelaptstructfile= resultpath+'lel'+STRCOMPRESS(level-1,/REMOVE_ALL)+'ptstruct'
    lelavdhfile= resultpath+'lel'+STRCOMPRESS(level-1,/REMOVE_ALL)+'vdh'
    
    lelaptstructfile_update=lelaptstructfile+'_update'
    lelavdhfile_merge= lelavdhfile+'_merge'
    lelaplistfile_update= lelaplistfile+'_update'
    lelaptattrfile_update= lelaptattrfile+'_update'
    lelapbasefile_update= lelapbasefile+'_update'
    lelaplafile_update= lelaplafile+'_update'
    lelapdifffile_update= lelapdifffile+'_update'
    
    lelaplistfile_merge=lelaplistfile_update+'_merge';///////////////////////////////////////////////////////
    lelaptattrfile_merge=lelaptattrfile_update+'_merge';///////////////////////////////////////////////////////
    lelaplistfile_update=lelaplistfile_merge ;///////////////////////////////////////////////////////
    lelaptattrfile_update=lelaptattrfile_merge;///////////////////////////////////////////////////////
    
    lelbplistfile=resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'plist'
    lelbptstructfile=resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'ptstruct'
    lelbpdifffile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'pdiff'
    lelbpslcfile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'pslc'
    lelbpbasefile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'pbase'
    lelbplafile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'pla'
    lelbvdhfile= resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'vdh'
    lelbptattrfile=resultpath+'lel'+STRCOMPRESS(level,/REMOVE_ALL)+'ptattr'
    lelbplistfile_update=lelbplistfile+'_update';///////////////////////////////////////////////////////
    lelbptattrfile_update=lelbptattrfile+'_update';///////////////////////////////////////////////////////
    
    sarlistfile= resultpath+'sarlist_Linux'
    pbasefile= resultpath+'pbase'
    plafile= resultpath+'pla'
    basepath= resultpath+'base'
    dafile=resultpath+'DA'
    result=TLI_HPA_CHECKFILES(resultpath, level=level-1,pass = pass) ; Check if the last loop is finished.
    IF NOT pass THEN Message, result
    
    dv_inc=3 ; Increased percent of v is not larger than dv_inc
    ddh_inc=10 ; Increased percent of dh is not larger thatn ddh_inc
    ;    mask_pt_corr=0.9
    ;    mask_arc= 0.9
    ;    mask_pt_coh= 0.9
    refind= refind
    IF ~KEYWORD_SET(v_acc) THEN v_acc= 5
    IF ~KEYWORD_SET(dh_acc) THEN dh_acc= 10
    adj_dist=10      ; Distance to locate adjacent points for consistency checking.
    ;    search_radius=25 ; Search radius of the information expansion.
    time_start= SYSTIME(/SECONDS)
    c= 299792458D ; Speed light
    temp= ALOG(2)
    e= 2^(1/temp)
    PrintF, loglun, 'Starts on:'+STRCOMPRESS(STRJOIN(TLI_TIME()))
    
    finfo= TLI_LOAD_MPAR(sarlistfilegamma, itabfile)
    lelanpt= TLI_PNUMBER(lelaplistfile_update)
    ;    tile_samples=30
    ;    tile_lines=30
    nintf= FILE_LINES(itabfile)
    
    mslc= TLI_GAMMA_INT(sarlistfilegamma,itabfile,/onlymaster)
    mslc= mslc[UNIQ(mslc)]
    
    master=TLI_GAMMA_FNAME(mslc,/DATE)
    
    IF 1 THEN BEGIN
      ; Update the mask file
      ;      TLI_UPDATEPLIST, lelavdhfile,lelaplistfile_update,/vdhfile
      ;;;;;;;;TLI_UPDATEMSK, mskfile, lelavdhfile_merge, finfo.range_samples, finfo.azimuth_lines, lel=level;**********************************************
      ;      TLI_UPDATEMSK, mskfile, lelavdhfile, finfo.range_samples, finfo.azimuth_lines, lel=level
      ;      TLI_UPDATEPTATTR, lelaptattrfile, outputfile=lelaptattrfile_update
    
      TLI_GAMMA_BP_LA_FUN, lelaplistfile_update, itabfile, sarlistfilegamma, basepath, lelapbasefile_update, lelaplafile_update
      ; Change gamma's format to my own.
      TLI_GAMMA2MYFORMAT_SARLIST, sarlistfilegamma, sarlistfile
      TLI_HPA_PDIFF, resultpath, lelaplistfile_update, master, pdifffile=lelapdifffile_update
      temp=TLI_PSLC(sarlistfile,lelaplistfile_update, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
        /swap_endian, outfile=lelapslcfile_update)
      ;    lelapslc_update=TLI_PSLC(sarlistfile,lelaplistfile_update, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
      ;      swap_endian=1, outfile=lelapdifffile_update)
        
      ; Choose the points to be analysis. For simplicity, only the master image is used.
      ; in case of multi masters, arbitrarily choose one
      ; Use a mask file to make sure that the points in the aformentioned are not analyzed.
      TLI_HPA_DA, sarlistfile,outputfile=dafile
      lelbplist=TLI_PSSELECT_SINGLE(dafile, mskfile=mskfile, coef=coef, samples=finfo.range_samples, format='float') ;**************************
      PrintF, loglun, ''
      PrintF, loglun, 'Threshold of the PSC:'
      PrintF, loglun, STRCOMPRESS(coef)
      PrintF, loglun, ''
      OPENW, lun, lelbplistfile,/GET_LUN
      WRITEU, lun, lelbplist
      FREE_LUN, lun
      lelbnpt= TLI_PNUMBER(lelbplistfile)
      
      ; Sort out the points.
      ; Using a wonderful structure to maitain the data.
      ; Tile data
      
      ;  finfo= TLI_LOAD_SLC_PAR(mslc+'.par')
      lelbpt_struct= TLI_HPA_TILE_PT(lelbplist, finfo.range_samples, finfo.azimuth_lines, tile_samples, tile_lines, pt_structfile=lelbptstructfile)
      lelapt_struct= TLI_HPA_TILE_PT(lelaplistfile_update, finfo.range_samples, finfo.azimuth_lines, tile_samples, tile_lines, pt_structfile=lelaptstructfile_update,/file)
      
      ; Extract diff. phase on the 3-rd level points.
      TLI_HPA_PDIFF, resultpath, lelbplistfile, master, pdifffile=lelbpdifffile
      temp=TLI_PSLC(sarlistfile,lelbplistfile, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
        /swap_endian, outfile=lelbpslcfile)
      ;    lelbpslc=TLI_PSLC(sarlistfile,lelbplistfile, finfo.range_samples, finfo.azimuth_lines,finfo.image_format,$
      ;      /swap_endian, outfile=lelbpdifffile)
        
      PRINTF, loglun, 'plistfile:'+lelbplistfile
      PrintF, loglun, 'number of points:'+STRING(lelbnpt)
      PrintF, loglun, ''
      ; Extract pbase and pslc on the lelb's points
      TLI_GAMMA_BP_LA_FUN, lelbplistfile, itabfile, sarlistfilegamma, basepath, lelbpbasefile, lelbplafile
    ENDIF
    
    
    ; A Great loop.
    ; Read lela points.
    lelanpt= TLI_PNUMBER(lelaplistfile_update)
    lelaplist= TLI_READDATA(lelaplistfile_update, samples=1, format='FCOMPLEX')
    lelapslc= TLI_READDATA(lelapslcfile_update, samples=lelanpt, format='FCOMPLEX')
    lelapdiff= TLI_READDATA(lelapdifffile_update, samples=lelanpt, format='FCOMPLEX')
    lelapbase= TLI_READDATA(lelapbasefile_update, samples=lelanpt, format='DOUBLE')
    lelapla= TLI_READDATA(lelaplafile_update, samples= lelanpt, format='DOUBLE')
    lelapt_struct= TLI_READDATA(lelaptstructfile_update,lines=1, format='LONG')
    
    ras_struct= TLI_HPA_TILE_DATA(mslc,finfo.range_samples, finfo.azimuth_lines,tile_samples=tile_samples, tile_lines=tile_lines)
    ind= ras_struct.index
    lelapt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
    lelapt_attr= REPLICATE(lelapt_attr, lelanpt)
    OPENR, lun, lelaptattrfile_update,/GET_LUN
    READU, lun, lelapt_attr
    FREE_LUN, lun
    
    PrintF, loglun, 'Points in the last level:'+STRING(lelanpt)
    PrintF, loglun, 'We apply the algorithm for each lelapoint.'
    
    ; Prepare some params for calculation.
    nrs= finfo.near_range_slc
    rps= finfo.range_pixel_spacing
    wavelength= c/finfo.radar_frequency
    lelbplist= TLI_READDATA(lelbplistfile, samples=1, format='FCOMPLEX')
    lelbpbase= TLI_READDATA(lelbpbasefile, samples= lelbnpt, format='DOUBLE')
    lelbpla= TLI_READDATA(lelbplafile,samples=lelbnpt, format='DOUBLE')
    lelbpslc= TLI_READDATA(lelbpslcfile, samples=lelbnpt, format='FCOMPLEX')
    Tbase_old= TBASE_ALL(sarlistfile, itabfile); Backup Tbase
    lelbpt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
    lelbnpt= TLI_PNUMBER(lelbplistfile)
    lelbpt_attr=REPLICATE(lelbpt_attr, lelbnpt)
    lelbpdiff=TLI_READDATA(lelbpdifffile, samples=lelbnpt, format='FCOMPLEX')
    
    corr_method=1  ; 0 : using original phase
    ;  corr_method=1  ; 1 : using diff. phase.
    For i=0D, lelanpt-1D DO BEGIN
    
      IF ~ (i MOD 100) THEN Print, STRCOMPRESS(i), '/', STRCOMPRESS(LONG(lelanpt)-1)
      
      lelapslc_i_old=lelapslc[i, *]
      lelaphi_old=ATAN(lelapslc_i_old,/PHASE)
      
      lelapdiff_i_old= lelapdiff[i, *]
      lelapdiff_phi_old=ATAN(lelapdiff_i_old, /PHASE)
      ; Find adjacent point for each ref. point. This is useful when using a mask file.
      ; Or find each adjacent point a ref. point.
      pscoor_i= lelaplist[i]
      
      ;      psx= REAL_PART(pscoor_i)
      ;      psy= IMAGINARY(pscoor_i)
      ;
      ;      indx= FLOOR(psx/tile_samples)
      ;      indy= FLOOR(psy/tile_lines)
      ;      ;    Print,'indx, indy', indx, indy, 'pscoor:', pscoor_i
      ;      ; Locate the point.
      ;      psind= ind[indx, indy]
      ;
      ;      ; Load adjacent points
      ;      IF lelbpt_struct[psind] GE lelbpt_struct[psind+1]-1 THEN CONTINUE ; No adjacent points.
      ;      adj_pt= lelbpt_struct[lelbpt_struct[psind]:lelbpt_struct[psind+1]-1];**********************************Find lela's adj. points in lelb
      adj_pt=TLI_ADJ_POINTS(pscoor_i,lelbplist, lelbpt_struct,ras_struct,radius=search_radius)
      IF adj_pt[0] EQ -1 THEN CONTINUE
      
      
      
      
      ;    Print,'Number of adjcent points of the'+STRING(i)+'th point:'+STRING(N_ELEMENTS(adj_pt))
      ;    IF N_ELEMENTS(adj_pt) NE 2638 THEN BEGIN
      ;
      ;      Print, i
      ;    ENDIF
      temp= WHERE(lelbpt_attr[adj_pt].accepted EQ 0) ; To calculate params on the uncalculated points.
      IF temp[0] EQ -1 THEN CONTINUE
      adj_pt= adj_pt[temp]
      temp=0
      
      ; Calculate correlation between the i-th point and its adj. points.
      ref_r=finfo.near_range_slc+REAL_PART(lelaplist[i])
      sinla= SIN(lelapla[i])
      Bperp_old= lelapbase[i, *]
      FOR j=0, N_ELEMENTS(adj_pt)-1 DO BEGIN
      
        lelbpdiff_j_old=lelbpdiff[adj_pt[j], *]
        lelbpdiff_phi_old=ATAN(lelbpdiff_j_old,/PHASE)
        ;      plot,lelapslc_phi_old,color=100,title='Original phase' & oplot, lelapslc_phi_old,color=200
        
        
        
        
        
        IF corr_method EQ 1 THEN BEGIN ; Use the original phase.
          lelbslc_j_old=lelbpslc[adj_pt[j],*]
          lelbphi_old=ATAN(lelbslc_j_old,/PHASE)
          corr=ABS(CORRELATE(lelaphi_old, lelbphi_old))
          IF corr LT mask_pt_corr THEN BEGIN
            ; Refine data
            ; diffphi=ATAN(lelbpdiff_j*CONJ(lelapdiff_i),/PHASE)
            diffphi=lelbphi_old-lelaphi_old
            refine_ind=TLI_REFINE_DATA(diffphi,delta=1)  ;******************************************************************
            IF N_ELEMENTS(refine_ind) LT nintf*0.5 THEN CONTINUE ; Too many errors,then quit
            lelb_phi=lelbphi_old[*,refine_ind]
            lela_phi= lelaphi_old[*,refine_ind]
            corr=ABS(CORRELATE(lela_phi, lelb_phi))
            IF corr LT mask_pt_corr THEN BEGIN
              ;          plot, diffphi
              ;          plot,lelapdiff_phi,color=100,title='Original phase' & oplot, lelbpdiff_phi,color=200
              ; Give no result.
              CONTINUE
            ENDIF
            lelapdiff_phi=lelapdiff_phi_old[*, refine_ind]
            lelbpdiff_phi=lelbpdiff_phi_old[*, refine_ind]
            Tbase=Tbase_old[*, refine_ind]
            Bperp=Bperp_old[*, refine_ind]
            lelbpdiff_j=lelbpdiff_j_old[*, refine_ind]
            lelapdiff_i=lelapdiff_i_old[*, refine_ind]
          ENDIF ELSE BEGIN
            refine_ind=LONARR(nintf)
            lelbpdiff_j=lelbpdiff_j_old
            lelbpdiff_phi=lelbpdiff_phi_old
            lelapdiff_i=lelapdiff_i_old
            lelapdiff_phi=lelapdiff_phi_old
            Tbase=Tbase_old
            Bperp=Bperp_old
          ENDELSE
        ENDIF ELSE BEGIN ; Use the differential phase
        
        
          corr=ABS(CORRELATE(lelapdiff_phi_old, lelbpdiff_phi_old))
          IF corr LT mask_pt_corr THEN BEGIN
            ; Refine data
            ; diffphi=ATAN(lelapslc_j*CONJ(lelapslc_i),/PHASE)
            diffphi=lelbpdiff_phi_old-lelapdiff_phi_old
            refine_ind=TLI_REFINE_DATA(diffphi,delta=1)  ;******************************************************************
            IF N_ELEMENTS(refine_ind) LT nintf*0.5 THEN CONTINUE ; Too many errors,then quit
            lelbpdiff_phi=lelbpdiff_phi_old[*,refine_ind]
            lelapdiff_phi= lelapdiff_phi_old[*,refine_ind]
            corr=ABS(CORRELATE(lelapdiff_phi, lelbpdiff_phi))
            IF corr LT mask_pt_corr THEN BEGIN
              ;          plot, diffphi
              ;          plot,lelapslc_phi,color=100,title='Original phase' & oplot, lelapslc_phi,color=200
              ; Give no result.
              CONTINUE
            ENDIF
            Tbase=Tbase_old[*, refine_ind]
            Bperp=Bperp_old[*, refine_ind]
            lelbpdiff_j=lelbpdiff_j_old[*, refine_ind]
            lelapdiff_i=lelapdiff_i_old[*, refine_ind]
          ENDIF ELSE BEGIN
            refine_ind=LONARR(nintf)
            lelbpdiff_j=lelbpdiff_j_old
            lelbpdiff_phi=lelbpdiff_phi_old
            lelapdiff_i=lelapdiff_i_old
            lelapdiff_phi=lelapdiff_phi_old
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
        dphi_j=ATAN(lelbpdiff_j*CONJ(lelapdiff_i),/PHASE)
        result= coefs_n##dphi_j ; dv ddh
        ;      Print,result
        ls_phi= coefs##result
        temp=dphi_j-ls_phi
        ;      plot, dphi_j,color=100,title='Cal. phase' & oplot,ls_phi,color=200
        ls_coh= ABS(MEAN(e^COMPLEX(0,temp))) ; coherence
        ;            ls_err= SQRT(TOTAL((dphi_j-ls_phi)^2)/nintf) ; sigma
        IF ls_coh LT mask_arc THEN BEGIN
          lelbpt_attr[adj_pt[j]].calculated=lelbpt_attr[adj_pt[j]].calculated+1
          CONTINUE
        ENDIF
        ;      IF ABS(result[0]) GT ABS(lelapt_attr[i].v)*dv_inc THEN BEGIN ; It is assumed that (delta vel.)% is not greater than dv_inc
        ;        lelapt_attr[adj_pt[j]].calculated=lelapt_attr[adj_pt[j]].calculated+1
        ;        CONTINUE
        ;      ENDIF
        ;      IF ABS(result[1]) GT ABS(lelapt_attr[i].dh)*ddh_inc THEN BEGIN ; Idem
        ;        lelapt_attr[adj_pt[j]].calculated=lelapt_attr[adj_pt[j]].calculated+1
        ;        CONTINUE
        ;      ENDIF
        IF ABS(result[0]) GT dv_inc THEN BEGIN ; It is assumed that (delta vel.)% is not greater than dv_inc
          lelbpt_attr[adj_pt[j]].calculated=lelbpt_attr[adj_pt[j]].calculated+1
          CONTINUE
        ENDIF
        IF ABS(result[1]) GT ddh_inc THEN BEGIN ; Idem
          lelbpt_attr[adj_pt[j]].calculated=lelbpt_attr[adj_pt[j]].calculated+1
          CONTINUE
        ENDIF
        
        
        
        
        ;        ; Using points in level 1 to assess the points quality
        ;        IF lelapt_struct[psind] GE lelapt_struct[psind+1] THEN BEGIN
        ;          ; No points in this area
        ;          ; In fact, this can never happen
        ;          CONTINUE
        ;        ENDIF
        ;        lela_adj_pt= lelapt_struct[lelapt_struct[psind]:lelapt_struct[psind+1]-1]
        ;        adj_coors= lelaplist[lela_adj_pt]
        ;        adj_dist_j= ABS(adj_coors-lelbplist[adj_pt[j]])
        ;        adj_adj_pt= WHERE(adj_dist_j LT adj_dist)
        
        
        
        adj_adj_pt= TLI_ADJ_POINTS(lelbplist[adj_pt[j]],lelaplist, lelapt_struct,ras_struct,radius=adj_dist)
        IF adj_adj_pt[0] EQ -1 THEN BEGIN
          ; Update the information
          lelbpt_attr[adj_pt[j]].accepted=1 ; Mask of the point is set to 1.
          lelbpt_attr[adj_pt[j]].parent=i
          lelbpt_attr[adj_pt[j]].steps=lelbpt_attr[adj_pt[j]].steps+1
          lelbpt_attr[adj_pt[j]].v=result[0]+lelapt_attr[i].v
          lelbpt_attr[adj_pt[j]].dh= result[1]+lelapt_attr[i].dh
          lelbpt_attr[adj_pt[j]].calculated=lelbpt_attr[adj_pt[j]].calculated+1
          lelbpt_attr[adj_pt[j]].v_acc=0
          lelbpt_attr[adj_pt[j]].dh_acc=0
          lelbpt_attr[adj_pt[j]].weight=lelapt_attr[i].weight+1;//////////////////////////////////////////////////////////
          ;        values=[[values], [i, adj_pt[j], TRANSPOSE(result), ls_coh, ls_err]]
          CONTINUE
        ENDIF
        
        ; Finally, I decide to use the precision assessment described by
        ; difference between the observed data and the true data.
        ; First calculate the relative params between the j-th point and its adj. points.
        ref_r_j= finfo.near_range_slc+REAL_PART(adj_pt[j])*finfo.azimuth_pixel_spacing
        sinla_j= SIN(lelbpla[adj_pt[j]])
        Bperp_j= lelbpbase[adj_pt[j], refine_ind]
        dvddh_real=[0.0, 0.0]
        FOR k=0, N_ELEMENTS(adj_adj_pt)-1 DO BEGIN
          lelapdiff_k= lelapdiff[adj_adj_pt[k], refine_ind]
          dphi_k= ATAN(lelapdiff_k*CONJ(lelbpdiff_j),/PHASE)
          
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
        
        dvddh_obs_v=lelapt_attr[adj_adj_pt].v-lelbpt_attr[adj_pt[j]].v
        dvddh_obs_dh=lelapt_attr[adj_adj_pt].dh-lelbpt_attr[adj_pt[j]].dh
        v_cosis=MAX(ABS(dvddh_real_v-dvddh_obs_v))
        dh_cosis=MAX(ABS(dvddh_real_dh-dvddh_obs_dh))
        IF v_cosis GT v_acc THEN BEGIN
          lelbpt_attr[adj_pt[j]].calculated=lelbpt_attr[adj_pt[j]].calculated+1
          CONTINUE
        ENDIF
        IF dh_cosis GT dh_acc THEN BEGIN
          lelbpt_attr[adj_pt[j]].calculated=lelbpt_attr[adj_pt[j]].calculated+1
          CONTINUE
        ENDIF
        dv_acc=SQRT(MEAN(TOTAL(dvddh_real_v-dvddh_obs_v)^2))
        ddh_acc= SQRT(MEAN(TOTAL(dvddh_real_dh-dvddh_obs_dh)^2))
        lelbpt_attr[adj_pt[j]].v_acc=SQRT(dv_acc^2+lelapt_attr[i].v_acc^2)
        lelbpt_attr[adj_pt[j]].dh_acc=SQRT(ddh_acc^2+lelapt_attr[i].dh_acc^2)
        lelbpt_attr[adj_pt[j]].parent=i
        lelbpt_attr[adj_pt[j]].steps=1
        lelbpt_attr[adj_pt[j]].v=result[0]+lelapt_attr[i].v
        lelbpt_attr[adj_pt[j]].dh= result[1]+lelapt_attr[i].dh
        lelbpt_attr[adj_pt[j]].accepted=1
        lelbpt_attr[adj_pt[j]].weight=lelapt_attr[i].weight+1;//////////////////////////////////////////////////////////
      ;    PRINTF, loglun, $
      ;            STRJOIN(STRCOMPRESS([lelaplist[adj_pt[j]], lelaplist[i], lelapt_attr[adj_pt[j]].v,lelapt_attr[i].v]))
        
        
        
      ENDFOR
      
      
    ENDFOR
    ; Output the result. Formats are referred to region growing.pro
    pt_calculated= WHERE(lelbpt_attr.accepted EQ 1, count)
    pt_coors= lelbplist[pt_calculated]
    v= lelbpt_attr[pt_calculated].v
    dh= lelbpt_attr[pt_calculated].dh
    result= [[pt_calculated],[REAL_PART(pt_coors)], [IMAGINARY(pt_coors)], [v], [dh]]
    result= TRANSPOSE(result)
    
    PrintF, loglun, ''
    PrintF, loglun, 'Statistics of the results.'
    PrintF, loglun, 'Max_v:'+STRING(MAX(v, min=min_v))
    PrintF, loglun, 'Min_v:'+STRING(min_v)
    PrintF, loglun, 'Max_dh:'+STRING(MAX(dh, min=min_dh))
    PrintF, loglun, 'Min_dh:'+STRING(min_dh)
    
    OPENW, lun, lelbvdhfile,/GET_LUN ; Index , x, y, v, dh
    WRITEU, lun, result
    FREE_LUN, lun
    PrintF, loglun, ''
    PRINTF, loglun, 'Points calculated:'+STRING(count)
    PrintF, loglun, 'Results of the points are stored in '+lelbvdhfile
    PrintF, loglun, 'Formats are: [index x y v dh]'
    PrintF, loglun, 'For details, please read '+lelbvdhfile+'.txt'
    OPENW, lun, lelbvdhfile+'.txt',/GET_LUN
    PRINTF, lun, result
    FREE_LUN, lun
    
    lelbpt_attr= lelbpt_attr[pt_calculated]
    OPENW,lun, lelbptattrfile,/GET_LUN
    WRITEU, lun, lelbpt_attr
    FREE_LUN, lun
    PrintF, loglun, ''
    PrintF, loglun, 'All information of a point is contained in:'+lelbptattrfile
    PrintF, loglun, 'Please be reminded that points with low quality is not output.'
    
    
    ;///////////////////////////////////////////////////////
    ; update plist
    TLI_UPDATEPLIST, lelbvdhfile,lelbplistfile_update,/vdhfile
    ; update msk
    TLI_UPDATEMSK, mskfile, lelbvdhfile, finfo.range_samples, finfo.azimuth_lines
    ; update ptattr
    TLI_UPDATEPTATTR, lelbptattrfile,  outputfile=lelbptattrfile_update
    ; merge vdh
    TLI_MERGE_RESULTS, lelavdhfile_merge, lelbvdhfile,type='vdh'
    ; merge ptattr
    TLI_MERGE_RESULTS, lelaptattrfile_merge, lelbptattrfile_update, type='ptattr'
    ; merge plist
    TLI_MERGE_RESULTS, lelaplistfile_merge, lelbplistfile_update, type='plist';///////////////////////////////////////////////////////
    ;      TLI_MERGE_RESULTS, lelavdhfile_merge, lelbvdhfile;///////////////////////////////////////////////////////
    PrintF, loglun, 'Results of lela and lelb are merged in:'
    PrintF, loglun, lelbvdhfile+'_merge.'
    
    
    time_end= SYSTIME(/SECONDS)
    time_consumed= (time_end-time_start)/3600D
    PrintF,loglun,  'Time consumed(h): ',STRCOMPRESS(time_consumed)
    
    
    PrintF,loglun, ''
    PrintF, loglun, 'Points analysis of the second level is finished.'
    FREE_LUN, loglun
    
    Print, 'TLI_HPA_'+STRCOMPRESS(level,/REMOVE_ALL)+'LEVEL:Main pro finished!'
    
  END