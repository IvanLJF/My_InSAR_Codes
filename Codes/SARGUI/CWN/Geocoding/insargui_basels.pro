;   base_ls,call the command of base_ls in the GAMMA software
;     usage: base_ls <SLC_par> <OFF_par> <gcp_ph> <baseline> [ph_flag] [bc_flag] [bn_flag] [bcdot_flag] [bndot_flag] [bperp_min] [SLC2R_par]
;       input parameters:
;           SLC_par    (input) ISP parameter file of the reference SLC
;           OFF_par    (input) ISP interferogram/offset parameter file
;           gcp_ph     (input)ground control point data + extracted unwrapped phase(text)
;           baseline   (input)baseline parameter file
;           ph_flag    restore range phase ramp (default=0: do not restore 1: restore)
;           bc_flag    cross-track baseline component estimate(0:orbit derived 1:estimate from data, default=1)
;           bn_flag    normal baseline component estimate     (0:orbit derived 1:estimate from data, default=1)
;           bcdot_flag cross-track baseline rate estimate     (0:orbit derived 1:estimate from data, default=1)
;           bndot_flag normal baseline rate estimate          (0:orbit derived 1:estimate from data, default=0)
;           bperp_min  minimum perpendicular baseline required for L.S estimation (m, default= 10.0)
;           SLC2R_par  (input) parameter file of resampled SLC,required if SLC-2 frequency differs from SLC-1
;           
;    -   Done written by CWN in Sasmac
;    -   29/12/2014

