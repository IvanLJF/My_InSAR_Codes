;   hgt_map,call the command of hgt_map in the GAMMA software
;     usage: hgt_map <unw> <SLC_par> <OFF_par> <baseline> <hgt> <gr> [ph_flag] [loff] [nlines] [SLC2R_par]
;       input parameters:
;           unw       (input) unwrapped interferometric phase
;           SLC_par   (input) ISP parameter file for the reference SLC
;           OFF_par   (input) ISP offset/interferogram processing parameters
;           baseline  (input) baseline parameter file
;           hgt       (output) height file (in slant range geometry) relative to WGS-84 ellipsoid
;           gr        (output) cross-track ground ranges on the WGS-84 ellipsoid (in slant range geometry)
;           ph_flag   restore phase slope flag (0:no phase change default=1:add back phase ramp)
;           loff      offset to starting line (default = 0)
;           nlines    number of lines to calculate (enter - for default: to end of file)
;           SLC2R_par (input) parameter file of resampled SLC,required if SLC-2 frequency differs from SLC-1
;
;    -   Done written by CWN in Sasmac
;    -   29/12/2014

PRO INSARGUI_HGTMAP_EVENT,EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  
  case uname of
    'unw_button':begin
    infile=dialog_pickfile(title='Please input unwrapped file',filter='*.unw',/read)
    if infile eq '' then return
      widget_control,(*pstate).unw_text,set_value=infile
      widget_control,(*pstate).unw_text,set_uvalue=infile
    end
    'masterpar_button':begin
    infile=dialog_pickfile(title='Please input master parfile',filter='*.pwr.par',/read) 
    if infile eq '' then return
      widget_control,(*pstate).masterpar_text,set_value=infile
      widget_control,(*pstate).masterpar_text,set_uvalue=infile
    end 
    'slavepar_button':begin
    infile=dialog_pickfile(title='Please input slave parfile',filter='*.pwr.par',/read)
    if infile eq '' then return
      widget_control,(*pstate).slavepar_text,set_value=infile
      widget_control,(*pstate).slavepar_text,set_uvalue=infile
    end
    'offset_button':begin
    infile=dialog_pickfile(title='Please input offset parfile',filter='*.off',/read)
    if infile eq '' then return
      widget_control,(*pstate).offset_text,set_value=infile
      widget_control,(*pstate).offset_text,set_uvalue=infile
    end
    'base_button':begin
    infile=dialog_pickfile(title='Please input baseline file',filter='*.base',/read)
    if infile eq '' then return
      widget_control,(*pstate).base_text,set_value=infile
      widget_control,(*pstate).base_text,set_uvalue=infile
    end
    
    'hgt_button':begin
    widget_control,(*pstate).unw_text,get_uvalue=unw
    if unw eq '' then begin
      result=dialog_message(title='unwrapped file','please input unwrapped file',/information)
      return
    endif
    widget_control,(*pstate).masterpar_text,get_uvalue=masterpar
    if masterpar eq '' then begin
      result=dialog_message(title='master parfile','please input master parfile',/information)
      return
    endif
    widget_control,(*pstate).slavepar_text,get_value=slavepar
    if slavepar ne '-' then begin
      if slavepar eq '' then begin
        result=dialog_message(title='slave parfile','please input slave parfile',/information)
        return
      endif
    endif
    widget_control,(*pstate).offset_text,get_uvalue=offset
    if offset eq '' then begin
      result=dialog_message(title='offset parfile','please input offset parfile',/information)
      return
    endif
    widget_control,(*pstate).base_text,get_uvalue=base
    if base eq '' then begin
      result=dialog_message(title='baseline file','please input baseline file',/information)
      return
    endif
    workpath=FILE_DIRNAME(unw)+PATH_SEP()
    temp=file_basename(unw)
    temp=strsplit(temp,'.',/extract)
    hgtfile=temp(0)
    file=hgtfile+'.hgt'
    infile=dialog_pickfile(title='output hegiht file',filter='*.hgt',path=workpath,file=file,/write,/overwrite_prompt)
    if infile eq '' then return
      widget_control,(*pstate).hgt_text,set_value=infile
      widget_control,(*pstate).hgt_text,set_uvalue=infile
    end
    
    'gr_button':begin
    widget_control,(*pstate).unw_text,get_uvalue=unw
    if unw eq '' then begin
      result=dialog_message(title='unwrapped file','please input unwrapped file',/information)
      return
    endif
    widget_control,(*pstate).masterpar_text,get_uvalue=masterpar
    if masterpar eq '' then begin
      result=dialog_message(title='master parfile','please input master parfile',/information)
      return
    endif
    widget_control,(*pstate).slavepar_text,get_value=slavepar
    if slavepar ne '-' then begin
      if slavepar eq '' then begin
        result=dialog_message(title='slave parfile','please input slave parfile',/information)
        return
      endif
    endif
    widget_control,(*pstate).offset_text,get_uvalue=offset
    if offset eq '' then begin
      result=dialog_message(title='offset parfile','please input offset parfile',/information)
      return
    endif
    widget_control,(*pstate).base_text,get_uvalue=base
    if base eq '' then begin
      result=dialog_message(title='baseline file','please input baseline file',/information)
      return
    endif
    workpath=FILE_DIRNAME(unw)+PATH_SEP()
    temp=file_basename(unw)
    temp=strsplit(temp,'.',/extract)
    hgtfile=temp(0)
    file=hgtfile+'.grd'
    infile=dialog_pickfile(title='output ground ranges file',filter='*.grd',path=workpath,file=file,/write,/overwrite_prompt)
    if infile eq '' then return
      widget_control,(*pstate).gr_text,set_value=infile
      widget_control,(*pstate).gr_text,set_uvalue=infile
    end
    
    'ok':begin
      if 1 then begin
        ;check input paramters
        widget_control,(*pstate).unw_text,get_uvalue=unw
        if unw eq '' then begin
          result=dialog_message(title='unw file','Please input unw file',/information)
          return
        endif
        widget_control,(*pstate).masterpar_text,get_uvalue=masterpar
        if masterpar eq '' then begin
          result=dialog_message(title='master parfile','Please input master parfile',/information)
          return
        endif
        widget_control,(*pstate).slavepar_text,get_value=slavepar
        if slavepar eq '' then begin
          result=dialog_message(title='slave parfile','Please input slave parfile',/information)
          return
        endif
        widget_control,(*pstate).offset_text,get_uvalue=offset
        if offset eq '' then begin
          result=dialog_message(title='offset file','Please input offset file',/information)
          return
        endif
        widget_control,(*pstate).base_text,get_uvalue=base
        if base eq '' then begin
          result=dialog_message(title='baseline file','Please input baseline file',/information)
          return
        endif
        
        widget_control,(*pstate).phflag_text,get_value=phflag
        if phflag ne '-' then begin
          phflag=long(phflag)
          if phflag ge 2 then begin
            result=dialog_message(title='restore phase slope flag','restore phase slope flag should be 0 or 1',/information)
            return
            widget_control,(*pstate).phflag_text,set_value=phflag
            widget_control,(*pstate).phflag_text,set_uvalue=phflag
          endif
        endif
        widget_control,(*pstate).loff_text,get_value=loff
        if loff ne '-' then begin
          loff=long(loff)
          if loff lt 0 then begin
            result=dialog_message(title='offset to starting line','offset to starting line should large than 0',/information)
            return
            widget_control,(*pstate).loff_text,set_value=loff
            widget_control,(*pstate).loff_text,set_uvalue=loff
          endif
        endif
        widget_control,(*pstate).nlines_text,get_value=nlines
        if nlines ne '-' then begin
          nlines=long(nlines)
          if nlines lt 0 then begin
            result=dialog_message(title='number of lines to calculate','number of lines to calculate should large than 0',/information)
            return
            widget_control,(*pstate).nlines_text,set_value=nlines
            widget_control,(*pstate).nlines_text,set_uvalue=nlines
          endif
        endif
        
        ;check output file parameters
        widget_control,(*pstate).hgt_text,get_uvalue=hgt
        if hgt eq '' then begin
          result=dialog_message(title='height file','Please input height file',/information)
          return
        endif
        widget_control,(*pstate).gr_text,get_uvalue=gr
        if gr eq '' then begin
          result=dialog_message(title='ground ranges file','Please input ground ranges file',/information)
          return
        endif        
      endif
      phflag=strcompress(string(phflag),/remove_all)
      loff=strcompress(string(loff),/remove_all)
      nlines=strcompress(string(nlines),/remove_all)

      wtlb = widget_base(title='process bar')
      widget_control,wtlb,/realize
      process = idlitwdprogressbar(group_leader=wtlb,time=0,title='processing...Please wait')
      idlitwdprogressbar_setvalue,process,0 ;-initialize the process bar,initial value=0
        scr='hgt_map '+unw+' '+masterpar+' '+offset+' '+base+' '+hgt+' '+gr+' '+phflag+' '+loff+' '+nlines+' '+slavepar
        spawn,scr
      idlitwdprogressbar_setvalue,process,100 ;finish
