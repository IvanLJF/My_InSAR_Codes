; Select phase correlated points.
; T. LI @ ISEIS, 20130524.
@ tli_hpa_2level
@ tli_updatemsk
FUNCTION TLI_PHASE_CORRELATION, slc_m, slc_s

  ; For simplicity, do not judge the input params.
  phi_m=ATAN(slc_m,/PHASE)
  phi_s=ATAN(slc_s,/PHASE)
  result=CORRELATE(phi_m, phi_s)
  RETURN, result
END

PRO TLI_LOOP_PCP,sarlistfile, itabfile, plistfile_last,plistfile_this, mskfile,loglun,finfo,$
    coef=coef,dafile=dafile, search_radius=search_radius, $
    arcsfile_this=arcsfile_this,corr_thresh=corr_thresh,$
    tile_samples=tile_samples, tile_lines=tile_lines
  ; sarlistfile            : sarlist file
  ; itabfile               : itab file
  ; plistfile_last         : The former plist file.
  ; plistfile_this         : the plistfile of this level. PSC
  ; mskfile                : the mask file indicating which points are processed.
  ; loglun                 : the file unit of the logfile.
  ; finfo                  : the file info.
  ; coef                   : the coefficient of the method.
  ; dafile                 : DA map. Can be produced from tli_hpa_da.pro
  ; search_radius          : The radius used to search the correlated points.
  
    
  IF N_PARAMS() NE 7 THEN Message, '*** TLI_LOOP_SCP - Usage error. ***'
  mslc='whatever'
  IF NOT KEYWORD_SET(arcsfile_this) THEN BEGIN
    arcsfile_this=FILE_BASENAME(plistfile_last)+'-'+FILE_BASENAME(plistfile_this)+'.arc'
  ENDIF
  
  ; Define some params
  IF NOT KEYWORD_SET(coef) THEN coef=2.0 ; Select points with amp. > coef_amp*mean_amp
  IF NOT KEYWORD_SET(tile_samples) THEN tile_samples=100
  IF NOT KEYWORD_SET(tile_lines) THEN tile_lines=100
  IF NOT KEYWORD_SET(corr_thresh) THEN corr_thresh=0.9
  
  finfo=TLI_LOAD_MPAR(sarlistfile,itabfile)
  
  ; Update the mask file.
  TLI_UPDATEMSK, mskfile, plistfile_last, finfo.range_samples, finfo.azimuth_lines, lel=1,type='plist'
  
  ; Select PT using coefs
  plist_this=TLI_PSSELECT_SINGLE(dafile, mskfile, coef=coef, samples=finfo.range_samples, format='float')
  npt_this=N_ELEMENTS(plist_this)
  IF npt_this LT 10 THEN Message, 'The point candidates are too small.'
  OPENW, lun, plistfile_this,/GET_LUN
  WRITEU, lun, plist_this
  FREE_LUN, lun
  PrintF, loglun, ''
  PrintF, loglun, 'Select PCP candidates using coef = '+STRCOMPRESS(coef)
  PrintF, loglun, 'The result is stored temporally in: '+plistfile_this
  PrintF, loglun, 'The initial points number:'+STRCOMPRESS(N_ELEMENTS(plist_this))
  PrintF, loglun, ''
  
  ;---------------------------- Diff phase of last level.--------------------
  PrintF, loglun, 'Calculate the differential phase for the points in last and this levels.'
  PrintF, loglun, 'Start at time:'+(TLI_TIME(/str))
  ; Calculate the diff phase
  
  npt_last=TLI_PNUMBER(plistfile_last)
  nintf=FILE_LINES(itabfile)
  pdifffile_last=plistfile_last+'.pdiff'
  master=TLI_GAMMA_INT(sarlistfile, itabfile,/onlymaster, /date,/uniq)
  IF FILE_TEST(pdifffile_last) THEN BEGIN
    pdifffinfo=FILE_INFO(pdifffile_last)
    IF pdifffinfo.size NE npt_last*nintf*8 THEN BEGIN
      TLI_HPA_PDIFF, FILE_DIRNAME(plistfile_last), plistfile_last, master,$
        plistfile_GAMMA=plistfile_GAMMA, pdifffile_GAMMA=pdifffile_GAMMA, pslcfile=pdifffile_last
    ENDIF
  ENDIF ELSE BEGIN
    TLI_HPA_PDIFF, FILE_DIRNAME(plistfile_last), plistfile_last, master, $
      plistfile_GAMMA=plistfile_GAMMA, pdifffile_GAMMA=pdifffile_GAMMA, pslcfile=pdifffile_last
  ENDELSE
  ;------------------------------------------------------------------------------
  
  ; -------------------Diff phase of this level-----------------------
  npt_this=TLI_PNUMBER(plistfile_this)
  pdifffile_this=plistfile_this+'.pdiff'
  IF FILE_TEST(pdifffile_this) THEN BEGIN
    pdifffinfo=FILE_INFO(pdifffile_this)
    IF pdifffinfo.size NE npt_this*nintf*8 THEN BEGIN
      TLI_HPA_PDIFF, FILE_DIRNAME(plistfile_this), plistfile_this,master, $
        plistfile_GAMMA=plistfile_GAMMA, pdifffile_GAMMA=pdifffile_GAMMA, pslcfile=pdifffile_this
    ENDIF
  ENDIF ELSE BEGIN
    TLI_HPA_PDIFF, FILE_DIRNAME(plistfile_this), plistfile_this, master,$
      plistfile_GAMMA=plistfile_GAMMA, pdifffile_GAMMA=pdifffile_GAMMA, pslcfile=pdifffile_this
  ENDELSE
  PrintF, loglun, 'End at time:'+TLI_TIME(/str)
  ; -----------------------------------------------------------------
  
  ;------------------------------PCC-------------------------
  ; Using PCC
  ; Extract the points with amp. in coef_amp
  
  ; Tile data
  pt_structfile=plistfile_this+'.pstr'
  ptstruct_this=TLI_HPA_TILE_PT(plist_this, finfo.range_samples, finfo.azimuth_lines, tile_samples, tile_lines, pt_structfile=pt_structfile)
  rasstruct_last= TLI_HPA_TILE_DATA(mslc,finfo.range_samples, finfo.azimuth_lines,tile_samples=tile_samples, tile_lines=tile_lines)
  ind= rasstruct_last.index
  plist_last=TLI_READMYFILES(plistfile_last, type='plist')
  npt_last=N_ELEMENTS(plist_last)
  pdiff_last=TLI_READDATA(pdifffile_last, samples=npt_last, format='fcomplex')
  pdiff_this=TLI_READDATA(pdifffile_this, samples=npt_this, format='fcomplex')
  
  count=0D
  count_tmp=0D
  plistfile_this_tmp=plistfile_this+'.tmp'
  ; Write when count_tmp eq 1000.
  wrt_count=10000
  plist_this_tmp=COMPLEXARR(wrt_count)
  arcs_tmp=COMPLEXARR(3, wrt_count)
  OPENW, plistlun, plistfile_this_tmp,/GET_LUN
  OPENW, arclun, arcsfile_this,/GET_LUN
  DEVICE, DECOMPOSED=1
  !P.BACKGROUND='FFFFFF'XL
  !P.COLOR='000000'XL
  pmask_this=BYTARR(npt_this)    ;-------------------------Better to use a mask file-----------------------------
  FOR i=0L, npt_last-1L DO BEGIN
    ; Find points in the same block.
    pscoor_i= plist_last[i]
    
    psx= REAL_PART(pscoor_i)
    psy= IMAGINARY(pscoor_i)
    
    indx= FLOOR(psx/tile_samples)
    indy= FLOOR(psy/tile_lines)
    ;    Print,'indx, indy', indx, indy, 'pscoor:', pscoor_i
    ; Locate the point.
    psind= ind[indx, indy]
    
   
   
    ; Load adjacent points in this level.
    adj_pt=TLI_ADJ_POINTS(pscoor_i, plist_this, ptstruct_this, rasstruct_last,radius=search_radius)
    IF adj_pt[0] EQ -1 THEN CONTINUE
