  pro cw_smc_base_perp_event,EVENT
  
   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
   
  widget_control,event.top,get_uvalue=pstate
  
  workpath=config.workpath
  
  uname=widget_info(event.id,/uname)
  
  case uname of

    'base_in_button': begin

   infile=dialog_pickfile(title='Open baseline file',filter='*.base',/read, /must_exist,path=config.workpath)
      
    IF NOT FILE_TEST(infile) THEN return   
      
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
       
    workpath=config.workpath
       
      IF FILE_TEST(config.inputfile) THEN begin
  inputfile=config.inputfile
   base_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.base'
  off=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.off'
  base_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.base.perp'
  endif

       IF FILE_TEST(config.m_rslc) THEN begin
       m_rslc=config.m_rslc
       parfile=m_rslc+'.par'
       finfo=TLI_LOAD_SLC_PAR(parfile)
      width=finfo.range_samples
       width=strcompress(width,/remove_all)
      lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
      parlab='Par file:'+parfile
     endif
    
              
      widget_control,(*pstate).width_text,set_value=width,set_uvalue=width
      widget_control,(*pstate).lines_text,set_value=lines,set_uvalue=lines
       widget_control,(*pstate).off_text,set_value=off,set_uvalue=off
      widget_control,(*pstate).base_in_text,set_value=infile,set_uvalue=infile
      widget_control,(*pstate).base_out_text,set_value=base_out,set_uvalue=base_out
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile
    end

          'm_slc_button': begin
            infile=config.m_rslc
          infile=dialog_pickfile(title='open master slc par:',filter='*.rslc, *.slc',/read,/must_exist,path=config.workpath)
     
    IF NOT FILE_TEST(infile) THEN return
      TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
            
       workpath=config.workpath
        inputfile=config.inputfile
       config.m_rslc=infile
      widget_control,(*pstate).m_slc_text,set_value=infile
      widget_control,(*pstate).m_slc_text,set_uvalue=infile
     end
    
      'off_button': begin
    infile=dialog_pickfile(title='open off file:',filter='*.off',/read,/must_exist,path=config.workpath)
      
   IF NOT FILE_TEST(infile) THEN return
     widget_control,(*pstate).off_text,set_value=infile
     widget_control,(*pstate).off_text,set_uvalue=infile
     end
    
   'base_out_button': begin
          
      widget_control,(*pstate).base_in_text,get_value=base_in
      
         IF NOT FILE_TEST(base_in) THEN begin
          TLI_SMC_DUMMY, inputstr=['Error!', 'please input the correct base']
          return
      endif
      
      
      temp=file_basename(base_in)
      temp=strsplit(temp, '.' ,/extract)
      base_out=temp(0)
      
      file=base_out+'.base.perp'
      
      infile=dialog_pickfile(title='output data',filter='*.base.perp',file=file,/write,/overwrite_prompt, path=config.workpath)
      
   IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).base_out_text,set_value=infile
      widget_control,(*pstate).base_out_text,set_uvalue=infile
      
    end
    
    'ok':begin
    
    widget_control,(*pstate).base_in_text,get_uvalue=base_in
   IF NOT FILE_TEST(base_in) THEN begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'input the correct data ']
      return
    endif
     
     widget_control,(*pstate).off_text,get_uvalue=off
   IF NOT FILE_TEST(off) THEN begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'please input the correct off file ']
      return
    endif
     
      widget_control,(*pstate).m_slc_text,get_uvalue=m_slc
      IF NOT FILE_TEST(m_slc) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'please input the correct master slc file ']
          return
    endif
     
     
    widget_control,(*pstate).base_out_text,get_uvalue=base_out
   if base_out EQ '' then begin
     TLI_SMC_DUMMY, inputstr=['Error!', 'Please Choose The Base Perp Output']
      return
    endif
        
        scr="base_perp "+base_in+" "+m_slc+".par  "+off +"  > "+base_out
        tli_smc_spawn,scr,info='Calculate baseline components perpendicular , Please wait...'
    
          end

 'cl':begin

    widget_control,event.top,/destroy
 
end

else: begin
  return
end
endcase

END
PRO cw_smc_base_perp,EVENT

   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=410
  
  ; Get config info
  workpath=config.workpath
  inputfile=''
  parfile=''
  m_slc=''
  base_in=''
  base_out=''
  parlab='Par file not found'
  width='0'
  lines='0'
  base_in=''
  off=''
  base_out=''
 ;  s_rslc=config.s_rslc  
   IF FILE_TEST(config.inputfile) THEN begin
  inputfile=config.inputfile
   base_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.base'
  off=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.off'
  base_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.base.perp'
  endif

       IF FILE_TEST(config.m_rslc) THEN begin
       m_rslc=config.m_rslc
       parfile=m_rslc+'.par'
       finfo=TLI_LOAD_SLC_PAR(parfile)
      width=finfo.range_samples
       width=strcompress(width,/remove_all)
      lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
      parlab='Par file:'+parfile
     endif

  tlb=widget_base(title='SASMAC_Base_Perp',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
 ; inID=widget_base(tlb,/row,xsize=xsize,frame=1)
  ;input=widget_text(inID,value=inputfile,uvalue=inputfile,uname='input',/editable,xsize=73)
  ;openinput=widget_button(inID,value='Input SLC',uname='openinput',xsize=90)
  
  base_in_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  base_in_text=widget_text(base_in_tlb,/editable,xsize=70,value=base_in,uvalue=base_in,uname='base_in_text')
  base_in_button=widget_button(base_in_tlb,value='Input Base',xsize=110,uname='base_in_button')
  
   m_slc_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
   m_slc_text=widget_text(m_slc_tlb,/editable,xsize=70,value=m_rslc,uvalue=m_rslc,uname='m_slc_text')
   m_slc_button=widget_button(m_slc_tlb,value='Input SLC',xsize=110,uname='m_slc_button')
  
   off_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
    off_text=widget_text(off_tlb,/editable,xsize=70,value= off,uvalue= off,uname='off_text')
    off_button=widget_button(off_tlb,value='Input Off file',xsize=110,uname='off_button')
  
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
  
  
   tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  width_tlb=widget_base(tempID, /column, xsize=xsize/2-20)
  width_label=widget_label(width_tlb,value='Width:',/ALIGN_LEFT)
  width_text=widget_text(width_tlb,xsize=10,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
   lines_tlb=widget_base(tempID,/column,xsize=xsize/2-20)
   lines_label=widget_label(lines_tlb,value='Lines:',/ALIGN_LEFT)
  lines_text=widget_text(lines_tlb,value=lines,uvalue=lines,uname='lines_text',xsize=10)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  base_out_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  base_out_text=widget_text(base_out_tlb,/editable,xsize=70,value=base_out,uvalue=base_out,uname='base_out_text')
  base_out_button=widget_button(base_out_tlb,value='Output Base Perp',xsize=110,uname='base_out_button')

;     ; non exclusive box
;  temp=widget_base(TLB,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  
  state={ base_in_text:base_in_text,base_in_button:base_in_button,$
               m_slc_text:m_slc_text,m_slc_button:m_slc_button,$
               off_text:off_text,off_button:off_button,$
              base_out_text:base_out_text,base_out_button:base_out_button,$
              width_text:width_text,$
              lines_text:lines_text,$
              parlabel:parlabel}
     
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_base_perp',tlb,/no_block
END