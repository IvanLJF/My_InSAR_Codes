
pro cw_smc_snaphu_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  uname=widget_info(event.id,/uname)
  
  case uname of
  
    'data_in_button': begin
    
      infile=dialog_pickfile(title='Open data ',filter='*.flt.filt.swap',/read, path=config.workpath)
      
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
        data_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.swap'
        cc_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc.convert'
        data_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.snaphu_ini'
      endif
      
      widget_control,(*pstate).width_text,set_value=width
      widget_control,(*pstate).width_text,set_uvalue=width
      widget_control,(*pstate).lines_text,set_value=lines
      widget_control,(*pstate).lines_text,set_uvalue=lines
      widget_control,(*pstate).data_in_text,set_value=infile
      widget_control,(*pstate).data_in_text,set_uvalue=infile
      widget_control,(*pstate).data_out_text,set_value=data_out
      widget_control,(*pstate).data_out_text,set_uvalue=data_out
      widget_control,(*pstate).cc_file_text,set_value=cc_file
      widget_control,(*pstate).cc_file_text,set_uvalue=cc_file
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
    end
    
    'cc_file_button': begin
      infile=dialog_pickfile(title='open coherence file ',filter='*.filt.cc.convert',/read, path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).cc_file_text,set_value=cc_file
      widget_control,(*pstate).cc_file_text,set_uvalue=cc_file
    end
    
    'data_out_button': begin
    
      widget_control,(*pstate).data_in_text,get_value=data_in
      IF data_in EQ '' THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please select output file.']
        return
      endif
      
      
      temp=file_basename(data_in)
      temp=strsplit(temp, '.' ,/extract)
      data_out=temp(0)
      
      file=data_out+'.snaphu_ini'
      
      infile=dialog_pickfile(title='output data',filter='*.snaphu_ini',file=file,/write,/overwrite_prompt, path=config.workpath)
      
      if infile eq '' then return
      widget_control,(*pstate).data_out_text,set_value=infile
      widget_control,(*pstate).data_out_text,set_uvalue=infile
      
    end
    
    'ok':begin
    
    widget_control,(*pstate).data_in_text,get_uvalue=data_in
    IF NOT FILE_TEST(data_in) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please select input filtered file']
      return
    endif
    
    widget_control,(*pstate).cc_file_text,get_uvalue=cc_file
    IF NOT FILE_TEST(cc_file) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please select input cc file']
      return
    endif
    
    widget_control,(*pstate).data_out_text,get_uvalue=data_out
    IF data_out EQ '' THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please select output file.']
      return
    endif
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please input file width.']
      return
    endif
    
    model_text=WIDGET_INFO((*pstate).model_text,/droplist_select)
    if model_text eq 0 then begin
      model='i'
    endif else begin
      model='s'
    endelse
    
    algorithm_text=WIDGET_INFO((*pstate).algorithm_text,/droplist_select)
    if algorithm_text eq 0 then begin
      algorithm='mst'
    endif else begin
      algorithm='mcf'
    endelse
    
    width=strcompress(width,/remove_all)
    
    ; scr="swap_bytes "+data_in+" "+data_out+" 4"
    ;     spawn,scr
    ;tli_format_convert,data_in,width,'float',output_format='alt_line_data',/input_swap_endian
    
    scr="snaphu "+data_in+" "+width+" -v -c "+cc_file +" -o "+data_out+" -"+model+" --"+algorithm
    tli_smc_spawn, scr ,info='Unwrapping using snaphu, Please wait...'
    
  end
  
  'cl':begin
  widget_control,event.top,/destroy
end

else: begin
  return
end
endcase

END
PRO cw_smc_snaphu,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=450
  
  ; Get config info
  workpath='/00'
  inputfile=''
  parfile=''
  parlab='Par file not found'
  width='0'
  lines='0'
  cc_file=''
  data_in=''
  data_out=''
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
    data_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.swap'
    cc_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc.convert'
    data_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.snaphu_ini'
  endif
  
  tlb=widget_base(title='SASMAC_SNAPHU2GAMMA_CC',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  data_in_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  data_in_text=widget_text(data_in_tlb,/editable,xsize=70,value=data_in,uvalue=data_in,uname='data_in_text')
  data_in_button=widget_button(data_in_tlb,value='Input Data',xsize=110,uname='data_in_button')
  
  cc_file_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  cc_file_text=widget_text(cc_file_tlb,/editable,xsize=70,value=cc_file,uvalue=cc_file,uname='cc_file_text')
  cc_file_button=widget_button(cc_file_tlb,value='cc_file',xsize=110,uname='cc_file_button')
  
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  ; Basic information extracted from par file
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
  
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  model__tlb=widget_base(tempID, /column, xsize=xsize/2-20)
  model_label=widget_label(model__tlb,value='Mode:',/ALIGN_LEFT)
  model_text=widget_droplist(model__tlb,value=['i: Do Initialization And Exit',$
                                               's: Use Smooth Mode           '])
    
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  algorithm_tlb=widget_base(tempID, /column, xsize=xsize/2-20)
  algorithm_label=widget_label(algorithm_tlb,value='Initialization Algorithm:',/ALIGN_LEFT)
  algorithm_text=widget_droplist(algorithm_tlb,value=['           MST          ',$
    '           MCF          '])
    
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  data_out_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  data_out_text=widget_text(data_out_tlb,/editable,xsize=70,value=data_out,uvalue=data_out,uname='data_out_text')
  data_out_button=widget_button(data_out_tlb,value='Output Data',xsize=110,uname='data_out_button')
  
  ;   ; non exclusive box
  ;  temp=widget_base(TLB,tab_mode=1,/column,/nonexclusive)
  ;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={ data_in_text:data_in_text,data_in_button:data_in_button,$
    data_out_text:data_out_text,data_out_button:data_out_button,$
    cc_file_text:cc_file_text,cc_file_button:cc_file_button,$
    width_text:width_text,$
    lines_text:lines_text,$
    model_text:model_text,$
    algorithm_text:algorithm_text,$
    parlabel:parlabel}
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_snaphu',tlb,/no_block
END