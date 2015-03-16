PRO CWN_SMC_CREATEOFFSET_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  Case uname OF
    'openmaster':begin
      master=config.m_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=config.workpath,file=master)
    IF NOT FILE_TEST(infile) THEN return
    ; Update definitions
    config.m_slc=infile
    parfile=infile+'.par'
    config.workpath=FILE_DIRNAME(infile)+PATH_SEP()
    config.m_slcpar=parfile
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile
    widget_control, (*pstate).width,set_value=width, set_uvalue=width
    
  END
  'openslave':begin
    infile=config.s_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=config.workpath)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    config.s_slc=infile
    config.s_slcpar=infile+'.par'

    widget_control,(*pstate).slave,set_value=infile
    widget_control,(*pstate).slave,set_uvalue=infile
    
    widget_control,(*pstate).master,get_value=master   
    outputfile=workpath+TLI_FNAME(master, /nosuffix)+'-'+TLI_FNAME(infile, /nosuffix)+'.off'
    widget_control,(*pstate).output,set_value=outputfile
    widget_control,(*pstate).output,set_uvalue=outputfile
    config.offfile=outputfile
  END
  
  'headfile':begin
    widget_control,(*pstate).master,get_uvalue=master
    widget_control,(*pstate).slave,get_uvalue=slave
    widget_control,(*pstate).width,set_value=width
    widget_control,(*pstate).width,set_uvalue=width
  END
   'openoutput':begin
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
  TLI_SMC_DEFINITIONS_UPDATE, inputfile=outfile
end

  'ok':begin
    widget_control,(*pstate).master,get_value=master
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).width,get_value=width
    widget_control,(*pstate).output,get_value=outputfile
    
    widget_control,(*pstate).rlks,get_value=rlks
    widget_control,(*pstate).azlks,get_value=azlks
    widget_control,(*pstate).title,get_value=title
    widget_control,(*pstate).roff,get_value=roff
    widget_control,(*pstate).azoff,get_value=azoff
    widget_control,(*pstate).mroff,get_value=mroff
    widget_control,(*pstate).mazoff,get_value=mazoff
    widget_control,(*pstate).rwisz,get_value=rwisz
    widget_control,(*pstate).azwisz,get_value=azwisz
    widget_control,(*pstate).snr,get_value=snr
    widget_control,(*pstate).intsam,get_value=intsam
    algorithm=WIDGET_INFO((*pstate).algorithm,/droplist_select)
    algorithm=STRCOMPRESS(algorithm+1, /REMOVE_ALL)

    IF NOT FILE_TEST(master) then begin
      TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
      RETURN
    ENDIF
    IF NOT FILE_TEST(slave) then begin
      TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
      RETURN
    ENDIF

    if rlks le 0 then begin
      result=dialog_message(['range looks should be greater than 0:',$
      STRCOMPRESS(rlks)],title='Sasmac InSAR',/information,/center)
      return
    endif
    if azlks le 0 then begin
      result=dialog_message(['azimuth looks should be greater than 0:',$
      STRCOMPRESS(azlks)],title='Sasmac InSAR',/information,/center)
      return
    endif
    
    if title eq '' then begin
      result=dialog_message(['Please input scene title.'],title='Sasmac InSAR',/information,/center)
      return
    endif
    if roff lt 0 then begin
      result=dialog_message(['initial range offset should be greater than 0:',$
      STRCOMPRESS(roff)],title='Sasmac InSAR',/information,/center)
      return
    endif
    if azoff lt 0 then begin
      result=dialog_message(['initial azimuth offset should be greater than 0:',$
      STRCOMPRESS(azoff)],title='Sasmac InSAR',/information,/center)
      return
    endif
    if mroff le 0 then begin
      result=dialog_message(['measurement range offset should be greater than 0:',$
      STRCOMPRESS(mroff)],title='Sasmac InSAR',/information,/center)
      return
    endif
    if mazoff le 0 then begin
      result=dialog_message(['measurement azimuth offset should be greater than 0:',$
      STRCOMPRESS(mazoff)],title='Sasmac InSAR',/information,/center)
      return
    endif
    if rwisz le 0 then begin
      result=dialog_message(['range window size should be greater than 0:',$
      STRCOMPRESS(rwisz)],title='Sasmac InSAR',/information,/center)
      return
    endif
    if azwisz le 0 then begin
      result=dialog_message(['azimuth window size should be greater than 0:',$
      STRCOMPRESS(azwisz)],title='Sasmac InSAR',/information,/center)
      return
    endif
    if intsam lt 0 then begin
      result=dialog_message(['interferogram samples should be greater than 0:',$
      STRCOMPRESS(intsam)],title='Sasmac InSAR',/information,/center)
      return
    endif
    if snr le 0 then begin
      result=dialog_message(['snr threshold should be greater than 0:',$
      STRCOMPRESS(snr)],title='Sasmac InSAR',/information,/center)
      return
    endif
    
    if width le 0 then begin
      result=dialog_message(['Width should be greater than 0:',$
      STRCOMPRESS(width)],title='Sasmac InSAR',/information,/center)
      return
    endif
    IF outputfile eq '' then begin
      TLI_SMC_DUMMY, inputstr='ERROR! Please specify output file.'
      RETURN
    ENDIF
        
        workpath=config.workpath
        hdrfile='tempfile'
        tempfile=workpath+hdrfile
                           
        OPENW, lun,tempfile,/GET_LUN
        PrintF, lun,title
        PrintF, lun,roff[0],' ',azoff[0]
        PrintF, lun,mroff[0],' ',mazoff[0]
        PrintF, lun,rwisz[0],' ',azwisz[0]
        PrintF, lun,snr[0]
        PrintF, lun,intsam[0]
        printF, lun,width[0]
        FREE_LUN, lun
    scr='create_offset '+master+'.par '+slave+'.par '+outputfile+' '+algorithm+' '+rlks+' '+azlks+' < '+tempfile 
    TLI_SMC_SPAWN, scr,info='Creating offset, Please wait...'
    FILE_DELETE, tempfile
    TLI_SMC_DEFINITIONS_UPDATE, inputfile=outputfile
