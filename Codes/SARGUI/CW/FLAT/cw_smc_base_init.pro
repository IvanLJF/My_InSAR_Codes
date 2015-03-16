pro cw_smc_base_init_event,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  workpath=config.workpath
  
  uname=widget_info(event.id,/uname)
  
  case uname of
  
    'm_rslc_button': begin
      infile=dialog_pickfile(title='open master slc par',filter=['*.rslc, *.slc'],/read,/must_exist,path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      widget_control,(*pstate).m_rslc_text,set_value=infile
      widget_control,(*pstate).m_rslc_text,set_uvalue=infile
    end
    
    's_rslc_button': begin
      m_rslc=config.inputfile
      infile=dialog_pickfile(title='open master slc par',filter='*.rslc, *.slc',/read,/must_exist,path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      
      workpath=config.workpath
      inputfile=config.inputfile
      parfile=inputfile+'.par'
      finfo=TLI_LOAD_SLC_PAR(parfile)
      
      width=finfo.range_samples
      for i=0,16 do begin
      
        if width le 2^i and width ge 2^(i-1)then begin
          nrfft=2^(i-2)
          nazfft=nrfft
          r_samp=nrfft/2
          az_line=r_samp
        endif
        
      endfor
      
      width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
      lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
      nrfft=STRCOMPRESS(nrfft,/REMOVE_ALL)
      nazfft=STRCOMPRESS(nazfft,/REMOVE_ALL)
      r_samp=strcompress(r_samp,/REMOVE_ALL)
      az_line=strcompress(az_line,/REMOVE_ALL)
      
      config.s_rslc=infile
      base_out=workpath+TLI_FNAME(m_rslc, /nosuffix)+'-'+TLI_FNAME(infile, /nosuffix)+'.base'
      interf=workpath+TLI_FNAME(m_rslc, /nosuffix)+'-'+TLI_FNAME(infile, /nosuffix)+'.int'
      off=workpath+TLI_FNAME(m_rslc, /nosuffix)+'-'+TLI_FNAME(infile, /nosuffix)+'.off'
      
      widget_control,(*pstate).s_rslc_text,set_value=infile,set_uvalue=infile
      widget_control,(*pstate).off_text,set_value=off,set_uvalue=off
      widget_control,(*pstate).interf_text,set_value=interf,set_uvalue=interf
      widget_control,(*pstate).base_out_text,set_value=base_out,set_uvalue=base_out
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).lines_text,set_uvalue=lines,set_value=lines
      widget_control,(*pstate).nrfft_text,set_uvalue=nrfft,set_value=nrfft
      widget_control,(*pstate).nazfft_text,set_value=nazfft,set_uvalue=nazfft
      widget_control,(*pstate).r_samp_text,set_value=r_samp,set_uvalue=r_samp
      widget_control,(*pstate).az_line_text,set_value=az_line,set_uvalue=az_line
      
    end
    
    
    'off_button': begin
      infile=dialog_pickfile(title='open offset/interferogram parameter file',filter='*.off',/read,/must_exist,path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).off_text,set_value=infile
      widget_control,(*pstate).off_text,set_uvalue=infile
    end
    
    'interf_button': begin
      infile=dialog_pickfile(title='open unflatrened interferogram',filter='*.int',/read,/must_exist,path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).interf_text,set_value=infile
      widget_control,(*pstate).interf_text,set_uvalue=infile
    end
    
    'base_out_button':begin
    
    widget_control,(*pstate).m_rslc_text,get_value=m_rslc
    IF NOT FILE_TEST(m_rslc) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the master slc par ']
      return
    endif
    
    widget_control,(*pstate). s_rslc_text,get_value= s_rslc
    IF NOT FILE_TEST(s_rslc) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the slave slc par ']
      return
    endif
    
    workpath=config.workpath
    file=TLI_FNAME(m_rslc, /nosuffix)+'-'+TLI_FNAME(s_rslc, /nosuffix)+'.base'
    infile=dialog_pickfile(title='output base file',filter='*.base',file=file,/write,/overwrite_prompt,path=config.workpath)
    
    IF NOT FILE_TEST(infile) THEN return
    widget_control,(*pstate).base_out_text,set_value=infile
    widget_control,(*pstate).base_out_text,set_uvalue=infile
    
  end
  
  'ok':begin
  
  widget_control,(*pstate).m_rslc_text,get_value=m_rslc
  IF NOT FILE_TEST(m_rslc) THEN begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the master slc par ']
    return
  endif
  
  widget_control,(*pstate). s_rslc_text,get_value= s_rslc
  IF NOT FILE_TEST(s_rslc) THEN begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the slave slc par ']
    return
  endif
  
  widget_control,(*pstate).off_text,get_value=off
  IF NOT FILE_TEST(off) THEN begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the off file ']
    return
  endif
  
  widget_control,(*pstate).width_text,get_value=width
  width=long(width)
  if width le  0 then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please input correct width ']
    return
  endif
  
  widget_control,(*pstate).lines_text,get_value=lines
  lines=long(lines)
  if lines lt  0  then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please input correct lines ']
    return
  endif
  
  widget_control,(*pstate).interf_text,get_value=interf
  IF NOT FILE_TEST(interf) THEN begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the unflattened interferogram ']
    return
  endif
  
  widget_control,(*pstate).nrfft_text,get_value=nrfft
  nrfft=long(nrfft)
  if nrfft le 0 then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'size of range FFT error ']
    return
  endif
  
  widget_control,(*pstate).nazfft_text,get_value=nazfft
  nazfft=long(nazfft)
  if nazfft lt 0 then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'size of azimuth FFT error ']
    return
  endif
  
  widget_control,(*pstate).r_samp_text,get_value=r_samp
  r_samp=long(r_samp)
  if r_samp lt 0 then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'range pixel offsets to center of the FFT window error ']
    return
  endif
  
  widget_control,(*pstate).az_line_text,get_value=az_line
  az_line=long(az_line)
  if az_line lt 0 then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'azimuth pixel offsets to center of the FFT window error ']
    return
  endif
  
  widget_control,(*pstate).base_out_text,get_value=base_out
  if base_out eq '' then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the output file ']
    return
  endif
  
  mflag=WIDGET_INFO((*pstate).mflag_text,/droplist_select)
  mflag=strcompress(mflag,/remove_all)
  nrfft=strcompress(nrfft,/remove_all)
  nazfft=strcompress(nazfft,/remove_all)
  az_line=strcompress(az_line,/remove_all)
  r_samp=strcompress(r_samp,/remove_all)
  
  if mflag eq 0 then begin
    scr="base_init "+m_rslc+".par "+s_rslc+".par - - "+base_out+" "+mflag+" "+nrfft+" "+nazfft+" "+r_samp+" " +az_line
    print,scr
    tli_smc_spawn, scr,info='Estimate Initial Baseline, Please wait...'
  endif else  if mflag eq 1 then begin
    scr="base_init "+m_rslc+".par  "+s_rslc+".par "+off+" - "+base_out+" "+mflag+" "+nrfft+" "+nazfft+" "+r_samp+" " +az_line
    tli_smc_spawn, scr,info='Estimate Initial Baseline, Please wait...'
  ; print,scr
  endif else  if mflag eq 2 then begin
    scr="base_init "+m_rslc+".par  "+s_rslc+".par "+off+" "+interf+" "+base_out+" "+mflag+" "+nrfft+" "+nazfft+" "+r_samp+" " +az_line
    tli_smc_spawn, scr,info='Estimate Initial Baseline, Please wait...'
    print,scr
  endif else if mflag eq 3  then begin
    scr="base_init "+m_rslc+".par  "+s_rslc+".par "+off+" "+interf+" "+base_out+" "+mflag+" "+nrfft+" "+nazfft+" "+r_samp+" " +az_line
    tli_smc_spawn, scr,info='Estimate Initial Baseline, Please wait...'
  endif else if mflag eq 4  then begin
    scr="base_init "+m_rslc+".par  "+s_rslc+".par "+off+" "+interf+" "+base_out+" "+mflag+" "+nrfft+" "+nazfft+" "+r_samp+" " +az_line
    tli_smc_spawn, scr,info='Estimate Initial Baseline, Please wait...'
    
  endif else begin
  endelse
  config.inputfile=base_out