PRO INSARGUI_BASELS_EVENT,EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
    'masterpar_button':begin
      infile=dialog_pickfile(title='Please input  master parfile',filter='*.rslc.par',/read)
      if infile eq '' then return
        widget_control,(*pstate).masterpar_text,set_value=infile
        widget_control,(*pstate).masterpar_text,set_uvalue=infile
      end
    'slavepar_button':begin
      
      infile=dialog_pickfile(title='Please input  slave parfile',filter='*.rslc.par',/read)
      if infile eq '' then return
        widget_control,(*pstate).slavepar_text,set_value=infile
        widget_control,(*pstate).slavepar_text,set_uvalue=infile
      end
    'offset_button':begin
      infile=dialog_pickfile(title='Please input  offset parfile',filter='*.off',/read)
      if infile eq '' then return
        widget_control,(*pstate).offset_text,set_value=infile
        widget_control,(*pstate).offset_text,set_uvalue=infile
      end  
    'gcpph_button':begin
      infile=dialog_pickfile(title='Please input  master parfile',filter='*.gcp_ph',/read)
      if infile eq '' then return
        widget_control,(*pstate).gcpph_text,set_value=infile
        widget_control,(*pstate).gcpph_text,set_uvalue=infile
    end
    'base_button':begin
      infile=dialog_pickfile(title='Please input  baseline parfile',filter='*.base',/read)
      if infile eq '' then return
        widget_control,(*pstate).base_text,set_value=infile
        widget_control,(*pstate).base_text,set_uvalue=infile
    end
    'ok':begin
      if 1 then begin
        ;check input parameters
        widget_control,(*pstate).masterpar_text,get_uvalue=masterpar
        if masterpar eq '' then begin
          result=dialog_message(title='master parfile','Please input master parfile',/information)
          return
        endif
        widget_control,(*pstate).slavepar_text,get_value=slavepar
        if slavepar ne '-' then begin
          result=dialog_message(title='slave parfile','Please input slave parfile',/information)
          return
        endif
        widget_control,(*pstate).offset_text,get_uvalue=offset
        if offset eq '' then begin
          result=dialog_message(title='offset parfile','Please input offset parfile',/information)
          return
        endif
        widget_control,(*pstate).gcpph_text,get_uvalue=gcpph
        if gcpph eq '' then begin
          result=dialog_message(title='gcpph parfile','Please input gcpph parfile',/information)
          return
        endif
        widget_control,(*pstate).base_text,get_uvalue=base
        if base eq '' then begin
          result=dialog_message(title='baseline file','Please input baseline file',/information)
          return
        endif
        
        widget_control,(*pstate).phflag_text,get_value=phflag
          phflag=long(phflag)
        if phflag ge 2 then begin
            result=dialog_message(title='phase ramp','restore range phase ramp should be 0 or 1',/information)
            return
            widget_control,(*pstate).phflag_text,set_value=phflag
            widget_control,(*pstate).phflag_text,set_uvalue=phflag
        endif
        widget_control,(*pstate).bcflag_text,get_value=bcflag
          bcflag=long(bcflag)
        if bcflag ge 2 then begin
          result=dialog_message(title='component estimate','cross-track baseline component estimate should be 0 or 1',/information)
          return
          widget_control,(*pstate).bcflag_text,set_value=bcflag
          widget_control,(*pstate).bcflag_text,set_uvalue=bcflag
        endif
        widget_control,(*pstate).bnflag_text,get_value=bnflag
          bnflag=long(bnflag)
        if bnflag ge 2 then begin
          result=dialog_message(title='normal component estimate','normal baseline component estimate should be 0 or 1',/information)
          return
          widget_control,(*pstate).bnflag_text,set_value=bnflag
          widget_control,(*pstate).bnflag_text,set_uvalue=bnflag
        endif
        
        widget_control,(*pstate).bcdotflag_text,get_value=bcdotflag
          bcdotflag=long(bcdotflag)
        if bcdotflag ge 2 then begin
          result=dialog_message(title='rate estimate','cross-track baseline rate estimate should be 0 or 1',/information)
          return
          widget_control,(*pstate).bcdotflag_text,set_value=bcdotflag
          widget_control,(*pstate).bcdotflag_text,set_uvalue=bcdotflag
        endif
        widget_control,(*pstate).bndotflag_text,get_value=bndotflag
        bndotflag=long(bndotflag)
        if bndotflag ge 2 then begin
          result=dialog_message(title='normal rate estimate','normal baseline rate estimate should be 0 or 1',/information)
          return
          widget_control,(*pstate).bndotflag_text,set_value=bndotflag
          widget_control,(*pstate).bndotflag_text,set_uvalue=bndotflag
        endif
        widget_control,(*pstate).bperpmin_text,get_value=bperpmin
        bperpmin=long(bperpmin)
        if bperpmin lt 0 then begin
          result=dialog_message(title='minimum perpendicular','minimum perpendicular baseline required for L.S estimate should be large than 0',/information)
          return
          widget_control,(*pstate).bperpmin_text,set_value=bperpmin
          widget_control,(*pstate).bperpmin_text,set_uvalue=bperpmin
        endif        
      endif
      
      phflag=strcompress(string(phflag),/remove_all)
      bcflag=strcompress(string(bcflag),/remove_all)
      bnflag=strcompress(string(bnflag),/remove_all)
      bcdotflag=strcompress(string(bcdotflag),/remove_all)
      bndotflag=strcompress(string(bndotflag),/remove_all)
      bperpmin=strcompress(string(bperpmin),/remove_all)
      
      wtlb = widget_base(title='process bar')
      widget_control,wtlb,/realize
      process = idlitwdprogressbar(group_leader=wtlb,time=0,title='processing...Please wait')
      idlitwdprogressbar_setvalue,process,0 ;-initialize the process bar,initial value=0

        scr='base_ls '+masterpar+' '+offset+' '+gcpph+' '+base+' '+phflag+' '+bcflag+' '+bnflag+' '+bcdotflag+' '+bndotflag+' '+bperpmin+' '+slavepar
        spawn,scr
      idlitwdprogressbar_setvalue,process,100 ;finish
     stop
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
PRO INSARGUI_BASELS,EVENT

  ;Create components
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  tlb=widget_base(title='base_ls',tlb_frame_attr=1,column=1,xsize=345,ysize=335,xoffset=xoffset,yoffset=yoffset)

  ;input window
  ;Create print flag input window
  inputID=widget_base(tlb,row=1)
  inputlabel=widget_label(inputID,value='input file:',/align_left,xsize=179)

  ;-Create master parfile input window
  masterparID=widget_base(tlb,row=1)
  masterpar_text=widget_text(masterparID,value='',uvalue='',uname='masterpar_text',/editable,xsize=37)
  masterpar_button=widget_button(masterparID,value='Master_par',uname='masterpar_button',xsize=96)
  
  ;-Create slave parfile input window
  slaveparID=widget_base(tlb,row=1)
  slavepar_text=widget_text(slaveparID,value='-',uvalue='',uname='slavepar_text',/editable,xsize=37)
  slavepar_button=widget_button(slaveparID,value='Slave_par',uname='slavepar_button',xsize=96)

  ;-Create offset file input window
  offsetID=widget_base(tlb,row=1)
  offset_text=widget_text(offsetID,value='',uvalue='',uname='offset_text',/editable,xsize=37)
  offset_button=widget_button(offsetID,value='OFF_par',uname='offset_button',xsize=96)
  
  ;-Create ground control point input window
  gcpphID=widget_base(tlb,row=1)
  gcpph_text=widget_text(gcpphID,value='',uvalue='',uname='gcpph_text',/editable,xsize=37)
  gcpph_button=widget_button(gcpphID,value='GCP_ph',uname='gcpph_button',xsize=96)

  ;-Create ground control point data file input window
  baseID=widget_base(tlb,row=1)
  base_text=widget_text(baseID,value='',uvalue='',uname='base_text',/editable,xsize=37)
  base_button=widget_button(baseID,value='Baseline',uname='base_button',xsize=96)

  ;-Create flag input window
  flag1ID=widget_base(tlb,row=1)
  flag1label=widget_label(flag1ID,value='ph_flag,bc_flag,bn_flag:',/align_left,xsize=255)
  phflag_text=widget_text(flag1ID,value='1',uvalue='',uname='phflag_text',/editable,xsize=5)
  bcflag_text=widget_text(flag1ID,value='1',uvalue='',uname='bcflag_text',/editable,xsize=5)
  bnflag_text=widget_text(flag1ID,value='1',uvalue='',uname='bnflag_text',/editable,xsize=5)
  
  ;-Create flag input window
  flag2ID=widget_base(tlb,row=1)
  flag2label=widget_label(flag2ID,value='bcdot_flag,bndot_flag,bperp_min:',/align_left,xsize=255)
  bcdotflag_text=widget_text(flag2ID,value='1',uvalue='',uname='bcdotflag_text',/editable,xsize=5)
  bndotflag_text=widget_text(flag2ID,value='1',uvalue='',uname='bndotflag_text',/editable,xsize=5)
  bperpmin_text=widget_text(flag2ID,value='1',uvalue='',uname='bperpmin_text',/editable,xsize=5)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={masterpar_text:masterpar_text,masterpar_button:masterpar_button,slavepar_text:slavepar_text,slavepar_button:slavepar_button,$
    offset_text:offset_text,offset_button:offset_button,gcpph_text:gcpph_text,gcpph_button:gcpph_button,base_text:base_text,base_button:base_button,$
    phflag_text:phflag_text,bcflag_text:bcflag_text,bnflag_text:bnflag_text,bcdotflag_text:bcdotflag_text,bndotflag_text:bndotflag_text,$
    bperpmin_text:bperpmin_text,ok:ok,cl:cl}

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'INSARGUI_BASELS',tlb,/no_block


END