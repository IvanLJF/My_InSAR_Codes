PRO CWN_SMC_TLIMASKINT_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    
    'openunw':begin
      infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.unw', path=workpath,file=intfile)
      IF NOT FILE_TEST(infile) THEN return
      gcpfile=workpath+PATH_SEP()+TLI_FNAME(infile, /REMOVE_ALL_SUFFIX)+'.gcp'

      widget_control,(*pstate).unw,set_value=infile
      widget_control,(*pstate).unw,set_uvalue=infile
      widget_control,(*pstate).gcp,set_value=gcpfile
      widget_control,(*pstate).gcp,set_uvalue=gcpfile
      
    end  
    'opendem':begin
      infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.dem', path=workpath,file=intfile)
      IF NOT FILE_TEST(infile) THEN return

      widget_control,(*pstate).dem,set_value=infile
      widget_control,(*pstate).dem,set_uvalue=infile
      
    end
    
    'opengcp':begin
    ;-Check if input master parfile
    widget_control,(*pstate).unw,get_value=unwfile
    widget_control,(*pstate).dem,get_uvalue=demfile
    
    if unwfile eq '' then begin
        result=dialog_message(['Please select unwrapped file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
    if demfile eq '' then begin
        result=dialog_message(['Please select DEM file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
       
    gcpfile=TLI_FNAME(unwfile, /REMOVE_ALL_SUFFIX)+'.gcp'
    outfile=dialog_pickfile(title='',/write,file=gcpfile,filter='*.gcp',path=workpath,/overwrite_prompt)   
    widget_control,(*pstate).gcp,set_value=outfile
    widget_control,(*pstate).gcp,set_uvalue=outfile
 
  END
    

    'ok': begin
      widget_control,(*pstate).unw,get_value=unwfile
      widget_control,(*pstate).gcp,get_value=gcpfile
      widget_control,(*pstate).dem,get_value=demfile
      widget_control,(*pstate).npt,get_value=npt
      
      if unwfile eq '' then begin
        result=dialog_message(['Please select the unwrapped file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      if demfile eq '' then begin
        result=dialog_message(['Please select the DEM file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      if gcpfile eq '' then begin
        result=dialog_message(['Please select the Ground control point file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      
      if npt le 0 then begin
          result=dialog_message(['Number of points to use should be greater than 0:',$
          STRCOMPRESS(npt)],title='Sasmac InSAR',/information,/center)
          return
      endif  
         
      TLI_GCP_DEM, unwfile, demfile, gcpfile=gcpfile, npt=npt
;stop
     end
     
    'cl':begin
;      result=dialog_message('Sure exit？',title='Exit',/question,/default_no,/center)
;      if result eq 'Yes'then begin
        widget_control,event.top,/destroy
;      endif
      end
      else: begin
        return
      end
   endcase
END


PRO CWN_SMC_TLIMASKINT
COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=360
  ysize=330
  
  ; Get config info
    
    unwfile=''
    demfile=''
    npt='1000'
    gcpfile=''

  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='tli_mask_int',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  unwID=widget_base(tlb,row=1, frame=1)
  unw=widget_text(unwID,value=unwfile,uvalue=unwfile,uname='unw',/editable,xsize=37)
  openunw=widget_button(unwID,value='Input Unwrapped',uname='openunw',xsize=110)
  
  demID=widget_base(tlb,row=1, frame=1)
  dem=widget_text(demID,value=demfile,uvalue=demfile,uname='dem',/editable,xsize=37)
  opendem=widget_button(demID,value='Input DEM',uname='opendem',xsize=110)
    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize)   
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize, frame=1)
  nptID=widget_base(tempID,/row, xsize=xsize-6)
  nptlabel=widget_label(nptID, value='Number of points to use:',/ALIGN_LEFT)
  npt=widget_text(nptID, value=npt,uvalue=npt, uname='npt',/editable,xsize=10) 
  
  
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Create GCP file:',/align_left,/dynamic_resize)
  
  gcpID=widget_base(tlb,row=1, frame=1)
  gcp=widget_text(gcpID,value=gcpfile,uvalue=gcpfile,uname='gcp',/editable,xsize=37)
  opengcp=widget_button(gcpID,value='Output GCP',uname='opengcp',xsize=110)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30) 
  
  ;Recognize components
   state={unw:unw,$
    openunw:openunw,$
    dem:dem,$
    opendem:opendem,$
    npt:npt,$
    gcp:gcp,$
    opengcp:opengcp,$

    
    ok:ok,$
    cl:cl $
   }
    
  pstate=ptr_new(state,/no_copy) 
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_TLIMASKINT',tlb,/no_block
END