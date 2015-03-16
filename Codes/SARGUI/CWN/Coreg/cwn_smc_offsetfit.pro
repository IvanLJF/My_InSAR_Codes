PRO CWN_SMC_OFFSETFIT_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openoffs':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.offs', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
    ; Update widget info.
    
    inputfile=config.inputfile
    
    widget_control,(*pstate).offs,set_value=infile
    widget_control,(*pstate).offs,set_uvalue=infile
    
    
  END
  'opensnr':begin
  infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off.snr', path=workpath)
  IF NOT FILE_TEST(infile) THEN return
  
  ; Update definitions
  TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
  
  inputfile=config.inputfile
  widget_control,(*pstate).snr,set_value=infile
  widget_control,(*pstate).snr,set_uvalue=infile
  
END
'openoff':begin
off=config.offfile
infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath,file=off)
IF NOT FILE_TEST(infile) THEN return

; Update definitions
config.offfile=infile
widget_control,(*pstate).off,set_value=infile
widget_control,(*pstate).off,set_uvalue=infile

finfo=TLI_LOAD_PAR(infile)
thres=STRCOMPRESS(string(long(finfo.offset_estimation_threshhold)),/remove_all)
widget_control,(*pstate).thres,set_value=thres
widget_control,(*pstate).thres,set_uvalue=thres

