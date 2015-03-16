pro cw_smc_corr_flag_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  workpath=config.workpath
  
  uname=widget_info(event.id,/uname)
  
  case uname of
  
    'corr_file_button': begin
    
      infile=dialog_pickfile(title='open interferometric correlation file',filter='*.cc',/read,/must_exist, path=config.workpath)
      
      IF NOT FILE_TEST(infile) THEN return
      
      ; Update definitions
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      
      IF FILE_TEST(config.m_rslc) THEN begin
        workpath=config.workpath
        m_rslc=config.m_rslc
        pwr_file=workpath+'/'+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
        parfile=pwr_file+'.par'
        parlab='Par file:'+STRING(10b)+parfile
        finfo=TLI_LOAD_SLC_PAR(parfile)
        width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
        lines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
        xmax=STRCOMPRESS(width-1,/REMOVE_ALL)
        ymax=STRCOMPRESS(lines-1,/REMOVE_ALL)
      endif
      
      IF FILE_TEST(config.inputfile) THEN begin
        inputfile=config.inputfile
        workpath=config.workpath
        corr_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
        flag_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.flag'
      endif
      
      widget_control,(*pstate).corr_file_text,set_value=infile
      widget_control,(*pstate).corr_file_text,set_uvalue=infile
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).nlines_text,set_value=lines,set_uvalue=lines
      widget_control,(*pstate).xmax_text,set_value=xmax,set_uvalue=xmax
      widget_control,(*pstate).ymax_text,set_value=ymax,set_uvalue=ymax
      widget_control, (*pstate).flag_file_text, set_value=flag_file
      widget_control, (*pstate).flag_file_text, set_uvalue=flag_file
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
    end
    
    'corr_flag_button': begin
    
      widget_control,(*pstate).flag_file_text,get_uvalue=flag_file
      
      IF NOT FILE_TEST(flag_file) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the interferometric correlation file ']
        return
      endif
      
      temp=file_basename(corr_file)
      temp=strsplit(temp, '.' ,/extract)
      interf=temp(0)
      
      file=interf+'.flt.filt.flag'
      
      infile=dialog_pickfile(title='output phase unwrapping flag file',filter='*.flt.filt.flag',file=file,/write,/overwrite_prompt)
      
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).flag_file_text,set_value=infile
      widget_control,(*pstate).flag_file_text,set_uvalue=infile
      
    end
    
    
    'ok':begin
    
    widget_control,(*pstate).corr_file_text,get_uvalue=corr_file
    IF NOT FILE_TEST(corr_file) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the correct correlation file ']
      return
    endif
    
    widget_control,(*pstate).flag_file_text,get_value=flag_file
    IF flag_file EQ '' THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the phase unwrapping flag file ']
      return
    endif
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please input the correct width ']
      return
    endif
    
    widget_control,(*pstate).corr_thr_text,get_value=corr_thr
    corr_thr=float(corr_thr)
    if corr_thr lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please input correlation threshold']
      return
    endif
    
    widget_control,(*pstate).start_text,get_value=start
    start=long(start)
    if start lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please input  the correct starting line']
      return
    endif
    
    widget_control,(*pstate).xmin_text,get_value=xmin
    xmin=long(xmin)
    if xmin lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please input  the correct starting range pixel offset']
      return
    endif
    
    widget_control,(*pstate).xmax_text,get_value=xmax
    xmax=long(xmax)
    if xmax lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please input  the correct  last range pixel offset']
      return
    endif
    
    widget_control,(*pstate).ymin_text,get_value=ymin
    ymin=float(ymin)
    if ymin lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please input  the correct  starting azimuth row offset']
      return
    endif
    
    widget_control,(*pstate).ymax_text,get_value=ymax
    ymax=float(ymax)
    if ymax le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please input  the correct  last azimuth row offset']
      return
    endif
    
    width=strcompress(width,/remove_all)
    corr_thr=strcompress(corr_thr,/remove_all)
    start=strcompress(start,/remove_all)
    xmin=strcompress(xmin,/remove_all)
    xmax=strcompress(xmax,/remove_all)
    ymin=strcompress(ymin,/remove_all)
    ymax=strcompress(ymax,/remove_all)
    
    scr="corr_flag "+corr_file+" "+flag_file+" "+width+" "+corr_thr+" "+start+" "+xmax+" "+ymin+" "+ymin
    tli_smc_spawn, scr ,info='Correlation Threshold For Phase Unwrapping, Please wait...'
  end
  
  'cl':begin
  
  widget_control,event.top,/destroy
  
end

else: begin
  return
end
endcase

END


