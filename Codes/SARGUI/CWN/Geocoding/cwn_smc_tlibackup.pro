PRO CWN_SMC_TLIBACKUP_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    
    'openbase':begin
      infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.unw', path=workpath)
      IF NOT FILE_TEST(infile) THEN return
      baselsfile=workpath+PATH_SEP()+TLI_FNAME(infile, /REMOVE_ALL_SUFFIX)+'.unw'

      widget_control,(*pstate).base,set_value=infile
      widget_control,(*pstate).base,set_uvalue=infile
      widget_control,(*pstate).basels,set_value=baselsfile
      widget_control,(*pstate).basels,set_uvalue=baselsfile
      
    end  
    'openbasels':begin
      widget_control,(*pstate).base,get_value=basefile
      if basefile eq '' then begin
        result=dialog_message(['Please select baseline file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
       
    baselsfile=TLI_FNAME(basefile, /REMOVE_ALL_SUFFIX)+'.base'
    outfile=dialog_pickfile(title='',/write,file=baselsfile,filter='*.base',path=workpath,/overwrite_prompt)   
    widget_control,(*pstate).basels,set_value=outfile
    widget_control,(*pstate).basels,set_uvalue=outfile
 
    end

    'ok': begin
      widget_control,(*pstate).base,get_value=basefile
      widget_control,(*pstate).basels,get_value=baselsfile
     
      if basefile eq '' then begin
        result=dialog_message(['Please select the baseline file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      if baselsfile eq '' then begin
        result=dialog_message(['Please specify the baseline file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      
      TLI_BASE_LS, basefile, outputfile=baselsfile
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


PRO CWN_SMC_TLIBACKUP
COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=360
  ysize=140
  
  ; Get config info
    
    basefile=''
    baselsfile=''

  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='tli_backup',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  baseID=widget_base(tlb,row=1, frame=1)
  base=widget_text(baseID,value=basefile,uvalue=basefile,uname='base',/editable,xsize=37)
  openbase=widget_button(baseID,value='Input Baseline',uname='openbase',xsize=110)
  
  baselsID=widget_base(tlb,row=1, frame=1)
  basels=widget_text(baselsID,value=baselsfile,uvalue=baselsfile,uname='basels',/editable,xsize=37)
  openbasels=widget_button(baselsID,value='Output Baseline',uname='openbasels',xsize=110)
    
  
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30) 
  
  ;Recognize components
   state={base:base,$
    openbase:openbase,$
    basels:basels,$
    openbasels:openbasels,$

    ok:ok,$
    cl:cl $
   }
    
  pstate=ptr_new(state,/no_copy) 
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_TLIBACKUP',tlb,/no_block
END