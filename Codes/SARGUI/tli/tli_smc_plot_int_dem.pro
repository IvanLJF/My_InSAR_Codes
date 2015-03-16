;
; Plot int DEM using GUI
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20121230.
;
; History
;
PRO TLI_SMC_PLOT_INT_DEM_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  uname=widget_info(event.id,/uname)
  workpath=config.workpath
  Case uname OF
    'openinput':BEGIN
    inputfile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.hgt.utm', path=workpath,/must_exist)
    IF inputfile EQ '' THEN return
    widget_control,(*pstate).input,set_value=inputfile
    widget_control,(*pstate).input,set_uvalue=inputfile
    
    ; Update config
    TLI_SMC_DEFINITIONS_UPDATE, inputfile=inputfile
    
    ; Get DEM seg info
    demseg=workpath+'dem_seg'
    IF FILE_TEST(demseg) THEN BEGIN
      config.dem_seg=demseg
      IF FILE_TEST(demseg+'.par') THEN BEGIN
        deminfo=TLI_LOAD_PAR(demseg+'.par',/keeptxt)
        value='DEM Segment:'+STRING(10b)+demseg
        widget_control, (*pstate).demseglabel,  set_value=value, set_uvalue=demseg
        widget_control, (*pstate).samples, set_value=deminfo.width
        widget_control, (*pstate).lines, set_value=deminfo.nlines
        widget_control, (*pstate).lontxt, set_value=deminfo.corner_lon
        widget_control, (*pstate).lattxt, set_value=deminfo.corner_lat
        widget_control, (*pstate).plontxt, set_value=deminfo.post_lon
        widget_control, (*pstate).plattxt, set_value=deminfo.post_lat
        
      ENDIF
    ENDIF
    ; set output file.
    widget_control, (*pstate).output, set_value=inputfile+'.jpg', set_uvalue=inputfile+'.jpg'
    
  END
  
  'opendemseg': BEGIN
    demseg=dialog_pickfile(title='Sasmac InSAR',filter="*dem_seg*",/read, path=workpath)
    IF NOT FILE_TEST(demseg) THEN RETURN
    deminfo=TLI_LOAD_PAR(inputfile+'.par',/keeptxt)
    value='DEM Segment:'+STRING(10b)+demseg
    widget_control, (*pstate).demseglabel,  set_value=value, set_uvalue=demseg
    widget_control, (*pstate).samples, set_value=deminfo.width
    widget_control, (*pstate).lines, set_value=deminfo.nlines
    widget_control, (*pstate).lontxt, set_value=deminfo.corner_lon
    widget_control, (*pstate).lattxt, set_value=deminfo.corner_lat
    widget_control, (*pstate).plontxt, set_value=deminfo.post_lon
    widget_control, (*pstate).plattxt, set_value=deminfo.post_lat
    
  END
  
  
  'openimg':begin
  widget_control,(*pstate).input,get_uvalue=input
  if input eq '' then begin
    result=dialog_message('Please specify input file',title='Plot interferometric DEM',/information,/center)
    return
  endif
  widget_control, (*pstate).output, get_uvalue=output
  IF output EQ '' THEN BEGIN
    output=input+'.jpg'
    widget_control, (*pstate).output, set_uvalue=output
  ENDIF
END

'ok':begin
widget_control,(*pstate).input,get_uvalue=inputfile
widget_control,(*pstate).samples,get_value=samples
widget_control,(*pstate).lines,get_value=lines
widget_control,(*pstate).output,get_uvalue=outputfile
widget_control,(*pstate).demseglabel, get_uvalue=demseg
show=widget_info((*pstate).show,/droplist_select)



;showmsk=widget_info((*pstate).show)
IF NOT FILE_TEST(inputfile) then begin
  TLI_SMC_DUMMY,inputstr='Input file not found: '+STRING(10b)+inputfile
  RETURN
ENDIF
if samples le 0 then begin
  TLI_SMC_DUMMY, inputstr='Samples should be greater than 0: '+columns
  RETURN
endif
if lines le 0 then begin
  TLI_SMC_DUMMY, inputstr='Lines should be greater than 0: '+lines
  RETURN
endif
IF NOT FILE_TEST(demseg) THEN BEGIN
  TLI_SMC_DUMMY, inputstr='DEM seg file not found: '+demseg
  RETURN
ENDIF
IF outputfile EQ '' THEN BEGIN
  TLI_SMC_DUMMY, inputstr='Please specify output file.'
  RETURN
ENDIF

TLI_SMC_PROGRESS, message='Plotting interferometric DEM. Please wait...'
  TLI_SMC_PROGRESS,percent=0
  TLI_SMC_PROGRESS,percent=10



TLI_PLOT_INT_DEM, inputfile, dem_segparfile=demseg+'.par', outputfile=outputfile
  
 

  
  TLI_SMC_PROGRESS, percent=100
IF show THEN BEGIN
  ; Show the results.
  fig=READ_IMAGE(outputfile)
  IF fig[0] EQ -1 THEN TLI_SMC_DUMMY, inputstr='Error! TLI_SMC_PLOT_INT_DEM: Result file cannot be read:'+STRING(10b)+outputfile

  
  TLI_SMC_DISPLAY, fig
ENDIF ELSE BEGIN
  result=dialog_message(['Plot interferometric DEM: ',$
                         'Finished successfully.'],$
                         title='Plot interferometric DEM',/Information,/center)
