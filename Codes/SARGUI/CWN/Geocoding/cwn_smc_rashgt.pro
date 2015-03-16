PRO CWN_SMC_RASHGT_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openhgt':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.hgt;*.rhgt;.interp', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update widget info.

    widget_control,(*pstate).hgt,set_value=infile
    widget_control,(*pstate).hgt,set_uvalue=infile
    
    widget_control,(*pstate).rasf,set_value=infile+'.ras'
    widget_control,(*pstate).rasf,set_uvalue=infile+'.ras'
    
     fpath=STRSPLIT(infile,'/',/extract)
    pathsize=size(fpath)
    fname=fpath(pathsize(1)-1)
    file=STRSPLIT(fname,'-',/extract)
    master=STRCOMPRESS(file(0)) 
    mparfile=workpath+PATH_SEP()+master+'.pwr.par'
    finfo=TLI_LOAD_SLC_PAR(mparfile)
    width=STRCOMPRESS(string(long(finfo.range_samples)),/REMOVE_ALL)
    nlines=STRCOMPRESS(string(long(finfo.azimuth_samples)),/REMOVE_ALL)
    
    widget_control,(*pstate).width,set_value=width
    widget_control,(*pstate).width,set_uvalue=width
    widget_control,(*pstate).nlines,set_value=nlines
    widget_control,(*pstate).nlines,set_uvalue=nlines
        
  END
  
  'openpwr':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.pwr', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update widget info.

    widget_control,(*pstate).pwr,set_value=infile
    widget_control,(*pstate).pwr,set_uvalue=infile
    
    parfile=infile+'par'
    finfo=TLI_LOAD_SLC_PAR(parfile)
    width=STRCOMPRESS(string(long(finfo.range_samples)),/REMOVE_ALL)
    nlines=STRCOMPRESS(string(long(finfo.azimuth_samples)),/REMOVE_ALL)
    
    widget_control,(*pstate).width,set_value=width
    widget_control,(*pstate).width,set_uvalue=width
    widget_control,(*pstate).nlines,set_value=nlines
    widget_control,(*pstate).nlines,set_uvalue=nlines
       
  END
  
  'openrasf':begin
    widget_control,(*pstate).hgt,get_value=hgt
    
    if hgt eq '' then begin
      result=dialog_message(title='Sasmac InSAR','please select input hgt file',/information,/center)
      return
    endif

    rasfile=hgt+'.ras'
    infile=dialog_pickfile(title='Sasmac InSAR',filter='*.hgt',path=workpath,file=rasfile,/write,/overwrite_prompt)
      widget_control,(*pstate).rasf,set_value=infile
      widget_control,(*pstate).rasf,set_uvalue=infile
  end
 
    'ok':begin
      widget_control,(*pstate).hgt,get_value=hgt
      widget_control,(*pstate).pwr,get_value=pwr
      widget_control,(*pstate).rasf,get_value=rasf
      
      widget_control,(*pstate).width,get_value=width
      widget_control,(*pstate).nlines,get_value=nlines
      widget_control,(*pstate).shgt,get_value=shgt
      widget_control,(*pstate).spwr,get_value=spwr
      widget_control,(*pstate).pixavr,get_value=pixavr
      widget_control,(*pstate).pixavaz,get_value=pixavaz
      widget_control,(*pstate).mcycle,get_value=mcycle
      widget_control,(*pstate).disexp,get_value=disexp
      widget_control,(*pstate).scale,get_value=scale
      
      mirror=WIDGET_INFO((*pstate).mirror,/droplist_select)
      mirror_d=long(mirror)
      if mirror_d eq o then begin
        mirror=STRCOMPRESS(string(long(mirror_d+1)),/remove_all)
      endif
      if mirror_d eq 1 then begin
        mirror=STRCOMPRESS(string(long(mirror_d-2)),/remove_all)
      endif
      
    if hgt eq '' then begin
      result=dialog_message(title='Sasmac InSAR','Please select input hgt parfile',/information,/center)
      return
    endif 
    if pwr ne '-' then begin
      if pwr eq '' then begin
        result=dialog_message(title='Sasmac InSAR','Please select input pwr file',/information,/center)
        return
      endif
    endif
    if rasf eq '' then begin
      result=dialog_message(title='Sasmac InSAR','Please specify raster image file',/information,/center)
      return
    endif

    if width lt 0 then begin
        result=dialog_message(['Samples per row of hgt and pwr should be greater than 0:',$
        STRCOMPRESS(width)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if nlines le 0 then begin
        result=dialog_message(['Number of lines to display should be greater than 0:',$
        STRCOMPRESS(nlines)],title='Sasmac InSAR',/information,/center)
        return
      endif 
      
      if shgt lt 0 then begin
        result=dialog_message(['Starting line of hgt should be greater than 0:',$
        STRCOMPRESS(shgt)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if spwr le 0 then begin
        result=dialog_message(['Starting line of hgt should be greater than 0:',$
        STRCOMPRESS(spwr)],title='Sasmac InSAR',/information,/center)
        return
      endif 
      if pixavr lt 0 then begin
        result=dialog_message(['number of pixels to average in range should be greater than 0:',$
        STRCOMPRESS(pixavr)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if pixavaz le 0 then begin
        result=dialog_message(['Number of pixels to average in azimuth should be greater than 0:',$
        STRCOMPRESS(pixavaz)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if mcycle lt 0 then begin
        result=dialog_message(['Meters per color cycle should be greater than 0:',$
        STRCOMPRESS(mcycle)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if scale le 0 then begin
        result=dialog_message(['Display scale factor should be greater than 0:',$
        STRCOMPRESS(scale)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if disexp le 0 then begin
        result=dialog_message(['Display exponent should be greater than 0:',$
        STRCOMPRESS(disexp)],title='Sasmac InSAR',/information,/center)
        return
      endif
    
      scr="rashgt " +hgt +' '+pwr +' '+width+' '+shgt+' '+spwr+' '+nlines+' '+pixavr+' '+pixavaz+' '+mcycle+' '+scale+' '+disexp+' '+mirror+' '+rasf
        TLI_SMC_SPAWN, scr,info='DISP Program rashgt, Please wait...'

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

PRO CWN_SMC_RASHGT,EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=520
  ysize=540
  
  
  ; Get config info

  hgtfile=''
  pwrfile=''
  
  width=''
  shgt='1'
  spwr='1'
  nlines=''
  pixavr='1'
  pixavaz='1'
  mcycle='160.0'
  scale='1.0'
  disexp='0.35'
         
  rasf=''
   ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='rashgt',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)

  ;-Create unw input window
 
  hgtID=widget_base(tlb,/row,xsize=xsize,frame=1)
  hgt=widget_text(hgtID,value=hgtfile,uvalue=hgtfile,uname='hgt',/editable,xsize=65)
  openhgt=widget_button(hgtID,value='Input Hgt',uname='openhgt',xsize=100)

  pwrID=widget_base(tlb,/row,xsize=xsize,frame=1)
  pwr=widget_text(pwrID,value=pwrfile,uvalue=pwrfile,uname='pwr',/editable,xsize=65)
  openpwr=widget_button(pwrID,value='Input Intensity',uname='openpwr',xsize=100)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize, value='Basic information about input parameters:',/align_left,/dynamic_resize) 
  
  infoID=widget_base(labID,/row, xsize=xsize)                                        
  tempID=widget_base(infoID,/row,xsize=xsize/3, frame=1)
  widthID=widget_base(tempID, /column, xsize=xsize/3)
  widthlabel=widget_label(widthID, value='Samples per row of hgt:',/ALIGN_LEFT)
  width=widget_text(widthID,value=width, uvalue=width, uname='width',/editable,xsize=10)
 
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  shgtID=widget_base(tempID,/column, xsize=xsize/3)
  shgtlabel=widget_label(shgtID, value='Starting line of hgt:',/ALIGN_LEFT)
  shgt=widget_text(shgtID, value=shgt,uvalue=shgt, uname='shgt',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
  spwrID=widget_base(tempID,/column, xsize=xsize/3-10)
  spwrlabel=widget_label(spwrID, value='Starting line of pwr:',/ALIGN_LEFT)
  spwr=widget_text(spwrID, value=spwr,uvalue=spwr, uname='spwr',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3, frame=1)
  nlinesID=widget_base(tempID,/column, xsize=xsize/3)
  nlineslabel=widget_label(nlinesID, value='Number of lines to display:',/ALIGN_LEFT)
  nlines=widget_text(nlinesID, value=nlines,uvalue=nlines, uname='nlines',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  pixavrID=widget_base(tempID,/column, xsize=xsize/3)
  pixavrlabel=widget_label(pixavrID, value='Average pixels in range:',/ALIGN_LEFT)
  pixavr=widget_text(pixavrID, value=pixavr,uvalue=pixavr, uname='pixavr',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
  pixavazID=widget_base(tempID,/column, xsize=xsize/3-10)
  pixavazlabel=widget_label(pixavazID, value='Average pixels in azimuth:',/ALIGN_LEFT)
  pixavaz=widget_text(pixavazID, value=pixavaz,uvalue=pixavaz, uname='pixavaz',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3, frame=1)
  mcycleID=widget_base(tempID,/column, xsize=xsize/3)
  mcyclelabel=widget_label(mcycleID, value='Meters per color cycle:',/ALIGN_LEFT)
  mcycle=widget_text(mcycleID, value=mcycle,uvalue=mcycle, uname='mcycle',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  scaleID=widget_base(tempID,/column, xsize=xsize/3)
  scalelabel=widget_label(scaleID, value='Display scale factor:',/ALIGN_LEFT)
  scale=widget_text(scaleID, value=scale,uvalue=scale, uname='scale',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
  expID=widget_base(tempID,/column, xsize=xsize/3-10)
  disexplabel=widget_label(expID, value='Display exponent:',/ALIGN_LEFT)
  disexp=widget_text(expID, value=disexp,uvalue=disexp, uname='disexp',/editable,xsize=10) 
  
  infoID=widget_base(labID,/row, xsize=xsize) 
  tempID=widget_base(infoID,/row,xsize=xsize, frame=1)
  mirrorID=widget_base(tempID,/row, xsize=xsize)
  mirrorlabel=widget_label(mirrorID, value='Left/Right mirror image flag:',/ALIGN_LEFT)
  mirror=widget_droplist(mirrorID, value=['1: normal (default)',$
                                          '-1: mirror image)']) 
  
  

  temp=widget_label(tlb,value='--------------------------------------------------------------------------------------')
  
  rasfID=widget_base(tlb,/row,xsize=xsize,frame=1)
  rasf=widget_text(rasfID,value=rasf,uvalue=rasf,uname='rasf',/editable,xsize=65)
  openrasf=widget_button(rasfID,value='Output image',uname='openrasf',xsize=100)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={ hgt:hgt,$
          openhgt:openhgt,$
          pwr:pwr,$
          openpwr:openpwr,$
          
          width:width,$
          shgt:shgt,$
          spwr:spwr,$
          nlines:nlines,$
          pixavr:pixavr,$
          pixavaz:pixavaz,$
          mcycle:mcycle,$
          scale:scale,$
          disexp:disexp,$
          mirror:mirror,$
         
          rasf:rasf,$
          openrasf:openrasf,$
          
          ok:ok,$
          cl:cl $
        }

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_RASHGT',tlb,/no_block

END