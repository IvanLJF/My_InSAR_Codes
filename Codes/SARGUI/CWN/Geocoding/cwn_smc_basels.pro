PRO CWN_SMC_BASELS_EVENT,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  
  case uname of
    'openmaster':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
    mparfile=infile+'.par'
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile 
    widget_control,(*pstate).mparfile,set_value=mparfile
    widget_control,(*pstate).mparfile,set_uvalue=mparfile
  END
  
  'openslave':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
      sparfile=infile+'.par'
      widget_control,(*pstate).slave,set_value=infile
      widget_control,(*pstate).slave,set_uvalue=infile 
      widget_control,(*pstate).sparfile,set_value=sparfile
      widget_control,(*pstate).sparfile,set_uvalue=sparfile
    END
    
  'openoff':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath)
    IF NOT FILE_TEST(infile) THEN return

      widget_control,(*pstate).off,set_value=infile
      widget_control,(*pstate).off,set_uvalue=infile     
    end
    
   'openbase':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.base', path=workpath)
    IF NOT FILE_TEST(infile) THEN return

      widget_control,(*pstate).base,set_value=base
      widget_control,(*pstate).base,set_uvalue=base     
    end
   'opengcpph':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.gcp_ph', path=workpath)
    IF NOT FILE_TEST(infile) THEN return

      widget_control,(*pstate).gcpph,set_value=infile
      widget_control,(*pstate).gcpph,set_uvalue=infile

      base=workpath+PATH_SEP()+TLI_FNAME(infile, /nosuffix)+'.base'
       
      widget_control,(*pstate).base,set_value=base
      widget_control,(*pstate).base,set_uvalue=base
          
    end
    
    'ok':begin
            
      widget_control,(*pstate).master,get_value=master
      widget_control,(*pstate).slave,get_value=slave
      widget_control,(*pstate).off,get_value=off
      widget_control,(*pstate).gcpph,get_value=gcpph
      widget_control,(*pstate).mparfile,get_value=mparfile
      widget_control,(*pstate).sparfile,get_value=sparfile
      widget_control,(*pstate).base,get_value=base
      widget_control,(*pstate).bperpmin,get_value=bperpmin
          
      phflag=WIDGET_INFO((*pstate).phflag,/droplist_select)
      phflag=STRCOMPRESS(phflag, /REMOVE_ALL)
      
      bcflag=WIDGET_INFO((*pstate).bcflag,/droplist_select)
      bcflag_d=long(bcflag)
      if bcflag_d eq 0 then begin
        bcflag=STRCOMPRESS(string(bcflag_d+1), /REMOVE_ALL)
      endif
      if bcflag_d eq 1 then begin
        bcflag=STRCOMPRESS(string(bcflag_d-1), /REMOVE_ALL)
      endif
      
      bnflag=WIDGET_INFO((*pstate).bnflag,/droplist_select)
      bnflag_d=long(bnflag)
      if bnflag_d eq 0 then begin
        bnflag=STRCOMPRESS(string(bnflag_d+1), /REMOVE_ALL)
      endif
      if bnflag_d eq 1 then begin
        bnflag=STRCOMPRESS(string(bnflag_d-1), /REMOVE_ALL)
      endif
      
      bcdotflag=WIDGET_INFO((*pstate).bcdotflag,/droplist_select)
      bcdotflag_d=long(bcdotflag)
      if bcdotflag_d eq 0 then begin
        bcdotflag=STRCOMPRESS(string(bcdotflag_d+1), /REMOVE_ALL)
      endif
      if bcdotflag_d eq 1 then begin
        bcdotflag=STRCOMPRESS(string(bcdotflag_d-1), /REMOVE_ALL)
      endif
      
      bndotflag=WIDGET_INFO((*pstate).bndotflag,/droplist_select)
      bndotflag=STRCOMPRESS(bndotflag, /REMOVE_ALL)
      
      
      IF master eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF slave eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
      IF mparfile eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Can not find master par file.'
        RETURN
      ENDIF
      IF sparfile eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Can not find slave par file.'
        RETURN
      ENDIF
      IF off eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input offset par file.'
        RETURN
      ENDIF
      IF gcpph eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input ground control point file.'
        RETURN
      ENDIF
      IF base eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select baseline file.'
        RETURN
      ENDIF
      
      if bperpmin lt 0 then begin
        result=dialog_message(['minimum perpendicular should be greater than 0:',$
        STRCOMPRESS(rcp)],title='Sasmac InSAR',/information,/center)
        return
      endif
      
      scr="base_ls " +mparfile +' '+off +' '+gcpph+' '+base+' '+phflag+' '+bcflag+' '+bnflag+' '+bcdotflag+' '+bndotflag+' '+bperpmin+' '+sparfile
        TLI_SMC_SPAWN, scr,info='Least squares baseline estimation using terrain heights, Please wait...'
      
    end
    
    'cl':begin
;      result=dialog_message('Sure exit?',title='Exit',/question,/default_no)
;      if result eq 'Yes' then begin
        widget_control,event.top,/destroy
;      endif
    end
      else:begin
        return
    end  
  endcase

END

