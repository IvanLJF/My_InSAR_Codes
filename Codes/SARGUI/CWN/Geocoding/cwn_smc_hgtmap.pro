PRO CWN_SMC_HGTMAP_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openmaster':begin
    master=config.m_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=master)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update widget info.
    config.m_slc=infile
    config.m_slcpar=infile+'.par'
    
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile
    
    widget_control,(*pstate).mpar,set_value=infile+'.par'
    widget_control,(*pstate).mpar,set_uvalue=infile+'.par'
  END
  'openslave':begin
  slave=config.s_slc
  infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=slave)
  IF NOT FILE_TEST(infile) THEN return
  
  ; Update widget info.
  config.s_slc=infile
  config.s_slcpar=infile+'.par'
  
  widget_control,(*pstate).slave,set_value=infile
  widget_control,(*pstate).slave,set_uvalue=infile
  widget_control,(*pstate).spar,set_value=infile+'.par'
  widget_control,(*pstate).spar,set_uvalue=infile+'.par'
END
'openunw':begin
infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.unw', path=workpath)
IF NOT FILE_TEST(infile) THEN return
widget_control,(*pstate).unw,set_value=infile
widget_control,(*pstate).unw,set_uvalue=infile
end
'openoff':begin
infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath)
IF NOT FILE_TEST(infile) THEN return
widget_control,(*pstate).off,set_value=infile
widget_control,(*pstate).off,set_uvalue=infile
end
'openbase':begin
infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.base', path=workpath)
IF NOT FILE_TEST(infile) THEN return
widget_control,(*pstate).base,set_value=infile
widget_control,(*pstate).base,set_uvalue=infile

hgtfile=workpath+PATH_SEP()+TLI_FNAME(infile, /nosuffix)+'.hgt'
grdfile=workpath+PATH_SEP()+TLI_FNAME(infile, /nosuffix)+'.grd'
widget_control,(*pstate).hgt,set_value=hgtfile
widget_control,(*pstate).hgt,set_uvalue=hgtfile
widget_control,(*pstate).grd,set_value=grdfile
widget_control,(*pstate).grd,set_uvalue=grdfile

end

'openhgt':begin
widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).slave,get_value=slave
widget_control,(*pstate).unw,get_value=unw
widget_control,(*pstate).off,get_value=off
widget_control,(*pstate).base,get_value=base

if unw eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input unwrapped file',/information,/center)
  return
endif
if master eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input master file',/information,/center)
  return
endif
if slave ne '-' then begin
  if slave eq '' then begin
    result=dialog_message(title='Sasmac InSAR','please select input slave file',/information,/center)
    return
  endif
endif
if off eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input offset parfile',/information,/center)
  return
endif
if base eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input baseline file',/information,/center)
  return
endif
hgtfile=TLI_FNAME(infile, /nosuffix)+'.hgt'
infile=dialog_pickfile(title='Sasmac InSAR',filter='*.hgt',path=workpath,file=hgtfile,/write,/overwrite_prompt)
widget_control,(*pstate).hgt,set_value=infile
widget_control,(*pstate).hgt,set_uvalue=infile
end
'openhgt':begin
widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).slave,get_value=slave
widget_control,(*pstate).unw,get_value=unw
widget_control,(*pstate).off,get_value=off
widget_control,(*pstate).base,get_value=base

if unw eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input unwrapped file',/information,/center)
  return
endif
if master eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input master file',/information,/center)
  return
endif
if slave ne '-' then begin
  if slave eq '' then begin
    result=dialog_message(title='Sasmac InSAR','please select input slave file',/information,/center)
    return
  endif
endif
if off eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input offset parfile',/information,/center)
  return
endif
if base eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input baseline file',/information,/center)
  return
endif

