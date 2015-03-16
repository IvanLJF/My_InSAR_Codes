@ tli_format_convert
  pro cw_smc_gamma2snaphu_int_event,EVENT
  
   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
   
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
  
    'data_in_button': begin
      infile=dialog_pickfile(title='open data ',filter='*.flt.filt',/read,/must_exist, path=config.workpath)
      
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
      data_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
      data_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.swap'
      endif
     
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).lines_text,set_value=lines,set_uvalue=lines
      widget_control,(*pstate).data_in_text,set_value=infile,set_uvalue=infile
      widget_control,(*pstate).data_out_text,set_value=data_out,set_uvalue=data_out
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
     end
    
    
    'data_out_button': begin
          
      widget_control,(*pstate).data_in_text,get_value=data_in
      IF NOT FILE_TEST(data_in) THEN begin
          TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Data_In']
        return
      endif
      
      
      temp=file_basename(data_in)
      temp=strsplit(temp, '.' ,/extract)
      data_out=temp(0)
      
      file=data_out+'.flt.filt.swap'
      
      infile=dialog_pickfile(title='output data',filter='*.flt.filt.swap',file=file,/write,/overwrite_prompt, path=config.workpath)
      
    IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).data_out_text,set_value=infile
      widget_control,(*pstate).data_out_text,set_uvalue=infile
      
    end
    
    'ok':begin
    
    widget_control,(*pstate).data_in_text,get_uvalue=data_in
    IF NOT FILE_TEST(data_in) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Data_In']
      return
    endif
    
   
    widget_control,(*pstate).data_out_text,get_uvalue=data_out
    IF NOT FILE_TEST(data_out) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Data_Out']
      return
    endif
        
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Width']
      return
    endif
    
   
    width=strcompress(width,/remove_all)
   
      scr="swap_bytes "+data_in+" "+data_out+" 4"
       tli_smc_spawn, scr ,info='Convert Int_File Gamma To Snaphu, Please wait...'
   ;  tli_format_convert,data_in,width,'float',output_format='alt_line_data',/input_swap_endian

 ;  scr="snaphu "+data_in+" "+data_out+" "+width+" "+r_max+" "+np_min+" "+np_max+" "+w_mode+" "+type+" "+cp_data
   ; spawn,scr
    
  end

 'cl':begin

    widget_control,event.top,/destroy
 
end

else: begin
  return
end
endcase

END
PRO cw_smc_gamma2snaphu_int,EVENT

   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=310
  
  ; Get config info
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  width='0'
  lines='0'
    data_in=''
  data_out=''
  
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
      data_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt'
       data_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.swap'
     endif

  
  tlb=widget_base(title='SASMAC_GAMMA2SNAPHU_INT',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
 ; inID=widget_base(tlb,/row,xsize=xsize,frame=1)
  ;input=widget_text(inID,value=inputfile,uvalue=inputfile,uname='input',/editable,xsize=73)
  ;openinput=widget_button(inID,value='Input SLC',uname='openinput',xsize=90)
  
  data_in_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  data_in_text=widget_text(data_in_tlb,/editable,xsize=70,value=data_in,uvalue=data_in,uname='data_in_text')
  data_in_button=widget_button(data_in_tlb,value='Input Data',xsize=110,uname='data_in_button')
  
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
   
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  data_out_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  data_out_text=widget_text(data_out_tlb,/editable,xsize=70,value=data_out,uvalue=data_out,uname='data_out_text')
  data_out_button=widget_button(data_out_tlb,value='Output Data',xsize=110,uname='data_out_button')
   ; non exclusive box
;  temp=widget_base(TLB,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  
  state={ data_in_text:data_in_text,data_in_button:data_in_button,$
              data_out_text:data_out_text,data_out_button:data_out_button,$
              width_text:width_text,$
              lines_text:lines_text,$
              parlabel:parlabel}
     
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_gamma2snaphu_int',tlb,/no_block
END