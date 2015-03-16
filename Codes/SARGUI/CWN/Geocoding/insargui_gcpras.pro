;   gcp_ras,call the command of gcp_ras in the GAMMA software
;     usage: gcp_ras <ras> <GCP> [mag] [win_sz]
;       input parameters:
;           ras     (input) SUN raster *.ras,or BMP *.bmp format image
;           GCP     (output) GCP data file (text format)
;           mag     zoom magnification factor (default=3)
;           win_sz  zoom window size before magnification (default=120)
;           
;    -   Done written by CWN in Sasmac
;    -   29/12/2014

PRO INSARGUI_GCPRAS_EVENT,EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
    ;-check input file

    'ras_button':begin
    infile=dialog_pickfile(title='Please input ras file',filter='*.ras',/read)
    if infile eq '' then return
      widget_control,(*pstate).ras_text,set_value=infile
      widget_control,(*pstate).ras_text,set_uvalue=infile
    end
    'gcp_button':begin
    widget_control,(*pstate).ras_text,get_uvalue=ras
    if ras eq '' then begin
      result=dialog_message(title='ras file','Please input ras file',/information)
      return
    endif
      workpath=file_dirname(ras)+path_sep()
      temp=file_basename(ras)
      temp=strsplit(temp,'.',/extract)
      ras=temp(0)
      file=ras+'.gcp'
      infiles=dialog_pickfile(title='output gcp data file',filter='*.gcp',path=workpath,file=file,/write,/overwrite_prompt)
    if infiles eq '' then return
      widget_control,(*pstate).gcp_text,set_value=infiles
      widget_control,(*pstate).gcp_text,set_uvalue=infiles
    end
    
    'ok':begin
    if 1 then begin
      ;check input parameters
      widget_control,(*pstate).ras_text,get_uvalue=ras
      if ras eq '' then begin
        result=dialog_message(title='ras file','Please input ras file',/information)
        return
      endif
      
      widget_control,(*pstate).mag_text,get_value=mag
      if mag ne '-' then begin
        mag=long(mag)
        if mag lt 0 then begin
          result=dialog_message(title='mag factor','zoom magnification factor should large than 0',/information)
          return
          widget_control,(*pstate).mag_text,set_value=mag
          widget_control,(*pstate).mag_text,set_uvalue=mag
        endif
      endif
      widget_control,(*pstate).winsz_text,get_value=winsz
      if winsz ne '-' then begin
        winsz=long(winsz)
        if winsz lt 0 then begin
          result=dialog_message(title='window size','zoom window size before magnification should large than 0',/information)
          return
          widget_control,(*pstate).winsz_text,set_value=winsz
          widget_control,(*pstate).winsz_text,set_uvalue=winsz
        endif
      endif
      
      ;check output file parameters
      widget_control,(*pstate).gcp_text,get_uvalue=gcp
      if gcp eq '' then begin
        result=dialog_message(title='ground control point file','Please input ground control point file',/information)
        return
      endif
    endif

    mag=strcompress(string(mag),/remove_all)
    winsz=strcompress(string(winsz),/remove_all)
    
    wtlb = widget_base(title='process bar')
    widget_control,wtlb,/realize
    process = idlitwdprogressbar(group_leader=wtlb,time=0,title='processing...Please wait')
    idlitwdprogressbar_setvalue,process,0 ;-initialize the process bar,initial value=0
      scr='gcp_ras '+ras+' '+gcp+' '+mag+' '+winsz
      spawn,scr
    idlitwdprogressbar_setvalue,process,100 ;finish
;    stop
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
PRO INSARGUI_GCPRAS,EVENT

  ;Create components
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  tlb=widget_base(title='gcp_ras',tlb_frame_attr=1,column=1,xsize=345,ysize=335,xoffset=xoffset,yoffset=yoffset)

  ;input window
  ;Create print flag input window
  inputID=widget_base(tlb,row=1)
  inputlabel=widget_label(inputID,value='input file:',/align_left,xsize=179)

  ;-Create ras input window
  rasID=widget_base(tlb,row=1)
  ras_text=widget_text(rasID,value='',uvalue='',uname='ras_text',/editable,xsize=37)
  ras_button=widget_button(rasID,value='RAS',uname='ras_button',xsize=96)

  ;-Create window size for averaging phase for each point input window
  winsizeID=widget_base(tlb,row=1)
  winsizelabel=widget_label(winsizeID,value='mag factor,window size:',/align_left,xsize=179)
  mag_text=widget_text(winsizeID,value='3',uvalue='',uname='mag_text',/editable,xsize=10)
  winsz_text=widget_text(winsizeID,value='120',uvalue='',uname='winsz_text',/editable,xsize=10)

  ;-output window
  ;Create print flag input window
  outputID=widget_base(tlb,row=1)
  outputlabel=widget_label(outputID,value='output file:',/align_left,xsize=179)

  ;-Create ground control point data file input window
  gcpID=widget_base(tlb,row=1)
  gcp_text=widget_text(gcpID,value='',uvalue='',uname='gcp_text',/editable,xsize=37)
  gcp_button=widget_button(gcpID,value='GCP',uname='gcp_button',xsize=96)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={ras_text:ras_text,ras_button:ras_button,mag_text:mag_text,winsz_text:winsz_text,gcp_text:gcp_text,gcp_button:gcp_button,ok:ok,cl:cl}

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'INSARGUI_GCPRAS',tlb,/no_block


END