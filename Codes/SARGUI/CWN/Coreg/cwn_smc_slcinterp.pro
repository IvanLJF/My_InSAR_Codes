PRO CWN_SMC_SLCINTERP_EVENT,EVENT
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
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile    
    widget_control,(*pstate).mpar,set_value=mparfile
    widget_control,(*pstate).mpar,set_uvalue=mparfile
    
  END
  'openslave':begin
    slave=config.s_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=slave)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update widget info.
    config.s_slc=infile
    config.s_slcpar=infile+'.par'

    sparfile=config.s_slcpar
    widget_control,(*pstate).slave,set_value=infile
    widget_control,(*pstate).slave,set_uvalue=infile
    widget_control,(*pstate).spar,set_value=sparfile
    widget_control,(*pstate).spar,set_uvalue=sparfile
   
  END
  'openoff':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
    
    inputfile=config.inputfile
    widget_control,(*pstate).off,set_value=infile
    widget_control,(*pstate).off,set_uvalue=infile
    
    widget_control,(*pstate).master,get_value=master 
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).off,get_value=off
    IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
    IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
        RETURN
      ENDIF  
    rslave=workpath+TLI_FNAME(slave, /nosuffix)+'.rslc'
    rsparfile=workpath+TLI_FNAME(slave, /nosuffix)+'.rslc.par'
    widget_control,(*pstate).rslave,set_value=rslave
    widget_control,(*pstate).rslave,set_uvalue=rslave
    widget_control,(*pstate).rspar,set_value=rsparfile
    widget_control,(*pstate).rspar,set_uvalue=rsparfile 
    config.s_rslc=rslave 
    config.s_rslcpar=rsparfile   
  end
   'openoffs':begin
    ;-Check if input master parfile
    widget_control,(*pstate).master,get_value=master 
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).off,get_value=off
    IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
    IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
        RETURN
      ENDIF  
  
      temp=file_basename(slave)
      temp=strsplit(temp,'.',/extract)
      slave=temp(0)
      file=slave+'.rslc'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.rslc',/overwrite_prompt)
    widget_control,(*pstate).rslave,set_value=outfile
    widget_control,(*pstate).rslave,set_uvalue=outfile 
    widget_control,(*pstate).rspar,set_value=outfile+'.par'
    widget_control,(*pstate).rspar,set_uvalue=outfile+'.par' 
    config.s_rslc=outfile
    config.s_rslcpar=outfile+'.par' 
      
  END
  'openrslave':begin
    ;-Check if input master parfile
    widget_control,(*pstate).master,get_value=master 
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).off,get_value=off
    IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
    IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
        RETURN
      ENDIF 

      temp=file_basename(slave)
      temp=strsplit(temp,'.',/extract)
      slave=temp(0)
      file=slave+'.rslc'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.rslc',/overwrite_prompt)
    widget_control,(*pstate).rspar,set_value=outfile
    widget_control,(*pstate).rspar,set_uvalue=outfile     
    config.s_rslc=outfile
  END
  'openrspar':begin
    ;-Check if input master parfile
    widget_control,(*pstate).master,get_value=master 
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).off,get_value=off
    IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
    IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
        RETURN
      ENDIF 

      temp=file_basename(slave)
      temp=strsplit(temp,'.',/extract)
      slave=temp(0)
      file=slave+'.rslc.par'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.rslc.par',/overwrite_prompt)
    widget_control,(*pstate).rspar,set_value=outfile
    widget_control,(*pstate).rspar,set_uvalue=outfile   
    config.s_rslcpar=outfile
  END

    'ok': begin
      widget_control,(*pstate).master,get_value=master 
      widget_control,(*pstate).slave,get_value=slave
      widget_control,(*pstate).off,get_value=off
      widget_control,(*pstate).mpar,get_value=mparfile 
      widget_control,(*pstate).spar,get_value=sparfile
      widget_control,(*pstate).rslave,get_value=rslave
      widget_control,(*pstate).rspar,get_value=rsparfile 
      
      widget_control,(*pstate).loff,get_value=loff
      widget_control,(*pstate).nlines,get_value=nlines

      
      IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(mparfile) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master par file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(sparfile) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave par file.'
        RETURN
      ENDIF      
      IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
        RETURN
      ENDIF
      if rslave EQ '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! specify single-look complex image 2 coregistered to SLC-1 file.'
        RETURN
      ENDIF
      if rsparfile EQ '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please specify SLC-2R ISP image parameter file for coregistered image file.'
        RETURN
      ENDIF     
  
