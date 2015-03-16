PRO CWN_SMC_GCPRAS_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  
  case uname of
    ;-check input file

    'openras':begin
    infile=dialog_pickfile(title='Sasmac InSAR',filter='*.unw.ras',/read,path=workpath)
    if infile eq '' then return
      widget_control,(*pstate).ras,set_value=infile
      widget_control,(*pstate).ras,set_uvalue=infile
      
      outputfile=workpath+PATH_SEP()+TLI_FNAME(infile, /nosuffix)+'.gcp'
      widget_control,(*pstate).gcp,set_value=outputfile
      widget_control,(*pstate).gcp,set_uvalue=outputfile
    end
    'opengcp':begin
    widget_control,(*pstate).ras,get_value=ras
    if ras eq '' then begin
      result=dialog_message(title='Sasmac InSAR','Please input ras file',/information,path=workpath,/center)
      return
    endif
      outputfile=TLI_FNAME(ras, /nosuffix)+'.gcp'
      infiles=dialog_pickfile(title='Sasmac InSAR',filter='*.gcp',path=workpath,file=file,/write,/overwrite_prompt)
    if infiles eq '' then return
      widget_control,(*pstate).gcp,set_value=infiles
      widget_control,(*pstate).gcp,set_uvalue=infiles
    end
    
    'ok':begin
      widget_control,(*pstate).ras,get_value=ras
      widget_control,(*pstate).gcp,get_value=gcp
      widget_control,(*pstate).mag,get_value=mag
      widget_control,(*pstate).wisz,get_value=wisz
      if ras eq '' then begin
        result=dialog_message(title='Sasmac InSAR','Please input ras file',/information,path=workpath,/center)
        return
      endif
      if gcp eq '' then begin
        result=dialog_message(title='Sasmac InSAR','Please specify output gcp file',/information,path=workpath,/center)
        return
      endif
      
      if mag le 0 then begin
        result=dialog_message([' Zoom magnification factor should be greater than 0:',$
        STRCOMPRESS(mag)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if wisz le 0 then begin
        result=dialog_message(['Zoom window size before magnification should be greater than 0:',$
        STRCOMPRESS(wisz)],title='Sasmac InSAR',/information,/center)
        return
      endif 
       scr='gcp_ras '+ras+' '+gcp+' '+mag+' '+wisz
        TLI_SMC_SPAWN, scr,info='Select GCPs using a SUN raster or BMP format reference image, Please wait...'
    end

  'cl':begin
;  result=dialog_message('Sure exit?',title='Exit',/question,/default_no)
;  if result eq 'Yes' then begin
    widget_control,event.top,/destroy
;  endif
end
else:begin
return
end
  endcase

END

PRO CWN_SMC_GCPRAS,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=420
  ysize=250
  
  ras=''
  wisz='120'
  mag='3'
  gcp=''
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='gcp_ras',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)


  ;-Create ras input window
  rasID=widget_base(tlb,/row,xsize=xsize,frame=1)
  ras=widget_text(rasID,value=ras,uvalue=ras,uname='ras',/editable,xsize=50)
  openras=widget_button(rasID,value='Input ras',uname='openras',xsize=96)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  ;-----------------------------------------------------------------------------------------
  ;range parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-50, frame=1)
  magID=widget_base(tempID, /column, xsize=xsize/2-5)
  maglabel=widget_label(magID, value='Zoom magnification factor:',/ALIGN_LEFT)
  mag=widget_text(magID,value=mag, uvalue=mag, uname='mag',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2+25, frame=1)
  wiszID=widget_base(tempID, /column, xsize=xsize/2+25)
  wiszlabel=widget_label(wiszID, value='Zoom window size before magnification:',/ALIGN_LEFT)
  wisz=widget_text(wiszID,value=wisz, uvalue=wisz, uname='wisz',/editable,xsize=10)

  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')

  ;-Create ground control point data file input window
  gcpID=widget_base(tlb,/row,xsize=xsize,frame=1)
  gcp=widget_text(gcpID,value=gcp,uvalue=gcp,uname='gcp',/editable,xsize=50)
  opengcp=widget_button(gcpID,value='Output GCP',uname='opengcp',xsize=96)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={ ras:ras,$
          openras:openras,$
          mag:mag,$
          wisz:wisz,$
          gcp:gcp,$
          ok:ok,$
          cl:cl $
        }

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_GCPRAS',tlb,/no_block


END