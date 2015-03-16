;
; TLI_SMC_PLOT_ERROR_HIST
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20150102
;
PRO TLI_SMC_REPORT_INT_DEM_ERROR_EVENT, EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  uname=widget_info(event.id,/uname)
  workpath=config.workpath
  Case uname OF
    'openint':BEGIN
    inputfile=dialog_pickfile(title='Sasmac InSAR',/read, path=workpath,/must_exist,filter='*.hgt*')
    IF inputfile EQ '' THEN RETURN
    widget_control,(*pstate).intdem,set_value=inputfile, set_uvalue=inputfile
    
    ; Update config
    TLI_SMC_DEFINITIONS_UPDATE, inputfile=inputfile
    
    ; Judge input par file.
    temp=STRPOS(inputfile, '.utm')
    mdate=config.m_date
    workpath=config.workpath
    dem_seg=config.dem_seg
    samples='0'
    lines='0'
    IF temp EQ '-1' THEN BEGIN  ; not geocoded
      parfile=config.workpath+mdate+'.pwr.par'
      IF FILE_TEST(parfile) THEN BEGIN
        finfo=TLI_LOAD_PAR(parfile,/keeptxt)
        samples=finfo.range_samples
        lines=finfo.azimuth_lines
      ENDIF
    ENDIF ELSE BEGIN  ; geocoded
      parfile=dem_seg+'.par'
      IF FILE_TEST(parfile) THEN BEGIN
        finfo=TLI_LOAD_PAR(parfile,/keeptxt)
        samples=finfo.width
        lines=finfo.nlines
      ENDIF
    ENDELSE
    
    ; Update widget
    widget_control, (*pstate).refdem, set_value=dem_seg, set_uvalue=dem_seg
    widget_control, (*pstate).parlabel, get_uvalue=temp
    
    IF NOT FILE_TEST(temp) THEN BEGIN
      parlabel='Par file:'+STRING(10b)+parfile
      widget_control, (*pstate).parlabel, set_value=parlabel, set_uvalue=parfile
      widget_control, (*pstate).samples, set_value=samples
      widget_control, (*pstate).lines, set_value=lines
    ENDIF
    
    ; set output file.
    widget_control, (*pstate).err, set_value=inputfile+'.err',set_uvalue=inputfile+'.err'
    widget_control, (*pstate).report, set_value=inputfile+'.err.txt', set_uvalue=inputfile+'.err.txt'
    widget_control, (*pstate).hist, set_value=inputfile+'.hist', set_uvalue=inputfile+'.hist'
    
  END
  
  'openref': BEGIN
    widget_control, (*pstate).intdem, get_value=intdem
    if STRPOS(intdem, 'utm') NE -1 THEN filter='*dem*seg*' ELSE filter='*dem.hgt*'
    inputfile=dialog_pickfile(title='Sasmac InSAR',filter=filter,/read, path=workpath,/must_exist)
    IF inputfile EQ '' THEN RETURN
    widget_control, (*pstate).refdem, set_value=inputfile, set_uvalue=inputfile
  END
  
  'openpar': BEGIN
    parfile=DIALOG_PICKFILE(title='Sasmac InSAR',filter="*.par",/read, path=workpath,/must_exist)
    finfo=TLI_LOAD_PAR(parfile,/keeptxt)
    IF TLI_IS_TAG_NAME(finfo,'range_samples') THEN BEGIN
      samples=finfo.range_samples
      lines=finfo.azimuth_lines
    ENDIF ELSE BEGIN
      IF TLI_IS_TAG_NAME(finfo, 'width') THEN BEGIN
        samples=finfo.width
        lines=finfo.nlines
      ENDIF ELSE BEGIN
        TLI_SMC_DUMMY, inputstr='Error! Please provide GAMMA par file!'
      ENDELSE
    ENDELSE
    
    ; Update widget info
    parlabel='Par file:'+STRING(10b)+parfile
    widget_control, (*pstate).parlabel, set_value=parlabel, set_uvalue=parfile
    widget_control, (*pstate).samples, set_value=samples
    widget_control, (*pstate).lines, set_value=lines
    
  END
  
  'openerr': BEGIN
    inputfile=DIALOG_PICKFILE(title='Sasmac InSAR', filter='*.err',/write, path=workpath)
    IF inputfile EQ '' THEN RETURN
    inputfile=TLI_FNAME(inputfile, /nosuffix,suffix=suffix)
    widget_control, (*pstate).report, set_value=inputfile+'.err.txt', set_uvalue=inputfile+'.err.txt'
    widget_control, (*pstate).hist, set_value=inputfile+'.hist', set_uvalue=inputfile+'.hist'
  END
  
  'openreport': BEGIN
    inputfile=DIALOG_PICKFILE(title='Sasmac InSAR', filter='*.txt',/write, path=workpath)
    IF inputfile EQ '' THEN RETURN
    
  END
  
  'openhist': BEGIN
    inputfile=DIALOG_PICKFILE(title='Sasmac InSAR', filter='*.hist',/write, path=workpath)
    IF inputfile EQ '' THEN RETURN
    
  END
  
  'ok':begin
  widget_control,(*pstate).intdem,get_uvalue=int_demfile
  widget_control, (*pstate).refdem, get_uvalue=ref_demfile
  widget_control,(*pstate).samples,get_value=samples
  widget_control,(*pstate).lines,get_value=lines
  widget_control,(*pstate).err,get_uvalue=errfile
  widget_control,(*pstate).report, get_uvalue=reportfile
  widget_control, (*pstate).hist, get_uvalue=histfile
  widget_control, (*pstate).parlabel, get_uvalue=parfile
  
  ;showmsk=widget_info((*pstate).show)
  IF NOT FILE_TEST(int_demfile) then begin
    TLI_SMC_DUMMY,inputstr='Input file not found: '+STRING(10b)+int_demfile
    RETURN
  ENDIF
  
  IF NOT FILE_TEST(ref_demfile) THEN BEGIN
    TLI_SMC_DUMMY,inputstr='Input file not found: '+STRING(10b)+ref_demfile
    RETURN
  ENDIF
  
  intdemsize=(FILE_INFO(int_demfile)).size & intdemsize=STRCOMPRESS(intdemsize,/REMOVE_ALL)
  refdemsize=(FILE_INFO(ref_demfile)).size & refdemsize=STRCOMPRESS(refdemsize,/REMOVE_ALL)
  IF intdemsize NE refdemsize THEN BEGIN
    TLI_SMC_DUMMY, inputstr=['File Inconsistence:', '', int_demfile+': '+intdemsize, ref_demfile+': '+refdemsize]
    RETURN
  ENDIF
  
  IF NOT FILE_TEST(parfile) THEN BEGIN
    TLI_SMC_DUMMY, inputstr='Input par not found:'+STRING(10b)+parfile
    RETURN
  ENDIF
  if samples le 0 then begin
    TLI_SMC_DUMMY, inputstr='Samples should be greater than 0: '+samples
    RETURN
  endif
  if lines le 0 then begin
    TLI_SMC_DUMMY, inputstr='Lines should be greater than 0: '+lines
    RETURN
  endif
  
  IF errfile EQ '' THEN BEGIN
    TLI_SMC_DUMMY, inputstr='Please Specify Err File!'
    RETURN
  ENDIF
  
  IF reportfile EQ '' THEN BEGIN
    TLI_SMC_DUMMY, inputstr='Please Specify Report File!'
    RETURN
  ENDIF
  
  IF histfile EQ '' THEN BEGIN
    TLI_SMC_DUMMY, inputstr='Please Specify Hist File!'
    RETURN
  ENDIF
  
  TLI_SMC_PROGRESS, message='Writting DEM error report. Please wait...'
  TLI_SMC_PROGRESS,percent=0
  TLI_SMC_PROGRESS,percent=10
  
  TLI_REPORT_INT_DEM_ERROR, int_demfile, ref_demfile, parfile=parfile, errfile=errfile, reportfile=reportfile, histfile=histfile
  
  TLI_SMC_PROGRESS, percent=100
  
  IF NOT FILE_TEST(histfile) THEN BEGIN
    TLI_SMC_DUMMY, inputstr='Error! Files were not created successfully! Please contact T.LI @ Sasmac.'
  ENDIF ELSE BEGIN
    result=dialog_message(['Plot interferometric DEM: ',$
                           'Finished successfully.',$
                           '',$
                           'Press OK to Continue.'],$
                           title='Plot interferometric DEM',/information,/center)
  ENDELSE
  TLI_SMC_PROGRESS,/destroy
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

