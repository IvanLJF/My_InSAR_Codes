PRO CWN_SMC_SLCINTF_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openmaster':begin
    master=config.m_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=slave)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    config.m_slc=infile
    config.m_slcpar=infile+'.par'
    
    master=config.m_slc
    mparfile=config.m_slcpar
    finfo=TLI_LOAD_SLC_PAR(mparfile)
    temp=TLI_MLFACTOR(parfile=mparfile)
    nlines=STRCOMPRESS(string(long(finfo.azimuth_lines)),/REMOVE_ALL)
    rlks=STRCOMPRESS(temp[0],/REMOVE_ALL)
    azlks=STRCOMPRESS(temp[1],/REMOVE_ALL)
    
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile
    widget_control,(*pstate).mpar,set_value=mparfile
    widget_control,(*pstate).mpar,set_uvalue=mparfile
    widget_control,(*pstate).nlines,set_value=nlines
    widget_control,(*pstate).nlines,set_uvalue=nlines
    widget_control, (*pstate).rlks, set_value=rlks, set_uvalue=rlks
    widget_control, (*pstate).azlks, set_value=azlks, set_uvalue=azlks
    
  END
  'openrslave':begin
  slave=config.s_slc
  infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=slave)
  IF NOT FILE_TEST(infile) THEN return
  
  ; Update widget info.
  config.s_rslc=infile
  config.s_rslcpar=infile+'.par'
  
  rsparfile=config.s_rslcpar
  widget_control,(*pstate).rslave,set_value=infile
  widget_control,(*pstate).rslave,set_uvalue=infile
  widget_control,(*pstate).rspar,set_value=rsparfile
  widget_control,(*pstate).rspar,set_uvalue=rsparfile
  
END
'openoff':begin
infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath)
IF NOT FILE_TEST(infile) THEN return

; Update definitions
config.offfile=infile
widget_control,(*pstate).off,set_value=infile
widget_control,(*pstate).off,set_uvalue=infile

widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).rslave,get_value=rslave
widget_control,(*pstate).off,get_value=off
IF NOT FILE_TEST(master) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
  RETURN
ENDIF
IF NOT FILE_TEST(rslave) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
  RETURN
ENDIF
IF NOT FILE_TEST(off) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
  RETURN
ENDIF
intf=workpath+PATH_SEP()+TLI_FNAME(off, /nosuffix)+'.int'
widget_control,(*pstate).intf,set_value=intf
widget_control,(*pstate).intf,set_uvalue=intf
config.intfile=intf
end
'openintf':begin
;-Check if input master parfile
widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).rslave,get_value=rslave
widget_control,(*pstate).off,get_value=off
IF NOT FILE_TEST(master) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
  RETURN
ENDIF
IF NOT FILE_TEST(rslave) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
  RETURN
ENDIF
IF NOT FILE_TEST(off) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
  RETURN
ENDIF

temp=file_basename(off)
temp=strsplit(temp,'.',/extract)
off=temp(0)
file=off+'.int'
outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.int',/overwrite_prompt)
widget_control,(*pstate).intf,set_value=outfile
widget_control,(*pstate).intf,set_uvalue=outfile
config.intfile=outfile
END

