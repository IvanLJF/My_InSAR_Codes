PRO CWN_SMC_OFFSETPWRM_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openmaster':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rdc', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
    
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile
    
  END
  'openslave':begin
  infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.pwr', path=workpath)
  IF NOT FILE_TEST(infile) THEN return
  
  sparfile=infile+'.par'
  widget_control,(*pstate).slave,set_value=infile
  widget_control,(*pstate).slave,set_uvalue=infile
  
END
'openoff':begin
infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.diff_par', path=workpath)
IF NOT FILE_TEST(infile) THEN return

widget_control,(*pstate).off,set_value=infile
widget_control,(*pstate).off,set_uvalue=infile

widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).slave,get_value=slave
widget_control,(*pstate).off,get_value=diff_par
if master eq '' then begin
  result=dialog_message(['Please select the master file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if slave eq '' then begin
  result=dialog_message(['Please select the slave file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if diff_par eq '' then begin
  result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
  return
endif
offs=workpath+TLI_FNAME(slave, /nosuffix)+'.offs'
snr=workpath+TLI_FNAME(slave, /nosuffix)+'.snr'
offsets=workpath+'offsets'
widget_control,(*pstate).offs,set_value=offs
widget_control,(*pstate).offs,set_uvalue=offs
widget_control,(*pstate).snr,set_value=snr
widget_control,(*pstate).snr,set_uvalue=snr
widget_control,(*pstate).offsets,set_value=offsets
widget_control,(*pstate).offsets,set_uvalue=offsets
end
'openoffs':begin
;-Check if input master parfile
widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).slave,get_value=slave
widget_control,(*pstate).off,get_value=diff_par
if master eq '' then begin
  result=dialog_message(['Please select the master file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if slave eq '' then begin
  result=dialog_message(['Please select the slave file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if diff_par eq '' then begin
  result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
  return
endif

workpath=config.workpath
temp=file_basename(master)
temp=strsplit(slave,'.',/extract)
slave=temp(0)
file=slave+'.offs'
outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.offs',/overwrite_prompt)
widget_control,(*pstate).offs,set_value=outfile
widget_control,(*pstate).offs,set_uvalue=outfile
END
'opensnr':begin
;-Check if input master parfile
widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).slave,get_value=slave
widget_control,(*pstate).off,get_value=diff_par
if master eq '' then begin
  result=dialog_message(['Please select the master file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if slave eq '' then begin
  result=dialog_message(['Please select the slave file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if diff_par eq '' then begin
  result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
  return
endif

workpath=config.workpath
temp=file_basename(slave)
temp=strsplit(temp,'.',/extract)
slave=temp(0)
file=slave+'.snr'
outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.snr',/overwrite_prompt)
widget_control,(*pstate).snr,set_value=outfile
widget_control,(*pstate).snr,set_uvalue=outfile
END
'openoffsets':begin
;-Check if input master parfile
widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).slave,get_value=slave
widget_control,(*pstate).off,get_value=diff_par
if master eq '' then begin
  result=dialog_message(['Please select the master file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if slave eq '' then begin
  result=dialog_message(['Please select the slave file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if diff_par eq '' then begin
  result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
  return
endif

workpath=config.workpath
file='offsets'
outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='offsets',/overwrite_prompt)
widget_control,(*pstate).offsets,set_value=outfile
widget_control,(*pstate).offsets,set_uvalue=outfile
END

'ok': begin
  widget_control,(*pstate).master,get_value=master
  widget_control,(*pstate).slave,get_value=slave
  widget_control,(*pstate).off,get_value=diff_par
  
  widget_control,(*pstate).offs,get_value=offs
  widget_control,(*pstate).snr,get_value=snr
  widget_control,(*pstate).offsets,get_value=offsets
  
  widget_control,(*pstate).rest,get_value=rest
  widget_control,(*pstate).azest,get_value=azest
  
  widget_control,(*pstate).estth,get_value=estth
  widget_control,(*pstate).rwisz,get_value=rwisz
  widget_control,(*pstate).azwisz,get_value=azwisz
  
  pflg=WIDGET_INFO((*pstate).pflg,/droplist_select)
  Case pflg OF
    0 : pflg='1'
    1 : pflg='0'
    Else : pflg='1'
  ENDCASE
  
  ovr=WIDGET_INFO((*pstate).ovr,/droplist_select)
  Case ovr OF
    0  : ovr='2'
    1  : ovr='1'
    2  : ovr='4'
    else: ovr='2'
  ENDCASE  
  
  if master eq '' then begin
    result=dialog_message(['Please select the master file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if slave eq '' then begin
    result=dialog_message(['Please select the slave file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  
  if diff_par eq '' then begin
    result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if offs eq '' then begin
    result=dialog_message('Please specify offs file',title='Sasmac InSAR',/information,/center)
    return
  endif
  if snr eq '' then begin
    result=dialog_message('Please specify snr file',title='Sasmac InSAR',/information,/center)
    return
  endif
  if offsets eq '' then begin
    result=dialog_message('Please specify coffsets file',title='Sasmac InSAR',/information,/center)
    return
  endif
  
  IF STRLOWCASE(rest) EQ 'default' THEN rest='-'
  if rest ne '-' then begin
    if rest le 0 then begin
      result=dialog_message(['number of offset estimates in range direction should be greater than 0:',$
        STRCOMPRESS(rest)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  
  IF STRLOWCASE(azest) EQ 'default' THEN azest='-'
  if azest ne '-' then begin
    if azest le 0 then begin
      result=dialog_message(['number of offset estimates in azimuth direction should be greater than 0:',$
        STRCOMPRESS(azest)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  
;  IF STRLOWCASE(rwisz) EQ 'default' THEN rwisz='-'
  if rwisz ne '-' then begin
    if rwisz le 0 then begin
      result=dialog_message(['range window size should be greater than 0:',$
        STRCOMPRESS(rwisz)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if azwisz ne '-' then begin
    if azwisz le 0 then begin
      result=dialog_message(['azimuth window size should be greater than 0:',$
        STRCOMPRESS(azwisz)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  
  IF STRLOWCASE(estth) EQ 'default' THEN estth='-'
  if estth ne '-' then begin
    if estth le 0 then begin
      result=dialog_message(['offset estimation quality threshold should be greater than 0:',$
        STRCOMPRESS(estth)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  
  scr="offset_pwrm " +master +' '+slave +' '+diff_par+' '+offs+' '+snr+' '+rwisz+' '+azwisz+' '+offsets+' '+ovr+' '+rest+' '+azest+' '+estth+' '+pflg
  TLI_SMC_SPAWN, scr,info='Offsets between MLI images using intensity cross-correlation, Please wait...'
  
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


PRO CWN_SMC_OFFSETPWRM
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=560
  
  ; Get config info
  master=''
  slave=''
  off=''
  rest='Default'
  azest='Default'
  rwisz='128'
  azwisz='128'
  ovr='2'
  estth='Default'
  pflg='0'
  offs=''
  snr=''
  offsets=''
  
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='offset_pwrm',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=master,uvalue=master,uname='master',/editable,xsize=73)
  openmaster=widget_button(masterID,value='Sim sar',uname='openmaster',xsize=95)
  
  slaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slave=widget_text(slaveID,value=slave,uvalue=slave,uname='Slave',/editable,xsize=73)
  openslave=widget_button(slaveID,value='MLI',uname='openslave',xsize=95)
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=inputfile,uvalue=inputfile,uname='off',/editable,xsize=73)
  openoff=widget_button(offID,value='Diff_par',uname='openoff',xsize=95)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize)
  
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  rwiszID=widget_base(tempID,/column, xsize=xsize/4-5)
  rwiszlabel=widget_label(rwiszID, value='Range Window Size:',/ALIGN_LEFT)
  rwisz=widget_text(rwiszID, value=rwisz,uvalue=rwisz, uname='rwisz',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  azwiszID=widget_base(tempID,/column, xsize=xsize/4-5)
  azwiszlabel=widget_label(azwiszID, value='Azimuth Window Size:',/ALIGN_LEFT)
  azwisz=widget_text(azwiszID, value=azwisz,uvalue=azwisz, uname='azwisz',/editable,xsize=10)
  
  ;-----------------------------------------------------------------------------------------
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  restID=widget_base(tempID,/column, xsize=xsize/4-5)
  restlabel=widget_label(restID, value='Range Estimates:',/ALIGN_LEFT)
  rest=widget_text(restID, value=rest,uvalue=rest, uname='rest',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  azestID=widget_base(tempID,/column, xsize=xsize/4-5)
  azestlabel=widget_label(azestID, value='Azimuth Estimates:',/ALIGN_LEFT)
  azest=widget_text(azestID, value=azest,uvalue=azest, uname='azest',/editable,xsize=10)
  
  ;-------------------------------------------------------------------------------------------
  ;other parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  estthID=widget_base(tempID,/column, xsize=xsize/4-5)
  estthlabel=widget_label(estthID, value='Estimation Threshold:',/ALIGN_LEFT)
  estth=widget_text(estthID, value=estth,uvalue=estth, uname='estth',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-25, frame=1)
  ovrID=widget_base(tempID,/column, xsize=xsize/3)
  ovrlabel=widget_label(ovrID, value='Image oversampling Factor:',/ALIGN_LEFT)
  
  ovr=widget_droplist(ovrID, value=['    2    ',$
    '    1    ',$
    '    4    '])
    
    
  tempID=widget_base(infoID,/row,xsize=xsize/3+45, frame=1)
  pflgID=widget_base(tempID,/column, xsize=xsize/3+40)
  pflglabel=widget_label(pflgID, value='Print Flag:',/ALIGN_CENTER)
  
  pflg=widget_droplist(pflgID, value=['All offset data',$
    'Offset summary'])
    
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Offsets between MLI images using intensity cross-correlation:',/align_left,/dynamic_resize)
  
  offsID=widget_base(tlb,row=1, frame=1)
  offs=widget_text(offsID,value=offs,uvalue=offs,uname='offs',/editable,xsize=73)
  openoffs=widget_button(offsID,value='Output Offs',uname='openoffs',xsize=95)
  
  snrID=widget_base(tlb,row=1, frame=1)
  snr=widget_text(snrID,value=snr,uvalue=snr,uname='snr',/editable,xsize=73)
  opensnr=widget_button(snrID,value='Output offsnr',uname='opensnr',xsize=95)
  
  offsetsID=widget_base(tlb,row=1, frame=1)
  offsets=widget_text(offsetsID,value=offsets,uvalue=offsets,uname='offsets',/editable,xsize=73)
  openoffsets=widget_button(offsetsID,value='Output offsets',uname='openoffsets',xsize=95)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30)
  
  ;Recognize components
  state={master:master,$
    openmaster:openmaster,$
    slave:slave,$
    openslave:openslave,$
    off:off,$
    openoff:openoff,$
    rwisz:rwisz,$
    azwisz:azwisz,$
    rest:rest,$
    azest:azest,$
    ovr:ovr,$
    estth:estth,$
    pflg:pflg,$
    offs:offs,$
    openoffs:openoffs,$
    snr:snr,$
    opensnr:opensnr,$
    offsets:offsets,$
    openoffsets:openoffsets,$
    
    ok:ok,$
    cl:cl $
    }
    
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_OFFSETPWRM',tlb,/no_block
END