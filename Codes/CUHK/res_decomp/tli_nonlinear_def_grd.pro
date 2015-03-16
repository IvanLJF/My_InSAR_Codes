;+
; Get nonlinear deformation using spatial-temporal filter on gradients of the arcs.
;
; Parameters:
; 
; Keywords:
; 
; Written by:
;   T.LI @ ISEIS.
;+
@TLI_LINEAR_SOLVE_CUHK

Function TLI_CHECK_PTATTR, ptattrfile, plistfile

  ptattr=TLI_READMYFILES(ptattrfile, type='ptattr')
  plist=TLI_READMYFILES(plistfile, type='plist')
  npt=TLI_PNUMBER(plistfile)
  
  p_ind=ptattr.parent
  maxp=MAX(p_ind, MIN=minp)
  
  IF maxp GT npt THEN Begin
    Print,'Maxima of parent index is larger than npt.'
    RETURN, -1
  ENDIF
  IF minp NE -1 THEN BEGIN
    Print, 'There is no reference point found'
    RETURN, -1
  ENDIF
  
  Print, 'The files are cosistent.'
  RETURN, 1
  
END


PRO TLI_GRD2DIF, grd_xfile, grd_yfile,arcinfo, outputfile=outputfile
  ; Convert gradients to difference

  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    suffix=STRSPLIT(grd_xfile,/EXTRACT)
    temp=N_ELEMENTS(suffix)
    IF temp GE 2 THEN BEGIN
      suffix=suffix[temp-1]
      fname=FILE_BASENAME(grd_xfile,'.'+suffix)
    ENDIF ELSE BEGIN
      fname=FILE_BASENAME(grd_xfile)
    ENDELSE
    outputfile=fname+'.arcdiff'
  ENDIF
  npt=N_ELEMENTS(arcinfo)
  grd_x=TLI_READDATA(grd_xfile, samples=npt, format='DOUBLE')
  grd_y=TLI_READDATA(grd_yfile, samples=npt, format='DOUBLE')
  
  sz=SIZE(grd_x,/DIMENSIONS)
  nintf=sz[1]
  coor_dx=REBIN(arcinfo.coor_dx, npt, nintf)
  coor_dy=REBIN(arcinfo.coor_dy, npt, nintf)
  ;  result=SQRT((grd_x[*,3:*]*coor_dx)^2+(grd_y[*, 3:*]*coor_dy)^2)^2
  result= grd_x[*,3:*] * coor_dx * (REBIN(COS(arcinfo.theta), npt,nintf)) $
    +grd_y[*, 3:*] * coor_dy * (REBIN(SIN(arcinfo.theta),npt, nintf))
  OPENW, lun, outputfile,/GET_LUN
  WRITEU, lun, grd_x[*, 0:2]
  WRITEU, lun, result
  FREE_LUN, lun
  
END

FUNCTION TLI_FIND_STARTPT, ptattrfile,arcinfo=arcinfo
  ; Calculate the start point from the ptattrfile
  IF NOT KEYWORD_SET(arcinfo) THEN BEGIN
    ptattr=TLI_READMYFILES(ptattrfile, type='ptattr')
  ENDIF ELSE BEGIN
    ptattr=ptattrfile
  ENDELSE
  npt=N_ELEMENTS(ptattr)
  ind=WHERE(ptattr.parent EQ -1)
  IF ind[0] EQ -1 THEN Message, 'ERROR: there should be at least one -1'
  IF N_ELEMENTS(ind) EQ 1 THEN RETURN, ind
  
  ; Find the reference point
  FOR i=0, npt-1 DO BEGIN
    IF ptattr[i].parent NE -1 THEN BEGIN
      endind=i
      BREAK
    ENDIF
  ENDFOR
  While ptattr[endind].parent NE -1 DO BEGIN
    endind=ptattr[endind].parent
  ENDWHILE
  RETURN, endind
END