end

'cl':begin
;result=dialog_message('Quit Multi-looking processing?',title='Sasmac InSAR v1.0',/question,/center)
;if result eq 'Yes'then begin
widget_control,event.top,/destroy
;endif
end


else:return
ENDCASE

END




PRO CWN_SMC_CREATEOFFSET

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=610
  
;  ; Get config info
;  workpath='/media/563d2a8d-f642-439e-89a2-ba83ef53ad17/Sasmac_data/DEM_Test/Base_test/shanghai/3000/lookup/base_init'+PATH_SEP()
;  config.workpath=workpath
  m_slc=config.m_slc
  s_slc=config.s_slc
  mpar=config.m_slcpar
  spar=config.s_slcpar
  parlab='Par file not found'
  algorithm='1'
  rlks='1'
  azlks='1'
  title='offset parameters'
  roff='0'
  azoff='0'
  mroff='32'
  mazoff='32'
  snr='7.0'
  rwisz='64'
  azwisz='64'
  intsam='0'
  width=''
  IF FILE_TEST(m_slc) THEN BEGIN
    IF FILE_TEST(s_slc) THEN BEGIN
      workpath=config.workpath
      inputfile=config.inputfile
      temp=TLI_FNAME(m_slc,suffix=suffix)
      IF suffix EQ '.rslc' OR suffix EQ '.slc' THEN BEGIN
        parfile=mpar
        parlab='Par file:'+parfile
        finfo=TLI_LOAD_SLC_PAR(parfile)
        width=STRCOMPRESS(string(long(finfo.range_samples)),/REMOVE_ALL)
        outputfile=workpath+PATH_SEP()+TLI_FNAME(m_slc, /nosuffix)+'-'+TLI_FNAME(s_slc, /nosuffix)+'.off'
      ENDIF
    endif
  ENDIF

  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='create offset',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  mastesID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(mastesID,value=m_slc,uvalue=m_slc,uname='master',/editable,xsize=73)
  openmaster=widget_button(mastesID,value='Input Master',uname='openmaster',xsize=90)
  
  slaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slave=widget_text(slaveID,value=s_slc,uvalue=s_slc,uname='slave',/editable,xsize=73)
  openslave=widget_button(slaveID,value='Input Slave',uname='openslave',xsize=90)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')

  temp=widget_base(tlb,/row,xsize=xsize,/frame)
  lab=widget_label(temp,value='offset estimation algorithm:')
      
  algorithm=widget_droplist(temp, value=['Intensity cross-correlation',$
                                   'Fringe visibility'])

  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize)   
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  widthID=widget_base(tempID,/column, xsize=xsize/3-10)
  widthlabel=widget_label(widthID, value='Width Of SLC:',/ALIGN_LEFT)
  width=widget_text(widthID, value=width,uvalue=width, uname='width',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  rlksID=widget_base(tempID, /column, xsize=xsize/3-10)
  rlkslabel=widget_label(rlksID, value='range looks:',/ALIGN_LEFT)
  rlks=widget_text(rlksID,value=rlks, uvalue=rlks, uname='rlks',/editable,xsize=10)

  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  azlksID=widget_base(tempID, /column, xsize=xsize/3-10)
  azlkslabel=widget_label(azlksID, value='azimuth looks:',/ALIGN_LEFT)
  azlks=widget_text(azlksID,value=azlks, uvalue=azlks, uname='azlks',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  titleID=widget_base(tempID, /column, xsize=xsize/3-10)
  titlelabel=widget_label(titleID, value='Scenetitle:',/ALIGN_LEFT)
  title=widget_text(titleID,value=title, uvalue=title, uname='title',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  roffID=widget_base(tempID, /column, xsize=xsize/3-10)
  rofflabel=widget_label(roffID, value='Initial Range Offset:',/ALIGN_LEFT)
  roff=widget_text(roffID,value=roff, uvalue=roff, uname='roff',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  azoffID=widget_base(tempID,/column, xsize=xsize/3-10)
  azofflabel=widget_label(azoffID, value='Initial Azimuth Offset:',/ALIGN_LEFT)
  azoff=widget_text(azoffID, value=azoff,uvalue=azoff, uname='azoff',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  mroffID=widget_base(tempID, /column, xsize=xsize/3-10)
  mrofflabel=widget_label(mroffID, value='Measurement Range Offset:',/ALIGN_LEFT)
  mroff=widget_text(mroffID,value=mroff, uvalue=mroff, uname='mroff',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  mazoffID=widget_base(tempID,/column, xsize=xsize/3-10)
  mazofflabel=widget_label(mazoffID, value='Measurement Azimuth Offset:',/ALIGN_LEFT)
  mazoff=widget_text(mazoffID, value=mazoff,uvalue=mazoff, uname='mazoff',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  snrID=widget_base(tempID,/column, xsize=xsize/3-10)
  snrlabel=widget_label(snrID, value='SNR Threshold:',/ALIGN_LEFT)
  snr=widget_text(snrID, value=snr,uvalue=snr, uname='snr',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  rwiszID=widget_base(tempID, /column, xsize=xsize/3-10)
  rwiszlabel=widget_label(rwiszID, value='Range Window Size:',/ALIGN_LEFT)
  rwisz=widget_text(rwiszID,value=rwisz, uvalue=rwisz, uname='rwisz',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  azwiszID=widget_base(tempID,/column, xsize=xsize/3-10)
  azwiszlabel=widget_label(azwiszID, value='Azimuth Window Size:',/ALIGN_LEFT)
  azwisz=widget_text(azwiszID, value=azwisz,uvalue=azwisz, uname='azwisz',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  intsamID=widget_base(tempID,/column, xsize=xsize/3-10)
  intsamlabel=widget_label(intsamID, value='Interferogram Samples:',/ALIGN_LEFT)
  intsam=widget_text(intsamID, value=intsam,uvalue=intsam, uname='intsam',/editable,xsize=10)
  
  ;--------------------------------------------------------------
  ;other parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  
  
  outID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outID,value=outputfile,uvalue=outputfile,uname='output',/editable,xsize=73)
  openoutput=widget_button(outID,value='Output offset',uname='openoutput',xsize=90)
  
  ; non exclusive box
  temp=widget_base(outID,tab_mode=1,/column)
  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok',ysize=30)
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl',ysize=30)
  
  state={master:master,$
    openmaster:openmaster,$
    slave:slave,$
    openslave:openslave,$
    algorithm:algorithm,$
    rlks:rlks,$
    azlks:azlks,$
    parlabel:parlabel,$    
    title:title,$   
    roff:roff,$
    azoff:azoff,$   
    mroff:mroff,$
    mazoff:mazoff,$
    snr:snr,$
    rwisz:rwisz,$
    azwisz:azwisz,$
    intsam:intsam,$
    width:width,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl $
    }
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_CREATEOFFSET',tlb,/no_block
  
END