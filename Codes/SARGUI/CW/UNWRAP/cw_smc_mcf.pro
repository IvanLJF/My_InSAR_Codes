PRO CW_SMC_MCF_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  uname=widget_info(event.id,/uname)
  Case uname OF
    'interf_button': begin
      infile=dialog_pickfile(title='open interferogram',filter='*.filt',/read,/must_exist, path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
      workpath=config.workpath
      inputfile=config.inputfile
      
      IF FILE_TEST(config.m_rslc) THEN begin
      
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
        cc_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
        mask_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.mask_thinned.ras'
        unw_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.unw_thinned'
      endif
      
      widget_control,(*pstate).roff_text,get_value=roff,set_uvalue=roff
      widget_control,(*pstate).loff_text,set_uvalue=loff,get_uvalue=loff
      nr=strcompress(long(width)-long(roff))
      nlines=strcompress(long(lines)-long(loff))
      r_init=roff
      az_init=roff
      widget_control,(*pstate).r_init_text,set_value=r_init,set_uvalue=r_init
      widget_control,(*pstate).az_init_text,set_value=az_init,set_uvalue=az_init
      widget_control,(*pstate).interf_text,set_value=infile,set_uvalue=infile
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).lines_text,set_value=lines,set_uvalue=lines
      widget_control,(*pstate).nr_text,set_value=nr,set_uvalue=nr
      widget_control,(*pstate).nlines_text,set_value=nlines,set_uvalue=nlines
      widget_control, (*pstate).unw_out_text, set_value=unw_out, set_uvalue=unw_out
      widget_control, (*pstate).cc_file_text, set_value=cc_file,set_uvalue=cc_file
      widget_control, (*pstate).mask_file_text, set_value=mask_file,set_uvalue=mask_file
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
      
    end
    
    'cc_file_button': begin
      infile=dialog_pickfile(title='open coherence file',filter='*.cc',/read,/must_exist, path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).cc_file_text,set_value=infile
      widget_control,(*pstate).cc_file_text,set_uvalue=infile
      
    end
    
    
    'mask_file_button': begin
      infile=dialog_pickfile(title='open the mask file',filter='*.ras',/read,/must_exist, path=config.workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).mask_file_text,set_value=infile
      widget_control,(*pstate).mask_file_text,set_uvalue=infile
    end
    
    
    'unw_out_button': begin
    
      widget_control,(*pstate).interf_text,get_value=interf
      IF NOT FILE_TEST(interf) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Interferometric File ']
        return
      endif
      
      widget_control,(*pstate).cc_file_text,get_value=cc_file
      IF NOT FILE_TEST(cc_file) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Interferometric Correlation File ']
        return
      endif
      
      
      temp=file_basename(cc_file)
      temp=strsplit(temp, '.' ,/extract)
      unw_out=temp(0)
      
      file=unw_out+'.unw_thinned'
      
      infile=dialog_pickfile(title='output unwrapped phase image',filter='*.flt.filt.unw_thinned',file=file,/write,/overwrite_prompt, path=config.workpath)
      
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).unw_out_text,set_value=infile
      widget_control,(*pstate).unw_out_text,set_uvalue=infile
      
    end
    
    'ok':begin
    
    widget_control,(*pstate).cc_file_text,get_uvalue=cc_file
    IF NOT FILE_TEST(cc_file) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Interferometric Correlation File ']
      return
    endif
    
    widget_control,(*pstate).interf_text,get_uvalue=interf
    IF NOT FILE_TEST(interf) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Interferometric File ']
      return
    endif
    
    widget_control,(*pstate).mask_file_text,get_uvalue=mask_file
    IF NOT FILE_TEST(mask_file) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Mask File ']
      return
    endif
    
    widget_control,(*pstate).unw_out_text,get_uvalue=unw_out
    IF unw_out EQ '' THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please select The Unwrapped  OutputFile ']
      return
    endif
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Width ']
      return
    endif
    
    widget_control,(*pstate).roff_text,get_value=roff
    roff=long(roff)
    if roff lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Offset To Starting Range Of Section To Unwrap Error ']
      return
    endif
    
    widget_control,(*pstate).loff_text,get_value=loff
    loff=long(loff)
    if loff lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Offset To Starting Line Of Section To Unwrap Error ']
      return
    endif
    
    widget_control,(*pstate).nr_text,get_value=nr
    nr=long(nr)
    if nr lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Offset To Starting Samples Of Section To Unwrap Error ']
      return
    endif
    
    widget_control,(*pstate).nlines_text,get_value=nlines
    nlines=long(nlines)
    if nlines lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Number of Lines To Display']
      return
    endif
    
    widget_control,(*pstate).npat_r_text,get_value=npat_r
    npat_r=float(npat_r)
    if npat_r le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Number of Patches In Range']
      return
    endif
    
    widget_control,(*pstate).npat_az_text,get_value=npat_az
    npat_az=float(npat_az)
    if npat_az le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Number of Patches In Azimuth']
      return
    endif
    
    widget_control,(*pstate).ovrlap_text,get_value=ovrlap
    ovrlap=float(ovrlap)
    if ovrlap lt 7 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Overlap Between Patches In Pixels']
      return
    endif
    
    widget_control,(*pstate).r_init_text,get_value=r_init
    r_init=float(r_init)
    if r_init lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Phase Reference Point Range Offset Error']
      return
    endif
    
    widget_control,(*pstate).az_init_text,get_value=az_init
    az_init=float(az_init)
    if az_init lt 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Phase Reference Point Azimuth Offset Error']
      return
    endif
    tri_mode=WIDGET_INFO((*pstate).tri_mode_text,/droplist_select)
    tri_mode=STRCOMPRESS(tri_mode ,/REMOVE_ALL)
    
    if tri_mode eq 0 then begin
      tri_mode='1'
    endif else begin
      tri_mode='0'
    endelse
    
    init_flag=WIDGET_INFO((*pstate).init_flag_text,/droplist_select)
    init_flag=STRCOMPRESS(init_flag ,/REMOVE_ALL)
    
    
    width=strcompress(width,/remove_all)
    tri_mode=strcompress(tri_mode,/remove_all)
    roff=strcompress(roff,/remove_all)
    nlines=strcompress(nlines,/remove_all)
    loff=strcompress(loff,/remove_all)
    nr=strcompress(nr,/remove_all)
    npat_r=strcompress(npat_r,/remove_all)
    npat_az=strcompress(npat_az,/remove_all)
    ovrlap=strcompress(ovrlap,/remove_all)
    r_init=strcompress(r_init,/remove_all)
    az_init=strcompress(az_init,/remove_all)
    
    scr="mcf "+interf+" "+cc_file+" "+mask_file+" "+unw_out+" "+width+" "+tri_mode+" "+roff+" "+loff+" "+nr+" "+nlines+" "+npat_r+" "+$
      npat_az+" "+ovrlap+" "+r_init+" "+az_init+" "+init_flag
    tli_smc_spawn, scr ,info='Phase Unwrapping Using Minimum Cost Flow, Please wait...',/supress
    ras_unw="rasrmg "+unw_out+" - "+width
    tli_smc_spawn, ras_unw ,info=' Ras Unwrapped Image, Please wait...'
  end
  
  
  'cl':begin
  
  widget_control,event.top,/destroy
  