FUNCTION TLI_ARCINFO, ptattrfile, plistfile

  plist=TLI_READMYFILES(plistfile, type='plist')
  startind=TLI_FIND_STARTPT(ptattrfile)
  startcoor=plistfile[startind]
  ptattr=TLI_READMYFILES(ptattrfile, type='ptattr')
  npt=N_ELEMENTS(ptattr)
  arcinfo=CREATE_STRUCT('parent', -1L, $
    'p_coor', COMPLEX(0,0),$ ; coor of parent's point
    'coor', COMPLEX(0.0), $ ; coor of this point
    'coor_dx', 0.0, $
    'coor_dy', 0.0, $
    'theta', 0.0) ; Argument of the coor.
  ;    'phi_x', 0.0, $
  ;    'phi_y', 0.0, $
  ;    'grd_x', 0.0, $
  ;    'grd_y', 0.0, $
  ;    'slx', 0.0, $
  ;    'sly', 0.0, $
  ;    'tlx', 0.0, $
  ;    'tly', 0.0, $
  ;    'thx', 0.0, $
  ;    'thy', 0.0)
  arcinfo=REPLICATE(arcinfo, npt)
  startcoor=plist[ptattr.parent]
  endcoor=plist[LINDGEN(npt)]
  arcinfo.parent=ptattr.parent
  arcinfo.p_coor=startcoor
  arcinfo.coor=endcoor
  temp=endcoor-startcoor
  arcinfo.coor_dx=REAL_PART(temp)
  arcinfo.coor_dy=IMAGINARY(temp)
  arcinfo.theta=ATAN(arcinfo.coor_dx,arcinfo.coor_dy,/PHASE) ; npt*1
  RETURN, arcinfo
END




PRO TLI_INTEGRATION, arcinfo, filelist,refind=refind,plistfile=plistfile
  ; Integrate the difference of the point
  nfiles=N_ELEMENTS(filelist)
  Print, 'There are', STRCOMPRESS(nfiles), ' files to process.'
  Print, filelist
  IF NOT KEYWORD_SET(refind) THEN refind=TLI_FIND_STARTPT(arcinfo,/arcinfo)
  
  npt=N_ELEMENTS(arcinfo)
  
  unwmask=BYTARR(npt)
  filtered=TLI_READDATA(filelist[0], samples=npt, format='DOUBLE')
  filtered=filtered[*, 3:*] ; The first three lines are header info.
  sz=SIZE(filtered,/DIMENSIONS)
  data=DBLARR(nfiles, sz[0],sz[1])
  FOR i=0, nfiles-1 DO BEGIN
    temp=TLI_READDATA(filelist[i], samples=npt, format='DOUBLE')
    data[i, *, *]=temp[*, 3:*]
  ENDFOR
  
  
  ; This is the test version;///////////////////////
  plist=TLI_READMYFILES(plistfile,type='plist');///////////////////////
  DEVICE, decomposed=1;///////////////////////
  !P.BACKGROUND='FFFFFF'XL;///////////////////////
  !P.COLOR='000000'XL;///////////////////////
  WINDOW,/free, xsize=1000, ysize=1200
  ; This is the test version;///////////////////////
  unwmask[refind]=1
  result=data
  FOR i=0D, npt-1D DO BEGIN
  
    IF  ~(i MOD 1000) THEN Print, STRCOMPRESS(i),'/', STRCOMPRESS(npt-1)
    
    IF unwmask[i] NE 1 THEN BEGIN
      ; Trace back to the point that is calculated.
      nods=0
      thisnod=arcinfo[i].parent
      WHILE unwmask[thisnod] NE 1 DO BEGIN
        nods=[nods, thisnod]
        temp=arcinfo[thisnod].parent
        IF thisnod EQ temp THEN STOP  ; Stop the while loop.
        ; The parent of the nod is itself.
        ; This should never happen but it happens.
        ; The error can be traced back to Freenetworking or TLI_RG_DVDDH_CONSTRAINTS.
        thisnod=temp
      ENDWHILE
      nods=[[nods], thisnod]
      nods=nods[1:*]
      ;Update unwmask
      unwmask[nods]=1
      ;/////////////////////////////////////////////////////////////
      coors=plist[nods];///////////////////////
      coors_x=REAL_PART(coors);///////////////////////
      coors_y=IMAGINARY(coors);///////////////////////
      PLOT, coors_x, coors_y,/NOERASE,xrange=[0,500],yrange=[0,500]
      ;//////////////////////////////////////////////////////////////
      ; Track forward from the ref. point to this point.
      nnods=N_ELEMENTS(nods)
      start_data=result[*, nods[nnods-1], *]
      FOR j=0, nnods-2 DO BEGIN
        ind_j=nods[nnods-j-1]
        p_j=nods[nnods-j-2]
        result[*, ind_j, *]=start_data+data[*, ind_j, *]
      ENDFOR
      
    ENDIF
  ENDFOR
  
  ; Write the data
  outlist=filelist+'.unw'
  FOR i=0, nfiles-1 DO BEGIN
    OPENW, lun, outlist[i],/GET_LUN
    WRITEU, lun, FLOAT(result[i, *, *])
    FREE_LUN, lun
  ENDFOR
  Print, 'The files are successfully unwrapped, please check the files.'
  Print, STRJOIN(outlist, STRING(13b))
  
