;   res_map,call the command of res_map in the GAMMA software
;     usage: res_map <hgt> <gr> <data> <SLC_par> <OFF_par> <res_hgt> <res_data> [nr] [naz] [azps_res] [loff] [nlines] > <report_file>
;       input parameters:
;           hgt       (input) height file in slant range geometry
;           gr        (input) ground ranges file in slant range geometry       
;           data      (input) data file in slant range geometry (float) (intensity *.pwr or correlation *.cc)
;           SLC_par   (input) ISP parameter file for the reference SLC
;           OFF_par   (input) ISP offset/interferogram processing parameters
;           res_hgt   (output) resampled height file in ground range geometry
;           res_data  (output) resampled data file in ground range geometry
;           nr        number of range samples for L.S. estimate (default=7, must be odd)
;           naz       number of range samples for L.S. estimate (default=7, must be odd)
;           azps_res  azimuth output map samples spacing in meters (default=azimuth spacing)
;           loff      offset to starting lines for height calculations (default=0)
;           nlines    number of lines to calculate (default=to end of file)
;
;    -   Done written by CWN in Sasmac
;    -   30/12/2014

PRO INSARGUI_RESMAP_EVENT,EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)

  case uname of
    'hgt_button':begin
      infile=dialog_pickfile(title='Please input height file',filter='*.hgt',/read)
      if infile eq '' then return
        widget_control,(*pstate).hgt_text,set_value=infile
        widget_control,(*pstate).hgt_text,set_uvalue=infile
      end
    'gr_button':begin
      infile=dialog_pickfile(title='Please input ground ranges file',filter='*.pwr;*.cc',/read)
      if infile eq '' then return
        widget_control,(*pstate).gr_text,set_value=infile
        widget_control,(*pstate).gr_text,set_uvalue=infile
      end
    'data_button':begin
      infile=dialog_pickfile(title='Please input unwrapped file',filter='*.pwr',/read)
      if infile eq '' then return
        widget_control,(*pstate).data_text,set_value=infile
        widget_control,(*pstate).data_text,set_uvalue=infile
      end
    'masterpar_button':begin
      infile=dialog_pickfile(title='Please input master parfile',filter='*.pwr.par',/read)
      if infile eq '' then return
        widget_control,(*pstate).masterpar_text,set_value=infile
        widget_control,(*pstate).masterpar_text,set_uvalue=infile
      end
    'offset_button':begin
      infile=dialog_pickfile(title='Please input offset parfile',filter='*.off',/read)
      if infile eq '' then return
        widget_control,(*pstate).offset_text,set_value=infile
        widget_control,(*pstate).offset_text,set_uvalue=infile
      end
      
    'rhgt_button':begin
      widget_control,(*pstate).hgt_text,get_uvalue=hgt
      if hgt eq '' then begin
        result=dialog_message(title='height file','please input height file',/information)
        return
      endif
      widget_control,(*pstate).gr_text,get_uvalue=gr
      if gr eq '' then begin
        result=dialog_message(title='ground ranges file','please input ground ranges file',/information)
        return
      endif
      widget_control,(*pstate).data_text,get_uvalue=data
      if data eq '' then begin
        result=dialog_message(title='data file','please input data file',/information)
        return
      endif      
      widget_control,(*pstate).masterpar_text,get_uvalue=masterpar
      if masterpar eq '' then begin
        result=dialog_message(title='master parfile','please input master parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      workpath=FILE_DIRNAME(offset)+PATH_SEP()
      temp=file_basename(offset)
      temp=strsplit(temp,'.',/extract)
      rhgtfile=temp(0)
      file=rhgtfile+'.rhgt'
      infile=dialog_pickfile(title='output ground ranges file',filter='*.rhgt',path=workpath,file=file,/write,/overwrite_prompt)
      if infile eq '' then return
        widget_control,(*pstate).rhgt_text,set_value=infile
        widget_control,(*pstate).rhgt_text,set_uvalue=infile
      end 
    'rdata_button':begin
      widget_control,(*pstate).hgt_text,get_uvalue=hgt
      if hgt eq '' then begin
        result=dialog_message(title='height file','please input height file',/information)
        return
      endif
      widget_control,(*pstate).gr_text,get_uvalue=gr
      if gr eq '' then begin
        result=dialog_message(title='ground ranges file','please input ground ranges file',/information)
        return
      endif
      widget_control,(*pstate).data_text,get_uvalue=data
      if data eq '' then begin
        result=dialog_message(title='data file','please input data file',/information)
        return
      endif
      widget_control,(*pstate).masterpar_text,get_uvalue=masterpar
      if masterpar eq '' then begin
        result=dialog_message(title='master parfile','please input master parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      workpath=FILE_DIRNAME(masterpar)+PATH_SEP()
      temp=file_basename(masterpar)
      temp=strsplit(temp,'.',/extract)
      rhgtfile=temp(0)
      file=rhgtfile+'.grd'
      infile=dialog_pickfile(title='output ground ranges file',filter='*.grd',path=workpath,file=file,/write,/overwrite_prompt)
      if infile eq '' then return
      widget_control,(*pstate).rdata_text,set_value=infile
      widget_control,(*pstate).rdata_text,set_uvalue=infile
    end
    'rfile_button':begin
      widget_control,(*pstate).hgt_text,get_uvalue=hgt
      if hgt eq '' then begin
        result=dialog_message(title='height file','please input height file',/information)
        return
      endif
      widget_control,(*pstate).gr_text,get_uvalue=gr
      if gr eq '' then begin
        result=dialog_message(title='ground ranges file','please input ground ranges file',/information)
        return
      endif
      widget_control,(*pstate).data_text,get_uvalue=data
      if data eq '' then begin
        result=dialog_message(title='data file','please input data file',/information)
        return
      endif
      widget_control,(*pstate).masterpar_text,get_uvalue=masterpar
      if masterpar eq '' then begin
        result=dialog_message(title='master parfile','please input master parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      widget_control,(*pstate).rhgt_text,get_uvalue=rhgt
      if rhgt eq '' then begin
        result=dialog_message(title='resample height file','please input resample height file',/information)
        return
      endif
      widget_control,(*pstate).rdata_text,get_uvalue=rdata
      if rdata eq '' then begin
        result=dialog_message(title='data file','please input data file',/information)
        return
      endif
      workpath=FILE_DIRNAME(masterpar)+PATH_SEP()
      
      file='rhgt'+'.par'
      infile=dialog_pickfile(title='output report file',filter='*.par',path=workpath,file=file,/write,/overwrite_prompt)
      if infile eq '' then return
        widget_control,(*pstate).rfile_text,set_value=infile
        widget_control,(*pstate).rfile_text,set_uvalue=infile
      end
    'ok':begin
      ;check input file
      widget_control,(*pstate).hgt_text,get_uvalue=hgt
      if hgt eq '' then begin
        result=dialog_message(title='height file','please input height file',/information)
        return
      endif
      widget_control,(*pstate).gr_text,get_uvalue=gr
      if gr eq '' then begin
        result=dialog_message(title='ground ranges file','please input ground ranges file',/information)
        return
      endif
      widget_control,(*pstate).data_text,get_uvalue=data
      if data eq '' then begin
        result=dialog_message(title='data file','please input data file',/information)
        return
      endif
      widget_control,(*pstate).masterpar_text,get_uvalue=masterpar
      if masterpar eq '' then begin
        result=dialog_message(title='master parfile','please input master parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      
      widget_control,(*pstate).nr_text,get_value=nr
      if nr ne '-' then begin
        nr=long(nr)
        if nr lt 0 then begin
          result=dialog_message(title='number of range samples for L.S. estimation','number of range samples for L.S. estimation should large than 0',/information)
          return
          widget_control,(*pstate).nr_text,set_value=nr
          widget_control,(*pstate).nr_text,set_uvalue=nr
        endif
      endif     
      widget_control,(*pstate).naz_text,get_value=naz
      if naz ne '-' then begin
        naz=long(naz)
        if naz lt 0 then begin
          result=dialog_message(title='number of azimuth samples for L.S. estimation','number of azimuth samples for L.S. estimation should large than 0',/information)
          return
          widget_control,(*pstate).naz_text,set_value=naz
          widget_control,(*pstate).naz_text,set_uvalue=naz
        endif
      endif
      widget_control,(*pstate).azps_text,get_value=azps
      if azps ne '-' then begin
        azps=long(azps)
        if azps lt 0 then begin
          result=dialog_message(title='azimuth output map sample','azimuth output map sample should large than 0',/information)
          return
          widget_control,(*pstate).azps_text,set_value=azps
          widget_control,(*pstate).azps_text,set_uvalue=azps
        endif
      endif
      widget_control,(*pstate).loff_text,get_value=loff
      if loff ne '-' then begin
        loff=long(loff)
        if loff lt 0 then begin
          result=dialog_message(title='offset to start line','offset to start line should large than 0',/information)
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
      
      ;check output file
      widget_control,(*pstate).rhgt_text,get_uvalue=rhgt
      if rhgt eq '' then begin
        result=dialog_message(title='resample height file','please input resample height file',/information)
        return
      endif
      widget_control,(*pstate).rdata_text,get_uvalue=rdata
      if rdata eq '' then begin
        result=dialog_message(title='data file','please input data file',/information)
        return
      endif
      widget_control,(*pstate).rfile_text,get_uvalue=rfile
      if rfile eq '' then begin
        result=dialog_message(title='report file','please input report file',/information)
        return
      endif
      
      nr=strcompress(string(nr),/remove_all)
      naz=strcompress(string(naz),/remove_all)
      azps=strcompress(string(azps),/remove_all)
      loff=strcompress(string(loff),/remove_all)
      nlines=strcompress(string(nlines),/remove_all)

      wtlb = widget_base(title='process bar')
      widget_control,wtlb,/realize
      process = idlitwdprogressbar(group_leader=wtlb,time=0,title='processing...Please wait')
      idlitwdprogressbar_setvalue,process,0 ;-initialize the process bar,initial value=0
        scr='res_map '+hgt+' '+gr+' '+data+' '+masterpar+' '+offset+' '+rhgt+' '+rdata+' '+nr+' '+naz+' '+azps+' '+loff+' '+nlines+' > '+rfile
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
PRO INSARGUI_RESMAP,EVENT

  ;Create components
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  tlb=widget_base(title='res_map',tlb_frame_attr=1,column=1,xsize=445,ysize=535,xoffset=xoffset,yoffset=yoffset)

  ;input window
  ;Create print flag input window
  inputID=widget_base(tlb,row=1)
  inputlabel=widget_label(inputID,value='input file:',/align_left,xsize=179)

  ;-Create height input window
  hgtID=widget_base(tlb,row=1)
  hgt_text=widget_text(hgtID,value='',uvalue='',uname='hgt_text',/editable,xsize=37)
  hgt_button=widget_button(hgtID,value='hgt',uname='hgt_button',xsize=96)

  ;-Create ground range file input window
  grdID=widget_base(tlb,row=1)
  gr_text=widget_text(grdID,value='',uvalue='',uname='gr_text',/editable,xsize=37)
  gr_button=widget_button(grdID,value='grd',uname='gr_button',xsize=96)
  
  ;-Create data input window
  dataID=widget_base(tlb,row=1)
  data_text=widget_text(dataID,value='',uvalue='',uname='data_text',/editable,xsize=37)
  data_button=widget_button(dataID,value='data',uname='data_button',xsize=96)
  
  ;-Create master parfile input window
  masterparID=widget_base(tlb,row=1)
  masterpar_text=widget_text(masterparID,value='',uvalue='',uname='masterpar_text',/editable,xsize=37)
  masterpar_button=widget_button(masterparID,value='Master_par',uname='masterpar_button',xsize=96)

  ;-Create offset parfile input window
  offsetID=widget_base(tlb,row=1)
  offset_text=widget_text(offsetID,value='',uvalue='',uname='offset_text',/editable,xsize=37)
  offset_button=widget_button(offsetID,value='OFF_par',uname='offset_button',xsize=96)

  ;-Create number of points used for the interpolation input window
  numID=widget_base(tlb,row=1)
  numlabel=widget_label(numID,value='samples for L.S.(range,azimuth):',/align_left,xsize=199)
  nr_text=widget_text(numID,value='-',uvalue='',uname='nr_text',/editable,xsize=5)
  naz_text=widget_text(numID,value='-',uvalue='',uname='naz_text',/editable,xsize=5)
  
  ;-Create number of points used for the interpolation input window
  azpsID=widget_base(tlb,row=1)
  azpslabel=widget_label(azpsID,value='azps_res,loff,nlines:',/align_left,xsize=199)
  azps_text=widget_text(azpsID,value='-',uvalue='',uname='azps_text',/editable,xsize=5)
  loff_text=widget_text(azpsID,value='-',uvalue='',uname='loff_text',/editable,xsize=5)
  nlines_text=widget_text(azpsID,value='-',uvalue='',uname='nlines_text',/editable,xsize=5)

  ;-output window
  ;Create print flag input window
  outputID=widget_base(tlb,row=1)
  outputlabel=widget_label(outputID,value='output file:',/align_left,xsize=179)

  ;-Create height file input window
  rhgtID=widget_base(tlb,row=1)
  rhgt_text=widget_text(rhgtID,value='',uvalue='',uname='rhgt_text',/editable,xsize=37)
  rhgt_button=widget_button(rhgtID,value='res_hgt',uname='rhgt_button',xsize=96)

  ;-Create cross-track ground ranges file input window
  rdataID=widget_base(tlb,row=1)
  rdata_text=widget_text(rdataID,value='',uvalue='',uname='rdata_text',/editable,xsize=37)
  rdata_button=widget_button(rdataID,value='res_data',uname='rdata_button',xsize=96)
  
  ;-Create cross-track ground ranges file input window
  rfileID=widget_base(tlb,row=1)
  rfile_text=widget_text(rfileID,value='',uvalue='',uname='rfile_text',/editable,xsize=37)
  rfile_button=widget_button(rfileID,value='report_file',uname='rfile_button',xsize=96)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={hgt_text:hgt_text,hgt_button:hgt_button,gr_text:gr_text,gr_button:gr_button,data_text:data_text,data_button:data_button,$
    masterpar_text:masterpar_text,masterpar_button:masterpar_button,offset_text:offset_text,offset_button:offset_button,nr_text:nr_text,$
    naz_text:naz_text,azps_text:azps_text,loff_text:loff_text,nlines_text:nlines_text,rhgt_text:rhgt_text,rhgt_button:rhgt_button,$
    rdata_text:rdata_text,rdata_button:rdata_button,rfile_text:rfile_text,rfile_button:rfile_button,ok:ok,cl:cl}

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'INSARGUI_RESMAP',tlb,/no_block

  END