PRO TLI_SMC_REPORT_INT_DEM_ERROR

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
  ysize=430
  workpath=config.workpath
  intdate=config.int_date
  
  intdem=''
  refdem=''
  parfile=''
  samples='0'
  lines='0'
  IF NOT FILE_TEST(parfile) THEN BEGIN
    parinfo='Par file not found, please manually select the file.'
  ENDIF ELSE BEGIN
    finfo=TLI_LOAD_PAR(parfile,/keeptxt)
    IF IDL_VALIDNAME('width') AND IDL_VALIDNAME('nlines') THEN BEGIN
      samples=finfo.width
      lines=finfo.nlines
    ENDIF ELSE BEGIN
      IF IDL_VALIDNAME('samples') AND IDL_VALIDNAME('lines') THEN BEGIN
        samples=finfo.samples
        lines=finfo.lines
      ENDIF
    ENDELSE
  ENDELSE
  
  tlb=widget_base(title='Report Interferometric DEM Error',tlb_frame_attr=0,column=1,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  temp=widget_base(tlb,row=1,xsize=xsize,frame=1)
  intdem=widget_text(temp,value=intdem,uvalue=intdem,uname='intdem',/editable,xsize=73)
  openint=widget_button(temp,value='Int DEM',uname='openint',xsize=90)
  
  temp=widget_base(tlb,row=1,xsize=xsize,frame=1)
  refdem=widget_text(temp,value=refdem,uvalue=refdem,uname='refdem',/editable,xsize=73)
  openref=widget_button(temp, value='Ref DEM', uname='openref',xsize=90)
  
  ;-----------------------------------------------
  ; Basic information extracted from corresponding par file
  temp=widget_label(tlb,value='---------------------------------------------------------------------------------------------')
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-110, value='Par file:'+STRING(10b)+'Please select par file.(.pwr.par->ungeocoded; dem_seg.par->geocoded)', uvalue=parfile,/align_left,/dynamic_resize)
  parbutton=widget_button(parID, xsize=90, value='Par', uname='openpar')
  
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
  
  ;-------------------------------------------
  ; Output information
  
  temp=widget_label(tlb,value='---------------------------------------------------------------------------------------------')
  
  outID=widget_base(tlb,/column, frame=1)
  
  temp=widget_base(outID,/row)
  err=widget_text(temp,value='',uvalue='err',uname='err',/editable,xsize=73)
  openerr=widget_button(temp,value='Output Err',uname='openerr',xsize=90)
  
  temp=widget_base(outID,/row)
  report=widget_text(temp,value='',uvalue='report',uname='report',/editable,xsize=73)
  openreport=widget_button(temp,value='Output Report',uname='openreport',xsize=90)
  
  temp=widget_base(outID,/row)
  hist=widget_text(temp,value='',uvalue='hist',uname='hist',/editable,xsize=73)
  openhist=widget_button(temp,value='Output Hist',uname='openhist',xsize=90)
  
  
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={    samples:samples,$
    lines:lines,$
    hist:hist,$
    report:report,$
    err:err,$
    openhist:openhist,$
    openreport:openreport,$
    openerr:openerr,$
    ok:ok,$
    cl:cl,$
    parbutton:parbutton, $
    parlabel:parlabel,$
    intdem:intdem,$
    refdem:refdem}
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_REPORT_INT_DEM_ERROR',tlb,/no_block
  
END