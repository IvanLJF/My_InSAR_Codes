pro cw_smc_grasses_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
  
    'int_in_button': begin
    
      infile=dialog_pickfile(title='open filt interferometric  file',filter='*.flt.filt',/read,/must_exist, path=config.workpath)
      
      IF NOT FILE_TEST(infile) THEN return
      
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      
      IF FILE_TEST(config.m_rslc) THEN begin
        m_rslc=config.m_rslc
        intensity=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
        parfile=intensity+'.par'
        parlab='Par file:'+parfile
        finfo=TLI_LOAD_SLC_PAR(parfile)
        width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
        xmax=STRCOMPRESS(finfo.range_samples-1,/REMOVE_ALL)
        nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
        ymax=STRCOMPRESS(finfo.azimuth_lines-2,/REMOVE_ALL)
      endif
      
      
      flag_file=workpath+TLI_FNAME(infile, /remove_all_suffix)+'.flt.filt.flag'
      unw_out=workpath+TLI_FNAME(infile, /remove_all_suffix)+'.flt.filt.unw'
      
      
      xmax=strcompress(long(width)-1)
      ymax=strcompress(long(ymax)-1)
      xinit=strcompress(long(width)/2)
      yinit=strcompress(long(ymax)/2)
      
      widget_control,(*pstate).int_in_text,set_value=infile,set_uvalue=infile
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).xmax_text,set_value=xmax,set_uvalue=xmax
      widget_control,(*pstate).ymax_text,set_value=ymax,set_uvalue=ymax
      widget_control,(*pstate).xinit_text,set_value=xinit,set_uvalue=xinit
      widget_control,(*pstate).yinit_text,set_value=yinit,set_uvalue=yinit
      widget_control, (*pstate).unw_out_text, set_value=unw_out, set_uvalue=unw_out
      widget_control, (*pstate).flag_file_text, set_value=flag_file,set_uvalue=flag_file
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
    end
    
    'flag_file_button':  begin
    
      infile=dialog_pickfile(title='open flag file',filter='*.flt.filt.flag',/read,/must_exist, path=config.workpath)
      if infile eq '' then return
      widget_control,(*pstate).flag_file_text,set_value=infile
      widget_control,(*pstate).flag_file_text,set_uvalue=infile
      
    end
    
    'unw_out_button': begin
    
      widget_control,(*pstate).int_in_text,get_value=int_in
      if int_in eq '' then begin
        result=dialog_message(title='filt file','please input the filt interferferogram file',/information)
        return
      endif
      
      widget_control,(*pstate).flag_file_text,get_value=flag_file
      if flag_file eq '' then begin
        result=dialog_message(title='flag file','please input the unwrapping flag file',/information)
        return
      endif
      
      temp=file_basename(int_in)
      temp=strsplit(temp, '.' ,/extract)
      interf=temp(0)
      
      file=interf+'.flt.filt.unw'
      
      infile=dialog_pickfile(title='output unw',filter='*.flt.filt.unw',file=file,/write,/overwrite_prompt, path=config.workpath)
      
      if infile eq '' then return
      widget_control,(*pstate).unw_out_text,set_value=infile
      widget_control,(*pstate).unw_out_text,set_uvalue=infile
      
    end
    
    'ok':begin
    
    widget_control,(*pstate).int_in_text,get_uvalue=int_in
    if int_in eq '' then begin
      result=dialog_message(title='filt interferogram','please choose the correct filt interferogram file',/information)
      return
    endif
    
    widget_control,(*pstate).flag_file_text,get_uvalue=flag_file
    if flag_file eq '' then begin
      result=dialog_message(title='flag_file','please choose the phase unwrapping flag file',/information)
      return
    endif
    
    widget_control,(*pstate).unw_out_text,get_uvalue=unw_out
    if unw_out eq '' then begin
      result=dialog_message(title='unw_out','please choose the unwrapped phase file',/information)
      return
    endif
    
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      result=dialog_message(title='width error','please imput the correct width'/information)
      return
    endif
    
    widget_control,(*pstate).xmin_text,get_value=xmin
    xmin=long(xmin)
    if xmin lt 0 then begin
      result=dialog_message(title='xmin error','please imput starting range pixel offset'/information)
      return
    endif
    
    widget_control,(*pstate).xmax_text,get_value=xmax
    xmax=long(xmax)
    if xmax lt 0 then begin
      result=dialog_message(title='xmax error','please imput last range pixel offset'/information)
      return
    endif
    
    widget_control,(*pstate).ymin_text,get_value=ymin
    ymin=long(ymin)
    if ymin lt 0 then begin
      result=dialog_message(title='ymin error','please imput the starting azimuth row offset'/information)
      return
    endif
    
    widget_control,(*pstate).ymax_text,get_value=ymax
    ymax=long(ymax)
    if ymax le 0 then begin
      result=dialog_message(title='ymax error','please imput last azimuth row offset'/information)
      return
    endif
    
    widget_control,(*pstate).xinit_text,get_value=xinit
    xinit=long(xinit)
    if xinit lt 0 then begin
      result=dialog_message(title='xinit error','please imput the starting range pixel for unwrapping'/information)
      return
    endif
    
    widget_control,(*pstate).yinit_text,get_value=yinit
    yinit=long(yinit)
    if yinit le 0 then begin
      result=dialog_message(title='yinit error','please imput the starting range pixel for unwrapping'/information)
      return
    endif
    
    
    
    width=strcompress(width,/remove_all)
    xmin=strcompress(xmin,/remove_all)
    xmax=strcompress(xmax,/remove_all)
    ymin=strcompress(ymin,/remove_all)
    ymax=strcompress(ymax,/remove_all)
    xinit=strcompress(xinit,/remove_all)
    yinit=strcompress(yinit,/remove_all)
    
    scr="grasses "+int_in+" "+flag_file+" "+unw_out+" "+width+" "+xmin+" "+xmax+" "+ymin+" "+ymax+" "+xinit+" "+yinit
    tli_smc_spawn, scr ,info=' Phase Unwrapping By Region Growing, Please wait...'
    ras_unw="rasrmg "+unw_out+" - "+width
    tli_smc_spawn, ras_unw ,info=' Ras Unwrapped FILE, Please wait...'
  end
  
  
  'cl':begin

    widget_control,event.top,/destroy

