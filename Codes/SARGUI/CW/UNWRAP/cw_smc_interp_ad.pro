PRO CW_SMC_INTERP_AD_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  uname=widget_info(event.id,/uname)
  
  Case uname OF
  
 'data_in_button': begin
      infile=dialog_pickfile(title='open interferogram',filter='*.unw_thinned',/read,/must_exist, path=config.workpath)
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
      data_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.unw_thinned'
       data_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.unw_interp'
      endif
  
      widget_control,(*pstate).data_in_text,set_value=infile
      widget_control,(*pstate).data_in_text,set_uvalue=infile
      widget_control,(*pstate).width_text,set_value=width
      widget_control,(*pstate).width_text,set_uvalue=width
      widget_control,(*pstate).lines_text,set_value=lines
      widget_control,(*pstate).lines_text,set_uvalue=lines
      widget_control, (*pstate).data_out_text, set_value=data_out, set_uvalue=data_out
      widget_control, (*pstate).parlabel, set_value='Parameter File:'+parfile, set_uvalue=parfile

end


 'data_out_button': begin
          
      widget_control,(*pstate).data_in_text,get_value=data_in
      IF NOT FILE_TEST(data_in) THEN begin
        TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Data With Gaps ']
        return
      endif
      
      
      temp=file_basename(data_in)
      temp=strsplit(temp, '.' ,/extract)
      data_out=temp(0)
      
      file=data_out+'.unw_interp'
      
      infile=dialog_pickfile(title='output data',filter='*.unw_interp',file=file,/write,/overwrite_prompt)
      
     IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).data_out_text,set_value=infile
      widget_control,(*pstate).data_out_text,set_uvalue=infile
      
    end
    
    'ok':begin
    
    widget_control,(*pstate).data_in_text,get_uvalue=data_in
    IF NOT FILE_TEST(data_in) THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Data With Gaps ']
      return
    endif
    
   
    widget_control,(*pstate).data_out_text,get_uvalue=data_out
    IF data_out eq '' THEN begin
      TLI_SMC_DUMMY, inputstr=['Error!', 'Please select the interpolated data']
      return
    endif
        
    widget_control,(*pstate).width_text,get_value=width
    width=long(width)
    if width le 0 then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Width']
      return
    endif
    
    widget_control,(*pstate).r_max_text,get_value=r_max
    r_max=long(r_max)
    if r_max lt 0 then begin
         TLI_SMC_DUMMY, inputstr=['Error!', 'Maximum Interpolatinon Window Radius Error']
      return
    endif
    
    widget_control,(*pstate).np_min_text,get_value=np_min
    np_min=long(np_min)
    if np_min le 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Minimum Number Of Points Used For The Interpolation Error']
      return
    endif
    
    widget_control,(*pstate).np_max_text,get_value=np_max
    np_max=float(np_max)
    if np_max le 0 then begin
    TLI_SMC_DUMMY, inputstr=['Error!', 'Maximum Number Of Points Used For The Interpolation Error']
    return
    endif
    
 
    w_mode=WIDGET_INFO((*pstate).w_mode_text,/droplist_select)
    w_mode=STRCOMPRESS(w_mode ,/REMOVE_ALL)
   if w_mode eq 0 then begin
    w_mode='2'
     endif else if w_mode eq 1 then begin
      w_mode='0'
      endif else if w_mode eq 2 then begin
        w_mode='1'
        endif else begin
          w_mode='3'
      endelse
    
     type=WIDGET_INFO((*pstate).type_text,/droplist_select)
    type=STRCOMPRESS(type ,/REMOVE_ALL)
    if type eq 0 then begin
     type='2'
     endif else if type eq 1 then begin
      type='0'
      endif else if type eq 2 then begin
        type='1'
        endif else begin
          type='3'
      endelse
    
   cp_data=WIDGET_INFO((*pstate).cp_data_text,/droplist_select)
    cp_data=STRCOMPRESS(cp_data ,/REMOVE_ALL)
    
    if cp_data eq 0 then begin
     cp_data='1'
        endif else begin
          type='0'
      endelse
    
    width=strcompress(width,/remove_all)
    r_max=strcompress(r_max,/remove_all)
    np_min=strcompress(np_min,/remove_all)
     np_max=strcompress(np_max,/remove_all)
    w_mode=strcompress(w_mode,/remove_all)
    type=strcompress(type,/remove_all)
    cp_data=strcompress(cp_data,/remove_all)

    scr="interp_ad "+data_in+" "+data_out+" "+width+" "+r_max+" "+np_min+" "+np_max+" "+w_mode+" "+type+" "+cp_data
 tli_smc_spawn, scr ,info='Weighted interpolation of gaps in 2D data, Please wait...'
    
  end

 'cl':begin

    widget_control,event.top,/destroy

end

else: begin
  return
end
endcase

END