;    IF ptstruct_this[psind] GE ptstruct_this[psind+1]-1 THEN CONTINUE ; No adjacent points.
;    adj_pt= ptstruct_this[ptstruct_this[psind]:ptstruct_this[psind+1]-1];**********************************
    
    adj_pt_ind=WHERE(pmask_this[adj_pt] EQ 0) ; Using the pmask array.
    IF adj_pt_ind[0] EQ -1 THEN CONTINUE ; No adj. points.
    adj_pt=adj_pt[adj_pt_ind] ; Using the pmask array.
    
    pdiff_last_i=pdiff_last[i, *]
    
    FOR j=0, N_ELEMENTS(adj_pt)-1 DO BEGIN
      pdiff_this_j=pdiff_this[adj_pt[j], *]
      
      corr_i_j= TLI_PHASE_CORRELATION(pdiff_last_i, pdiff_this_j)
      IF corr_i_j LT corr_thresh THEN CONTINUE
      pmask_this[adj_pt[j]]=1 ; Update the pmask file.
      plist_this_tmp[count_tmp]=plist_this[adj_pt[j]]
      temp=[pscoor_i, plist_this[adj_pt[j]], COMPLEX(i,count)] ; coor in plista, coor in plistb, [inda, indb]
      arcs_tmp[count_tmp]=temp
      count=count+1
      
      IF count_tmp EQ wrt_count-1 THEN BEGIN
        scale=0.2
        IF 0 THEN BEGIN
          FOR k=0, wrt_count-1 DO BEGIN
            coor= arcs_tmp[*, k]*scale
            PLOTS, [REAL_PART(coor[0]),REAL_PART(coor[1])], $
              [finfo.azimuth_lines*scale-IMAGINARY(coor[0]), finfo.azimuth_lines*scale-IMAGINARY(coor[1])], $
              /DEVICE
          ;    IF ~(i MOD 40000) THEN BEGIN
          ;      Print, i
          ;      wait, 2
          ;    ENDIF
          ENDFOR
        ENDIF
        ; Better to use a point mask
        Print, STRCOMPRESS(i)+'/'+STRCOMPRESS(npt_last-1L)
        WriteU, plistlun, plist_this_tmp
        WriteU, arclun, arcs_tmp
        count_tmp=0
      ENDIF ELSE BEGIN
        count_tmp=count_tmp+1
      ENDELSE
      
    ENDFOR
    
  ENDFOR
  IF count MOD wrt_count-1 THEN BEGIN ; 'IF' is used to avoid duplicated write.
    WriteU, plistlun, plist_this_tmp[0:count_tmp-1]
    WriteU, arclun, arcs_tmp[*, 0:count_tmp-1]
  ENDIF
  FREE_LUN, plistlun
  FREE_LUN, arclun
  FILE_MOVE, plistfile_this_tmp, plistfile_this,/overwrite
  PrintF, loglun, 'The points accessing the quality test:'+STRCOMPRESS(count)
  PrintF, loglun, 'Plist of the last level:'+plistfile_last
  PrintF, loglun, 'Plist of this level (updated):'+plistfile_this
  PrintF, loglun, 'Finish at time: '+TLI_TIME(/str)
  PrintF, loglun, ''
