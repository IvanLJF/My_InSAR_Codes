PRO CWN_SMC_GCPPHASE_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    ;-check input file
    'openunw':begin
      infile=dialog_pickfile(title='Sasmac InSAR',filter='*.unw',/read,path=workpath)
      if infile eq '' then return
        widget_control,(*pstate).unw,set_value=infile
        widget_control,(*pstate).unw,set_uvalue=infile
    end
    
    'openoff':begin
      infile=dialog_pickfile(title='Sasmac InSAR',filter='*.off',/read,path=workpath)
      if infile eq '' then return
        widget_control,(*pstate).off,set_value=infile
        widget_control,(*pstate).off,set_uvalue=infile
    end
    
    'opengcp':begin
      infile=dialog_pickfile(title='Sasmac InSAR',filter='*.gcp',/read,path=workpath)
      if infile eq '' then return
        widget_control,(*pstate).gcp,set_value=infile
        widget_control,(*pstate).gcp,set_uvalue=infile
        
        widget_control,(*pstate).unw,get_value=unw
        widget_control,(*pstate).off,get_value=off
        
        if unw eq '' then begin
          result=dialog_message(title='unwrapped file','Please input unwrapped file',/information,/center)
          return
        endif
        if off eq '' then begin
          result=dialog_message(title='offset parfile','Please input offset parfile',/information,/center)
          return
        endif
        
       gcpph=workpath+PATH_SEP()+TLI_FNAME(infile, /nosuffix)+'.gcp_ph'
       widget_control,(*pstate).gcpph,set_value=gcpph
       widget_control,(*pstate).gcpph,set_uvalue=gcpph
      end
    'opengcpph':begin
      widget_control,(*pstate).unw,get_uvalue=unw
      widget_control,(*pstate).off,get_uvalue=off
      widget_control,(*pstate).gcp,get_uvalue=gcp
      if unw eq '' then begin
        result=dialog_message(title='unwrapped file','Please input unwrapped file',/information,/center)
        return
      endif     
      if off eq '' then begin
        result=dialog_message(title='offset parfile','Please input offset parfile',/information,/center)
        return
      endif 
      if gcp eq '' then begin
        result=dialog_message(title='gcp file','Please input ground control point file',/information,/center)
        return
      endif
      
      temp=file_basename(gcp)
      temp=strsplit(temp,'.',/extract)
      gcp=temp(0)
      file=gcp+'.gcp_ph'
      infiles=dialog_pickfile(title='output gcp data + extracted unwrapped phase file',filter='*.gcp_ph',path=workpath,file=file,/write,/overwrite_prompt)
      if infiles eq '' then return
      widget_control,(*pstate).gcpph,set_value=infiles
      widget_control,(*pstate).gcpph,set_uvalue=infiles
      end
    
    'ok':begin
      widget_control,(*pstate).unw,get_uvalue=unw
      widget_control,(*pstate).off,get_uvalue=off
      widget_control,(*pstate).gcp,get_uvalue=gcp
      widget_control,(*pstate).gcpph,get_uvalue=gcpph
      widget_control,(*pstate).wisz,get_uvalue=wisz
      
      
      if unw eq '' then begin
        result=dialog_message(title='unwrapped file','Please input unwrapped file',/information,/center)
        return
      endif     
      if off eq '' then begin
        result=dialog_message(title='offset parfile','Please input offset parfile',/information,/center)
        return
      endif 
      if gcp eq '' then begin
        result=dialog_message(title='gcp file','Please input ground control point file',/information,/center)
        return
      endif   
      if gcpph eq '' then begin
        result=dialog_message(title='gcp file','Please specify gcp data + extracted unwrapped phase file',/information,/center)
        return
      endif
        
      if wisz le 0 then begin
          result=dialog_message([' window size for averaging phase for each GCP should be greater than 0:',$
          STRCOMPRESS(azwisz)],title='Sasmac InSAR',/information,/center)
          return
      endif
      
      scr='gcp_phase ' +unw +' '+off +' '+gcp+' '+gcpph+' '+wisz
        TLI_SMC_SPAWN, scr,info='extract unwrapped phase at GCP locations, Please wait...'
 ;     stop
    end
    
    'cl':begin
;      result=dialog_message('Sure exit?',title='Exit',/question,/default_no)
;      if result eq 'Yes' then begin
       widget_control,event.top,/destroy
;      endif
    end
      else:begin
        return
    end
  endcase
END
;-create the components
; input the paraments window
; deal with window
PRO CWN_SMC_GCPPHASE,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=380
  ysize=340
  
  ; Get config info
  unw=''
  off=''
  gcp=''
  wisz='1.0'
   ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='gcp_phase',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  unwID=widget_base(tlb,/row,xsize=xsize,frame=1)
  unw=widget_text(unwID,value=unw,uvalue=unw,uname='unw',/editable,xsize=42)
  openunw=widget_button(unwID,value='Input Unwrapped',uname='openunw',xsize=100)

  ;-Create offset file input window
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=42)
  openoff=widget_button(offID,value='Input offset',uname='openoff',xsize=100)

  ;-Create ground control point data file input window
  gcpID=widget_base(tlb,/row,xsize=xsize,frame=1)
  gcp=widget_text(gcpID,value=gcp,uvalue=gcp,uname='gcp',/editable,xsize=42)
  opengcp=widget_button(gcpID,value='Input GCP',uname='opengcp',xsize=100)
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize-10)
  parlabel=widget_label(parID, xsize=xsize, value='Basic information about input parameters:',/align_left,/dynamic_resize) 
 
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize-15, frame=1)
  wiszID=widget_base(tempID,/row,xsize=xsize-15)
  wiszlabel=widget_label(wiszID,value='window size for averaging phase for each GCP:',/align_left)
  wisz=widget_text(wiszID,value=wisz,uvalue=wisz,uname='wisz',/editable,xsize=14)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')  
  ;-Create ground control point data file input window
  gcpphID=widget_base(tlb,/row,xsize=xsize,frame=1)
  gcpph=widget_text(gcpphID,value='',uvalue='',uname='gcpph',/editable,xsize=42)
  opengcpph=widget_button(gcpphID,value='Output GCP_ph',uname='opengcpph',xsize=100)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={ unw:unw,$
          openunw:openunw,$
          off:off,$
          openoff:openoff,$
          gcp:gcp,$
          opengcp:opengcp,$
          wisz:wisz,$
          gcpph:gcpph,$
          opengcpph:opengcpph,$
           
          ok:ok,$
          cl:cl $
        }

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_GCPPHASE',tlb,/no_block


END