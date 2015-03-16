pro cw_smc_neutron_event,EVENT

 COMMON TLI_SMC_GUI, types, file, wid, config, finfo
 
   widget_control,event.top,get_uvalue=pstate
   
  uname=widget_info(event.id,/uname)
  
    case uname of

'intensity_button': begin
  
      infile=dialog_pickfile(title='Open Image Intensity File',filter='*.pwr',/read,/must_exist, path=config.workpath)
    
      IF NOT FILE_TEST(infile) THEN return   
          
    widget_control,(*pstate).intensity_text,set_value=infile
    widget_control,(*pstate).intensity_text,set_uvalue=infile
          
end

  'flag_file_button': begin
      
     infile=dialog_pickfile(title='open flag file',filter='*.flt.filt.flag',/read,/must_exist, path=config.workpath)
  
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
   
       IF FILE_TEST(config.m_rslc) THEN begin
   workpath=config.workpath
     m_rslc=config.m_rslc
    intensity=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
 
     parfile=intensity+'.par'
      parlab='Par file:'+parfile
      finfo=TLI_LOAD_SLC_PAR(parfile)
      width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
      nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
      ymax=nlines
       endif
   
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).nlines_text,set_value=nlines,set_uvalue=nlines
       widget_control,(*pstate).ymax_text,set_value=ymax,set_uvalue=ymax
      widget_control, (*pstate).flag_file_text, set_value=infile
      widget_control, (*pstate).flag_file_text, set_uvalue=infile
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
         
      end

 'ok':begin
    
    widget_control,(*pstate).intensity_text,get_uvalue=intensity
     IF NOT FILE_TEST(intensity) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the correct correlation file ']

      return
    endif
    
    widget_control,(*pstate).flag_file_text,get_uvalue=flag_file
   IF NOT FILE_TEST(flag_file) THEN begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the phase unwrapping flag file ']
      return
    endif
    
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please choose the correct width ']
      return
    endif
    
    widget_control,(*pstate).n_thres_text,get_value=n_thres
    n_thres=float(n_thres)
    if n_thres le 0 then begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'please input the correct neutron threshold ']
      return
    endif
    
    
    widget_control,(*pstate).ymin_text,get_value=ymin
    ymin=float(ymin)
    if ymin lt 0 then begin
          TLI_SMC_DUMMY, inputstr=['Error!', 'please input the starting azimuth row offset']
      return
    endif
    
    widget_control,(*pstate).ymax_text,get_value=ymax
    ymax=float(ymax)
    if ymax le 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'please input the ast azimuth row offset']
      return
    endif
    
      width=strcompress(width,/remove_all)
       n_thres=strcompress(n_thres,/remove_all)
     ymin=strcompress(ymin,/remove_all)
      ymax=strcompress(ymax,/remove_all)
      config.inputfile=flag_file
    scr="neutron "+intensity+" "+flag_file+" "+width+" "+n_thres+" "+ymin+" "+ymin
   tli_smc_spawn, scr ,info='Generate Phase Unwrapping Neutrons, Please wait...'

  end

'cl':begin

      widget_control,event.top,/destroy

  end

else: begin
  return
end
endcase

END


PRO cw_smc_neutron,EVENT

   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
   

 device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=460
  
   workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  width='0'
 nlines='0'
intensity=''
flag_file=''
    
  IF FILE_TEST(config.inputfile) THEN begin
  inputfile=config.inputfile
  flag_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.flag'
endif

   IF FILE_TEST(config.m_rslc) THEN begin
     m_rslc=config.m_rslc
    intensity=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
    parfile=intensity+'.par'
      parlab='Par file:'+STRING(10b)+parfile
      finfo=TLI_LOAD_SLC_PAR(parfile)
      width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
   endif
  
  tlb=widget_base(title='SASMAC_NEUTRON',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 intensity_ID=widget_base(tlb,/row,xsize=xsize,frame=1)
 intensity_tlb=widget_base(intensity_ID,row=1,tlb_frame_attr=1)
 intensity_text=widget_text(intensity_tlb,value=intensity,uvalue=intensity,/editable,xsize=63,uname='intensity_text')
 intensity_button=widget_button(intensity_tlb,value='Input intensity file',xsize=150,uname='intensity_button')
  
   flag_fileID=widget_base(tlb,/row,xsize=xsize,frame=1)
  flag_file_tlb=widget_base(flag_fileID,row=1,tlb_frame_attr=1)
 flag_file_text=widget_text(flag_file_tlb,value=flag_file,uvalue=flag_file,uname='flag_file_text',/editable,xsize=63)
 flag_file_button=widget_button(flag_file_tlb,value='Intput Flag File ',xsize=150,uname='flag_file_button')
        
   temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
   
  labID=widget_base(tlb,/column,xsize=xsize)
 
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
 tempID=widget_base(infoID,/row,xsize=xsize/2-10, frame=1)
 width_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
 width_label=widget_label(width_tlb,value='Width:',xsize=45,uname='width_button',/ALIGN_LEFT)
 width_text=widget_text(width_tlb,/editable,value=width,uvalue=width,uname='width_text')

 tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
 nlines_tlb=widget_base(tempID, /column, xsize=xsize/2-10)
 nlines_label=widget_label(nlines_tlb,value='Lines:',xsize=45,uname='nlines_label',/ALIGN_LEFT)
 nlines_text=widget_text(nlines_tlb,/editable,value=nlines,uvalue=nlines,uname='nlines_text')
 
 infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize-20, frame=1)
  n_thres_tlb=widget_base(tempID,/row, xsize=xsize-10)
  n_thres_label=widget_label(n_thres_tlb,value='Neutron yhreshold, multiples of the average intensity',xsize=350,uname='n_thres_label',/ALIGN_LEFT)
  n_thres_text=widget_text(n_thres_tlb,/editable,xsize=27,value='6',uvalue='6',uname='neutron threshold')
 
 infoID=widget_base(labID,/row, xsize=xsize)
 tempID=widget_base(infoID,/row,xsize=xsize/2-10, frame=1)
  ymin_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  ymin_label=widget_label(ymin_tlb,value='Offset to Starting Azimuth Row:',xsize=200,uname='label',/ALIGN_LEFT)
  ymin_text=widget_text(ymin_tlb,/editable,xsize=5,value='0',uvalue='0',uname='ymin_text')

  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  ymax_tlb=widget_base(tempID,/column, xsize=xsize/2-10)
  ymax_label=widget_label(ymax_tlb,value='Offset to Last Azimuth Row:',xsize=200,uname='ymax_label',/ALIGN_LEFT)
  ymax_text=widget_text(ymax_tlb,/editable,xsize=5,value=nlines,uvalue=nlines,uname='ymax_text')
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  
;   temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
   
  state={intensity_text:intensity_text,intensity_button:intensity_button,$
      flag_file_text:flag_file_text,flag_file_button:flag_file_button,$
    parlabel:parlabel,$
     ok:ok,cl:cl,$
     n_thres_text:n_thres_text,$
     nlines_text:nlines_text,$
     width_text:width_text,$
    ymin_text:ymin_text,$
    ymax_text:ymax_text}
    
    
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_neutron',tlb,/no_block
END
  
  