pro cw_smc_ph_slope_base_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  workpath=config.workpath
  
  uname=widget_info(event.id,/uname)
  
  case uname of
  
    'slc_button': begin
    
      infile=dialog_pickfile(title='Input reference slc',filter='*.rslc, *.slc',/read,/must_exist,path=config.workpath)
      
      IF NOT FILE_TEST(infile) THEN return
      
      ; Update definitions
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      workpath=config.workpath
      inputfile=config.inputfile
      parfile=inputfile+'.par'
      finfo=TLI_LOAD_SLC_PAR(parfile)
      
      widget_control, (*pstate).format_text, set_value=format, set_uvalue=format
      widget_control,(*pstate).slc_text,set_value=infile
      widget_control,(*pstate).slc_text,set_uvalue=infile
      config.workpath=workpath
      config.m_rslc=infile
    end
    
    
    
    'int_in_button': begin
    
      infile=dialog_pickfile(title='Input interferogram ',filter='*.int',/read,/must_exist,path=config.workpath)
      
      IF NOT FILE_TEST(infile) THEN return
      
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      
      
      off=workpath+TLI_FNAME(infile, /nosuffix)+'.off'
      IF FILE_TEST(config.inputfile) THEN BEGIN
        workpath=config.workpath
        inputfile=config.inputfile
        base=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.base'
        int_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.int'
        int_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.int.flt'
        off=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.off'
      endif
      
      if FILE_TEST(config.m_rslc) THEN BEGIN
        m_rslc=config.m_rslc
        parfile=m_rslc+'.par'
        parlab='Par file:'+parfile
        finfo=TLI_LOAD_SLC_PAR(parfile)
        width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
        lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
      endif
      
      widget_control,(*pstate).int_in_text,set_value=infile
      widget_control,(*pstate).int_in_text,set_uvalue=infile
      widget_control,(*pstate).off_text,set_value=off
      widget_control,(*pstate).off_text,set_uvalue=off
      
      widget_control,(*pstate).base_text,set_value=base
      widget_control,(*pstate).base_text,set_uvalue=base
      widget_control,(*pstate).int_out_text,set_value=int_out
      widget_control,(*pstate).int_out_text,set_uvalue=int_out
      widget_control, (*pstate).width_text, set_value=width, set_uvalue=width
      widget_control, (*pstate).lines_text, set_value=lines, set_uvalue=lines
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
    end
    
    
    'off_button': begin
      infile=dialog_pickfile(title='open offset/interferogram parameter file',filter='*.off',/read,/must_exist,path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).off_text,set_value=infile
      widget_control,(*pstate).off_text,set_uvalue=infile
    end
    
    'int_out_button':begin
    
    widget_control,(*pstate).int_in_text,get_uvalue=infile
    IF NOT FILE_TEST(infile) THEN begin
      result=dialog_message(title='int_in file error','please input the interferogram file',/information)
      return
    endif
    
    
    
    temp=file_basename(int_in)
    temp=strsplit(temp, '.' ,/extract)
    int_in=temp(0)
    
    file=int_in+'.int.filt'
    
    infile=dialog_pickfile(title='output ph_slope_base',filter='*.int.filt',file=file,/write,/overwrite_prompt)
    IF NOT FILE_TEST(infile) THEN return
    widget_control,(*pstate).int_out_text,set_value=infile
    widget_control,(*pstate).int_out_text,set_uvalue=infile
    
    
  end
  
  'ok':begin
  
  widget_control,(*pstate).int_in_text,get_value=int_in
  IF NOT FILE_TEST(int_in) THEN begin
    result=dialog_message(title='int_in file','please input the interferogram file',/information)
    return
  endif
  
  widget_control,(*pstate). slc_text,get_value= slc_file
  IF NOT FILE_TEST(slc_file) THEN begin
    result=dialog_message(title='slc par file','please choose the slave slc par',/information)
    return
  endif
  
  widget_control,(*pstate).off_text,get_value=off
  IF NOT FILE_TEST(off) THEN begin
    result=dialog_message(title='offset file','please choose the offest file',/information)
    return
  endif
  
  widget_control,(*pstate).base_text,get_value=base
  IF NOT FILE_TEST(base) THEN begin
    result=dialog_message(title='base file','please choose the base file',/information)
    return
  endif
  
  widget_control,(*pstate).int_out_text,get_value=int_out
  IF int_out EQ '' THEN begin
    result=dialog_message(title='int out error','please choose the flatted interferogram',/information)
    return
  endif
  
  
  format_text=WIDGET_INFO((*pstate).format_text,/droplist_select)
  if format_text eq 0 then begin
    format='1'
  endif else begin
    format='0'
  endelse
  
  inverse_text=WIDGET_INFO((*pstate).inverse_text,/droplist_select)
  inverse=STRCOMPRESS(inverse_text ,/REMOVE_ALL)
  
  widget_control,(*pstate).width_text,get_value=width
  width=long(width)
  if width le  0 then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please input correct width ']
    return
  endif
  width=STRCOMPRESS(width ,/REMOVE_ALL)
  
  
  scr="ph_slope_base "+int_in+"  "+slc_file+".par "+off+" "+base+" "+int_out+" "+format+" "+inverse
  tli_smc_spawn, scr ,info='Step 1/2: Subtracting interferogram flat-Earth phase trend, Please wait...',/supress
  
  scr="rasmph "+int_out+" "+width
  tli_smc_spawn,scr,info='Step 2/2: Plotting Flatenned Interferogram, Please wait...'
  