PRO cw_smc_corr_flag,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=400
  
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  samples='0'
  lines='0'
  format=''
  corr_file=''
  flag_file=''
  
  IF FILE_TEST(config.m_rslc) THEN begin
    workpath=config.workpath
    m_rslc=config.m_rslc
    pwr_file=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
    parfile=pwr_file+'.par'
    parlab='Par file:'+STRING(10b)+parfile
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    lines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
    xmax=STRCOMPRESS(width-1,/REMOVE_ALL)
    ymax=STRCOMPRESS(lines-1,/REMOVE_ALL)
  endif
  
  IF FILE_TEST(config.inputfile) THEN begin
    inputfile=config.inputfile
    workpath=config.workpath
    corr_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
    flag_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.flag'
  endif
  
  config.workpath=workpath
  
  tlb=widget_base(title='SASMAC_CORR_FLAG',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  corr_file_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  corr_file_tlb=widget_base(corr_file_ID,row=1,tlb_frame_attr=1)
  corr_file_text=widget_text(corr_file_tlb,value=corr_file,uvalue=corr_file,/editable,xsize=63,uname='corr_file_text')
  corr_file_button=widget_button(corr_file_tlb,value='Input Correlation File',xsize=150,uname='corr_file_button')
  
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  width_label=widget_label(width_tlb,value='Width:',xsize=45,uname='width_button',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  nlines_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  nlines_label=widget_label(nlines_tlb,value='Lines:',xsize=45,uname='nlines_label',/ALIGN_LEFT)
  nlines_text=widget_text(nlines_tlb,/editable,value=lines,uvalue=lines,uname='nlines_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  corr_thr_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  corr_thr_label=widget_label(corr_thr_tlb,value='Coherence Threshold: ',xsize=130,uname='corr_thr_label',/ALIGN_LEFT)
  corr_thr_text=widget_text(corr_thr_tlb,/editable,xsize=5,value='0.3',uvalue='0.3',uname='corr_thr_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  start_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  start_label=widget_label(start_tlb,value='Start Line:',xsize=80,uname='start_label',/ALIGN_LEFT)
  start_text=widget_text(start_tlb,/editable,xsize=5,value='0',uvalue='0',uname='start_text')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  xmin_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  xmin_label=widget_label(xmin_tlb,value='Start Range Pixel :',xsize=120,uname='xmin_label',/ALIGN_LEFT)
  xmin_text=widget_text(xmin_tlb,/editable,xsize=5,value='0',uvalue='0',uname='xmin_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  xmax_tlb=widget_base(tempID,/column, xsize=xsize/4-10)
  xmax_label=widget_label(xmax_tlb,value='Last Range Pixel:',xsize=120,uname='xmax_label',/ALIGN_LEFT)
  xmax_text=widget_text(xmax_tlb,/editable,xsize=5,value=xmax,uvalue=ymax,uname='xmax_text')
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  ymin_tlb=widget_base(tempID,/column, xsize=xsize/4-10)
  ymin_label=widget_label(ymin_tlb,value='Start Azimuth Row:',xsize=120,uname='label',/ALIGN_LEFT)
  ymin_text=widget_text(ymin_tlb,/editable,xsize=5,value='0',uvalue='0',uname='ymin_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  ymax_tlb=widget_base(tempID,/column, xsize=xsize/4-10)
  ymax_label=widget_label(ymax_tlb,value='Last Azimuth Row:',xsize=120,uname='ymax_label',/ALIGN_LEFT)
  ymax_text=widget_text(ymax_tlb,/editable,xsize=5,value=ymax,uvalue=ymax,uname='ymax_text')
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  flag_fileID=widget_base(tlb,/row,xsize=xsize,frame=1)
  flag_file_tlb=widget_base(flag_fileID,row=1,tlb_frame_attr=1)
  flag_file_text=widget_text(flag_file_tlb,value=flag_file,uvalue=flag_file,uname='flag_file_text',/editable,xsize=63)
  flag_file_button=widget_button(flag_file_tlb,value='Output Flag File ',xsize=150,uname='flag_file_button')
  
  
  
;  temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={corr_file_text:corr_file_text,corr_flile_button:corr_file_button,start_text:start_text,$
    parlabel:parlabel,$
    xmin_text:xmin_text,xmax_text:xmax_text,$
    ymin_text:ymin_text,$
    ymax_text:ymax_text,nlines_text:nlines_text,$
    flag_file_text:flag_file_text,flag_file_button:flag_file_button,$
    ok:ok,cl:cl,width_text:width_text,corr_thr_text:corr_thr_text}
    
    
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_corr_flag',tlb,/no_block
END