end

else: begin
  return
end
endcase

END


PRO cw_smc_grasses,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=440
  
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  width='0'
  nlines='0'
  xinit='0'
  yinit='0'
  xmin='0'
  ymin='0'
  ymax='0'
  
  
  IF FILE_TEST(config.m_rslc) THEN begin
  
    m_rslc=config.m_rslc
    intensity=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
    
    parfile=intensity+'.par'
    parlab='Par file:'+STRING(10b)+parfile
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(LONG(finfo.range_samples),/REMOVE_ALL)
    xmax=STRCOMPRESS(LONG(finfo.range_samples-1),/REMOVE_ALL)
    nlines=STRCOMPRESS(LONG(finfo.azimuth_lines-1),/REMOVE_ALL)
    ymax=STRCOMPRESS(LONG(finfo.azimuth_lines-2),/REMOVE_ALL)
    xinit=strcompress(long(width)/2)
    yinit=strcompress(long(ymax)/2)
  endif
  
  IF FILE_TEST(config.inputfile) THEN begin
    inputfile=config.inputfile
    int_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
    flag_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.flag'
    unw_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.unw'
  endif
  config.workpath=workpath
  
  tlb=widget_base(title='SASMAC_GRASSES',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  int_in_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  int_in_tlb=widget_base(int_in_ID,row=1,tlb_frame_attr=1)
  int_in_text=widget_text(int_in_tlb,value=int_in,uvalue=int_in,/editable,xsize=63,uname='int_in_text')
  int_in_button=widget_button(int_in_tlb,value='Input interferogram',xsize=150,uname='int_in_button')
  
  flag_file_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  flag_file_tlb=widget_base(flag_file_ID,row=1,tlb_frame_attr=1)
  flag_file_text=widget_text(flag_file_tlb,/editable,xsize=63,value=flag_file,uvalue=flag_file,uname='flag_file_text')
  flag_file_button=widget_button(flag_file_tlb,value='flag_file',xsize=150,uname='flag_file_button')
  
  
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  width_label=widget_label(width_tlb,value='Width:',xsize=45,uname='width_label',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  nlines_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  nlines_label=widget_label(nlines_tlb,value='Lines:',xsize=45,uname='nlines_label',/ALIGN_LEFT)
  nlines_text=widget_text(nlines_tlb,/editable,value=nlines,uvalue=nlines,uname='nlines_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  xinit_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  xinit_label=widget_label(xinit_tlb,value='Xinit:',uname='xinit_label',xsize=45,/ALIGN_LEFT)
  xinit_text=widget_text(xinit_tlb,value=xinit,uvalue=xinit,uname='xinit_text',/editable,xsize=5)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  yinit_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  yinit_label=widget_label(yinit_tlb,value='Yinit:',uname='yinit_label',xsize=45,/ALIGN_LEFT)
  yinit_text=widget_text(yinit_tlb,value=yinit,uvalue=yinit,uname='yinit_text',/editable,xsize=5)
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  xmin_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  xmin_label=widget_label(xmin_tlb,value='Xmin:',uname='xmin_label',xsize=45,/ALIGN_LEF)
  xmin_text=widget_text(xmin_tlb,value=xmin,uvalue=xmin,uname='xmin_text',/editable,xsize=5)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  xmax_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  xmax_label=widget_label(xmax_tlb,value='Xmax:',uname='xmax_label',xsize=45,/ALIGN_LEF)
  xmax_text=widget_text(xmax_tlb,value=xmax,uvalue=xmax,uname='xmax_text',/editable,xsize=5)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  ymin_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  ymin_label=widget_label(ymin_tlb,value='Ymin:',uname='ymin_label',xsize=45,/ALIGN_LEF)
  ymin_text=widget_text(ymin_tlb,value=ymin,uvalue=ymin,uname='ymin_text',/editable,xsize=5)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  ymax_tlb=widget_base(tempID, /column, xsize=xsize/4-10)
  ymax_label=widget_label(ymax_tlb,value='Ymax:',uname='ymax_button',xsize=45,/ALIGN_LEF)
  ymax_text=widget_text(ymax_tlb,value=ymax,uvalue=ymax,uname='ymax_text',/editable,xsize=5)
  
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  unw_ou_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  unw_out_tlb=widget_base(unw_ou_ID,row=1,tlb_frame_attr=1)
  unw_out_text=widget_text(unw_out_tlb,/editable,xsize=63,value=unw_out,uvalue=unw_out,uname='unw_out_text')
  unw_out_button=widget_button(unw_out_tlb,value='unwrapped',xsize=150,uname='unw_out_button')
  
;  temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  
  state={int_in_text:int_in_text,int_in_button:int_in_button,$
    flag_file_text:flag_file_text,flag_file_button:flag_file_button,$
    width_text:width_text,nlines_text:nlines_text,$
    unw_out_text:unw_out_text,unw_out_button:unw_out_button,$
    xmin_text:xmin_text,xmax_text:xmax_text,$
    ymin_text:ymin_text,ymax_text:ymax_text,$
    xinit_text:xinit_text,yinit_text:yinit_text,$
    parlabel:parlabel}
    
    
    
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_grasses',tlb,/no_block
END