PRO cw_smc_interp_ad,EVENT

   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=530
  
  ; Get config info
  workpath='/00'
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
    pwr_file=workpath+'/'+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
      parfile=pwr_file+'.par'
      parlab='Par file:'+parfile
      finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    lines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
        endif
    
      IF FILE_TEST(config.inputfile) THEN begin
      inputfile=config.inputfile
      workpath=config.workpath
      data_in=workpath+'/'+TLI_FNAME(inputfile, /remove_all_suffix)+'.flt.filt.unw_thinned'
       data_out=workpath+'/'+TLI_FNAME(inputfile, /remove_all_suffix)+'.unw_interp'
     endif
  
  tlb=widget_base(title='SASMAC_INTERP_AD',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
 ; inID=widget_base(tlb,/row,xsize=xsize,frame=1)
  ;input=widget_text(inID,value=inputfile,uvalue=inputfile,uname='input',/editable,xsize=73)
  ;openinput=widget_button(inID,value='Input SLC',uname='openinput',xsize=90)
  
 data_in_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
 data_in_text=widget_text(data_in_tlb,/editable,xsize=65,value=data_in,uvalue=data_in,uname='data_in_text')
 data_in_button=widget_button(data_in_tlb,value='Input data with gaps',xsize=140,uname='data_in_button')
  
  
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
  width_text=widget_text(width_tlb,/editable,xsize=10,value=width,uvalue=width,uname='width_text')
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
   lines_tlb=widget_base(tempID,/column,xsize=xsize/2-20)
   lines_label=widget_label(lines_tlb,value='Lines:',/ALIGN_LEFT)
  lines_text=widget_text(lines_tlb,value=lines,uvalue=lines,uname='lines_text',xsize=10)
  
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
    
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
 r_max_tlb=widget_base(tempID,/column,xsize=xsize/3-10)
 r_max_lable=widget_label(r_max_tlb,value='R_max:',/ALIGN_LEFT)
 r_max_text=widget_text(r_max_tlb,value='32',uvalue='32',uname='r_max_text',/editable,xsize=5)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
 np_min_tlb=widget_base(tempID,/column,xsize=xsize/3-10)
   np_min_label=widget_label(np_min_tlb,value='Np_min:',xsize=50,/ALIGN_LEFT)
 np_min_text=widget_text(np_min_tlb,value='8',uvalue='8',uname='np_min_text',/editable,xsize=5)

    
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
   np_max_tlb=widget_base(tempID,/column,xsize=xsize/3-10)
   np_max_label=widget_label(np_max_tlb,value='Np_max:',xsize=50,/ALIGN_LEFT)
  np_max_text=widget_text(np_max_tlb,value='16',uvalue='16',uname='np_max_text',/editable,xsize=5)
  
  
    labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3*2-20, frame=1)
  w_mode_tlb=widget_base(tempID,/row,xsize=xsize)
  w_mode_label=widget_label(w_mode_tlb,value='Data Weighting Mode:',/ALIGN_LEFT)
  w_mode_text=widget_droplist(w_mode_tlb,value=['0: 1 - (r/r_max)**2       ',$
                                                                                                           '1: constant',$
                                                                                                           '2: 1 - (r/r_max)**2',$
                                                                                                            '3: exp(-2.*(r**2/r_max**2))']) 
  

    
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  type_tlb=widget_base(tempID,/row,xsize=xsize/3-0)
   type_label=widget_label(type_tlb,value='Data Type:',xsize=60,/ALIGN_LEFT)
    type_text=widget_droplist(type_tlb,value=['0: FLOAT   ',$
                                                                                             '1: FCOMPLEX',$
                                                                                             '2: SCOMPLEX',$
                                                                                             '3: INT',$
                                                                                              '4: SHORT']) 
    
   labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
      tempID=widget_base(infoID,/row,xsize=xsize-30, frame=1)
     cp_data_tlb=widget_base(tempID,/row,xsize=xsize)
     cp_data_label=widget_label(cp_data_tlb,value='Copy Data Flag:',xsize=100,/ALIGN_LEFT)
    cp_data_text=widget_droplist(cp_data_tlb,value=['0:Copy Input Data Values To Output',$
                                                                                                           '1:  Do Not Copy Input Data Values To Output'])

  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  data_out_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
  data_out_text=widget_text(data_out_tlb,/editable,xsize=65,value=data_out,uvalue=data_out,uname='data_out_text')
  data_out_button=widget_button(data_out_tlb,value='Output filled data ',xsize=140,uname='data_out_button')
  
;  ; non exclusive box
;  temp=widget_base(TLB,tab_mode=1,/column,/nonexclusive)
;  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
    
  state={ data_in_text:data_in_text,data_in_button:data_in_button,$
              data_out_text:data_out_text,data_out_button:data_out_button,$
              width_text:width_text,$
              lines_text:lines_text,$
             r_max_text:r_max_text,$
              np_min_text:np_min_text,$
             w_mode_text:w_mode_text,$
             np_max_text:np_max_text,$
             type_text:type_text,$
             cp_data_text:cp_data_text,$
                         parlabel:parlabel}
    
  pstate=ptr_new(state)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'cw_smc_interp_ad',tlb,/no_block
END