widget_control,(*pstate).offs,get_value=offs
widget_control,(*pstate).snr,get_value=snr
widget_control,(*pstate).off,get_value=off
if offs eq '' then begin
  result=dialog_message(['Please select the offsets estimates file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if snr eq '' then begin
  result=dialog_message(['Please select the SNR values file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if off eq '' then begin
  result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
  return
endif
coffs=workpath+TLI_FNAME(off, /nosuffix)+'.coffs'
coffsets=workpath+TLI_FNAME(off, /nosuffix)+'.coffsets'
widget_control,(*pstate).coffs,set_value=coffs
widget_control,(*pstate).coffs,set_uvalue=coffs
widget_control,(*pstate).coffsets,set_value=coffsets
widget_control,(*pstate).coffsets,set_uvalue=coffsets
end
'opencoffs':begin
;-Check if input master parfile
widget_control,(*pstate).offs,get_value=offs
if offs eq '' then begin
  result=dialog_message(['Please select the offsets estimates file.'],title='Sasmac InSAR',/information,/center)
  return
endif
widget_control,(*pstate).snr,get_value=snr
if snr eq '' then begin
  result=dialog_message(['Please select the SNR values file.'],title='Sasmac InSAR',/information,/center)
  return
endif
widget_control,(*pstate).off,get_value=off
if off eq '' then begin
  result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
  return
endif


temp=file_basename(off)
temp=strsplit(temp,'.',/extract)
off=temp(0)
file=off+'.coffs'
outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.coffs',/overwrite_prompt)
widget_control,(*pstate).coffs,set_value=outfile
widget_control,(*pstate).coffs,set_uvalue=outfile
END
'opencoffsets':begin
;-Check if input master parfile
widget_control,(*pstate).offs,get_value=offs
if offs eq '' then begin
  result=dialog_message(['Please select the offsets estimates file.'],title='Sasmac InSAR',/information,/center)
  return
endif
widget_control,(*pstate).snr,get_value=snr
if snr eq '' then begin
  result=dialog_message(['Please select the SNR values file.'],title='Sasmac InSAR',/information,/center)
  return
endif
widget_control,(*pstate).off,get_value=off
if off eq '' then begin
  result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
  return
endif

temp=file_basename(off)
temp=strsplit(temp,'.',/extract)
off=temp(0)
file=off+'.coffsets'
outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.coffsets',/overwrite_prompt)
widget_control,(*pstate).coffsets,set_value=outfile
widget_control,(*pstate).coffsets,set_uvalue=outfile
END

'ok': begin
  widget_control,(*pstate).off,get_value=off
  widget_control,(*pstate).offs,get_value=offs
  widget_control,(*pstate).snr,get_value=snr
  widget_control,(*pstate).coffs,get_value=coffs
  widget_control,(*pstate).coffsets,get_value=coffsets
  
  widget_control,(*pstate).thres,get_value=thres
  ;      widget_control,(*pstate).npoly,get_value=npoly
  ;      widget_control,(*pstate).inter,get_value=inter
  npoly=WIDGET_INFO((*pstate).npoly,/droplist_select)
  npoly_d=long(npoly)
  Case npoly_d OF
    0: npoly='3'
    1: npoly='1'
    2: npoly='4'
    3: npoly='6'
    else: npoly='-'
  ENDCASE 
  
  inter=WIDGET_INFO((*pstate).inter,/droplist_select)
  inter=STRCOMPRESS(inter, /REMOVE_ALL)
  
  IF NOT FILE_TEST(offs) then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset estimates file.'
    RETURN
  ENDIF
  IF NOT FILE_TEST(snr) then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
    RETURN
  ENDIF
  IF NOT FILE_TEST(off) then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
    RETURN
  ENDIF
  
  if coffs eq '' then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please specify culled offset estimates file.'
    RETURN
  endif
  if coffsets eq '' then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please specify culled offset estimates and snr file.'
    RETURN
  endif
  
  if thres ne '-' then begin
    if thres le 0 then begin
      result=dialog_message(['SNR threshold should be greater than 0:',$
        STRCOMPRESS(thres)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  
  
  coreg_quality=workpath+'coreg_quality'
  
  scr="offset_fit " +offs +' '+snr +' '+off+' '+coffs+' '+coffsets+' '+thres+' '+npoly+' '+inter+' >> '+coreg_quality
  TLI_SMC_SPAWN, scr,info='Range and azimuth offset polynomial estimation, Please wait...'
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


PRO CWN_SMC_OFFSETFIT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=500
  ysize=470
  
  ; Get config info
  off=config.offfile
  offs=FILE_TEST(off)?off+'s':''
  snr=FILE_TEST(off)?off+'.snr':''
  thres='-'
  npoly='4'
  inter='0'
  coffs=FILE_TEST(off)?config.workpath+config.int_date+'.coffs':''
  coffsets=FILE_TEST(off)?config.workpath+config.int_date+'.coffsets':''
  
  if file_test(off) then begin
    temp=TLI_FNAME(off,suffix=suffix)
    IF suffix EQ '.off' THEN BEGIN
      finfo=TLI_LOAD_PAR(off)
      
      thres=STRCOMPRESS(string(long(finfo.offset_estimation_threshhold)),/remove_all)
      
    ENDIF
  endif
  
  
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='offset_fit',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  offsID=widget_base(tlb,row=1, frame=1)
  offs=widget_text(offsID,value=offs,uvalue=offs,uname='offs',/editable,xsize=62)
  openoffs=widget_button(offsID,value='Input Offs',uname='openoffs',xsize=100)
  
  snrID=widget_base(tlb,row=1, frame=1)
  snr=widget_text(snrID,value=snr,uvalue=snr,uname='snr',/editable,xsize=62)
  opensnr=widget_button(snrID,value='Input offsnr',uname='opensnr',xsize=100)
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=62)
  openoff=widget_button(offID,value='Input Offeset',uname='openoff',xsize=100)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize)
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  thresID=widget_base(tempID,/column, xsize=xsize/3-5)
  threslabel=widget_label(thresID, value='SNR Threshold:',/ALIGN_LEFT)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  thres2ID=widget_base(tempID,/column, xsize=xsize/3-5)
  thres=widget_text(thres2ID, value=thres,uvalue=thres, uname='thres',/editable,xsize=10)
  
  
  infoID=widget_base(labID,/row, xsize=xsize)
  temp=widget_base(infoID,/row,xsize=xsize/2,frame=1)
  lab=widget_label(temp,value='Polynomial parameters:')
  
  npoly=widget_droplist(temp, value=['4          ',$  
    '1          ',$    
    '3          ',$    
    '6          '])
  temp=widget_base(infoID,/row,xsize=xsize/2-25,frame=1)
  lab=widget_label(temp,value='Interact mode:')
  inter=widget_droplist(temp, value=['Off          ',$
    'On'])
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Range and azimuth offset polynomial estimation:',/align_left,/dynamic_resize)
  
  coffsID=widget_base(tlb,row=1, frame=1)
  coffs=widget_text(coffsID,value=coffs,uvalue=coffs,uname='coffs',/editable,xsize=62)
  opencoffs=widget_button(coffsID,value='Output Coffs',uname='opencoffs',xsize=100)
  
  coffsetsID=widget_base(tlb,row=1, frame=1)
  coffsets=widget_text(coffsetsID,value=coffsets,uvalue=coffsets,uname='coffsets',/editable,xsize=62)
  opencoffsets=widget_button(coffsetsID,value='Output coffsets',uname='opencoffsets',xsize=100)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30)
  
  ;Recognize components
  state={offs:offs,$
    openoffs:openoffs,$
    snr:snr,$
    opensnr:opensnr,$
    off:off,$
    openoff:openoff,$
    thres:thres,$
    npoly:npoly,$
    inter:inter,$
    coffs:coffs,$
    opencoffs:opencoffs,$
    coffsets:coffsets,$
    opencoffsets:opencoffsets,$
    
    ok:ok,$
    cl:cl $
    }
    
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_OFFSETFIT',tlb,/no_block
END