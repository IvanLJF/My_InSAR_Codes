pro cw_smc_adf_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  uname=widget_info(event.id,/uname)
  
  case uname of
  
    'int_in_button': begin
    
      infile=dialog_pickfile(title='open interferoferogram',filter='*.int.flt',/read,/must_exist, path=config.workpath)
      
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
        int_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.int.filt'
        sm_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
        cc_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
      endif
      
      widget_control,(*pstate).int_in_text,set_value=infile,set_uvalue=infile
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).nlines_text,set_value=lines,set_uvalue=lines
      widget_control, (*pstate).sm_out_text, set_value=sm_out, set_uvalue=sm_out
      widget_control, (*pstate).cc_out_text, set_value=cc_out, set_uvalue=cc_out
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
    end
    
    'cc_out_button': begin
    
      widget_control,(*pstate).int_in_text,get_value=int_in
      
      IF NOT FILE_TEST(int_in) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'please input the interferferogram ']
        return
      endif
      
      temp=file_basename(int_in)
      temp=strsplit(temp, '.' ,/extract)
      interf=temp(0)
      
      file=interf+'.filt.cc'
      
      infile=dialog_pickfile(title='output adf',filter='*.filt.cc',file=file,/write,/overwrite_prompt, path=config.workpath)
      IF infile EQ '' THEN RETURN
      widget_control,(*pstate).cc_out_text,set_value=infile
      widget_control,(*pstate).cc_out_text,set_uvalue=infile
      
    end
    
    'sm_out_button': begin
    
      widget_control,(*pstate).int_in_text,get_value=int_in
      
      IF NOT FILE_TEST(int_in) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the  interferferogram ']
        return
      endif
      
      
      temp=file_basename(int_in)
      temp=strsplit(temp, '.' ,/extract)
      interf=temp(0)
      
      file=interf+'.flt.filt'
      
      infile=dialog_pickfile(title='output adf',filter='*.flt.filt',file=file,/write,/overwrite_prompt, path=config.workpath)
      
      IF infile EQ '' THEN return
      widget_control,(*pstate).sm_out_text,set_value=infile
      widget_control,(*pstate).sm_out_text,set_uvalue=infile
      
    end
    
    
    'ok':begin
    
    widget_control,(*pstate).int_in_text,get_uvalue=int_in
    IF NOT FILE_TEST(int_in) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the  interferferogram ']
      return
    endif
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct width ']
      return
    endif
    
    widget_control,(*pstate).alpha_text,get_value=alpha
    alpha=float(alpha)
    if alpha le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct  alpha ']
      return
    endif
    
    widget_control,(*pstate).nfft_text,get_value=nfft
    nfft=long(nfft)
    if nfft le 0 or (nfft mod 2) ne 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct  filterfing FFT widow size ']
      return
    endif
    
    widget_control,(*pstate).cc_win_text,get_value=cc_win
    cc_win=long(cc_win)
    if cc_win le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct  coherence parameter estimatino window size ']
      return
    endif
    
    widget_control,(*pstate).step_text,get_value=step
    step=long(step)
    if step le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct  processing step ']
      return
    endif
    
    widget_control,(*pstate).loff_text,get_value=loff
    loff=long(loff)
    if loff lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct  offset to starting lines to process ']
      return
    endif
    
    widget_control,(*pstate).nlines_text,get_value=nlines
    nlines=long(nlines)
    if nlines lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct number of lines to process']
      return
    endif
    
    widget_control,(*pstate).wfrac_text,get_value=wfrac
    wfrac=float(wfrac)
    if wfrac le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct wfrac']
      return
    endif
    
    temp=WIDGET_INFO((*pstate).times_text, /droplist_select)
    Case temp OF
      '0': times=3
      '1': times=1
      '2': times=2
      else:
    ENDCASE
    
    widget_control,(*pstate).sm_out_text,get_value=sm_out
    IF NOT FILE_TEST(sm_out) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the correct times to filter']
      return
      
      openw,lun,sm_out,/get_lun
      printerff,lun,sm_out
      free_lun,lun
    endif
    
    widget_control,(*pstate).cc_out_text,get_value=cc_out
    IF NOT FILE_TEST(cc_out) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the Output file']
      return
      
    endif
    
    
    ;数值转字符串
    alpha=strcompress(alpha,/remove_all)
    nfft=strcompress(nfft,/remove_all)
    cc_win=strcompress(cc_win,/remove_all)
    step=strcompress(step,/remove_all)
    loff=strcompress(loff,/remove_all)
    nlines=strcompress(nlines,/remove_all)
    wfrac=strcompress(wfrac,/remove_all)
    width=strcompress(width,/remove_all)
    
    ; tli_smc_spawn, scr ,info='Subtract interferogram flat-Earth phase trend, Please wait...'
    Case times OF
      1: BEGIN
        scr="adf "+int_in+" "+sm_out+" "+cc_out+" "+width+" "+alpha+" "+nfft+" "+cc_win+" "+step+" "+loff+" "+nlines+" "+wfrac
        tli_smc_spawn, scr ,info=' Adaptive spectral filtering, Please wait...'
      END
      2: BEGIN
        scr="adf "+int_in+" "+sm_out+" "+cc_out+" "+width+" "+alpha+" "+nfft+" "+cc_win+" "+step+" "+loff+" "+nlines+" "+wfrac
        tli_smc_spawn, scr ,info='Step 1/3: Adaptive spectral filtering, Please wait...',/supress
        ;file_copy,sm_out,interf
        nfft='64'
        (*pstate).int_in_text=(*pstate).sm_out_text
        scr="adf "+int_in+" "+sm_out+" "+cc_out+" "+width+" "+alpha+" "+nfft+" "+cc_win+" "+step+" "+loff+" "+nlines+" "+wfrac
        tli_smc_spawn, scr ,info='Step 2/3: Adaptive spectral filtering, Please wait...'
      END
      3: BEGIN
        scr="adf "+int_in+" "+sm_out+" "+cc_out+" "+width+" "+alpha+" "+nfft+" "+cc_win+" "+step+" "+loff+" "+nlines+" "+wfrac
        tli_smc_spawn, scr ,info='Step 1/3: Adaptive spectral filtering, Please wait...',/supress
        ;file_copy,sm_out,interf
        nfft='64'
        (*pstate).int_in_text=(*pstate).sm_out_text
        scr="adf "+int_in+" "+sm_out+" "+cc_out+" "+width+" "+alpha+" "+nfft+" "+cc_win+" "+step+" "+loff+" "+nlines+" "+wfrac
        tli_smc_spawn, scr ,info='Step 2/3: Adaptive spectral filtering, Please wait...',/supress
        nfft='32'
        scr="adf "+int_in+" "+sm_out+" "+cc_out+" "+width+" "+alpha+" "+nfft+" "+cc_win+" "+step+" "+loff+" "+nlines+" "+wfrac
        tli_smc_spawn, scr ,info='Step 3/3: Adaptive spectral filtering, Please wait...'
      END
      
    ENDCASE
    
    config.inputfile=sm_out
    ras_sm="rasmph "+sm_out+" "+width
    spawn,ras_sm
    ras_cc="rascc "+cc_out+" - "+width
    spawn,ras_cc
  end
  
  
  'cl':begin
  
  widget_control,event.top,/destroy
  