;      if loff ne '-' then begin      
;        if loff le 0 then begin
;          result=dialog_message(['number of offset estimates in range direction should be greater than 0:',$
;          STRCOMPRESS(loff)],title='Sasmac InSAR',/information,/center)
;          return
;        endif
;      endif
      if nlines ne '-' then begin      
        if nlines le 0 then begin
          result=dialog_message(['number of offset estimates in azimuth direction should be greater than 0:',$
          STRCOMPRESS(nlines)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif     
      
        scr="SLC_interp " +slave +' '+master+'.par '+slave+'.par '+off+' '+rslave+' '+rsparfile+' '+loff+' '+nlines
        TLI_SMC_SPAWN, scr,info='Offsets between SLC images using intensity cross-correlation, Please wait...'

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


PRO CWN_SMC_SLCINTERP
COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=460
  ysize=520
  
  ; Get config info
  workpath=config.workpath
  m_slc=config.m_slc
  s_slc=config.s_slc
  mparfile=config.m_slcpar
  sparfile=config.s_slcpar
  
  off=config.offfile
  loff='0'
  nlines='0'
  rslave=''
  rspar=''
  
  IF FILE_TEST(mparfile) THEN BEGIN
    finfo=TLI_LOAD_SLC_PAR(mparfile)
    nlines=STRCOMPRESS(string(long(finfo.azimuth_lines)),/REMOVE_ALL)
  ENDIF
  
  if FILE_TEST(s_slc) then begin
    temp=TLI_FNAME(s_slc,suffix=suffix)
    IF suffix EQ '.slc' OR suffix EQ '.rslc' THEN BEGIN
      rslave=workpath+TLI_FNAME(s_slc, /nosuffix)+'.rslc'
      rspar=workpath+TLI_FNAME(s_slc, /nosuffix)+'.rslc.par'
      
      config.s_rslc=rslave
      config.s_rslcpar=rspar
    ENDIF
  endif


  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='SLC_interp',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=m_slc,uvalue=m_slc,uname='master',/editable,xsize=57)
  openmaster=widget_button(masterID,value='Input Master',uname='openmaster',xsize=90)
  
  slaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slave=widget_text(slaveID,value=s_slc,uvalue=s_slc,uname='slave',/editable,xsize=57)
  openslave=widget_button(slaveID,value='Input Slave',uname='openslave',xsize=90) 
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=57)
  openoff=widget_button(offID,value='Input Offeset',uname='openoff',xsize=90)
    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input SLC parameters:',/align_left,/dynamic_resize) 
  
  mparID=widget_base(labID,/row,xsize=xsize,frame=1)
  mpar=widget_text(mparID,value=mparfile,uvalue=mparfile,uname='mpar',/editable,xsize=90)
  
  sparID=widget_base(labID,/row, xsize=xsize,frame=1)
  spar=widget_text(sparID,value=sparfile,uvalue=sparfile,uname='spar',/editable,xsize=90) 
  
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  loffID=widget_base(tempID,/column, xsize=xsize/2-10)
  lofflabel=widget_label(loffID, value='Offset to first valid output line:',/ALIGN_LEFT)
  loff=widget_text(loffID, value=loff,uvalue=loff, uname='loff',/editable,xsize=10) 
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  nlinesID=widget_base(tempID,/column, xsize=xsize/2-10)
  nlineslabel=widget_label(nlinesID, value='Number of valid output lines:',/ALIGN_LEFT)
  nlines=widget_text(nlinesID, value=nlines,uvalue=nlines, uname='nlines',/editable,xsize=10)
  
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='SLC complex image resampling using 2-D SINC interpolation:',/align_left,/dynamic_resize)
  
  rslaveID=widget_base(tlb,row=1, frame=1)
  rslave=widget_text(rslaveID,value=rslave,uvalue=rslave,uname='rslave',/editable,xsize=57)
  openrslave=widget_button(rslaveID,value='Output Rslave',uname='openrslave',xsize=90)
  
  rsparID=widget_base(tlb,row=1, frame=1)
  rspar=widget_text(rsparID,value=rspar,uvalue=rspar,uname='rspar',/editable,xsize=57)
  openrspar=widget_button(rsparID,value='Output Rspar',uname='openrspar',xsize=90)
  
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
    mpar:mpar,$
    spar:spar,$
    loff:loff,$
    nlines:nlines,$
    rslave:rslave,$
    openrslave:openrslave,$
    rspar:rspar,$
    openrspar:openrspar,$    
    ok:ok,$
    cl:cl $
   }
    
  pstate=ptr_new(state,/no_copy) 
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_SLCINTERP',tlb,/no_block
END