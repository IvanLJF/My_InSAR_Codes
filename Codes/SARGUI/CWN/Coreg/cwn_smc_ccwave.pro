PRO CWN_SMC_CCWAVE_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openintf':begin
    intfile=config.intfile
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.int', path=workpath,file=intfile)
    IF NOT FILE_TEST(infile) THEN return
    ; Update definitions
    config.intfile=infile
    TLI_SMC_DEFINITIONS_UPDATE, inputfile=infile
    
    widget_control,(*pstate).intf,set_value=infile
    widget_control,(*pstate).intf,set_uvalue=infile
    fpath=STRSPLIT(infile,'/',/extract)
    pathsize=size(fpath)
    fname=fpath(pathsize(1)-1)
    file=STRSPLIT(fname,'-',/extract)
    master=STRCOMPRESS(file(0))
    sfile=STRSPLIT(file(1),'.',/extract)
    slave=STRCOMPRESS(sfile(0))
    pwr1=workpath+PATH_SEP()+master+'.pwr' & pwr1=FILE_TEST(pwr1)? pwr1: 'Not found. Will be ignored.'
    pwr2=workpath+PATH_SEP()+slave+'.pwr' & pwr2=FILE_TEST(pwr2)?pwr2:'Not found. Will be ignored.'
    parfile=workpath+PATH_SEP()+master+'.pwr.par' & parfile=FILE_TEST(parfile)?parfile:config.m_rslcpar
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(string(long(finfo.range_samples)),/REMOVE_ALL)
    rpixl=STRCOMPRESS(string(long(finfo.range_samples)-1),/REMOVE_ALL)
    azrpixl=STRCOMPRESS(string(long(finfo.azimuth_lines)-1),/REMOVE_ALL)
    coh=workpath+PATH_SEP()+TLI_FNAME(infile, /nosuffix)+'.cc'
    
    
    widget_control,(*pstate).width,set_value=width
    widget_control,(*pstate).width,set_uvalue=width
    widget_control,(*pstate).rpixl,set_value=rpixl
    widget_control,(*pstate).rpixl,set_uvalue=rpixl
    widget_control,(*pstate).azrpixl,set_value=azrpixl
    widget_control,(*pstate).azrpixl,set_uvalue=azrpixl
    
    widget_control,(*pstate).pwr1,set_value=pwr1
    widget_control,(*pstate).pwr1,set_uvalue=pwr1
    widget_control,(*pstate).pwr2,set_value=pwr2
    widget_control,(*pstate).pwr2,set_uvalue=pwr2
    widget_control,(*pstate).coh,set_value=coh
    widget_control,(*pstate).coh,set_uvalue=coh
    
    
    widget_control,(*pstate).intf,get_value=intf
    widget_control,(*pstate).pwr1,get_value=pwr1
    widget_control,(*pstate).pwr2,get_value=pwr2
    
    if intf eq '' then begin
      result=dialog_message(['Please select the interferogram file.'],title='Sasmac InSAR',/information,/center)
      return
    endif
    if pwr1 ne '-' then begin
      if pwr1 eq '' then begin
        result=dialog_message(['Please select intensity image of the first scene file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
    endif
    if pwr2 ne '-' then begin
      if pwr2 eq '' then begin
        result=dialog_message(['Please select intensity image of the second scene file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
    endif
    
    coh=workpath+TLI_FNAME(intf, /nosuffix)+'.cc'
    widget_control,(*pstate).coh,set_value=coh
    widget_control,(*pstate).coh,set_uvalue=coh
  END
  'openpwr1':begin
  infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.pwr', path=workpath)
  IF NOT FILE_TEST(infile) THEN return
  
  ; Update definitions
  
  widget_control,(*pstate).pwr1,set_value=infile
  widget_control,(*pstate).pwr1,set_uvalue=infile
  
  widget_control,(*pstate).intf,get_value=intf
  widget_control,(*pstate).pwr1,get_uvalue=pwr1
  widget_control,(*pstate).pwr2,get_uvalue=pwr2
  
  if intf eq '' then begin
    result=dialog_message(['Please select the interferogram file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if pwr1 ne '-' then begin
    if pwr1 eq '' then begin
      result=dialog_message(['Please select intensity image of the first scene file.'],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if pwr2 ne '-' then begin
    if pwr2 eq '' then begin
      result=dialog_message(['Please select intensity image of the second scene file.'],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  
  coh=workpath+TLI_FNAME(intf, /nosuffix)+'.cc'
  widget_control,(*pstate).coh,set_value=coh
  widget_control,(*pstate).coh,set_uvalue=coh
  
END
'openpwr2':begin
infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.pwr', path=workpath)
IF NOT FILE_TEST(infile) THEN return

; Update definitions

widget_control,(*pstate).pwr2,set_value=infile
widget_control,(*pstate).pwr2,set_uvalue=infile

widget_control,(*pstate).intf,get_value=intf
widget_control,(*pstate).pwr1,get_uvalue=pwr1
widget_control,(*pstate).pwr2,get_uvalue=pwr2

if intf eq '' then begin
  result=dialog_message(['Please select the interferogram file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if pwr1 ne '-' then begin
  if pwr1 eq '' then begin
    result=dialog_message(['Please select intensity image of the first scene file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
endif
if pwr2 ne '-' then begin
  if pwr2 eq '' then begin
    result=dialog_message(['Please select intensity image of the second scene file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
endif

coh=workpath+TLI_FNAME(intf, /nosuffix)+'.cc'
widget_control,(*pstate).coh,set_value=coh
widget_control,(*pstate).coh,set_uvalue=coh
end
'opencoh':begin
;-Check if input master parfile
widget_control,(*pstate).intf,get_value=intf
widget_control,(*pstate).pwr1,get_uvalue=pwr1
widget_control,(*pstate).pwr2,get_uvalue=pwr2

if intf eq '' then begin
  result=dialog_message(['Please select the interferogram file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if pwr1 ne '-' then begin
  if pwr1 eq '' then begin
    result=dialog_message(['Please select intensity image of the first scene file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
endif
if pwr2 ne '-' then begin
  if pwr2 eq '' then begin
    result=dialog_message(['Please select intensity image of the second scene file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
endif
workpath=config.workpath
coh=workpath+TLI_FNAME(intf, /nosuffix)+'.cc'
outfile=dialog_pickfile(title='',/write,file=coh,filter='*.cc',/overwrite_prompt)
widget_control,(*pstate).coh,set_value=outfile
widget_control,(*pstate).coh,set_uvalue=outfile

END

'ok': begin
  widget_control,(*pstate).intf,get_value=intf
  widget_control,(*pstate).pwr1,get_value=pwr1
  widget_control,(*pstate).pwr2,get_value=pwr2
  widget_control,(*pstate).coh,get_value=coh
  
  widget_control,(*pstate).width,get_value=width
  widget_control,(*pstate).clwisz,get_value=clwisz
  widget_control,(*pstate).rwisz,get_value=rwisz
  widget_control,(*pstate).rpixs,get_value=rpixs
  widget_control,(*pstate).rpixl,get_value=rpixl
  widget_control,(*pstate).azrpixs,get_value=azrpixs
  widget_control,(*pstate).azrpixl,get_value=azrpixl
  wflg=WIDGET_INFO((*pstate).wflg,/droplist_select)
  wflg=STRCOMPRESS(wflg,/REMOVE_ALL)
  
  if intf eq '' then begin
    result=dialog_message(['Please select the interferogram file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  
  IF NOT FILE_TEST(pwr1) THEN pwr1='-'
  IF NOT FILE_TEST(pwr2) THEN pwr2='-'
  
  if coh eq '' then begin
    result=dialog_message('Please specify  the coherence file',title='Sasmac InSAR',/information,/center)
    return
  endif
  
  if width le 0 then begin
    result=dialog_message(['number of samples/row should be greater than 0:',$
      STRCOMPRESS(width)],title='Sasmac InSAR',/information,/center)
    return
  endif
  
  if clwisz lt 0 then begin
    result=dialog_message(['coherence window size (columns) should be greater than 0:',$
      STRCOMPRESS(clwisz)],title='Sasmac InSAR',/information,/center)
    return
  endif
  if rwisz lt 0 then begin
    result=dialog_message(['coherence window size (row) should be greater than 0:',$
      STRCOMPRESS(rwisz)],title='Sasmac InSAR',/information,/center)
    return
  endif
  
  if rpixs ne '-' then begin
    if rpixs lt 0 then begin
      result=dialog_message(['starting range pixel offset should be greater than 0:',$
        STRCOMPRESS(rpixs)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if rpixl ne '-' then begin
    if rpixl lt 0 then begin
      result=dialog_message(['last range pixel offset should be greater than 0:',$
        STRCOMPRESS(rpixl)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if azrpixs ne '-' then begin
    if azrpixs lt 0 then begin
      result=dialog_message(['starting azimuth row offset, relative to start should be greater than 0:',$
        STRCOMPRESS(azrpixs)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if azrpixl ne '-' then begin
    if azrpixl lt 0 then begin
      result=dialog_message(['last azimuth row offset, relative to start should be greater than 0:',$
        STRCOMPRESS(azrpixl)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  
  scr="cc_wave " +intf +' '+pwr1 +' '+pwr2+' '+coh+' '+width+' '+clwisz+' '+rwisz+' '+wflg+' '+rpixs+' '+rpixl+' '+azrpixs+' '+azrpixl
  TLI_SMC_SPAWN, scr,info='Step 1/2: Interferogram coherence estimation, Please wait...',/supress
  
  rascc='rascc '+coh+' '+pwr2+' '+width
  TLI_SMC_SPAWN, rascc,info='Step 2/2: DISP Program rascc, Please wait...'
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


PRO CWN_SMC_CCWAVE
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=530
  ysize=525
  
  ; Get config info
  workpath=config.workpath
  intf=config.intfile
  pwr1='-'
  pwr2='-'
  width=''
  wflg='0'
  clwisz='5.0'
  rpixs='0'
  azrpixs='0'
  rwisz='5.0'
  rpixl='-'
  azrpixl='-'
  coh=''
  if FILE_TEST(intf) then begin
    TLI_SMC_DEFINITIONS_UPDATE, inputfile=intf
    temp=TLI_FNAME(intf,suffix=suffix)
    IF suffix EQ '.int' THEN BEGIN
      fpath=STRSPLIT(intf,'/',/extract)
      pathsize=size(fpath)
      fname=fpath(pathsize(1)-1)
      file=STRSPLIT(fname,'-',/extract)
      master=STRCOMPRESS(file(0))
      sfile=STRSPLIT(file(1),'.',/extract)
      slave=STRCOMPRESS(sfile(0))
      pwr1=FILE_TEST(workpath+master+'.pwr')?workpath+PATH_SEP()+master+'.pwr':'Not found. Will be ignored.'
      pwr2=FILE_TEST(workpath+slave+'.pwr')?workpath+PATH_SEP()+slave+'.pwr':'Not found. Will be ignored.'
      parfile=FILE_TEST(pwr1)?pwr1+'.par':config.m_rslcpar
      finfo=TLI_LOAD_SLC_PAR(parfile)
      width=STRCOMPRESS(string(long(finfo.range_samples)),/REMOVE_ALL)
      rpixl=STRCOMPRESS(string(long(finfo.range_samples)-1),/REMOVE_ALL)
      azrpixl=STRCOMPRESS(string(long(finfo.azimuth_lines)-1),/REMOVE_ALL)
      coh=workpath+PATH_SEP()+TLI_FNAME(intf, /nosuffix)+'.cc'
    ENDIF
  endif
  
  
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='cc_wave',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  intfID=widget_base(tlb,row=1, frame=1)
  intf=widget_text(intfID,value=intf,uvalue=intf,uname='intf',/editable,xsize=66)
  openintf=widget_button(intfID,value='Input intf',uname='openintf',xsize=110)
  
  pwr1ID=widget_base(tlb,row=1, frame=1)
  pwr1=widget_text(pwr1ID,value=pwr1,uvalue=pwr1,uname='pwr1',/editable,xsize=66)
  openpwr1=widget_button(pwr1ID,value='Input pwr1',uname='openpwr1',xsize=110)
  
  pwr2ID=widget_base(tlb,/row,xsize=xsize,frame=1)
  pwr2=widget_text(pwr2ID,value=pwr2,uvalue=pwr2,uname='pwr2',/editable,xsize=66)
  openpwr2=widget_button(pwr2ID,value='Input pwr2',uname='openpwr2',xsize=110)
  
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
  widthID=widget_base(tempID,/row, xsize=xsize/3-6)
  widthlabel=widget_label(widthID, value='Width of SLC:',/ALIGN_LEFT)
  width=widget_text(widthID, value=width,uvalue=width, uname='width',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize-(xsize/3)-15, /frame)
  ; wflgID=widget_base(tempID,/column, xsize=xsize/2-10)
  wflglabel=widget_label(tempID, value='Magnitude weighting function:')
  
  wflg=widget_droplist(tempID, value=['0: constant (default)',$
    '1: triangular',$
    '2: gaussian',$
    '3: none (phase only)'])
    
  ;-------------------------------------------------------------------------------------------
  ;other parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  clwiszID=widget_base(tempID,/column, xsize=xsize/3-5)
  clwiszlabel=widget_label(clwiszID, value='Columns Window size:',/ALIGN_LEFT)
  clwisz=widget_text(clwiszID, value=clwisz,uvalue=clwisz, uname='clwisz',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  rpixsID=widget_base(tempID,/column, xsize=xsize/3-5)
  rpixslabel=widget_label(rpixsID, value='Starting range pixel:',/ALIGN_LEFT)
  rpixs=widget_text(rpixsID, value=rpixs,uvalue=rpixs, uname='rpixs',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
  azrpixsID=widget_base(tempID,/column, xsize=xsize/3-10)
  azrpixslabel=widget_label(azrpixsID, value='Starting Azimuth pixel:',/ALIGN_LEFT)
  azrpixs=widget_text(azrpixsID, value=azrpixs,uvalue=azrpixs, uname='azrpixs',/editable,xsize=10)
  
  ;-------------------------------------------------------------------------------------------
  ;other parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  rwiszID=widget_base(tempID,/column, xsize=xsize/3-5)
  rwiszlabel=widget_label(rwiszID, value='Row Window size:',/ALIGN_LEFT)
  rwisz=widget_text(rwiszID, value=rwisz,uvalue=rwisz, uname='rwisz',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  rpixlID=widget_base(tempID,/column, xsize=xsize/3-5)
  rpixllabel=widget_label(rpixlID, value='Last range pixel:',/ALIGN_LEFT)
  rpixl=widget_text(rpixlID, value=rpixl,uvalue=rpixl, uname='rpixl',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
  azrpixlID=widget_base(tempID,/column, xsize=xsize/3-10)
  azrpixllabel=widget_label(azrpixlID, value='Last Azimuth pixel:',/ALIGN_LEFT)
  azrpixl=widget_text(azrpixlID, value=azrpixl,uvalue=azrpixl, uname='azrpixl',/editable,xsize=10)
  
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Interferogram coherence estimation:',/align_left,/dynamic_resize)
  
  cohID=widget_base(tlb,row=1, frame=1)
  coh=widget_text(cohID,value=coh,uvalue=coh,uname='coh',/editable,xsize=66)
  opencoh=widget_button(cohID,value='Output Coherence',uname='opencoh',xsize=110)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30)
  
  ;Recognize components
  state={intf:intf,$
    openintf:openintf,$
    pwr1:pwr1,$
    openpwr1:openpwr1,$
    pwr2:pwr2,$
    openpwr2:openpwr2,$
    width:width,$
    wflg:wflg,$
    clwisz:clwisz,$
    rpixs:rpixs,$
    azrpixs:azrpixs,$
    rwisz:rwisz,$
    rpixl:rpixl,$
    azrpixl:azrpixl,$
    coh:coh,$
    opencoh:opencoh,$
    
    
    ok:ok,$
    cl:cl $
    }
    
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_CCWAVE',tlb,/no_block
END