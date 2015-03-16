pro cw_smc_unw_model_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  uname=widget_info(event.id,/uname)
  case uname of
  
    'interf_button': begin
      infile=dialog_pickfile(title='open complex interferogram',filter='*.flt.filt',/read,/must_exist, path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      
      IF FILE_TEST(config.m_rslc) THEN begin
        workpath=config.workpath
        m_rslc=config.m_rslc
        pwr_file=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
        
        parfile=pwr_file+'.par'
        parlab='Par file:'+parfile
        finfo=TLI_LOAD_SLC_PAR(parfile)
        width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
        lines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
      endif
      
      IF FILE_TEST(config.inputfile) THEN begin
        inputfile=config.inputfile
        workpath=config.workpath
        interf=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
        unw_model=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.unw_interp'
        unw_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.unw'
      endif
      config.inputfile=infile
      
      widget_control,(*pstate).interf_text,set_value=infile,set_uvalue=infile
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).lines_text,set_value=lines,set_uvalue=lines
      widget_control,(*pstate).width_model_text,set_value=width_model,set_uvalue=width_model
      widget_control,(*pstate).unw_model_text,set_value=unw_model,set_uvalue=unw_model
      widget_control,(*pstate).unw_out_text,set_value=unw_out,set_uvalue=unw_out
      
    end
    
    
    'unw_model_button': begin
      infile=dialog_pickfile(title='open approximate unwrapped phase model',filter='*.unw_interp',/read,/must_exist, path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).unw_model_text,set_value=infile
      widget_control,(*pstate).unw_model_text,set_uvalue=infile
    end
    
    'unw_out_button': begin
    
      widget_control,(*pstate).interf_text,get_value=interf
      IF NOT FILE_TEST(interf) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Approximate Unwrapped Phase Model']
        return
      endif
      
      widget_control,(*pstate).unw_model_text,get_value=unw_model
      IF NOT FILE_TEST(unw_model) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Complex Interferogram']
        return
      endif
      
      temp=file_basename(interf)
      temp=strsplit(temp, '.' ,/extract)
      unw_out=temp(0)
      
      file=unw_out+'.flt.filt.unw'
      
      infile=dialog_pickfile(title='output unwrapped phase',filter='*.flt.filt.unw',file=file,/write,/overwrite_prompt, path=config.workpath)
      
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).unw_out_text,set_value=infile
      widget_control,(*pstate).unw_out_text,set_uvalue=infile
      
    end
    
    'ok':begin
    
    widget_control,(*pstate).interf_text,get_uvalue=interf
    IF NOT FILE_TEST(interf) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Cmplex Inerferogram']
      return
    endif
    
    widget_control,(*pstate).unw_model_text,get_uvalue=unw_model
    IF NOT FILE_TEST(unw_model) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Approximate Unwrapped Phase Model']
      return
    endif
    
    widget_control,(*pstate).unw_out_text,get_uvalue=unw_out
    IF NOT FILE_TEST(unw_out) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The  Unwrapped Phase Output']
      return
    endif
    
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The  Correct Width']
      return
    endif
    
    widget_control,(*pstate).xinit_text,get_value=xinit
    xinit=long(xinit)
    if xinit lt 0 or xinit  then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The  Correct Starting Line Of Coherence Image']
      return
    endif
    
    widget_control,(*pstate).yinit_text,get_value=yinit
    yinit=long(yinit)
    if yinit lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The  Correct Starting Line Of Intensity Image']
      return
    endif
    
    widget_control,(*pstate).width_model_text,get_value=width_model
    width_model=long(width_model)
    if width_model lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The  Correct Number Of Pixels To Average In Azimuth']
      return
    endif
    widget_control,(*pstate).ref_ph_text,get_value=ref_ph
    IF STRLOWCASE(ref_ph) EQ 'keep original' THEN ref_ph='-'
    width=strcompress(width,/remove_all)
    xinit=strcompress(xinit,/remove_all)
    yinit=strcompress(yinit,/remove_all)
    width_model=strcompress(width_model,/remove_all)
    
    scr="unw_model "+interf+" "+unw_model+" "+unw_out+" "+width+" "+xinit+" "+yinit+" "+ref_ph+" "+width_model
    tli_smc_spawn, scr ,info='Phase Unwrapping Using a Model of the Unwrapped Phase, Please wait...',/supress
    ras_unw="rasrmg "+unw_out+" - "+width
    tli_smc_spawn, scr ,info='RAS Unwrapped Image, Please wait...'
  end
  
  'cl':begin
  
  widget_control,event.top,/destroy
  
end

else: begin
  return
end
endcase

