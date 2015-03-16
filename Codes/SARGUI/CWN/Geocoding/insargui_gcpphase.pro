;   gcp_phase,call the command of gcp_phase in the GAMMA software
;     usage: gcp_phase <unw> <OFF_par> <gcp> <gcp_ph> [win_sz]
;       input parameters:
;           unw     (input) unwrapped interferometeric phase
;           OFF_par (input) ISP interferogram/offset parameter file
;           gcp     (input) ground control point data (text format)
;           gcp_ph  (output)ground control point data + extracted unwrapped phase(text)
;           win_sz  window size for averaging phase for each GCP,must be odd (default: 1)
;           
;    -   Done written by CWN in Sasmac
;    -   29/12/2014 

PRO INSARGUI_GCPPHASE_EVENT,EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
    ;-check input file
    'unw_button':begin
      infile=dialog_pickfile(title='Please input unwrapped iterferometeric phase file',filter='*.unw',/read)
      if infile eq '' then return
        widget_control,(*pstate).unw_text,set_value=infile
        widget_control,(*pstate).unw_text,set_uvalue=infile
    end
    
    'offset_button':begin
      infile=dialog_pickfile(title='Please input interferometeric/offset parameter file',filter='*.off',/read)
      if infile eq '' then return
        widget_control,(*pstate).offset_text,set_value=infile
        widget_control,(*pstate).offset_text,set_uvalue=infile
    end
    
    'gcp_button':begin
      infile=dialog_pickfile(title='Please input gcp file',filter='*.gcp',/read)
      if infile eq '' then return
        widget_control,(*pstate).gcp_text,set_value=infile
        widget_control,(*pstate).gcp_text,set_uvalue=infile
    end
    'gcpph_button':begin
      widget_control,(*pstate).unw_text,get_uvalue=unw
      if unw eq '' then begin
        result=dialog_message(title='unwrapped file','Please input unwrapped file',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','Please input offset parfile',/information)
        return
      endif
      widget_control,(*pstate).gcp_text,get_uvalue=gcp
      if gcp eq '' then begin
        result=dialog_message(title='gcp file','Please input ground control point file',/information)
        return
      endif
      workpath=file_dirname(gcp)+path_sep()
      temp=file_basename(gcp)
      temp=strsplit(temp,'.',/extract)
      gcp=temp(0)
      file=gcp+'.gcp_ph'
      infiles=dialog_pickfile(title='output gcp data + extracted unwrapped phase file',filter='*.gcp_ph',path=workpath,file=file,/write,/overwrite_prompt)
      if infiles eq '' then return
      widget_control,(*pstate).gcpph_text,set_value=infiles
      widget_control,(*pstate).gcpph_text,set_uvalue=infiles
      end
    
    'ok':begin
      if 1 then begin
        ;check input parameters
        widget_control,(*pstate).unw_text,get_uvalue=unw
        if unw eq '' then begin
          result=dialog_message(title='unwrapped file','Please input unwrapped file',/information)
          return
        endif
        widget_control,(*pstate).offset_text,get_uvalue=offset
        if offset eq '' then begin
          result=dialog_message(title='offset parfile','Please input offset parfile',/information)
          return
        endif
        widget_control,(*pstate).gcp_text,get_uvalue=gcp
        if gcp eq '' then begin
          result=dialog_message(title='ground control point file','Please input ground control point file',/information)
          return
        endif
        widget_control,(*pstate).win_text,get_value=win
        if win ne '-' then begin
          win=long(win)
          if win lt 0 then begin
            result=dialog_message(title='window size','window size for averaging phase for each GCP should large than 0',/information)
            return
            widget_control,(*pstate).win_text,set_value=win
            widget_control,(*pstate).win_text,set_uvalue=win
          endif
        endif
        
        ;check output file parameters
        widget_control,(*pstate).gcpph_text,get_uvalue=gcpph
        if  gcpph eq '' then begin
          result=dialog_message(title='gcp data + extracted unwrapped phase','Please input gcp data + extracted unwrapped phase file',/information)
          return
        endif
      endif
      
      win=strcompress(string(win),/remove_all)
      wtlb = widget_base(title='process bar')
      widget_control,wtlb,/realize
      process = idlitwdprogressbar(group_leader=wtlb,time=0,title='processing...Please wait')
      idlitwdprogressbar_setvalue,process,0 ;-initialize the process bar,initial value=0
      
        scr='gcp_phase '+unw+' '+offset+' '+gcp+' '+gcpph+' '+win
        spawn,scr
      idlitwdprogressbar_setvalue,process,100 ;finish
 ;     stop
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
PRO INSARGUI_GCPPHASE,EVENT

  ;Create components
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  tlb=widget_base(title='gcp_phase',tlb_frame_attr=1,column=1,xsize=345,ysize=335,xoffset=xoffset,yoffset=yoffset)

  ;input window
  ;Create print flag input window
  inputID=widget_base(tlb,row=1)
  inputlabel=widget_label(inputID,value='input file:',/align_left,xsize=179)

  ;-Create unwrapped input window
  unwID=widget_base(tlb,row=1)
  unw_text=widget_text(unwID,value='',uvalue='',uname='unw_text',/editable,xsize=37)
  unw_button=widget_button(unwID,value='Unwrapped',uname='unw_button',xsize=96)

  ;-Create offset file input window
  offsetID=widget_base(tlb,row=1)
  offset_text=widget_text(offsetID,value='',uvalue='',uname='offset_text',/editable,xsize=37)
  offset_button=widget_button(offsetID,value='OFF_par',uname='offset_button',xsize=96)

  ;-Create ground control point data file input window
  gcpID=widget_base(tlb,row=1)
  gcp_text=widget_text(gcpID,value='',uvalue='',uname='gcp_text',/editable,xsize=37)
  gcp_button=widget_button(gcpID,value='GCP',uname='gcp_button',xsize=96)

  ;-Create window size for averaging phase for each point input window
  winsizeID=widget_base(tlb,row=1)
  winsizelabel=widget_label(winsizeID,value='window size:',/align_left,xsize=179)
  win_text=widget_text(winsizeID,value='1',uvalue='',uname='win_text',/editable,xsize=10)

  ;-output window
  ;Create print flag input window
  outputID=widget_base(tlb,row=1)
  outputlabel=widget_label(outputID,value='output file:',/align_left,xsize=179)

  ;-Create ground control point data file input window
  gcpphID=widget_base(tlb,row=1)
  gcpph_text=widget_text(gcpphID,value='',uvalue='',uname='gcpph_text',/editable,xsize=37)
  gcpph_button=widget_button(gcpphID,value='GCP_ph',uname='gcpph_button',xsize=96)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={unw_text:unw_text,unw_button:unw_button,offset_text:offset_text,offset_button:offset_button,gcp_text:gcp_text,gcp_button:gcp_button,$
    win_text:win_text,gcpph_text:gcpph_text,gcpph_button:gcpph_button,ok:ok,cl:cl}

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'INSARGUI_GCPPHASE',tlb,/no_block


END