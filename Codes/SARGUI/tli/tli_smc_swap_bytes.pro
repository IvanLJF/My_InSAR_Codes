;
; Swap bytes using GAMMA command.
;
PRO TLI_SMC_SWAP_BYTES_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  WIDGET_CONTROL,event.top,get_uvalue=pstate
  workpath=config.workpath
  
  uname=WIDGET_INFO(event.id,/uname)
  Case STRLOWCASE(uname) OF
    'openslc':BEGIN
    inputfile=dialog_pickfile(title='Sasmac InSAR',/read,/must_exist,path=workpath)
    IF NOT FILE_TEST(inputfile) THEN return
    
    date=TLI_FNAME(inputfile,/remove_all_suffix, all_suffix=all_suffix,dirname=workpath)
    outputfile=workpath+date+'_swap'+all_suffix
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=outputfile
    widget_control, (*pstate).slctxt, set_value=inputfile
    widget_control, (*pstate).output, set_value=outputfile
  END
  'openoutput':BEGIN
  
  inputfile=config.inputfile
  date=TLI_FNAME(inputfile,/remove_all_suffix, all_suffix=all_suffix,dirname=workpath)
  outputfile=workpath+date+'_crop'+all_suffix
  outputfile=dialog_pickfile(title='Sasmac InSAR',/write,filter='*.slc', file=outputfilefile)
  IF outputfile EQ '' THEN return
  widget_control, (*pstate).output, set_value=outputfile, set_uvalue=outputfile
end

'ok':begin

widget_control, (*pstate).slctxt,get_value=inputfile
widget_control, (*pstate).output, get_value=outputfile

swap_type=WIDGET_INFO((*pstate).swap_type,/droplist_select)
swap_type=STRCOMPRESS(swap_type*2+2, /REMOVE_ALL)

IF NOT FILE_TEST(inputfile) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select input slc file.'
  RETURN
ENDIF

if outputfile EQ '' then begin
  TLI_SMC_DUMMY, inputstr=['Error!',' Please select output file.']
  RETURN
endif


scr='swap_bytes '+inputfile+' '+outputfile+' '+swap_type
  
TLI_SMC_SPAWN, scr,info='Copying SLC subset, Please wait...'

END
'cl':begin
;result=dialog_message('Quit Multi-looking processing?',title='Sasmac InSAR v1.0',/question,/center)
;if result eq 'Yes'then begin
widget_control,event.top,/destroy
;endif
end
ELSE: 
ENDCASE
END

PRO TLI_SMC_SWAP_BYTES
  COMPILE_OPT idl2
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size[0]/3
  yoffset=screen_size[1]/3
  xsize=560
  ysize=230
  
  ; Information
  
  ; Get config info
  workpath='/mnt/data_tli/ForExperiment/int_ERS_Shanghai/int_ERS_shanghai_2000_10000'+PATH_SEP()
  config.workpath=workpath
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='Cut Out Region',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  slctxt=widget_text(temp,value='',uvalue='',uname='slctxt',/editable,xsize=73)
  openslc=widget_button(temp,value='Data',uname='openslc',xsize=90)
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  temp=widget_base(tlb,/row,xsize=xsize,/frame)
  lab=widget_label(temp,value='Swap Type:')
  
  
  
  swap_type=widget_droplist(temp, value=['(1,2,3,4,5,6,7,8...) --> (2,1,4,3,6,5,8,7...) (SHORT, SCOMPLEX)',$
                                   '(1,2,3,4,5,6,7,8...) --> (4,3,2,1,8,7,6,5...) (INT, FLOAT, FCOMPLEX)',$
                                   '(1,2,3,4,5,6,7,8...) --> (8,7,6,5,4,3,2,1...) (DOUBLE)'])
  
  
  
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  
  outID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outID,value=outputfile,uvalue=outputfile,uname='output',/editable,xsize=73)
  openoutput=widget_button(outID,value='Output SLC',uname='openoutput',xsize=90)
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={slctxt:slctxt,$
    openslc:openslc,$    
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl, $
    swap_type:swap_type $
    }
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_SWAP_BYTES',tlb,/no_block
  
END