grdfile=TLI_FNAME(infile, /nosuffix)+'.grd'
infile=dialog_pickfile(title='Sasmac InSAR',filter='*.grd',path=workpath,file=grdfile,/write,/overwrite_prompt)
widget_control,(*pstate).grd,set_value=infile
widget_control,(*pstate).grd,set_uvalue=infile
end

'ok':begin
widget_control,(*pstate).master,get_value=master
widget_control,(*pstate).slave,get_value=slave
widget_control,(*pstate).unw,get_value=unw
widget_control,(*pstate).off,get_value=off
widget_control,(*pstate).base,get_value=base
widget_control,(*pstate).hgt,get_value=hgt
widget_control,(*pstate).grd,get_value=grd
widget_control,(*pstate).loff,get_value=loff
widget_control,(*pstate).nlines,get_value=nlines

phflag=WIDGET_INFO((*pstate).phflag,/droplist_select)
phflag_d=long(phflag)
if phflag_d eq 0 then begin
  phflag=STRCOMPRESS(string(phflag_d+1), /REMOVE_ALL)
endif
if phflag_d eq 1 then begin
  phflag=STRCOMPRESS(string(phflag_d-1), /REMOVE_ALL)
endif

if unw eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input unwrapped file',/information,/center)
  return
endif
if master eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input master file',/information,/center)
  return
endif
if slave ne '-' then begin
  if slave eq '' then begin
    result=dialog_message(title='Sasmac InSAR','please select input slave file',/information,/center)
    return
  endif
endif
if off eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input offset parfile',/information,/center)
  return
endif
if base eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please select input baseline file',/information,/center)
  return
endif
if hgt eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please specify hgt file',/information,/center)
  return
endif
if grd eq '' then begin
  result=dialog_message(title='Sasmac InSAR','please specify grd file',/information,/center)
  return
endif

if loff lt 0 then begin
  result=dialog_message(['offset to starting line should be greater than 0:',$
    STRCOMPRESS(loff)],title='Sasmac InSAR',/information,/center)
  return
endif
if STRLOWCASE(nlines) NE 'all' AND LONG(nlines) EQ 0 then begin
  result=dialog_message(['number of lines to calculate should be greater than 0:',$
    STRCOMPRESS(nlines)],title='Sasmac InSAR',/information,/center)
  return
endif ELSE BEGIN
  nlines='-'
ENDELSE

scr="hgt_map " +unw +' '+master+'.par' +' '+off+' '+base+' '+hgt+' '+grd+' '+phflag+' '+loff+' '+nlines+' '+slave+'.par'
TLI_SMC_SPAWN, scr,info='Step 1/2: Interferometric height/ground range estimation vs. slant range, Please wait...',/supress

;draw raster file
width=STRCOMPRESS(string(long(finfo.range_samples)),/REMOVE_ALL)
mlifile=FILE_DIRNAME(master)+PATH_SEP()+FILE_BASENAME(master,'.rslc')+'.pwr'

rashgt='rashgt '+hgt+' '+mlifile+' '+width+' '+' - - - - - 160 - - - '+hgt+'.ras'
TLI_SMC_SPAWN, rashgt,info='Step 2/2: DISP Program rashgt, Please wait...'
;      stop
end

'cl':begin
;    result=dialog_message('Sure exit?',title='Exit',/question,/default_no)
;    if result eq 'Yes' then begin
widget_control,event.top,/destroy
;    endif
end
else:begin
return
end
endcase

END

