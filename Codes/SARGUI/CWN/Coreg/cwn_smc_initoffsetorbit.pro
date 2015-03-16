PRO CWN_SMC_INITOFFSETORBIT_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openmaster':begin
     master=config.m_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=master)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    config.m_slc=infile
    config.m_slcpar=infile+'.par'
    
    master=config.m_slc
    mparfile=config.m_slcpar
    
    finfo=TLI_LOAD_SLC_PAR(mparfile)
      width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
      width=string(long(width)/2)
      rpos=STRCOMPRESS(width)
      lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
      lines=string(long(lines)/2)  
      azpos=STRCOMPRESS(lines)
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile
    
    widget_control,(*pstate).mpar,set_value=mparfile
    widget_control,(*pstate).mpar,set_uvalue=mparfile
    
    widget_control,(*pstate).rpos,set_value=rpos
    widget_control,(*pstate).rpos,set_uvalue=rpos
    
    widget_control,(*pstate).azpos,set_value=azpos
    widget_control,(*pstate).azpos,set_uvalue=azpos
    
    
    
  END
  'openslave':begin
    slave=config.s_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=slave)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    config.s_slc=infile
    config.s_slcpar=infile+'.par'
    workpath=config.workpath
    slave=config.s_slc
    sparfile=config.s_slcpar
    widget_control,(*pstate).slave,set_value=infile
    widget_control,(*pstate).slave,set_uvalue=infile
    widget_control,(*pstate).spar,set_value=sparfile
    widget_control,(*pstate).spar,set_uvalue=sparfile
       
    widget_control,(*pstate).master,get_value=master   
    outputfile=workpath+PATH_SEP()+TLI_FNAME(master, /nosuffix)+'-'+TLI_FNAME(infile, /nosuffix)+'.off'
    widget_control,(*pstate).output,set_value=outputfile
    widget_control,(*pstate).output,set_uvalue=outputfile
    config.offfile=outfile
  END
    
    'openoutput':begin
      offfile=config.offfile
      infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath,file=slave)
      widget_control,(*pstate).master,get_value=master
      widget_control,(*pstate).slave,get_value=slave
      IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
  
      temp=file_basename(master)
      temp=strsplit(temp,'.',/extract)
      master=temp(0)
      temp=file_basename(slave)
      temp=strsplit(temp,'.',/extract)
      slave=temp(0)
      file=master+'-'+slave+'.off'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.off',/overwrite_prompt)

    widget_control,(*pstate).output,set_value=outfile
    widget_control,(*pstate).output,set_uvalue=outfile 
    config.offfile=outfile  
  END    
        
    'ok':begin
    ;-Check input paraments   
      widget_control,(*pstate).master,get_uvalue=master
      widget_control,(*pstate).slave,get_uvalue=slave
      widget_control,(*pstate).mpar,get_uvalue=mparfile
      widget_control,(*pstate).spar,get_uvalue=sparfile
      widget_control,(*pstate).output,get_uvalue=outputfile
      widget_control,(*pstate).rpos,get_value=rpos
      widget_control,(*pstate).azpos,get_value=azpos
      
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
      
      if rpos lt 0 then begin
        result=dialog_message(['range position should be greater than 0:',$
        STRCOMPRESS(rpos)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if azpos lt 0 then begin
        result=dialog_message(['azimuth position should be greater than 0:',$
        STRCOMPRESS(azpos)],title='Sasmac InSAR',/information,/center)
        return
      endif
      IF outputfile eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please specify output file.'
        RETURN
      ENDIF
       
       scr="init_offset_orbit "+master+'.par '+slave+'.par '+outputfile+' '+rpos+' '+azpos
       TLI_SMC_SPAWN, scr,info='Initial SLC image offset estimation from orbit state vector data, Please wait...'
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


PRO CWN_SMC_INITOFFSETORBIT


COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=460
  ysize=440
  
  ; Get config info

  m_slc=config.m_slc
  s_slc=config.s_slc
  mparfile=config.m_slcpar
  sparfile=config.s_slcpar
  rpos='0'
  azpos='0'
  outputfile=config.offfile
  IF FILE_TEST(m_slc) THEN BEGIN
    IF FILE_TEST(s_slc) THEN BEGIN
      workpath=config.workpath
      m_slc=config.m_slc
      s_slc=config.s_slc
      temp=TLI_FNAME(m_slc,suffix=suffix)
      IF suffix EQ '.rslc' OR suffix EQ '.slc' THEN BEGIN
      mparfile=config.m_slcpar
      sparfile=config.s_slcpar
      finfo=TLI_LOAD_SLC_PAR(mparfile)
      width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
      width=string(long(width)/2)
      rpos=STRCOMPRESS(width)
      lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
      lines=string(long(lines)/2)
      azpos=STRCOMPRESS(lines)
     ENDIF
    outputfile=workpath+TLI_FNAME(m_slc, /nosuffix)+'-'+TLI_FNAME(s_slc, /nosuffix)+'.off'
    endif
  ENDIF
  
 ; config.workpath=workpath
  
  ;--------------------------------------------------------------------------------------------------------------------------  
  ;Create widgets
  tlb=widget_base(title='init offset orbit',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=m_slc,uvalue=m_slc,uname='master',/editable,xsize=56)
  openmaster=widget_button(masterID,value='Input Master',uname='openmaster',xsize=90)
  
  slaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slave=widget_text(slaveID,value=s_slc,uvalue=s_slc,uname='slave',/editable,xsize=56)
  openslave=widget_button(slaveID,value='Input Slave',uname='openslave',xsize=90) 
 
    
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize)  
  
  mparID=widget_base(labID,/row,xsize=xsize,frame=1)
  mpar=widget_text(mparID,value=mparfile,uvalue=mparfile,uname='mpar',/editable,xsize=72)
  
  sparID=widget_base(labID,/row, xsize=xsize,frame=1)
  spar=widget_text(sparID,value=sparfile,uvalue=sparfile,uname='spar',/editable,xsize=72) 
  
  ;-Create range position and azimuth position input window
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-20, frame=1)
  rposID=widget_base(tempID, /column, xsize=xsize/2-10)
  rposlabel=widget_label(rposID, value='Range Position:',/ALIGN_LEFT)
  rpos=widget_text(rposID,value=rpos, uvalue=rpos, uname='rpos',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-10, frame=1)
  azposID=widget_base(tempID, /column, xsize=xsize/2-10)
  azposlabel=widget_label(azposID, value='Azimuth Position:',/ALIGN_LEFT)
  azpos=widget_text(azposID,value=azpos, uvalue=azpos, uname='azpos',/editable,xsize=10)
  
  ;---------------------------------------------------------------------------------------------------
  ;output file
  tempID=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  offID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(offID,/row,xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10,value=off_orb_lab,/align_left,/dynamic_resize)
  
  offsetID=widget_base(tlb,row=1,frame=1)
  output=widget_text(offsetID,value=outputfile,uvalue=outputfile,uname='output',/editable,xsize=56)
  openoutput=widget_button(offsetID,value='OFF_par',uname='openoutput',xsize=90)  
   
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30) 
  
  ;Recognize components
   state={master:master,$
    openmaster:openmaster,$
    slave:slave,$
    openslave:openslave,$
    rpos:rpos,$
    azpos:azpos,$
    mpar:mpar,$
    spar:spar,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl $
    }
    
  pstate=ptr_new(state,/no_copy) 
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_INITOFFSETORBIT',tlb,/no_block

END