;      stop
    end      
      
    'cl':begin
    result=dialog_message('Sure exit?',title='Exit',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
    end
      else:begin
        return
    end     
  endcase

END
;-create the components
; input the paraments window
; deal with window
PRO INSARGUI_HGTMAP,EVENT

  ;Create components
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  tlb=widget_base(title='hgt_map',tlb_frame_attr=1,column=1,xsize=345,ysize=335,xoffset=xoffset,yoffset=yoffset)

  ;input window
  ;Create print flag input window
  inputID=widget_base(tlb,row=1)
  inputlabel=widget_label(inputID,value='input file:',/align_left,xsize=179)

  ;-Create unw input window
  unwID=widget_base(tlb,row=1)
  unw_text=widget_text(unwID,value='',uvalue='',uname='unw_text',/editable,xsize=37)
  unw_button=widget_button(unwID,value='Unwrapped',uname='unw_button',xsize=96)

  ;-Create master parfile input window
  masterparID=widget_base(tlb,row=1)
  masterpar_text=widget_text(masterparID,value='',uvalue='',uname='masterpar_text',/editable,xsize=37)
  masterpar_button=widget_button(masterparID,value='Master_par',uname='masterpar_button',xsize=96)
  
  ;-Create slave parfile input window
  slaveparID=widget_base(tlb,row=1)
  slavepar_text=widget_text(slaveparID,value='-',uvalue='',uname='slavepar_text',/editable,xsize=37)
  slavepar_button=widget_button(slaveparID,value='Slave_par',uname='slavepar_button',xsize=96)
  
  ;-Create offset parfile input window
  offsetID=widget_base(tlb,row=1)
  offset_text=widget_text(offsetID,value='',uvalue='',uname='offset_text',/editable,xsize=37)
  offset_button=widget_button(offsetID,value='OFF_par',uname='offset_button',xsize=96)
  
  ;-Create baseline file input window
  baseID=widget_base(tlb,row=1)
  base_text=widget_text(baseID,value='',uvalue='',uname='base_text',/editable,xsize=37)
  base_button=widget_button(baseID,value='Baseline',uname='base_button',xsize=96)

  ;-Create number of points used for the interpolation input window
  numID=widget_base(tlb,row=1)
  numlabel=widget_label(numID,value='ph_flag,loff,nlines:',/align_left,xsize=179)
  phflag_text=widget_text(numID,value='-',uvalue='',uname='phflag_text',/editable,xsize=5)
  loff_text=widget_text(numID,value='-',uvalue='',uname='loff_text',/editable,xsize=5)
  nlines_text=widget_text(numID,value='-',uvalue='',uname='nlines_text',/editable,xsize=5)

  ;-output window
  ;Create print flag input window
  outputID=widget_base(tlb,row=1)
  outputlabel=widget_label(outputID,value='output file:',/align_left,xsize=179)

  ;-Create height file input window
  hgtID=widget_base(tlb,row=1)
  hgt_text=widget_text(hgtID,value='',uvalue='',uname='hgt_text',/editable,xsize=37)
  hgt_button=widget_button(hgtID,value='hgt',uname='hgt_button',xsize=96)
  
  ;-Create cross-track ground ranges file input window
  grID=widget_base(tlb,row=1)
  gr_text=widget_text(grID,value='',uvalue='',uname='gr_text',/editable,xsize=37)
  gr_button=widget_button(grID,value='gr',uname='gr_button',xsize=96)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={unw_text:unw_text,unw_button:unw_button,masterpar_text:masterpar_text,masterpar_button:masterpar_button,offset_text:offset_text,$
    offset_button:offset_button,base_text:base_text,base_button:base_button,phflag_text:phflag_text,loff_text:loff_text,nlines_text:nlines_text,$
    hgt_text:hgt_text,hgt_button:hgt_button,gr_text:gr_text,gr_button:gr_button,slavepar_text:slavepar_text,slavepar_button:slavepar_button,ok:ok,cl:cl}

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'INSARGUI_HGTMAP',tlb,/no_block

END