end

'cl':begin

widget_control,event.top,/destroy

end

else: begin
  return
end
endcase

END



PRO cw_smc_ph_slope_base,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=550
  
  workpath='/00'
  inputfile=''
  parfile=''
  samples='0'
  lines='0'
  base=''
  int_out=''
  m_rslc=''
  off=''
  int_in=''
  width=''
  lines=''
  parlab='Par file not found'
  
  
  IF FILE_TEST(config.inputfile) THEN BEGIN
    workpath=config.workpath
    inputfile=config.inputfile
    base=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.base'
    int_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.int'
    int_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.int.flt'
    off=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.off'
  endif
  
  if FILE_TEST(config.m_rslc) THEN BEGIN
    m_rslc=config.m_rslc
    parfile=m_rslc+'.par'
    parlab='Par file:'+parfile
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
  endif
  
  
  config.workpath=workpath
  
  tlb=widget_base(title='SASMAC_PH_SLOPE_BASE',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  int_in_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  int_in_tlb=widget_base(int_in_ID,row=1,tlb_frame_attr=1)
  int_in_text=widget_text(int_in_tlb,value=int_in,uvalue=int_in,/editable,xsize=63,uname='int_in_text')
  int_in_button=widget_button(int_in_tlb,value='Input interferogram',xsize=150,uname='int_in_button')
  
  slcID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slc_tlb=widget_base(slcID,row=1,tlb_frame_attr=1)
  slc_text=widget_text( slc_tlb,/editable,xsize=63,value=m_rslc,uvalue=m_rslc,uname='slc_button')
  slc_button=widget_button( slc_tlb,value='Input reference slc',xsize=150,uname='slc_button')
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off_tlb=widget_base(offID,row=1,tlb_frame_attr=1)
  off_text=widget_text(off_tlb,/editable,xsize=63,value=off,uvalue=off,uname='off_text')
  off_button=widget_button(off_tlb,value='Input offset par',xsize=150,uname='off_button')
  
  baseID=widget_base(tlb,/row,xsize=xsize,frame=1)
  base_tlb=widget_base(baseID,row=1,tlb_frame_attr=1)
  base_text=widget_text(base_tlb,/editable,xsize=63,value=base,uvalue=base,uname='base_text')
  base_button=widget_button(base_tlb,value='Input baseline file',xsize=150,uname='base_button')
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/2-20)
  width_label=widget_label(width_tlb,value='Width:',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,xsize=10,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  lines_tlb=widget_base(tempID,/column,xsize=xsize/2-20)
  lines_label=widget_label(lines_tlb,value='Lines:',/ALIGN_LEFT)
  lines_text=widget_text(lines_tlb,value=lines,uvalue=lines,uname='lines_text',/editable,xsize=10)
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  format_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  format_label=widget_label(format_tlb, value='Interferogram Type:',xsize=220,uname='format_button',/ALIGN_LEFT)
  format_text=widget_droplist(format_tlb,value=['0: unwrapped phase',$
    '1: complex interf'])
    
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  inverse_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  inverse_label=widget_label(inverse_tlb, value='Sutract/add Inversion Flag:',xsize=220,uname='inverse_button',/ALIGN_LEFT)
  inverse_text=widget_droplist(inverse_tlb,value=['0: subtract phase ramp',$
    '1: add phase ramp'])
    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  int_out_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  int_out_tlb=widget_base(int_out_ID,row=1,tlb_frame_attr=1)
  int_out_text=widget_text(int_out_tlb,value=int_out,uvalue=int_out,/editable,xsize=63,uname='int_out_text')
  int_out_button=widget_button(int_out_tlb,value='Output flattened',xsize=150,uname='int_in_button')
  
;  temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={int_in_text:int_in_text,int_in_button:int_in_button,$
    width_text:width_text,$
    lines_text:lines_text,$
    slc_text: slc_text, slc_button: slc_button,$
    off_text:off_text,off_button:off_button,$
    base_text:base_text,base_button:base_button,$
    format_text:format_text,$
    inverse_text:inverse_text,$
    parlabel:parlabel,$
    int_out_text:int_out_text,int_out_button:int_out_button,$
    ok:ok,cl:cl}
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_ph_slope_base',tlb,/no_block
END