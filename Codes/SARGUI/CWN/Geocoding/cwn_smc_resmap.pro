PRO CWN_SMC_RESMAP_EVENT,EVENT
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
      parfile=config.m_slcpar
      widget_control,(*pstate).master,set_value=infile
      widget_control,(*pstate).master,set_uvalue=infile
    
      widget_control,(*pstate).mpar,set_value=infile+'.par'
      widget_control,(*pstate).mpar,set_uvalue=infile+'.par'  
      
      
      finfo=TLI_LOAD_SLC_PAR(parfile)
      nlines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
      azpsres=STRCOMPRESS(finfo.azimuth_pixel_spacing,/REMOVE_ALL)
      
      widget_control, (*pstate).nlines,set_value=nlines
      widget_control, (*pstate).nlines,set_uvalue=nlines
      widget_control, (*pstate).azpsres,set_value=azpsres
      widget_control, (*pstate).azpsres,set_uvalue=azpsres
        
    END
    'openhgt':begin
      infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.hgt', path=workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).hgt,set_value=infile
      widget_control,(*pstate).hgt,set_uvalue=infile
      
      rhgtfile=workpath+PATH_SEP()+TLI_FNAME(infile, /nosuffix)+'.rhgt'
      widget_control,(*pstate).rhgt,set_value=rhgtfile
      widget_control,(*pstate).rhgt,set_uvalue=rhgtfile
    end
    'opengrd':begin
      infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.grd', path=workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).grd,set_value=infile
      widget_control,(*pstate).grd,set_uvalue=infile
    end
    'opendata':begin
      infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.pwr;*.cc', path=workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).data,set_value=infile
      widget_control,(*pstate).data,set_uvalue=infile
      
      rdatafile=infile+'.grd'
      widget_control,(*pstate).rdata,set_value=rdatafile
      widget_control,(*pstate).rdata,set_uvalue=rdatafile   
    end  
    'openoff':begin
      infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath)
      IF NOT FILE_TEST(infile) THEN return
      widget_control,(*pstate).off,set_value=infile
      widget_control,(*pstate).off,set_uvalue=infile
      
      rfile=workpath+PATH_SEP()+'rhgt'+'.par'
      widget_control,(*pstate).rfile,set_value=rfile
      widget_control,(*pstate).rfile,set_uvalue=rfile 
      
    end
    
    'openrhgt':begin
      widget_control,(*pstate).master,get_value=master
      widget_control,(*pstate).hgt,get_value=hgt
      widget_control,(*pstate).grd,get_value=grd
      widget_control,(*pstate).data,get_value=data
      widget_control,(*pstate).off,get_value=off
      
      if master eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input master file',/information,/center)
        return
      endif
      if hgt eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input hgt file',/information,/center)
        return
      endif
      if grd eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input grd file',/information,/center)
        return
      endif
      if data eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input data file',/information,/center)
        return
      endif
      if off eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input offset par file',/information,/center)
        return
      endif
      
      rhgtfile=TLI_FNAME(hgt, /nosuffix)+'.rhgt'
      infile=dialog_pickfile(title='Sasmac InSAR',filter='*.rhgt',path=workpath,file=rhgtfile,/write,/overwrite_prompt)
      IF infile EQ '' THEN RETURN
      widget_control,(*pstate).rhgt,set_value=infile
      widget_control,(*pstate).rhgt,set_uvalue=infile

    End
    
    'openrdata':begin
      widget_control,(*pstate).master,get_value=master
      widget_control,(*pstate).hgt,get_value=hgt
      widget_control,(*pstate).grd,get_value=grd
      widget_control,(*pstate).data,get_value=data
      widget_control,(*pstate).off,get_value=off
      
      if master eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input master file',/information,/center)
        return
      endif
      if hgt eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input hgt file',/information,/center)
        return
      endif
      if grd eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input grd file',/information,/center)
        return
      endif
      if data eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input data file',/information,/center)
        return
      endif
      if off eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input offset par file',/information,/center)
        return
      endif
      
      grdfile=TLI_FNAME(data, /nosuffix)+'.grd'
      infile=dialog_pickfile(title='Sasmac InSAR',filter='*.grd',path=workpath,file=grdfile,/write,/overwrite_prompt)
      widget_control,(*pstate).rdata,set_value=infile
      widget_control,(*pstate).rdata,set_uvalue=infile

    End
    'openrfile':begin
      widget_control,(*pstate).master,get_value=master
      widget_control,(*pstate).hgt,get_value=hgt
      widget_control,(*pstate).grd,get_value=grd
      widget_control,(*pstate).data,get_value=data
      widget_control,(*pstate).off,get_value=off
      widget_control,(*pstate).rhgt,get_value=rhgt
      widget_control,(*pstate).rdata,get_value=rdata
      
      if master eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input master file',/information,/center)
        return
      endif
      if hgt eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input hgt file',/information,/center)
        return
      endif
      if grd eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input grd file',/information,/center)
        return
      endif
      if data eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input data file',/information,/center)
        return
      endif
      if off eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input offset par file',/information,/center)
        return
      endif
      
      if rhgt eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please specify resampled hgt file',/information,/center)
        return
      endif
      if rdata eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please specify resampled data file',/information,/center)
        return
      endif
      
      parfile='rhgt'+'.par'
      infile=dialog_pickfile(title='Sasmac InSAR',filter='*.par',path=workpath,file=parfile,/write,/overwrite_prompt)
      if infile eq '' then return
        widget_control,(*pstate).rfile,set_value=infile
        widget_control,(*pstate).rfile,set_uvalue=infile
     
    End
      
    'ok':begin
      widget_control,(*pstate).master,get_value=master
      widget_control,(*pstate).mpar,get_value=mpar
      widget_control,(*pstate).hgt,get_value=hgt
      widget_control,(*pstate).grd,get_value=grd
      widget_control,(*pstate).data,get_value=data
      widget_control,(*pstate).off,get_value=off
      widget_control,(*pstate).rhgt,get_value=rhgt
      widget_control,(*pstate).rdata,get_value=rdata
      widget_control,(*pstate).rfile,get_value=rfile
      
      widget_control,(*pstate).numran,get_value=numran
      widget_control,(*pstate).numazi,get_value=numazi
      widget_control,(*pstate).loff,get_value=loff
      widget_control,(*pstate).nlines,get_value=nlines
      widget_control,(*pstate).azpsres,get_value=azpsres
      
      if master eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input master file',/information,/center)
        return
      endif
      if mpar eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input master par file',/information,/center)
        return
      endif
      if hgt eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input hgt file',/information,/center)
        return
      endif
      if grd eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input grd file',/information,/center)
        return
      endif
      if data eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input data file',/information,/center)
        return
      endif
      if off eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please input offset par file',/information,/center)
        return
      endif
      
      if rhgt eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please specify resampled hgt file',/information,/center)
        return
      endif
      if rdata eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please specify resampled data file',/information,/center)
        return
      endif
      if rfile eq '' then begin
        result=dialog_message(title='Sasmac InSAR','please specify report file',/information,/center)
        return
      endif
      
      if numran lt 0 then begin
        result=dialog_message(['number of range samples for L.S. estimate should be greater than 0:',$
        STRCOMPRESS(numran)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if numazi lt 0 then begin
        result=dialog_message(['number of azimuth samples for L.S. estimate should be greater than 0:',$
        STRCOMPRESS(numazi)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if azpsres lt 0 then begin
        result=dialog_message(['azimuth output map sample spacing in meters should be greater than 0:',$
        STRCOMPRESS(azpsres)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if loff lt 0 then begin
        result=dialog_message(['offset to starting line for height calculations should be greater than 0:',$
        STRCOMPRESS(loff)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if nlines lt 0 then begin
        result=dialog_message(['number of lines to calculate should be greater than 0:',$
        STRCOMPRESS(nlines)],title='Sasmac InSAR',/information,/center)
        return
      endif
      
      if rdata EQ data THEN BEGIN
        result=DIALOG_MESSAGE(['Error! Output file should be different from input file.', $
                               'Allocating data error will be reported by GAMMA.',$
                               '',$
                               'Input file: '+data, $
                               'Output file: '+rdata])
        RETURN                               
      END
      
      scr="res_map " +hgt +' '+grd +' '+data+' '+mpar+' '+off+' '+rhgt+' '+rdata+' '+numran+' '+numazi+' '+azpsres+' '+loff+' '+nlines +' >'+rfile
        TLI_SMC_SPAWN, scr,info='Slant range to ground range transformation based on interferometric ground-range, Please wait...'
      
      
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

PRO CWN_SMC_RESMAP,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=570
  ysize=650
  
  
  ; Get config info
  m_slc=config.m_slc
  mparfile=config.m_slcpar
  hgt=''
  grd=''
  data=''
  off=''
  
  numran='7'
  numazi='7'
  loff='0'
  nlines=''
  azpsres=''
  
  rhgt=''
  rdata=''
  rfile=''
  
  IF FILE_TEST(m_slc) THEN BEGIN
      temp=TLI_FNAME(m_slc,suffix=suffix)
      IF suffix EQ '.rslc' OR suffix EQ '.slc' THEN BEGIN
        parfile=m_slc+'.par'
        finfo=TLI_LOAD_SLC_PAR(parfile)
        nlines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
        azpsres=STRCOMPRESS(finfo.azimuth_pixel_spacing,/REMOVE_ALL)
      ENDIF
  ENDIF
  
   ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='res_map',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)

  ;-Create unw input window
 
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=m_slc,uvalue=m_slc,uname='master',/editable,xsize=74)
  openmaster=widget_button(masterID,value='Input Master',uname='openmaster',xsize=100)
  
  hgtID=widget_base(tlb,/row,xsize=xsize,frame=1)
  hgt=widget_text(hgtID,value=hgt,uvalue=hgt,uname='hgt',/editable,xsize=74)
  openhgt=widget_button(hgtID,value='Input hgt',uname='openhgt',xsize=100)
  
  grdID=widget_base(tlb,/row,xsize=xsize,frame=1)
  grd=widget_text(grdID,value=grd,uvalue=grd,uname='grd',/editable,xsize=74)
  opengrd=widget_button(grdID,value='Input grd',uname='opengrd',xsize=100)
  
  dataID=widget_base(tlb,/row,xsize=xsize,frame=1)
  data=widget_text(dataID,value=data,uvalue=data,uname='data',/editable,xsize=74)
  opendata=widget_button(dataID,value='Input data',uname='opendata',xsize=100)
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=74)
  openoff=widget_button(offID,value='Input offset',uname='openoff',xsize=100)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize, value='Basic information about master parameters:',/align_left,/dynamic_resize) 
  
  mparID=widget_base(labID,/row,xsize=xsize,frame=1)
  mpar=widget_text(mparID,value=mparfile,uvalue=mparfile,uname='mpar',/editable,xsize=91)
  
  infoID=widget_base(labID,/row, xsize=xsize)                                        
  tempID=widget_base(infoID,/row,xsize=xsize/2-10, frame=1)
  numranID=widget_base(tempID, /column, xsize=xsize/2-5)
  numranlabel=widget_label(numranID, value='Number of range samples for L.S. estimate:',/ALIGN_LEFT)
  numran=widget_text(numranID,value=numran, uvalue=numran, uname='numran',/editable,xsize=10)
 
  tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
  numaziID=widget_base(tempID,/column, xsize=xsize/2-10)
  numazilabel=widget_label(numaziID, value='Number of azimuth samples for L.S. estimate:',/ALIGN_LEFT)
  numazi=widget_text(numaziID, value=numazi,uvalue=numazi, uname='numazi',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize)                                        
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  azpsresID=widget_base(tempID, /column, xsize=xsize/3-5)
  azpsreslabel=widget_label(azpsresID, value='Azimuth map sample spacing:',/ALIGN_LEFT)
  azpsres=widget_text(azpsresID,value=azpsres, uvalue=azpsres, uname='azpsres',/editable,xsize=10)
 
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  loffID=widget_base(tempID,/column, xsize=xsize/3-10)
  lofflabel=widget_label(loffID, value='Offset to starting line:',/ALIGN_LEFT)
  loff=widget_text(loffID, value=loff,uvalue=loff, uname='loff',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-7, frame=1)
  nlinesID=widget_base(tempID,/column, xsize=xsize/3-5)
  nlineslabel=widget_label(nlinesID, value='Number of lines to calculate:',/ALIGN_LEFT)
  nlines=widget_text(nlinesID, value=nlines,uvalue=nlines, uname='nlines',/editable,xsize=10)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------------------')

  ;-Create height file input window
  
  rhgtID=widget_base(tlb,/row,xsize=xsize,frame=1)
  rhgt=widget_text(rhgtID,value=rhgt,uvalue=rhgt,uname='rhgt',/editable,xsize=74)
  openrhgt=widget_button(rhgtID,value='Output rhgt',uname='openrhgt',xsize=100)
  
  rdataID=widget_base(tlb,/row,xsize=xsize,frame=1)
  rdata=widget_text(rdataID,value=rdata,uvalue=rdata,uname='rdata',/editable,xsize=74)
  openrdata=widget_button(rdataID,value='Output rdata',uname='openrdata',xsize=100)
  
  ;-Create cross-track ground ranges file input window
  rfileID=widget_base(tlb,/row,xsize=xsize,frame=1)
  rfile=widget_text(rfileID,value=rfile,uvalue=rfile,uname='rfile',/editable,xsize=74)
  openrfile=widget_button(rfileID,value='Output report',uname='openrfile',xsize=100)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={ master:master,$
          openmaster:openmaster,$
          hgt:hgt,$
          openhgt:openhgt,$
          grd:grd,$
          opengrd:opengrd,$
          data:data,$
          opendata:opendata,$
          off:off,$
          openoff:openoff,$
          mpar:mpar,$
          numran:numran,$
          numazi:numazi,$
          loff:loff,$
          nlines:nlines,$
          azpsres:azpsres,$
          rhgt:rhgt,$
          openrhgt:openrhgt,$
          rdata:rdata,$
          openrdata:openrdata,$
          rfile:rfile,$
          openrfile:openrfile,$
          ok:ok,$
          cl:cl $
  
        }

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_RESMAP',tlb,/no_block

  END