ENDELSE

tli_smc_progress,/destroy
;widget_control,event.top,/destroy
end

'cl':begin
;result=dialog_message('',title='',/question,/default_no)
;if result eq 'Yes'then begin
;  widget_control,event.top,/destroy
;endif
widget_control,event.top,/destroy
end


else:return
ENDCASE

END

PRO TLI_SMC_PLOT_INT_DEM

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; For test
  IF 1 THEN BEGIN
    IF STRLEN(config.workpath) LE 3 THEN config.workpath='/mnt/data_tli/ForExperiment/InSARGUI/int_ERS_shanghai_2000_10000/'
  ENDIF
  ;----------------------------------------------------
  ; Assignment
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=400
  workpath=config.workpath
  intdate=config.int_date
  intdem=intdate+'.hgt.utm'
  dem_seg=workpath+'dem_seg'
  IF NOT FILE_TEST(intdem) THEN BEGIN
    intdem=''
    img=''
  ENDIF ELSE BEGIN
    img=intdem+'.jpg'
  ENDELSE
  IF NOT FILE_TEST(dem_seg) THEN BEGIN
    dem_seg='File not found, please manually select the file.'
  ENDIF ELSE BEGIN
    IF NOT FILE_TEST(dem_seg+'.par') THEN BEGIN
      samples='0'
      lines='0'
      clat='0'
      clon='0'
      plat='-0.000833'
      plon='0.000833'
      prj='EQA'
      e_name='WGS 84'
      e_ra='6378137.00'
    ENDIF ELSE BEGIN
      finfo=TLI_LOAD_PAR(dem_seg+'.par',/keeptxt)
      samples=finfo.width
      lines=finfo.nlines
      clat=finfo.corner_lat
      clon=finfo.corner_lon
      plat=finfo.post_lat
      plon=finfo.post_lon
      prj=finfo.dem_projection
      e_name=finfo.ellipsoid_name
      e_ra=finfo.ellipsoid_ra
    ENDELSE
  ENDELSE
  
  tlb=widget_base(title='Plot Interferometric DEM ERROR',tlb_frame_attr=0,column=1,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  inID=widget_base(tlb,row=1,xsize=xsize,frame=1)
  input=widget_text(inID,value=intdem,uvalue=intdem,uname='input',/editable,xsize=73)
  openinput=widget_button(inID,value='Int DEM',uname='openinput',xsize=90)
  
  
  ;-----------------------------------------------
  ; Basic information extracted from dem_seg par file
  temp=widget_label(tlb,value='---------------------------------------------------------------------------------------------')
  labID=widget_base(tlb,/column,xsize=xsize)
  
  demsegID=widget_base(labID,/row, xsize=xsize)
  demseglabel=widget_label(demsegID, xsize=xsize-110, value='DEM Segment:'+STRING(10b)+dem_seg, uvalue=dem_seg,/align_left)
  demsegbutton=widget_button(demsegID, xsize=90, value='DEM Seg', uname='opendemseg')
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  sampID=widget_base(tempID, /column, xsize=xsize/3-10)
  samplabel=widget_label(sampID, value='Samples:',/ALIGN_LEFT)
  samples=widget_text(sampID,value=samples, uvalue='samples', uname='samples',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  lineID=widget_base(tempID,/column, xsize=xsize/3-10)
  linelabel=widget_label(lineID, value='Lines:',/ALIGN_LEFT)
  lines=widget_text(lineID, value=lines,uvalue='lines', uname='lines',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  fmID=widget_base(tempID,/column, xsize=xsize/3-10)
  fmlabel=widget_label(fmID,value='Format:',/ALIGN_LEFT)
  fm=widget_text(fmID, value='float', uvalue='format',/editable,xsize=10)
  
  
  ;
  infoID=widget_base(tlb,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  ulID=widget_base(tempID, /column, xsize=xsize/3-10)
  ullabel=widget_label(ulID, value='UL Coord(Lon Lat):',/ALIGN_LEFT)
  lontxt=widget_text(ulID,value=clon, uvalue='lon', uname='lon',/editable,xsize=10)
  lattxt=widget_text(ulID,value=clat, uvalue='lat', uname='lat',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  posID=widget_base(tempID, /column, xsize=xsize/3-10)
  poslabel=widget_label(posID, value='Post Coord(Lon Lat):',/ALIGN_LEFT)
  plontxt=widget_text(posID,value=plon, uvalue='plon', uname='plon',/editable,xsize=10)
  plattxt=widget_text(posID,value=plat, uvalue='plat', uname='plat',/editable,xsize=10)
  
  ;-------------------------------------------
  ; Output information
  
  temp=widget_label(tlb,value='---------------------------------------------------------------------------------------------')
  
  outID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outID,value=img,uvalue='ouput',uname='output',/editable,xsize=58)
  openoutput=widget_button(outID,value='Output Img',uname='openimg',xsize=90)
  show=widget_droplist(outID, value=['Hide','Show'],xsize=90)
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={input:input,$
    openinput:openinput,$
    samples:samples,$
    lines:lines,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl,$
    demsegbutton:demsegbutton, $
    demseglabel:demseglabel,$
    lontxt:lontxt,$
    lattxt:lattxt,$
    plontxt:plontxt,$
    plattxt:plattxt,$
    show:show}
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_PLOT_INT_DEM',tlb,/no_block
  
END