end

else: begin
  return
end
endcase

END

PRO cw_smc_adf,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=520
  
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  width='0'
  nlines='0'
  alpha='0.5'
  loff='0'
  wfrac='0.7'
  nfft='128'
  cc_win='7'
  step='4'
  times=['3          ','1          ','2          ']
  int_in=''
  sm_out=''
  cc_out=''
  
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
    int_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.int.filt'
    sm_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
    cc_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
  endif
  
  tlb=widget_base(title='SASMAC_ADF',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  int_in_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  int_in_tlb=widget_base(int_in_ID,row=1,tlb_frame_attr=1)
  int_in_text=widget_text(int_in_tlb,value=int_in,uvalue=int_in,/editable,xsize=63,uname='int_in_text')
  int_in_button=widget_button(int_in_tlb,value='Input interferogram',xsize=150,uname='int_in_button')
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/3-10)
  width_label=widget_label(width_tlb,value='Width:',xsize=45,uname='width_button',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  nlines_tlb=widget_base(tempID, /column, xsize=xsize/3-10)
  nlines_label=widget_label(nlines_tlb,value='Lines:',xsize=45,uname='nlines_label',/ALIGN_LEFT)
  nlines_text=widget_text(nlines_tlb,/editable,value=lines,uvalue=lines,uname='nlines_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  times_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  times_label=widget_label(times_tlb,value='Filtering Times:',uname='times_label',/ALIGN_LEFT)
  times_text=widget_droplist(times_tlb,xsize=5,value=times,uvalue=times,uname='times_text')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  alpha_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  alpha_label=widget_label(alpha_tlb,value='Alpha:',xsize=45,uname='alpha_label',/ALIGN_LEFT)
  alpha_text=widget_text(alpha_tlb,/editable,xsize=5,value=alpha,uvalue=alpha,uname='alpha_text')
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  nfft_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  nfft_label=widget_label(nfft_tlb,value='NFFT:',xsize=45,uname='nfft_label',/ALIGN_LEFT)
  nfft_text=widget_text(nfft_tlb,/editable,xsize=5,value=nfft,uvalue=nfft,uname='nfft_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  cc_win_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  cc_win_label=widget_label(cc_win_tlb,value='CC_Win:',xsize=45,uname='cc_win_label',/ALIGN_LEFT)
  cc_win_text=widget_text(cc_win_tlb,/editable,xsize=5,value=cc_win,uvalue=cc_win,uname='cc_win_text')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  step_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  step_label=widget_label(step_tlb,value='Step:',xsize=45,uname='label',/ALIGN_LEFT)
  step_text=widget_text(step_tlb,/editable,xsize=5,value=step,uvalue=step,uname='step_text')
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  loff_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  loff_label=widget_label(loff_tlb,value='Loff:',xsize=45,uname='loff_label',/ALIGN_LEFT)
  loff_text=widget_text(loff_tlb,/editable,xsize=5,value=loff,uvalue=loff,uname='loff_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  wfrac_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  wfrac_label=widget_label(wfrac_tlb,value='Wfrac:',xsize=45,uname='wfrac_label',/ALIGN_LEFT)
  wfrac_text=widget_text(wfrac_tlb,/editable,xsize=5,value= wfrac,uvalue= wfrac,uname='wfrac_text')
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  
  sm_outID=widget_base(tlb,/row,xsize=xsize,frame=1)
  sm_out_tlb=widget_base(sm_outID,row=1,tlb_frame_attr=1)
  sm_out_text=widget_text(sm_out_tlb,value=sm_out,uvalue=sm_out,uname='sm_out_text',/editable,xsize=63)
  sm_out_button=widget_button(sm_out_tlb,value='Output smoothed interf',xsize=150,uname='sm_out_button')
  
  cc_outID=widget_base(tlb,/row,xsize=xsize,frame=1)
  cc_out_tlb=widget_base(cc_outID,row=1,tlb_frame_attr=1)
  cc_out_text=widget_text(cc_out_tlb,value=cc_out,uvalue=cc_out,uname='cc_out_text',/editable,xsize=63)
  cc_out_button=widget_button(cc_out_tlb,value='Output Coherence file',xsize=150,uname='cc_out_button')
  
  
  
  ;  temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
  ;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={int_in_text:int_in_text,int_in_button:int_in_button,alpha_text:alpha_text,$
    nfft_text:nfft_text,cc_win_text:cc_win_text,$
    parlabel:parlabel,$
    step_text:step_text,wfrac_text:wfrac_text,$
    loff_text:loff_text,nlines_text:nlines_text,$
    sm_out_text:sm_out_text,sm_out_button:sm_out_button,$
    cc_out_text:cc_out_text,cc_ou_button:cc_out_button,$
    ok:ok,cl:cl,width_text:width_text,times_text:times_text}
    
    
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_adf',tlb,/no_block
END