end

'cl':begin


widget_control,event.top,/destroy

end

else: begin
  return
end
endcase

END



PRO cw_smc_base_init,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=580
  
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  width='0'
  lines='0'
  nrfft='1024'
  nazfft='1024'
  
  
  
  
  IF FILE_TEST(config.m_rslc) THEN begin
    m_rslc=config.m_rslc
    
    parfile=m_rslc+'.par'
    finfo=TLI_LOAD_SLC_PAR(parfile)
    
    width=finfo.range_samples
    
    for i=0,16 do begin
    
      if width le 2^i and width ge 2^(i-1)then begin
        nrfft=2^(i-2)
        nazfft=nrfft
        r_samp=nrfft/2
        az_line=r_samp
        nrfft=strcompress(nrfft,/remove_all)
        nazfft=strcompress(nazfft,/remove_all)
        az_line=strcompress(az_line,/remove_all)
        r_samp=strcompress(r_samp,/remove_all)
        width=strcompress(width,/remove_all)
        lines=strcompress(finfo.azimuth_lines,/remove_all)
      endif
    endfor
    
    IF FILE_TEST(config.s_rslc) THEN begin
    
      s_rslc=config.s_rslc
      interf=workpath+TLI_FNAME(m_rslc, /nosuffix)+'-'+TLI_FNAME(s_rslc, /nosuffix)+'.int'
      off=workpath+TLI_FNAME(m_rslc, /nosuffix)+'-'+TLI_FNAME(s_rslc, /nosuffix)+'.off'
      outputfile=workpath+TLI_FNAME(m_rslc, /nosuffix)+'-'+TLI_FNAME(s_rslc, /nosuffix)+'.base'
    endif
  endif
  
  tlb=widget_base(title='SASMAC_Base_Init',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  mID=widget_base(tlb,/row,xsize=xsize,frame=1)
  m_rslc_tlb=widget_base(mID,row=1,tlb_frame_attr=1)
  m_rslc_text=widget_text(m_rslc_tlb,value=m_rslc,uvalue=m_rslc,/editable,xsize=70,uname='m_rslc_text')
  m_rslc_button=widget_button(m_rslc_tlb,value='Input m_rslc',xsize=110,uname='m_rslc_button')
  
  sID=widget_base(tlb,/row,xsize=xsize,frame=1)
  s_rslc_tlb=widget_base(sID,row=1,tlb_frame_attr=1)
  s_rslc_text=widget_text( s_rslc_tlb,/editable,xsize=70,value=s_rslc,uvalue=s_rslc,uname='s_rslc_text')
  s_rslc_button=widget_button( s_rslc_tlb,value='Input s_rslc',xsize=110,uname='s_rslc_button')
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off_tlb=widget_base(offID,row=1,tlb_frame_attr=1)
  off_text=widget_text(off_tlb,/editable,xsize=70,value=off,uvalue=off,uname='off_text')
  off_button=widget_button(off_tlb,value='Input offset par',xsize=110,uname='off_button')
  
  interfID=widget_base(tlb,/row,xsize=xsize,frame=1)
  interf_tlb=widget_base(interfID,row=1,tlb_frame_attr=1)
  interf_text=widget_text(interf_tlb,/editable,xsize=70,value=interf,uvalue=interf,uname='interf_text')
  interf_button=widget_button(interf_tlb,value='Input Interf',xsize=110,uname='interf_button')
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  
  ; Basic information extracted from par file
  
  labID=widget_base(tlb,/column,xsize=xsize)
  
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  width_label=widget_label(width_tlb,value='Width:',xsize=45,uname='width_button',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  lines_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
  lines_label=widget_label(lines_tlb,value='Lines:',xsize=45,uname='lines_label',/ALIGN_LEFT)
  lines_text=widget_text(lines_tlb,/editable,value=lines,uvalue=lines,uname='lines_text')
  
  temp=widget_base(tlb,/row,xsize=xsize,/frame)
  lab=widget_label(temp,value='Baseline Estimation Method: '+STRING(10b)+'(flag: b_para-b_perp [input])')
  
  
  
  mflag_text=widget_droplist(temp, value=[$
    '0: orbit-obit         [p1,p2] ',$
    '1: offsets-offsets    [p1,p2,off]',$
    '2: orbits-fft         [p1,p2,off,int]',$
    '3: offsets-fft        [p1,p2,off,int]',$
    '4: fft-fft            [p1,off,int]'])
    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  nrfftID=widget_base(tempID, /column, xsize=xsize/4-10)
  nrfft_label=widget_label(nrfftID,value='nrfft:',/ALIGN_LEFT)
  nrfft_text=widget_text(nrfftID,/editable,xsize=10,value=nrfft,uvalue=nrfft,uname='nrfft_text')
  ;  samples=widget_text(sampID,value=samples, uvalue=samples, uname='samples',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  nazfftID=widget_base(tempID, /column, xsize=xsize/4)
  nazfft_label=widget_label(nazfftID,value='nazfft:',/ALIGN_LEFT)
  nazfft_text=widget_text(nazfftID,/editable,value=nazfft,uvalue=nazfft,uname='nazfft_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  r_sampID=widget_base(tempID, /column, xsize=xsize/4-10)
  r_samp_label=widget_label(r_sampID,value='r_samp:',/ALIGN_LEFT)
  r_samp_text=widget_text(r_sampID,/editable,value=r_samp,uvalue=r_samp,uname='r_samp_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  az_lineID=widget_base(tempID, /column, xsize=xsize/4-10)
  az_line_label=widget_label(az_lineID,value='az_line:',/ALIGN_LEFT)
  az_line_text=widget_text(az_lineID,/editable,value=az_line,uvalue=az_line,uname='az_line_text')
  
  baseID=widget_base(tlb,/row,xsize=xsize,frame=1)
  base_out_tlb=widget_base(baseID,row=1,tlb_frame_attr=1)
  base_out_text=widget_text(base_out_tlb,value=outputfile,uvalue=outputfile,uname='base_out_text',/editable,xsize=70)
  base_out_button=widget_button(base_out_tlb,value='Output Base',uname='base_out_button',xsize=110)
  
;  ; non exclusive box
;  temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  
  
  state={m_rslc_text:m_rslc_text,m_rslc_button:m_rslc_button, $
    s_rslc_text: s_rslc_text, s_rslc_button: s_rslc_button,$
    width_text:width_text,$
    lines_text:lines_text,$
    off_button:off_button,off_text:off_text,$
    interf_text:interf_text,interf_button:interf_button,$
    mflag_text:mflag_text,$
    nrfft_text:nrfft_text,$
    nazfft_text:nazfft_text,$
    r_samp_text:r_samp_text,$
    az_line_text:az_line_text,$
    base_out_button:base_out_button,base_out_text:base_out_text,$
    ok:ok,cl:cl}
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_base_init',tlb,/no_block
END