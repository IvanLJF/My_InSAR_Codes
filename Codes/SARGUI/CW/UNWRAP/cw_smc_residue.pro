pro cw_smc_residue_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
  
  
    'filt_file_button': begin
      infile=dialog_pickfile(title='open filt interferometric  file',filter='*.flt.filt',/read,/must_exist, path=config.workpath)
      
      IF NOT FILE_TEST(infile) THEN return
      
      ; Update definitions
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      
      workpath=config.workpath
      inputfile=config.inputfile
      
      filt_file=workpath+TLI_FNAME(infile, /remove_all_suffix)+'.flt.filt'
      flag_file=workpath+TLI_FNAME(infile, /remove_all_suffix)+'.flt.filt.flag'
      
      IF FILE_TEST(config.m_rslc) THEN begin
        m_rslc=config.m_rslc
        intensity=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr
        parfile=intensity+'.par'
        parlab='Par file:'+parfile
        finfo=TLI_LOAD_SLC_PAR(parfile)
        width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
        nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
        xmax=STRCOMPRESS(finfo.range_samples-1,/REMOVE_ALL)
        ymax=STRCOMPRESS(finfo.azimuth_lines-2,/REMOVE_ALL)
      endif
      
      
      widget_control,(*pstate).filt_file_text,set_value=infile
      widget_control,(*pstate).filt_file_text,set_uvalue=infile
      widget_control,(*pstate).width_text,set_value=width
      widget_control,(*pstate).width_text,set_uvalue=width
      widget_control,(*pstate).xmax_text,set_value=xmax
      widget_control,(*pstate).xmax_text,set_uvalue=xmax
      widget_control,(*pstate).ymax_text,set_value=ymax
      widget_control,(*pstate).ymax_text,set_uvalue=ymax
      widget_control,(*pstate).flag_file_text,set_value=flag_file
      widget_control,(*pstate).flag_file_text,set_uvalue=flag_file
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
    end
    
    'flag_file_button': begin
    
      infile=dialog_pickfile(title='open flag file',filter='*.flt.filt.flag',/read,/must_exist, path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).flag_file_text,set_value=infile
      widget_control,(*pstate).flag_file_text,set_uvalue=infile
      
    end
    
    
    'ok':begin
    
    widget_control,(*pstate).filt_file_text,get_uvalue=filt_file
    IF NOT FILE_TEST(filt_file) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Choose The Correct  Filt Interferogram File']
      return
    endif
    
    widget_control,(*pstate).flag_file_text,get_uvalue=flag_file
    IF NOT FILE_TEST(flag_file) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Choose The Phase Unwrapping Flag File']
      return
    endif
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Width']
      return
    endif
    
    widget_control,(*pstate).xmin_text,get_value=xmin
    xmin=long(xmin)
    if xmin lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Starting Range Pixel Offset']
      return
    endif
    
    widget_control,(*pstate).xmax_text,get_value=xmax
    xmax=long(xmax)
    if xmax lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Last Range Pixel Offset']
      return
    endif
    
    widget_control,(*pstate).ymin_text,get_value=ymin
    ymin=float(ymin)
    if ymin lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Starting Azimuth Row Offset']
      return
    endif
    
    widget_control,(*pstate).ymax_text,get_value=ymax
    ymax=float(ymax)
    if ymax le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Last Azimuth Row Offset']
      return
    endif
    
    width=strcompress(width,/remove_all)
    xmin=strcompress(xmin,/remove_all)
    xmax=strcompress(xmax,/remove_all)
    ymin=strcompress(ymin,/remove_all)
    ymax=strcompress(ymax,/remove_all)
    
    scr="residue "+filt_file+" "+flag_file+" "+width+" "+xmin+" "+xmax+" "+ymin+" "+ymax
    tli_smc_spawn, scr ,info='Generate Phase Residue, Please wait...'
    
  end
  
  'cl':begin
  
  widget_control,event.top,/destroy
  