PRO CWN_SMC_HGTMAP,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=500
  ysize=640
  
  
  ; Get config info
  m_slc=config.m_slc
  mparfile=config.m_slcpar
  s_slc=config.s_slc
  sparfile=config.s_slc
  
  unw=''
  off=''
  gcp=''
  base=''
  hgt=''
  grd=''
  
  loff='0'
  nlines='All'
  ;  IF FILE_TEST(mparfile) THEN BEGIN
  ;    finfo=TLI_LOAD_PAR(mparfile,/keeptxt)
  ;    nlines=finfo.azimuth_lines
  ;  ENDIF
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='hgt_map',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  ;-Create unw input window
  
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=m_slc,uvalue=m_slc,uname='master',/editable,xsize=62)
  openmaster=widget_button(masterID,value='Input Master',uname='openmaster',xsize=100)
  
  slaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slave=widget_text(slaveID,value=s_slc,uvalue=s_slc,uname='slave',/editable,xsize=62)
  openslave=widget_button(slaveID,value='Input Slave',uname='openslave',xsize=100)
  
  unwID=widget_base(tlb,/row,xsize=xsize,frame=1)
  unw=widget_text(unwID,value=unw,uvalue=unw,uname='unw',/editable,xsize=62)
  openunw=widget_button(unwID,value='Input Unwrapped',uname='openunw',xsize=100)
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=62)
  openoff=widget_button(offID,value='Input offset',uname='openoff',xsize=100)
  
  baseID=widget_base(tlb,/row,xsize=xsize,frame=1)
  base=widget_text(baseID,value=base,uvalue=base,uname='base',/editable,xsize=62)
  openbase=widget_button(baseID,value='Input Baseline',uname='openbase',xsize=100)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize, value='Basic information about input parameters:',/align_left,/dynamic_resize)
  
  mparID=widget_base(labID,/row,xsize=xsize,frame=1)
  mpar=widget_text(mparID,value=mparfile,uvalue=mparfile,uname='mpar',/editable,xsize=79)
  
  sparID=widget_base(labID,/row, xsize=xsize,frame=1)
  spar=widget_text(sparID,value=sparfile,uvalue=sparfile,uname='spar',/editable,xsize=79)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize, frame=1)
  phflagID=widget_base(tempID,/row, xsize=xsize)
  phflaglabel=widget_label(phflagID, value='Restore phase slope flag:',/ALIGN_LEFT)
  phflag=widget_droplist(phflagID, value=['Add back phase ramp',$
    'No phase change'])
    
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-10, frame=1)
  loffID=widget_base(tempID, /column, xsize=xsize/2-5)
  lofflabel=widget_label(loffID, value='Offset to starting line:',/ALIGN_LEFT)
  loff=widget_text(loffID,value=loff, uvalue=loff, uname='loff',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
  nlinesID=widget_base(tempID,/column, xsize=xsize/2-10)
  nlineslabel=widget_label(nlinesID, value='Number of lines to calculate:',/ALIGN_LEFT)
  nlines=widget_text(nlinesID, value=nlines,uvalue=nlines, uname='nlines',/editable,xsize=10)
  
  temp=widget_label(tlb,value='--------------------------------------------------------------------------------------')
  
  hgtID=widget_base(tlb,/row,xsize=xsize,frame=1)
  hgt=widget_text(hgtID,value=hgt,uvalue=hgt,uname='hgt',/editable,xsize=62)
  openhgt=widget_button(hgtID,value='Output hgt',uname='openhgt',xsize=100)
  
  ;-Create cross-track ground ranges file input window
  grdID=widget_base(tlb,/row,xsize=xsize,frame=1)
  grd=widget_text(grdID,value=grd,uvalue=grd,uname='grd',/editable,xsize=62)
  opengrd=widget_button(grdID,value='Output grd',uname='opengrd',xsize=100)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)
  
  ;Recognize components
  state={ master:master,$
    openmaster:openmaster,$
    slave:slave,$
    openslave:openslave,$
    off:off,$
    openoff:openoff,$
    base:base,$
    openbase:openbase,$
    
    mpar:mpar,$
    spar:spar,$
    phflag:phflag,$
    
    hgt:hgt,$
    openhgt:openhgt,$
    grd:grd,$
    opengrd:opengrd,$
    loff:loff,$
    nlines:nlines,$
    
    unw: unw,$
    
    ok:ok,$
    cl:cl $
    }
    
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_HGTMAP',tlb,/no_block
  
END