END



PRO cw_smc_unw_model,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=430
  
  ; Get config info
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  width='0'
  lines='0'
  interf=''
  unw_model=''
  unw_out=''
  IF FILE_TEST(config.m_rslc) THEN begin
    workpath=config.workpath
    m_rslc=config.m_rslc
    pwr_file=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
    
    parfile=pwr_file+'.par'
    parlab='Par file:'+STRING(10b)+parfile
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    lines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
  endif
  
  IF FILE_TEST(config.inputfile) THEN begin
    inputfile=config.inputfile
    workpath=config.workpath
    interf=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
    unw_model=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.unw_interp'
    unw_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.unw'
  endif
  
  tlb=widget_base(title='SASMAC_Unw_Model',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  ; inID=widget_base(tlb,/row,xsize=xsize,frame=1)
  ;input=widget_text(inID,value=inputfile,uvalue=inputfile,uname='input',/editable,xsize=73)
  ;openinput=widget_button(inID,value='Input SLC',uname='openinput',xsize=90)
  
  interf_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  interf_text=widget_text(interf_tlb,/editable,xsize=70,value=interf,uvalue=interf,uname='interf_text')
  interf_button=widget_button(interf_tlb,value='Input Interf',xsize=110,uname='interf_button')
  
  unw_model_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  unw_model_text=widget_text(unw_model_tlb,/editable,xsize=70,value=unw_model,uvalue=unw_model,uname='unw_model_text')
  unw_model_button=widget_button(unw_model_tlb,value='Input Unw_Model',xsize=110,uname='unw_model_button')
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  ; Basic information extracted from par file
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  
  
  ; tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  ;sampID=widget_base(tempID, /column, xsize=xsize/3-10)
  ;samplabel=widget_label(sampID, value='Samples:',/ALIGN_LEFT)
  ; samples=widget_text(sampID,value=samples, uvalue=samples, uname='samples',/editable,xsize=10)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/3-20)
  width_label=widget_label(width_tlb,value='Width:',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,xsize=10,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  lines_tlb=widget_base(tempID,/column,xsize=xsize/3-20)
  lines_label=widget_label(lines_tlb,value='Lines:',/ALIGN_LEFT)
  lines_text=widget_text(lines_tlb,value=lines,uvalue=lines,uname='lines_text',xsize=10)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  width_model_tlb=widget_base(tempID,/column,xsize=xsize/3-10)
  width_model_lable=widget_label(width_model_tlb,value='Width_model:',/ALIGN_LEFT)
  width_model_text=widget_text(width_model_tlb,value=width,uvalue=width,uname='width_model_text',/editable,xsize=5)
  
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  xinit_tlb=widget_base(tempID,/column,xsize=xsize/3-10)
  xinit_label=widget_label(xinit_tlb,value='Xinit:',xsize=50,/ALIGN_LEFT)
  xinit_text=widget_text(xinit_tlb,value='0',uvalue='0',uname='xinit_text',/editable,xsize=5)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  yinit_tlb =widget_base(tempID,/column,xsize=xsize/3-10)
  yinit_label=widget_label(yinit_tlb,value='Yinit:',xsize=50,/ALIGN_LEFT)
  yinit_text=widget_text(yinit_tlb,value='0',uvalue='0',uname='yinit_text',/editable,xsize=5)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  ref_ph_tlb=widget_base(tempID,/column,xsize=xsize/3-10)
  ref_ph_label=widget_label(ref_ph_tlb,value='Reference Point Phase:',/ALIGN_LEFT)
  ref_ph_text=widget_text(ref_ph_tlb,value='Keep Original',uvalue='-',uname='ref_ph_text',/editable,xsize=10)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  unw_out_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  unw_out_text=widget_text(unw_out_tlb,/editable,xsize=70,value=unw_out,uvalue=unw_out,uname='unw_out_text')
  unw_out_button=widget_button(unw_out_tlb,value='Output Unw',xsize=110,uname='unw_out_button')
  
  ; non exclusive box
  ;  temp=widget_base(TLB,tab_mode=1,/column,/nonexclusive)
  ;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  
  state={unw_model_text:unw_model_text,unw_model_button:unw_model_button,$
    interf_text:interf_text,interf_button:interf_button,$
    unw_out_text:unw_out_text,unw_out_button:unw_out_button,$
    width_text:width_text,$
    lines_text:lines_text,$
    width_model_text:width_model_text,$
    xinit_text:xinit_text,$
    ref_ph_text:ref_ph_text,$
    yinit_text:yinit_text,$
    parlabel:parlabel}
    
    
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_unw_model',tlb,/no_block
END