PRO CWN_SMC_BASELS,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=500
  ysize=700
  
  master=FILE_TEST(config.m_slc)?config.m_slc:''
  slave=FILE_TEST(config.s_slc)?config.s_slc:''
  mparfile=FILE_TEST(config.m_slcpar)?config.m_slcpar:''
  sparfile=FILE_TEST(config.s_slcpar)?config.s_slcpar:''
  gcpph=''
  base=''
  off=''
  
  bperpmin='10.0'
  
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='base_ls',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=master,uvalue=master,uname='master',/editable,xsize=63)
  openmaster=widget_button(masterID,value='Input Master',uname='openmaster',xsize=95)
  
  slaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slave=widget_text(slaveID,value=slave,uvalue=slave,uname='slave',/editable,xsize=63)
  openslave=widget_button(slaveID,value='Input Slave',uname='openslave',xsize=95) 
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=inputfile,uvalue=inputfile,uname='off',/editable,xsize=63)
  openoff=widget_button(offID,value='Input offset',uname='openoff',xsize=95)
  
  ;-Create ground control point input window
  gcpphID=widget_base(tlb,/row,xsize=xsize,frame=1)
  gcpph=widget_text(gcpphID,value=gcpph,uvalue=gcpph,uname='gcpph',/editable,xsize=63)
  opengcpph=widget_button(gcpphID,value='Input GCP',uname='opengcpph',xsize=95)
    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)

  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize)

  mparfileID=widget_base(labID,/row,xsize=xsize,frame=1)
  mparfile=widget_text(mparfileID,value=mparfile,uvalue=mparfile,uname='mparfile',/editable,xsize=78)
  
  sparfileID=widget_base(labID,/row, xsize=xsize,frame=1)
  sparfile=widget_text(sparfileID,value=sparfile,uvalue=sparfile,uname='sparfile',/editable,xsize=78) 
  
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2, frame=1)
  bperpminID=widget_base(tempID,/column, xsize=xsize/2-10)
  bperpminlabel=widget_label(bperpminID, value='Minimum perpendicular for LS estimation:',/ALIGN_LEFT)  
  bperpmin=widget_text(bperpminID,value=bperpmin,uvalue=bperpmin,uname='bperpmin',/editable,xsize=5)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-25, frame=1)
  phflagID=widget_base(tempID,/column, xsize=xsize/2-10)
  phflaglabel=widget_label(phflagID, value='Restore range phase ramp:',/ALIGN_LEFT)
  phflag=widget_droplist(phflagID, value=['Do not restore',$
                                          'Restore'])
                                        
  infoID=widget_base(labID,/row, xsize=xsize) 
  tempID=widget_base(infoID,/row,xsize=xsize/2, frame=1)
  bcflagID=widget_base(tempID,/column, xsize=xsize/2-10)
  bcflaglabel=widget_label(bcflagID, value='Cross-track baseline component estimate:',/ALIGN_LEFT)
  bcflag=widget_droplist(bcflagID, value=['Estimate from data',$
                                          'Orbit derived']) 
                                  
  tempID=widget_base(infoID,/row,xsize=xsize/2-25, frame=1)
  bnflagID=widget_base(tempID,/column, xsize=xsize/2-10)
  bnflaglabel=widget_label(bnflagID, value='Normal baseline component estimate:',/ALIGN_LEFT)
  bnflag=widget_droplist(bnflagID, value=['Estimate from data',$
                                          'Orbit derived'])   
                                                                               
  infoID=widget_base(labID,/row, xsize=xsize) 
  tempID=widget_base(infoID,/row,xsize=xsize/2, frame=1)
  bcdotflagID=widget_base(tempID,/column, xsize=xsize/2-10)
  bcdotflaglabel=widget_label(bcdotflagID, value='Cross-track baseline rate estimate:',/ALIGN_LEFT)
  bcdotflag=widget_droplist(bcdotflagID, value=['Estimate from data',$
                                                'Orbit derived'])
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-25, frame=1)
  bndotflagID=widget_base(tempID,/column, xsize=xsize/2-10)
  bndotflaglabel=widget_label(bndotflagID, value='Normal baseline rate estimate:',/ALIGN_LEFT)
  bndotflag=widget_droplist(bndotflagID, value=['Orbit derived',$
                                                'Estimate from data'])
  
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)

  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Least squares baseline estimation using terrain heights:',/align_left,/dynamic_resize)
  
  ;-Create ground control point data file input window
  baseID=widget_base(tlb,/row,xsize=xsize,frame=1)
  base=widget_text(baseID,value=base,uvalue=base,uname='base',/editable,xsize=63)
  openbase=widget_button(baseID,value='Baseline',uname='openbase',xsize=95)
  
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
          gcpph:gcpph,$
          opengcpph:opengcpph,$
          mparfile:mparfile,$
          sparfile:sparfile,$
          
          bperpmin:bperpmin,$
          phflag:phflag,$
          bcflag:bcflag,$
          bnflag:bnflag,$
          bcdotflag:bcdotflag,$
          bndotflag:bndotflag,$
      
          ok:ok,$
          cl:cl $
        }

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_BASELS',tlb,/no_block


END