end

else: begin
  return
end
endcase

END



PRO cw_smc_residue,EVENT


  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=480
  
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  samples='0'
  lines='0'
  filt_file=''
  flag_file=''
  xmin='0'
  xmax='0'
  ymin='0'
  ymax='0'
  
  IF FILE_TEST(config.inputfile) THEN begin
    inputfile=config.inputfile
    filt_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
    flag_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.flag'
  endif
  
  IF FILE_TEST(config.m_rslc) THEN begin
    m_rslc=config.m_rslc
    intensity=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr
    parfile=intensity+'.par'
    parlab='Par file:'+STRING(10b)+parfile
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
    xmax=STRCOMPRESS(finfo.range_samples-1,/REMOVE_ALL)
    ymax=STRCOMPRESS(finfo.azimuth_lines-2,/REMOVE_ALL)
  endif
  
  
  tlb=widget_base(title='SASMAC_RESIDUE',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  filt_file_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  filt_file_tlb=widget_base(filt_file_ID,row=1,tlb_frame_attr=1)
  filt_file_text=widget_text(filt_file_tlb,value=filt_file,uvalue=filt_file,/editable,xsize=60,uname='filt_file_text')
  filt_file_button=widget_button(filt_file_tlb,value='Input Interferogram File',xsize=170,uname='filt_file_button')
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  width_label=widget_label(width_tlb,value='Width:',xsize=60,uname='width_button',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  nlines_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  nlines_label=widget_label(nlines_tlb,value='Lines:',xsize=60,uname='nlines_label',/ALIGN_LEFT)
  nlines_text=widget_text(nlines_tlb,/editable,value=nlines,uvalue=nlines,uname='nlines_text')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  xmin_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  xmin_label=widget_label(xmin_tlb,value='Offset To Starting Range Pixel:',xsize=180,uname='xmin_label',/ALIGN_LEFT)
  xmin_text=widget_text(xmin_tlb,/editable,xsize=5,value=xmin,uvalue=xmin,uname='xmin_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  xmax_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  xmax_label=widget_label(xmax_tlb,value='Offset Last Range Pixel:',xsize=180,uname='xmax_label',/ALIGN_LEFT)
  xmax_text=widget_text(xmax_tlb,/editable,xsize=5,value=xmax,uvalue=xmax,uname='xmax_text')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  ymin_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  ymin_label=widget_label(ymin_tlb,value='Offset To Starting Azimuth Row:',xsize=180,uname='label',/ALIGN_LEFT)
  ymin_text=widget_text(ymin_tlb,/editable,xsize=5,value=ymin,uvalue=ymin,uname='ymin_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  ymax_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  ymax_label=widget_label(ymax_tlb,value='Offset To Last Azimuth Row:',xsize=180,uname='ymax_label',/ALIGN_LEFT)
  ymax_text=widget_text(ymax_tlb,/editable,xsize=5,value=ymax,uvalue=ymax,uname='ymax_text')
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  flag_fileID=widget_base(tlb,/row,xsize=xsize,frame=1)
  flag_file_tlb=widget_base(flag_fileID,row=1,tlb_frame_attr=1)
  flag_file_text=widget_text(flag_file_tlb,value=flag_file,uvalue=flag_file,uname='flag_file_text',/editable,xsize=60)
  flag_file_button=widget_button(flag_file_tlb,value='Output Flag File ',xsize=170,uname='flag_file_button')
  
  
;  temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={filt_file_text:filt_file_text,filt_file_button:filt_file_button,$
    parlabel:parlabel,$
    xmin_text:xmin_text,xmax_text:xmax_text,$
    ymin_text:ymin_text,$
    ymax_text:ymax_text,nlines_text:nlines_text,$
    flag_file_text:flag_file_text,flag_file_button:flag_file_button,$
    ok:ok,cl:cl,width_text:width_text}
    
    
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_residue',tlb,/no_block
END