;---------------------------------------------------------
  
END

PRO TLI_PCP

  COMPILE_OPT idl2
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023'
  
  workpath=workpath+PATH_SEP()
  
  ;----------Files in workpath------------
  resultpath=workpath+'PCP'+PATH_SEP()
  itabfile=workpath+'itab'
  plistfile_GAMMA=workpath+'pt'
  sarlistfile_GAMMA=workpath+'SLC_tab'
  rasfile=workpath+'ave.ras'
  ;---------------------------------------------
  
  ;-----------------Files in resultpath---------------
  sarlistfile=resultpath+'sarlist'
  logfile=resultpath+'Spatially_corr_points.log'
  loglun=TLI_OPENLOG(logfile)
  plistfile_lel1=resultpath+'lel1plist'
  mskfile=resultpath+'pcp.mask'
  IF FILE_TEST(mskfile) THEN FILE_DELETE, mskfile
  dafile=resultpath+'DA'
  ;------------------------------------------------------------
  
  IF NOT FILE_TEST(resultpath,/DIRECTORY) THEN FILE_MKDIR, resultpath
  
  ;-----------Create DA file-------------------
  TLI_HPA_DA, sarlistfile,outputfile=dafile
  ;-----------------------------------------
  
  ;-----------Change sarlist to my own format--------------
  TLI_GAMMA2MYFORMAT_SARLIST, sarlistfile_gamma, sarlistfile
  finfo=TLI_LOAD_MPAR(sarlistfile,itabfile)
  ;------------------------------------------
  
  PrintF, loglun, 'Main pro started at: '+STRJOIN(STRCOMPRESS(TLI_TIME()))
  PrintF, loglun, ''
  
  ;----------------------------DA------------------
  ; Using DA
  da=0.45
  TLI_HPA_PSC, sarlistfile, da=da, tempfile=dafile,outputfile=plistfile_lel1
  npt=TLI_PNUMBER(plistfile_lel1)
  PrintF, loglun, '******************************************************************'
  PrintF, loglun, ''
  PrintF, loglun, 'Select PSC using (DA, amp):('+STRING(DA)+')'
  PrintF, loglun, STRING(npt)
  ;------------------------------------------------------------
  corr_thresh=0.8
  tile_samples=50
  tile_lines=50
  loop_times=3
  if 1 then BEGIN
    count=0
    FOR i=0, loop_times-1 DO BEGIN
      Print, i, loop_times-1
      count=count+1
      plistfile_last=resultpath+'lel'+STRCOMPRESS(count,/REMOVE_ALL)+'plist'
      plistfile_this=resultpath+'lel'+STRCOMPRESS(count+1,/REMOVE_ALL)+'plist'
      arcsfile_this=FILE_BASENAME(plistfile_last)+'-'+FILE_BASENAME(plistfile_this)+'.arc'
      
      
      
      
      
      
      coef=0.45
      
      
      
      
      
      
      
      
      TLI_LOOP_PCP,sarlistfile, itabfile, plistfile_last,plistfile_this, mskfile,loglun,finfo,$
        coef=coef, dafile=dafile,$
        arcsfile_this=arcsfile_this,corr_thresh=corr_thresh,$
        tile_samples=tile_samples, tile_lines=tile_lines
      outputfile=plistfile_this+'.jpg'
      TLI_PLOT_PLIST,plistfile_this, rasfile, sarlistfile,outputfile=outputfile,/show
    ENDFOR
  ENDIF
  
  count=3
  FOR i=3, loop_times+3-1 DO BEGIN
    print, i, loop_times+2
    FOR j=0, 3 DO BEGIN ; Just select points with amp in [2.0-0.5*(j+1), 2.0-0.5*j]
      count=count+1
      plistfile_last=resultpath+'lel'+STRCOMPRESS(count,/REMOVE_ALL)+'plist'
      plistfile_this=resultpath+'lel'+STRCOMPRESS(count+1,/REMOVE_ALL)+'plist'
      arcsfile_this=FILE_BASENAME(plistfile_last)+'-'+FILE_BASENAME(plistfile_this)+'.arc'
      coef_amp=[2.0-0.5*(j+1), 2.0-0.5*j]
      
      TLI_LOOP_PCP,sarlistfile, itabfile, plistfile_last,plistfile_this, mskfile,loglun,finfo,$
        coef=coef, dafile=dafile,$
        arcsfile_this=arcsfile_this,corr_thresh=corr_thresh,$
        tile_samples=tile_samples, tile_lines=tile_lines
      outputfile=plistfile_this+'.jpg'
      TLI_PLOT_PLIST,plistfile_this, rasfile, sarlistfile,outputfile=outputfile
    ENDFOR
  ENDFOR
  
  PrintF, loglun, TLI_TIME(/str)
  FREE_LUN, loglun
  Print, 'Main pro. finished.'
  Print, TLI_TIME(/str)
END