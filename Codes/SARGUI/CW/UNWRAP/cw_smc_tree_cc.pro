pro cw_smc_tree_cc_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
  
    'flag_file_button': begin
    
      infile=dialog_pickfile(title='open flag file',filter='*.flt.filt.flag',/read,/must_exist, path=config.workpath)
      
      IF NOT FILE_TEST(infile) THEN return
      
      ; Update definitions
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      
      workpath=config.workpath
      inputfile=config.inputfile
      
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
      
      widget_control,(*pstate).flag_file_text,set_value=infile,set_uvalue=infile
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).xmax_text,set_value=xmax,set_uvalue=xmax
      widget_control,(*pstate).ymax_text,set_value=ymax,set_uvalue=ymax
      widget_control,(*pstate).nlines_text,set_value=nlines,set_uvalue=nlines
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
    end
    
    'ok':begin
    
    
    widget_control,(*pstate).flag_file_text,get_uvalue=flag_file
    IF NOT FILE_TEST(flag_file) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Choose The Phase Unwrapping Flag File ']
      return
    endif
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Width ']
      return
    endif
    
    widget_control,(*pstate).mbl_text,get_value=mbl
    mbl=long(mbl)
    if mbl le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct  Maximum Branch Length ']
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
    mbl=strcompress(mbl,/remove_all)
    xmin=strcompress(xmin,/remove_all)
    xmax=strcompress(xmax,/remove_all)
    ymin=strcompress(ymin,/remove_all)
    ymax=strcompress(ymax,/remove_all)
    
    scr="tree_cc "+flag_file+" "+width+" "+mbl+" "+xmin+" "+xmax+" "+ymin+" "+ymax
    tli_smc_spawn, scr ,info=' Phase unwrapping Tree Generation, Please wait...'
    
  end
  
  'cl':begin
  
  widget_control,event.top,/destroy
  
end

else: begin
  return
end
endcase

END

PRO cw_smc_tree_cc,EVENT

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
  xmin='0'
  xmax='0'
  ymin='0'
  ymax='0'
  
  
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
  
  IF FILE_TEST(config.inputfile) THEN begin
    inputfile=config.inputfile
    flag_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.flag'
  endif
  
  config.workpath=workpath
  
  tlb=widget_base(title='TREE_CC',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  flag_fileID=widget_base(tlb,/row,xsize=xsize,frame=1)
  flag_file_tlb=widget_base(flag_fileID,row=1,tlb_frame_attr=1)
  flag_file_text=widget_text(flag_file_tlb,value=flag_file,uvalue=flag_file,uname='flag_file_text',/editable,xsize=63)
  flag_file_button=widget_button(flag_file_tlb,value='Input Flag File ',xsize=150,uname='flag_file_button')
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-16, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/3-10)
  width_label=widget_label(width_tlb,value='Width:',xsize=60,uname='width_button',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-16, frame=1)
  nlines_tlb=widget_base(tempID, /column, xsize=xsize/3-10)
  nlines_label=widget_label(nlines_tlb,value='Lines:',xsize=60,uname='nlines_label',/ALIGN_LEFT)
  nlines_text=widget_text(nlines_tlb,/editable,value=nlines,uvalue=nlines,uname='nlines_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-16, frame=1)
  mbl_tlb=widget_base(tempID,/column, xsize=xsize/3-10)
  mbl_label=widget_label(mbl_tlb,value='maximum branch length',xsize=350,uname='mbl_label',/ALIGN_LEFT)
  mbl_text=widget_text(mbl_tlb,/editable,value='32',uvalue='32',uname='mbl_text')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  xmin_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  xmin_label=widget_label(xmin_tlb,value='Xmin:',xsize=45,uname='xmin_label',/ALIGN_LEFT)
  xmin_text=widget_text(xmin_tlb,/editable,xsize=5,value=xmin,uvalue=xmin,uname='xmin_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  xmax_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  xmax_label=widget_label(xmax_tlb,value='Xmax:',xsize=45,uname='xmax_label',/ALIGN_LEFT)
  xmax_text=widget_text(xmax_tlb,/editable,xsize=5,value=xmax,uvalue=xmax,uname='xmax_text')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  ymin_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  ymin_label=widget_label(ymin_tlb,value='Ymin:',xsize=45,uname='label',/ALIGN_LEFT)
  ymin_text=widget_text(ymin_tlb,/editable,xsize=5,value=ymin,uvalue=ymin,uname='ymin_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  ymax_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  ymax_label=widget_label(ymax_tlb,value='Ymax:',xsize=45,uname='ymax_label',/ALIGN_LEFT)
  ymax_text=widget_text(ymax_tlb,/editable,xsize=5,value=ymax,uvalue=ymax,uname='ymax_text')
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
;  temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={ mbl_text:mbl_text,$
    parlabel:parlabel,$
    xmin_text:xmin_text,$
    xmax_text:xmax_text,$
    ymin_text:ymin_text,$
    ymax_text:ymax_text,$
    nlines_text:nlines_text,$
    flag_file_text:flag_file_text,flag_file_button:flag_file_button,$
    ok:ok,cl:cl,width_text:width_text}
    
    
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_tree_cc',tlb,/no_block
END