END


PRO TLI_NONLINEAR_DEF_GRD

  COMPILE_OPT idl2
  CLOSE,/ALL
  
  IF 1 THEN BEGIN ; Params for Tianjin 121023
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/HPA/testnonlinear'
    IF !D.NAME EQ 'WIN' THEN BEGIN
      workpath=TLI_DIRW2L(workpath,/REVERSE)
    ENDIF
    IF ~TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
    
    plistfile=workpath+'plistupdate'
    ptattrfile=workpath+'ptattrupdate'
    pdifffile=workpath+'lel1pdiff'
    pbasefile=workpath+'pbaseupdate'
    plafile=workpath+'plaupdate'
    sarlistfile=workpath+'sarlist_X'
    ppath=FILE_DIRNAME(workpath)+PATH_SEP()
    itabfile=workpath+'itab'
  ENDIF
  
  IF 0 THEN BEGIN  ; Params for Tianjin
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/nonlinear'
    
    workpath=workpath+PATH_SEP()
    plistfile=workpath+'plist_merge_all'
    ptattrfile=workpath+'ptattr_merge_all'
    pdifffile=plistfile+'.pdiff.swap'
    pbasefile=workpath+'pbase_merge_all'
    plafile=workpath+'pla_merge_all'
    sarlistfile=workpath+'sarlist_Linux'
    itabfile=workpath+'itab'
  ENDIF
  
  IF 0 THEN BEGIN ; Params for Shanghai
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_SH_3/HPA/nonlinear'
    
    IF !D.NAME EQ 'WIN' THEN BEGIN
      workpath=TLI_DIRW2L(workpath,/REVERSE)
    ENDIF
    workpath=workpath+PATH_SEP()
    
    plistfile=workpath+'plistupdate'
    ptattrfile=workpath+'ptattrupdate'
    pdifffile=workpath+'lel1pdiff'
    pbasefile=workpath+'pbaseupdate'
    plafile=workpath+'plaupdate'
    sarlistfile=workpath+'sarlist_'+!D.NAME
    ppath=FILE_DIRNAME(workpath)+PATH_SEP()
    itabfile=workpath+'itab'
  ENDIF
  
  
  logfile=workpath+'nonliear_def.log'
  slxfile=plistfile+'.slx'
  slyfile=plistfile+'.sly'
  tlxfile=plistfile+'.tlx'
  tlyfile=plistfile+'.tly'
  thxfile=plistfile+'.thx'
  thyfile=plistfile+'.thy'
  nonlinear_arcdifffile=plistfile+'.arcnl'
  nonlinearfile=plistfile+'.nl'
  aps_arcdifffile=plistfile+'.arcaps'
  apsfile=plistfile+'.aps'
  
  
  c= 299792458D ; Speed light
  sl_winsize=300 ; window size of spatially low pass filter. 1000m.
  force=0
  
  ; Check the files
  temp=TLI_CHECK_PTATTR(ptattrfile, plistfile)
  IF temp EQ -1 THEN Message, 'ptattr file is not updated successfully.'
  
  IF 0 THEN BEGIN
    ;/////////////////////////////////////////////
    ; Generate pdiff, pbase and pla files.
    hpapath=FILE_DIRNAME(workpath)+PATH_SEP()
    basepath=hpapath+'base'+PATH_SEP()
    master=TLI_GAMMA_INT(sarlistfile, itabfile,/onlymaster,/uniq,/date)
    TLI_HPA_PDIFF, hpapath, plistfile,master, $
      plistfile_GAMMA=plistfile_GAMMA, pdifile_GAMMA=pdifile_GAMMA, pdifffile=pdifffile, force=force
    TLI_GAMMA_BP_LA_FUN, plistfile, itabfile, sarlistfile, basepath, pbasefile, plafile,gamma=gamma,force=force
    
    ;/////////////////////////////////////////////
    ; Get some params
    npt=TLI_PNUMBER(plistfile)
    nintf=FILE_LINES(itabfile)
    finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
    wavelength=c/finfo.radar_frequency
    loglun=TLI_OPENLOG(logfile)
    PrintF, loglun, 'Extract the nonliear deformation for each image & each point'
    PrintF, loglun, 'Start at: '+TLI_TIME(/str)
    PrintF, loglun, ''
    ; Define a structure
    arcinfo=TLI_ARCINFO(ptattrfile, plistfile)
    
    ;---------------Get phase residuals for each arc------------------
    ; endphase-startphase
    Print, 'Calculating the phase residuals for each arc...'
    pbase=TLI_READDATA(pbasefile, samples=npt, format='double')
    pla=TLI_READDATA(plafile, samples=npt, format='double')
    ptattr=TLI_READMYFILES(ptattrfile, type='ptattr')
    plist=TLI_READMYFILES(plistfile, type='plist')
    pdiff=TLI_READDATA(pdifffile,samples=npt, format='FCOMPLEX')
    
    startind=ptattr.parent
    endind=LINDGEN(npt) ; point index
    endcoor=plist[endind] ; coor of the point
    startcoor=plist[startind]
    startx=REAL_PART(startcoor)
    ref_r=finfo.near_range_slc+finfo.range_pixel_spacing*startx ; npt*1
    sinla=SIN(DEGREE2RADIUS(pla[startind, *])) ; npt*1
    tbase=TBASE_ALL(sarlistfile, itabfile) ; nintf*1
    dv=ptattr[endind].v-ptattr[startind].v ; npt*1
    ddh=ptattr[endind].dh-ptattr[startind].dh ; npt*1
    
    K1= -4*(!PI)/(wavelength*ref_r*sinla) ; npt*1
    K2= -4*(!PI)/(wavelength*1000) ; 1*1
    K1= REBIN(K1, npt, nintf) ; npt*nint. tbase has to be a 1*nint array.
    dphi= K1*pbase*REBIN(ddh, npt, nintf) + K2*(FLTARR(npt, nintf)+1) * (TRANSPOSE(tbase)##dv) ; npt*nintf
    dphi= ATAN(pdiff[endind,*]*CONJ(pdiff[startind, *]),/PHASE)-dphi ; phase difference, npt*nintf
    
    
    
    temp=dphi*REBIN(COS(arcinfo.theta),npt,nintf) ; phi_x, npt*nintf
    grd_x=temp/REBIN(arcinfo.coor_dx,npt,nintf) ; grd_x
    temp=WHERE(FINITE(grd_x,/infinity))
    grd_x[temp]=0  ; Change infinity to 0   *********************important****************
    
    temp=dphi*REBIN(SIN(arcinfo.theta),npt, nintf); phi_y
    grd_y=temp/REBIN(arcinfo.coor_dy,npt,nintf) ; grd_y
    temp=WHERE(FINITE(grd_y,/infinity))
    grd_y[temp]=0  ; Change infinity to 0   *********************important****************
    
    ;----------------------------------------
    
    ;--------------------------Spatially low-pass filtering---------------------
    Print, ''
    Print, 'Doing spatially low pass filtering.'
    Print, ''
    
    PrintF, loglun, 'Check if the spatially low-pass filtering is applied or not.'
    exist=0
    doit=0
    temp=FILE_INFO(slxfile)
    fsize=npt*(nintf+3)*8
    IF temp.size EQ fsize THEN BEGIN
      PrintF,loglun,  'The file exists:'
      PrintF, loglun, slxfile
      exist=1
    ENDIF
    temp=FILE_INFO(slyfile)
    IF temp.size EQ fsize THEN BEGIN
      PrintF, loglun, slyfile
      exist=1
    ENDIF
    
    IF exist EQ 1 THEN BEGIN
      IF NOT KEYWORD_SET(force) THEN BEGIN
        PrintF, loglun, ''
        PrintF, loglun, 'No duplicated files are constructed.'
        Print, 'Files exist. No duplicated files are constructed.'
        Print, 'If you want to re-process the files, please set force=1.'
        doit=0
      ENDIF
    ENDIF ELSE BEGIN
      doit=1
    ENDELSE
    
    IF KEYWORD_SET(force) AND force EQ 1 THEN doit=1
    
    IF doit THEN BEGIN
      aps=finfo.azimuth_pixel_spacing
      rps=finfo.range_pixel_spacing
      starty=IMAGINARY(startcoor)
      endx=REAL_PART(endcoor)
      endy=IMAGINARY(endcoor)
      slx=grd_x ; Result to write, spatially low pass in x direction
      sly=grd_y ; Result to write, spatially low pass in y direction
      FOR i=0, npt-1 DO BEGIN
        IF ~ (i MOD 1000) THEN Print, STRCOMPRESS(i),'/', STRCOMPRESS(npt-1)
        ; search arcs whose end points are in the search radius
        coor=arcinfo[i].coor
        coorx=REAL_PART(coor)
        coory=IMAGINARY(coor)
        dis=SQRT(((endx-coorx)*rps)^2+((endy-coory)*aps)^2)
        ind=WHERE(dis LT sl_winsize)
        IF ind[0] EQ -1 THEN CONTINUE ; a single point
        ; Get the distance between this point and arcs' start points.
        endx_arc=endx[ind]
        endy_arc=endy[ind]
        dis=SQRT(((endx_arc-coorx)*rps)^2 + ((endy_arc-coory)*aps)^2)
        ind_ind=WHERE(dis LT sl_winsize)
        IF ind_ind[0] EQ -1 THEN CONTINUE
        ; update the index
        ind=ind[ind_ind] ; Final arcs within the filtering window ***********important*************
        nind=N_ELEMENTS(ind)
        ; Spatially low pass filtering
        slx[i, *]=TOTAL(grd_x[ind, *],1,/NAN)/TOTAL(FINITE(grd_x[ind, *]),1,/NAN) ; Calculate total value in x direction.
        sly[i, *]=TOTAL(grd_y[ind, *],1,/NAN)/TOTAL(FINITE(grd_y[ind, *]),1,/NAN) ; Calculate total value in y direction.
      ENDFOR
      ; Write the file. with reference to .atm file. npt*(nintf+3)-->x,y, mask,time_series
      plist=TRANSPOSE(plist)
      slx=[[REAL_PART(plist)], [IMAGINARY(plist)], [DBLARR(npt)+1], [slx]]
      OPENW, lun, slxfile,/GET_LUN
      WRITEU, lun, slx
      FREE_LUN, lun
      slx=0
      sly=[[REAL_PART(plist)], [IMAGINARY(plist)], [DBLARR(npt)+1], [sly]]
      OPENW, lun, slyfile,/GET_LUN
      WRITEU, lun, sly
      FREE_LUN, lun
      sly=0
    ENDIF
    
    ;------------------------------------------------------
    
    ;------------------ Temporally low pass----------------------
    low_f=0
    high_f=0.25
    TLI_TL_FILTER, plistfile, slxfile, low_f, high_f,res_phase_tlfile=tlxfile
    TLI_TL_FILTER, plistfile, slyfile, low_f, high_f,res_phase_tlfile=tlyfile
    ; ----------------------------------------------
    
    ; -----------------------Temporally high pass---------------------
    low_f=0.25
    high_f=1
    TLI_TL_FILTER, plistfile, tlxfile, low_f, high_f,res_phase_tlfile=thxfile
    TLI_TL_FILTER, plistfile, tlyfile, low_f, high_f,res_phase_tlfile=thyfile
    ;-----------------------------------------------------
    
    ;-------------------------Convert gradients to difference----------------------
    nonlinear_arcdifffile=plistfile+'.arcnl'
    nonlinearfile=plistfile+'.nl'
    aps_arcdifffile=plistfile+'.arcaps'
    apsfile=plistfile+'.aps'
    TLI_GRD2DIF, tlxfile, tlyfile,arcinfo, outputfile=nonlinear_arcdifffile
    TLI_GRD2DIF, thxfile, thyfile,arcinfo, outputfile=aps_arcdifffile
  ;--------------------------------------------------------
  ENDIF
  ; --------------------------Integration-------------------------
  arcinfo=TLI_ARCINFO(ptattrfile, plistfile)
  filelist=[nonlinear_arcdifffile, aps_arcdifffile]
  TLI_INTEGRATION, arcinfo, filelist,refind=refind, plistfile=plistfile
  ;----------------------------------------------------------------
  
  
  Print, 'Main pro finished.'
  FREE_LUN, loglun
END