end

else: begin
  return
end
endcase

END



PRO cw_smc_mcf,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=630
  
  ; Get config info
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  width='0'
  lines='0'
  nr='0'
  nlines='0'
  
  IF FILE_TEST(config.m_rslc) THEN begin
  
    m_rslc=config.m_rslc
    pwr_file=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
    
    parfile=pwr_file+'.par'
    parlab='Par file:'+STRING(10b)+parfile
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    lines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
    nr=width
    nlines=lines
  endif
  
  IF FILE_TEST(config.inputfile) THEN begin
    inputfile=config.inputfile
    interf=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
    cc_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
    mask_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.mask_thinned.ras'
    unw_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.unw_thinned'
  endif
  
  
  tlb=widget_base(title='SASMAC_MCF',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  ; inID=widget_base(tlb,/row,xsize=xsize,frame=1)
  ;input=widget_text(inID,value=inputfile,uvalue=inputfile,uname='input',/editable,xsize=73)
  ;openinput=widget_button(inID,value='Input SLC',uname='openinput',xsize=90)
  
  interf_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  interf_text=widget_text(interf_tlb,/editable,xsize=70,value=interf,uvalue=interf,uname='interf_text')
  interf_button=widget_button(interf_tlb,value='Input Interf',xsize=110,uname='interf_button')
  
  cc_file_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  cc_file_text=widget_text(cc_file_tlb,/editable,xsize=70,value=cc_file,uvalue=cc_file,uname='cc_file_text')
  cc_file_button=widget_button(cc_file_tlb,value='Input cc_file',xsize=110,uname='cc_file_button')
  
  
  mask_file_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  mask_file_text=widget_text(mask_file_tlb,/editable,xsize=70,value=mask_file,uvalue=mask_file,uname='mask_file_text')
  mask_file_button=widget_button(mask_file_tlb,value='Input Mask File',xsize=110,uname='mask_file_button')
  
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  ; Basic information extracted from par file
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/3-20)
  width_label=widget_label(width_tlb,value='Width:',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,/editable,xsize=10,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  lines_tlb=widget_base(tempID,/column,xsize=xsize/3-20)
  lines_label=widget_label(lines_tlb,value='Lines:',/ALIGN_LEFT)
  lines_text=widget_text(lines_tlb,value=lines,uvalue=lines,uname='lines_text',/editable,xsize=10)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  ovrlap_tlb=widget_base(tempID,/column,xsize=xsize/3-10)
  ovrlap_label=widget_label(ovrlap_tlb,value='Ovrlap Between Patches:',/ALIGN_LEFT)
  ovrlap_text=widget_text(ovrlap_tlb,value='512',uvalue='512',uname='ovrlap_text',/editable,xsize=5)
  
  
  
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  roff_tlb=widget_base(tempID,/column,xsize=xsize/4-10)
  roff_lable=widget_label(roff_tlb,value='Range Offset:',/ALIGN_LEFT)
  roff_text=widget_text(roff_tlb,value='0',uvalue='0',uname='roff_text',/editable,xsize=5)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  loff_tlb=widget_base(tempID,/column,xsize=xsize/4-10)
  loff_label=widget_label(loff_tlb,value='Line Offset:',/ALIGN_LEFT)
  loff_text=widget_text(loff_tlb,value='0',uvalue='0',uname='loff_text',/editable,xsize=5)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  nr_tlb =widget_base(tempID,/column,xsize=xsize/4-10)
  nr_label=widget_label(nr_tlb,value='Width To Unwrap:',/ALIGN_LEFT)
  nr_text=widget_text(nr_tlb,value=nr,uvalue=nr,uname='nr_text',/editable,xsize=5)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  nlines_tlb=widget_base(tempID,/column,xsize=xsize/4-10)
  nlines_label=widget_label(nlines_tlb,value='Lines To Unwrp:',/ALIGN_LEFT)
  nlines_text=widget_text(nlines_tlb,value=nlines,uvalue=nlines,uname='nlines_text',/editable,xsize=10)
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  npat_r_tlb=widget_base(tempID,/column,xsize=xsize/4-10)
  npat_r_label=widget_label(npat_r_tlb,value='Npat_r:',xsize=50,/ALIGN_LEFT)
  npat_r_text=widget_text(npat_r_tlb,value='1',uvalue='1',uname='npat_r_text',/editable,xsize=5)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  npat_az_tlb=widget_base(tempID,/column,xsize=xsize/4-10)
  npat_az_label=widget_label(npat_az_tlb,value='Npat_az:',xsize=50,/ALIGN_LEFT)
  npat_az_text=widget_text(npat_az_tlb,value='1',uvalue='1',uname='npat_az_text',/editable,xsize=5)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  r_init_tlb=widget_base(tempID,/column,xsize=xsize/4-10)
  r_init_label=widget_label(r_init_tlb,value='R_init:',xsize=50,/ALIGN_LEFT)
  r_init_text=widget_text(r_init_tlb,value='0',uvalue='0',uname='r_init_text',/editable,xsize=5)
  
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  az_init_tlb=widget_base(tempID,/column,xsize=xsize/2-10)
  az_init_label=widget_label(az_init_tlb,value='Az_init:',xsize=50,/ALIGN_LEFT)
  az_init_text=widget_text(az_init_tlb,value='0',uvalue='0',uname='az_init_text',/editable,xsize=5)
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  init_flag_tlb=widget_base(tempID,/column,xsize=xsize/2-10)
  init_flag_label=widget_label(init_flag_tlb,value='Init_flag:',xsize=65,/ALIGN_LEFT)
  init_flag_text=widget_droplist(init_flag_tlb,value=['0: use initial point phase value',$
    '1: set phase to 0.0 at initial point'])
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  tri_mode__tlb=widget_base(tempID,/column,xsize=xsize/2-10)
  tri_mode_label=widget_label(tri_mode__tlb,value='Tri_mode:',xsize=60,/ALIGN_LEFT)
  tri_mode_text=widget_droplist(tri_mode__tlb,value=['0: Delaunay triangulation           ',$
    '1: filled triangular mesh     '])
    
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
  
  
  state={cc_file_text:cc_file_text,cc_file_button:cc_file_button,$
    interf_text:interf_text,interf_button:interf_button,$
    unw_out_text:unw_out_text,unw_out_button:unw_out_button,$
    width_text:width_text,$
    lines_text:lines_text,$
    roff_text:roff_text,$
    loff_text:loff_text,$
    nlines_text:nlines_text,$
    nr_text:nr_text,$
    npat_r_text:npat_r_text,$
    npat_az_text:npat_az_text,$
    ovrlap_text:ovrlap_text,$
    r_init_text:r_init_text,$
    az_init_text:az_init_text,$
    init_flag_text:init_flag_text,$
    tri_mode_text:tri_mode_text,$
    mask_file_text:mask_file_text,mask_file_button:mask_file_button,$
    parlabel:parlabel}
    
    
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_mcf',tlb,/no_block
END