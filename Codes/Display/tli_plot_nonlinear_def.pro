PRO TLI_PLOT_NONLINEAR_DEF

  IF 1 THEN BEGIN
 
  ; Params for Tianjin121023
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/nonlinear/'
    hpapath=FILE_DIRNAME(workpath)+PATH_SEP()
    
    ; Files
    plistfile=workpath+'plist_merge_all'
    nlfile=plistfile+'.arcnl.unw'
    slxfile=plistfile+'.slx'
    slyfile=plistfile+'.sly'
    tlxfile=plistfile+'.tlx'
    tlyfile=plistfile+'.tly'
    arcnlfile=plistfile+'.arcnl'
    arcapsfile=plistfile+'.arcaps'
    
    sarlistfile=workpath+'sarlist_Linux'
    rasfile=workpath+'ave.ras'
    outputfile=nlfile+'.bmp'
    itabfile=workpath+'itab'
  ENDIF

  IF 0 THEN BEGIN
    ; Params for Shanghai
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_SH_3/HPA/nonlinear/'
    hpapath=FILE_DIRNAME(workpath)+PATH_SEP()
    
    ; Files
    plistfile=workpath+'plistupdate'
    nlfile=plistfile+'.arcnl.unw'
    slxfile=plistfile+'.slx'
    slyfile=plistfile+'.sly'
    
    
    sarlistfile=workpath+'sarlist_X'
    rasfile=workpath+'ave.ras'
    outputfile=nlfile+'.bmp'
    itabfile=workpath+'itab'
  ;  atmfile=plistfile+'.arcaps.unw'
  ENDIF
  
  IF 0 THEN BEGIN
    ; Params for Tianjin121023
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/HPA/testnonlinear/'
    hpapath=FILE_DIRNAME(workpath)+PATH_SEP()
    
    ; Files
    plistfile=workpath+'plistupdate'
    nlfile=plistfile+'.arcnl.unw'
    slxfile=plistfile+'.slx'
    slyfile=plistfile+'.sly'
    tlxfile=plistfile+'.tlx'
    tlyfile=plistfile+'.tly'
    arcnlfile=plistfile+'.arcnl'
    arcapsfile=plistfile+'.arcaps'
    
    sarlistfile=workpath+'sarlist_X'
    rasfile=workpath+'ave.ras'
    outputfile=nlfile+'.bmp'
    itabfile=workpath+'itab'
  ;  atmfile=plistfile+'.arcaps.unw'
    
  ENDIF
  
  ; params
  indices=LINDGEN(FILE_LINES(itabfile))
  nitab_ind=N_ELEMENTS(indices)
  inputfile=arcnlfile   ;//////////////////////////////////////////////////////////////
  swap_endian=swap_endian
  
  
  ; Readdata
  npt=TLI_PNUMBER(plistfile)
;    data=TLI_READDATA(inputfile, samples=npt, format='FLOAT',swap_endian=swap_endian)
  data=TLI_READDATA(inputfile, samples=npt, format='DOUBLE',swap_endian=swap_endian)
  
  ; Prepare the data for the points.
  pdata=data[*,indices+3]     ; indices indicates the number of the interferogram.
  FOR i=0D, nitab_ind-1D DO BEGIN
    pdata_i=pdata[*,i]
    file_i=workpath+'nl_'+STRCOMPRESS(indices[i]+1,/REMOVE_ALL)
    
    TLI_WRITE, file_i, FLOAT(pdata_i)   ; Write the data into this file
    ; Call .pro to plot.
    vdhfile_ps=workpath+'nl_temp'
    TLI_PSUDOVDH, file_i,outputfile=vdhfile_ps,plistfile=plistfile  ; Create a psudo vdhfile in order to call plot procedure.
    
    unit='rad'
;    compress=0
    percent=0.2
    outputfile=file_i+'.bmp'
    TLI_PLOT_LINEAR_DEF,vdhfile_ps, rasfile, sarlistfile, $
      outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,frame=frame, $
      tick_major=tick_major,tick_minor=tick_minor, $
      /fliph_pt, /fliph_image, flipv_image=flipv_image, los_to_v=los_to_v,$
      no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,/overwrite,/refine,delta=1
    FILE_DELETE, file_i
  ENDFOR
  
  
  
  
END