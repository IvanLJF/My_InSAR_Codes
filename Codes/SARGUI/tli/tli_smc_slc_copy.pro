;
; SLC_copy
;
; Parameters:
;
; Keywords:
;
; Written by:
;  T.LI @ Sasmac, 20150108
;
PRO TLI_SMC_SLC_COPY_EVENT, EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  WIDGET_CONTROL,event.top,get_uvalue=pstate
  workpath=config.workpath
  
  uname=WIDGET_INFO(event.id,/uname)
  Case STRLOWCASE(uname) OF
    'openslc':BEGIN
    slcfile=dialog_pickfile(title='Sasmac InSAR',/read,filter=['*.slc;*.rslc'],/must_exist,path=workpath)
    IF NOT FILE_TEST(slcfile) THEN return
    
    date=TLI_FNAME(slcfile,/remove_all_suffix, all_suffix=all_suffix,dirname=workpath)
    outputfile=workpath+date+'_crop'+all_suffix
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=outputfile
    widget_control, (*pstate).slctxt, set_value=slcfile
    widget_control, (*pstate).output, set_value=outputfile
  END
  'openoutput':BEGIN
  
  slcfile=config.inputfile
  date=TLI_FNAME(slcfile,/remove_all_suffix, all_suffix=all_suffix,dirname=workpath)
  outputfile=workpath+date+'_crop'+all_suffix
  outputfile=dialog_pickfile(title='Sasmac InSAR',/write,filter='*.slc', file=outputfilefile, path=workpath,/overwrite_prompt)
  IF outputfile EQ '' THEN return
  widget_control, (*pstate).output, set_value=outputfile, set_uvalue=outputfile
end

'ok':begin

widget_control, (*pstate).slctxt,get_value=slcfile
widget_control, (*pstate).startx, get_value=startx
widget_control, (*pstate).endx, get_value=endx
widget_control, (*pstate).starty, get_value=starty
widget_control, (*pstate).endy, get_value=endy
widget_control, (*pstate).output, get_value=outputfile
show=WIDGET_INFO((*pstate).show,/droplist_select)

IF NOT FILE_TEST(slcfile) OR NOT FILE_TEST(slcfile+'.par') then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select input slc file.'
  RETURN
ENDIF

finfo=TLI_LOAD_SLC_PAR(slcfile+'.par')
startx=long(startx) & starty=long(starty) & endx=LONG(endx) & endy=LONG(endy)
IF startx LT 0 OR endx GT finfo.range_samples-1 OR startx GE endx THEN BEGIN
  TLI_SMC_DUMMY, inputstr=['Error!', 'Please provide correct values for startx and endx']
  RETURN
ENDIF

IF starty LT 0 OR endy GT finfo.azimuth_lines-1 OR starty GE endy THEN BEGIN
  TLI_SMC_DUMMY, inputstr=['Error!', 'Please provide correct values for starty and endy']
  RETURN
ENDIF

if outputfile EQ '' then begin
  TLI_SMC_DUMMY, inputstr=['Error!',' Please select output file.']
  RETURN
endif

startx=STRCOMPRESS(startx,/REMOVE_ALL)
nx=STRCOMPRESS(endx-startx+1,/REMOVE_ALL)
starty=STRCOMPRESS(starty,/REMOVE_ALL)
ny=STRCOMPRESS(endy-starty+1,/REMOVE_ALL)

scr='SLC_copy'+' '+slcfile+' '+slcfile+'.par '+outputfile+' '+outputfile+'.par - - '+$
    startx+' '+nx+' '+starty+' '+ny

TLI_SMC_SPAWN, scr,info='Copying SLC subset, Please wait...'

IF show THEN BEGIN
data=TLI_READSLC(outputfile)
data=data^0.25
TLI_SMC_DISPLAY, data
ENDIF

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

PRO TLI_SMC_SLC_COPY

  COMPILE_OPT idl2
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size[0]/3
  yoffset=screen_size[1]/3
  xsize=560
  ysize=400
  
  ; Information
   ; Get config info
;  workpath='/mnt/data_tli/ForExperiment/int_ERS_Shanghai/int_ERS_shanghai_2000_10000'+PATH_SEP()
;  config.workpath=workpath
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='Cut Out Region',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  slctxt=widget_text(temp,value='',uvalue='',uname='slctxt',/editable,xsize=73)
  openslc=widget_button(temp,value='SLC',uname='openslc',xsize=90)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Crop info
  crop=widget_base(tlb, /column,xsize=xsize,/frame)
  
  temp=widget_base(crop,/column,/base_align_center,xsize=xsize)
  lab=widget_label(temp, value='Start Y:')
  starty=widget_text(temp,value='0',xsize=10,/editable)
  
  temp=widget_base(crop,/row,xsize=xsize,/base_align_center)
  lab=widget_label(temp, value='Start X:')
  startx=widget_text(temp, value='0', xsize=10,/editable)
  label=widget_label(temp, xsize=xsize-300, $
    value='                  |              '+STRING(10b)+$
    '                  |              '+STRING(10b)+$
    '   -------------- | -------------'+STRING(10b)+$
    '                  |              '+STRING(10b)+$
    '                  |              ')
  lab=widget_label(temp, value='End X:')
  endx=widget_text(temp, value='0', xsize=10,/editable)
  
  temp=widget_base(crop,/column,/base_align_center,xsize=xsize)
  lab=widget_label(temp, value='End Y:')
  endy=widget_text(temp,value='0',xsize=10,/editable)
  
  ;--------------------------------------------------------------
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  outID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outID,value=outputfile,uvalue=outputfile,uname='output',/editable,xsize=58)
  openoutput=widget_button(outID,value='Output SLC',uname='openoutput',xsize=90)
  show=widget_droplist(outID, value=['Hide','Show'],xsize=90)
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={slctxt:slctxt,$
    openslc:openslc,$
    startx: startx,$
    endx: endx, $
    starty: starty, $
    endy: endy, $
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl, $
    show:show $
    }
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_SLC_COPY',tlb,/no_block
  
  
END