'ok': begin
  widget_control,(*pstate).master,get_value=master
  widget_control,(*pstate).rslave,get_value=rslave
  widget_control,(*pstate).off,get_value=off
  widget_control,(*pstate).mpar,get_value=mparfile
  widget_control,(*pstate).rspar,get_value=rsparfile
  widget_control,(*pstate).intf,get_value=intf
  
  
  widget_control,(*pstate).rlks,get_value=rlks
  widget_control,(*pstate).azlks,get_value=azlks
  widget_control,(*pstate).loff,get_value=loff
  widget_control,(*pstate).nlines,get_value=nlines
  
  config.ml_r=rlks
  config.ml_azi=azlks
  
  spsflg=WIDGET_INFO((*pstate).spsflg,/droplist_select)
  spsflg_d=long(spsflg)
  if spsflg_d eq 0 then begin
    spsflg=STRCOMPRESS(string(spsflg_d+1),/REMOVE_ALL)
  endif
  if spsflg_d ne 0 then begin
    spsflg=STRCOMPRESS(string(spsflg_d-1),/REMOVE_ALL)
  endif
  
  azfflg=WIDGET_INFO((*pstate).azfflg,/droplist_select)
  azfflg_d=long(azfflg)
  if azfflg_d eq 0 then begin
    azfflg=STRCOMPRESS(string(azfflg_d+1),/REMOVE_ALL)
  endif
  if azfflg_d ne 0 then begin
    azfflg=STRCOMPRESS(string(azfflg_d-1),/REMOVE_ALL)
  endif
  
  rp1flg=WIDGET_INFO((*pstate).rp1flg,/droplist_select)
  rp1flg_d=long(rp1flg)
  if rp1flg_d eq 0 then begin
    rp1flg=STRCOMPRESS(string(rp1flg_d+1),/REMOVE_ALL)
  endif
  if rp1flg_d ne 0 then begin
    rp1flg=STRCOMPRESS(string(rp1flg_d-1),/REMOVE_ALL)
  endif
  
  rp2flg=WIDGET_INFO((*pstate).rp2flg,/droplist_select)
  rp2flg_d=long(rp2flg)
  if rp2flg_d eq 0 then begin
    rp2flg=STRCOMPRESS(string(rp2flg_d+1),/REMOVE_ALL)
  endif
  if rp2flg_d ne 0 then begin
    rp2flg=STRCOMPRESS(string(rp2flg_d-1),/REMOVE_ALL)
  endif
  
  IF NOT FILE_TEST(master) then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
    RETURN
  ENDIF
  IF NOT FILE_TEST(rslave) then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
    RETURN
  ENDIF
  IF NOT FILE_TEST(mparfile) then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please select input master par file.'
    RETURN
  ENDIF
  IF NOT FILE_TEST(rsparfile) then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave par file.'
    RETURN
  ENDIF
  IF NOT FILE_TEST(off) then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
    RETURN
  ENDIF
  
  if intf eq '' then begin
    TLI_SMC_DUMMY, inputstr='ERROR! Please specify interferogram file.'
    return
  endif
  
  if rlks ne '-' then begin
    if rlks le 0 then begin
      result=dialog_message(['number of range looks should be greater than 0:',$
        STRCOMPRESS(rlks)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if azlks ne '-' then begin
    if azlks le 0 then begin
      result=dialog_message(['number of azimuth looks should be greater than 0:',$
        STRCOMPRESS(azlks)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if loff ne '-' then begin
    if loff lt 0 then begin
      result=dialog_message(['offset to starting line relative to SLC1 for interferogram should be greater than 0:',$
        STRCOMPRESS(loff)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if nlines ne '-' then begin
    if nlines le 0 then begin
      result=dialog_message(['number of SLC lines to process should be greater than 0:',$
        STRCOMPRESS(nlines)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  
  config.ml_r=LONG(rlks)
  config.ml_azi=LONG(azlks)
  
  finfo=TLI_LOAD_SLC_PAR(rsparfile)
  data_type=STRCOMPRESS(finfo.image_format,/REMOVE_ALL)
  if data_type eq 'SCOMPLEX' then begin
    dtype=STRCOMPRESS(1,/REMOVE_ALL)
  endif
  if data_type eq 'FCOMPLEX' then begin
    dtype=STRCOMPRESS(0,/REMOVE_ALL)
  endif
  range=STRCOMPRESS(STRING(long(finfo.range_samples)),/REMOVE_ALL)
  azimuth=STRCOMPRESS(STRING(long(finfo.azimuth_lines)),/REMOVE_ALL)
  rasfile=rslave+'.ras'
  rasscr='rasSLC '+rslave+' '+range+' 1 '+azimuth+' '+rlks+' '+azlks+' 1. .35 1 '+dtype+' - '+rasfile
  scr="SLC_intf " +master +' '+rslave +' '+master+'.par '+rslave+'.par '+off+' '+intf+' '+rlks+' '+azlks+' '+loff+' '+nlines+' '+spsflg+' '+azfflg+' '+rp1flg+' '+rp2flg
  
  TLI_SMC_SPAWN, rasscr,info='Calculating Interferogram, Please wait...',/supress
  TLI_SMC_SPAWN, scr,info='Calculating Interferogram, Please wait...',/supress
  
  rasmph='rasmph '+intf+' '+range+' - - - - - - - '+intf+'.ras '+'0'
  TLI_SMC_SPAWN, rasmph,info='Calculating Interferogram, Please wait...'
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


PRO CWN_SMC_SLCINTF
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=630
  ysize=640
  
  ; Get config info
  workpath=config.workpath
  m_slc=config.m_slc
  s_rslc=config.s_rslc
  mparfile=config.m_slcpar
  rsparfile=config.s_rslcpar
  off=config.offfile
  rlks=STRCOMPRESS(config.ml_r,/remove_all)
  azlks=STRCOMPRESS(config.ml_azi,/remove_all)
  loff='0'
  nlines='-'
  
  intf=''
  
  IF FILE_TEST(mparfile) THEN BEGIN
    finfo=TLI_LOAD_SLC_PAR(mparfile)
    nlines=STRCOMPRESS(STRING(long(finfo.azimuth_lines)),/REMOVE_ALL)
    temp=TLI_MLFACTOR(mparfile)
    rlks=STRCOMPRESS(temp[0],/remove_all)
    azlks=STRCOMPRESS(temp[1],/remove_all)
  ENDIF
  
  if FILE_TEST(off) then begin
    temp=TLI_FNAME(off,suffix=suffix)
    IF suffix EQ '.off' THEN BEGIN
      intf=workpath+PATH_SEP()+TLI_FNAME(off, /nosuffix)+'.int'
      config.intfile=intf
    ENDIF
  endif
  
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='SLC_intf',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=m_slc,uvalue=m_slc,uname='master',/editable,xsize=84)
  openmaster=widget_button(masterID,value='Input Master',uname='openmaster',xsize=100)
  
  rslaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  rslave=widget_text(rslaveID,value=s_rslc,uvalue=s_rslc,uname='Rslave',/editable,xsize=84)
  openrslave=widget_button(rslaveID,value='Input Rslave',uname='openrslave',xsize=100)
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=84)
  openoff=widget_button(offID,value='Input Offset',uname='openoff',xsize=100)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input SLC parameters:',/align_left,/dynamic_resize)
  
  mparID=widget_base(labID,/row,xsize=xsize,frame=1)
  mpar=widget_text(mparID,value=mparfile,uvalue=mparfile,uname='mpar',/editable,xsize=101)
  
  rsparID=widget_base(labID,/row, xsize=xsize,frame=1)
  rspar=widget_text(rsparID,value=rsparfile,uvalue=rsparfile,uname='rspar',/editable,xsize=101)
  
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-5, frame=1)
  rlksID=widget_base(tempID,/column, xsize=xsize/4-5)
  rlkslabel=widget_label(rlksID, value='Range Looks:',/ALIGN_LEFT)
  rlks=widget_text(rlksID, value=rlks,uvalue=rlks, uname='rlks',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  azlksID=widget_base(tempID,/column, xsize=xsize/4-10)
  azlkslabel=widget_label(azlksID, value='Azimuth Looks:',/ALIGN_LEFT)
  azlks=widget_text(azlksID, value=azlks,uvalue=azlks, uname='azlks',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  loffID=widget_base(tempID,/column, xsize=xsize/4-10)
  lofflabel=widget_label(loffID, value='First Offset Line:',/ALIGN_LEFT)
  loff=widget_text(loffID, value=loff,uvalue=loff, uname='loff',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-20, frame=1)
  nlinesID=widget_base(tempID,/column, xsize=xsize/4-20)
  nlineslabel=widget_label(nlinesID, value='Offset Line Number:',/ALIGN_LEFT)
  nlines=widget_text(nlinesID, value=nlines,uvalue=nlines, uname='nlines',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-5, frame=1)
  spsflgID=widget_base(tempID,/column, xsize=xsize/2,/ALIGN_LEFT)
  spsflglabel=widget_label(spsflgID, value='Range spectral Flag:',/ALIGN_CENTER)
  
  spsflg=widget_droplist(spsflgID, value=['1: apply spectral shift filter(default)',$
    '0: do not apply spectral shift filter'])
    
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  rp1flgID=widget_base(tempID,/column, xsize=xsize/2)
  rp1flglabel=widget_label(rp1flgID, value='SLC1 Range Phase Mode:',/ALIGN_CENTER)
  rp1flg=widget_droplist(rp1flgID, value=['1: ref. function center (Doppler centroid)',$
    '0: nearest approach (zero-Doppler) phase'])
    
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-5, frame=1)
  azfflgID=widget_base(tempID,/column, xsize=xsize/2)
  azfflglabel=widget_label(azfflgID, value='Azimuth Filter Flag:',/ALIGN_CENTER)
  azfflg=widget_droplist(azfflgID, value=['1: apply azimuth common-band filter(default)',$
    '0: do not apply azimuth common band filter'])
    
    
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  rp2flgID=widget_base(tempID,/column, xsize=xsize/2)
  rp2flglabel=widget_label(rp2flgID, value='SLC2 Range Phase Mode:',/ALIGN_CENTER)
  
  rp2flg=widget_droplist(rp2flgID, value=['1: ref. function center (Doppler centroid)',$
    '0: nearest approach (zero-Doppler) phase'])
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Interferogram generation from co-registered SLC data:',/align_left,/dynamic_resize)
  
  intfID=widget_base(tlb,row=1, frame=1)
  intf=widget_text(intfID,value=intf,uvalue=intf,uname='intf',/editable,xsize=84)
  openintf=widget_button(intfID,value='Output intf',uname='openintf',xsize=100)
  
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30)
  
  ;Recognize components
  state={master:master,$
    openmaster:openmaster,$
    rslave:rslave,$
    openrslave:openrslave,$
    off:off,$
    openoff:openoff,$
    mpar:mpar,$
    rspar:rspar,$
    
    rlks:rlks,$
    azlks:azlks,$
    loff:loff,$
    nlines:nlines,$
    spsflg:spsflg,$
    azfflg:azfflg,$
    rp1flg:rp1flg,$
    rp2flg:rp2flg,$
    
    intf:intf,$
    openintf:openintf,$
    
    
    ok:ok,$
    cl:cl $
    }
    
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_SLCINTF',tlb,/no_block
END