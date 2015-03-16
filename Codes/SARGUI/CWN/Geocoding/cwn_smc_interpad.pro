PRO CWN_SMC_INTERPAD_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  
  case uname of
    'opengaps':begin
      infile=dialog_pickfile(title='Sasmac InSAR',filter='*.unw;*.hgt',/read,path=workpath)
      if infile eq '' then return
        widget_control,(*pstate).gaps,set_value=infile
        widget_control,(*pstate).gaps,set_uvalue=infile
        if infile eq '' then result=dialog_message('input filename',title='input file',/information)
        if infile ne '' then begin
          
        gapsint=workpath+PATH_SEP()+TLI_FNAME(infile, /nosuffix)+'.interp'
        
        widget_control,(*pstate).gapsint,set_value=gapsint
        widget_control,(*pstate).gapsint,set_uvalue=gapsint
          
        fpath=strsplit(infile,'\',/extract)
        pathsize=size(fpath)
        fname=fpath(pathsize(1)-1)
        file=strsplit(fname,'.',/extract)
        length=strlen(file(0))
        fname=strmid(file(0),length-8)
        filename=fname+'.pwr.par';parfile name
   
        hdrpath=''
        for i=0,pathsize(1)-2 do begin
          hdrpath=hdrpath+fpath(i)+'\'
        endfor
          hpath=hdrpath+filename
          files=findfile(hpath,count=numfiles)
          ;-can not find parfile
        if (numfiles eq 0) then begin
          result=dialog_message('can not find parfile',title='can not find par file')
        endif else begin
          openr,lun,hpath,/get_lun
          temp=''
          for i=0,9 do begin
            readf,lun,temp
          endfor
            readf,lun,temp
            width=(strsplit(temp,/extract))(1)
        endelse
          widget_control,(*pstate).width,set_value=width
          widget_control,(*pstate).width,set_uvalue=width
        endif  
    end
    
    'opengapsint':begin
      widget_control,(*pstate).gaps,get_uvalue=gaps
      if gaps eq '' then begin
        result=dialog_message(title='gaps file','Please input gaps file',/information,/center)
        return
      endif
        temp=file_basename(gaps)
        temp=strsplit(temp,'.',/extract)
        gaps=temp(0)
        file=gaps+'.interp'
        infiles=dialog_pickfile(title='output interpolation gaps data file',filter='*.interp',path=workpath,file=file,/write,/overwrite_prompt)
      if infiles eq '' then return
        widget_control,(*pstate).gapsint,set_value=infiles
        widget_control,(*pstate).gapsint,set_uvalue=infiles
    end
    'ok':begin
      widget_control,(*pstate).gaps,get_value=gaps
      widget_control,(*pstate).gapsint,get_value=gapsint
      widget_control,(*pstate).width,get_value=width
      widget_control,(*pstate).rmax,get_value=rmax
      widget_control,(*pstate).npmin,get_value=npmin
      widget_control,(*pstate).npmax,get_value=npmax
      
      wmode=WIDGET_INFO((*pstate).wmode,/droplist_select)
      wmode=STRCOMPRESS(wmode, /REMOVE_ALL)
      
      type=WIDGET_INFO((*pstate).type,/droplist_select)
      type=STRCOMPRESS(type, /REMOVE_ALL)
      
      cpdata=WIDGET_INFO((*pstate).cpdata,/droplist_select)
      cpdata=STRCOMPRESS(cpdata, /REMOVE_ALL)
      
      if gaps eq '' then begin
        result=dialog_message(title='Input data file','Please input data with gaps file',/information,/center)
        return
      endif
      if gapsint eq '' then begin 
        result=dialog_message(title='Output data file','Please specify output data with gaps filled by interpolation file',/information,/center)
        return
      endif
      
      if width lt 0 then begin
        result=dialog_message(['Number of samples/row should be greater than 0:',$
          STRCOMPRESS(width)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if rmax lt 0 then begin
        result=dialog_message(['maximum interpolation window radius should be greater than 0:',$
          STRCOMPRESS(rmax)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if npmin lt 0 then begin
        result=dialog_message(['minimum number of points used for the interpolation should be greater than 0:',$
          STRCOMPRESS(npmin)],title='Sasmac InSAR',/information,/center)
        return
      endif
      if npmax lt 0 then begin
        result=dialog_message(['Maximum number of points used for the interpolation should be greater than 0:',$
          STRCOMPRESS(npmax)],title='Sasmac InSAR',/information,/center)
        return
      endif
      
      scr='interp_ad ' +gaps+' '+gapsint+' '+width+' '+rmax+' '+npmin+' '+npmax+' '+wmode+' '+type+' '+cpdata
        TLI_SMC_SPAWN, scr,info='Weighted interpolation of gaps in 2D data using an adaptive smoothing window, Please wait...'
      
      fpath=STRSPLIT(gapsint,'/',/extract)
      pathsize=size(fpath)
      fname=fpath(pathsize(1)-1)
      file=STRSPLIT(fname,'-',/extract)
      master=STRCOMPRESS(file(0)) 
      mlifile=master+'.pwr'
      
      rasrmg='rasrmg '+gapsint+' '+mlifile+' '+width+' '+' - - - 1 1 - - - - - '+gapsint+'.ras'
      TLI_SMC_SPAWN, rasrmg,info='DISP Program rasrmg, Please wait...'
      
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

PRO CWN_SMC_INTERPAD,EVENT

  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=500
  ysize=490
  
  gaps=''
  width=''
  rmax=''
  gapsint=''
  
  
  
  
   ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='interp_ad',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  gapsID=widget_base(tlb,/row,xsize=xsize,frame=1)
  gaps=widget_text(gapsID,value=gaps,uvalue=gaps,uname='gaps',/editable,xsize=62)
  opengaps=widget_button(gapsID,value='Input Gaps',uname='opengaps',xsize=100)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------') 

  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize-10)
  parlabel=widget_label(parID, xsize=xsize, value='Basic information about input parameters:',/align_left,/dynamic_resize) 
 
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-25, frame=1)
  widthID=widget_base(tempID,/column,xsize=xsize/2)
  widthlabel=widget_label(widthID,value='Number of samples:',/align_left)
  width=widget_text(widthID,value=width,uvalue=width,uname='width',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2, frame=1)
  rmaxID=widget_base(tempID,/column,xsize=xsize/2)
  rmaxlabel=widget_label(rmaxID,value='Maximum interpolation window radius:',/align_left)
  rmax=widget_text(rmaxID,value=rmax,uvalue=rmax,uname='rmax',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-25, frame=1)
  npminID=widget_base(tempID,/column,xsize=xsize/2)
  npminlabel=widget_label(npminID,value='Minimum interpolation points number:',/align_left)
  npmin=widget_text(npminID,value=npmin,uvalue=npmin,uname='npmin',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2, frame=1)
  npmaxID=widget_base(tempID,/column,xsize=xsize/2)
  npmaxlabel=widget_label(npmaxID,value='Maximum interpolation points number:',/align_left)
  npmax=widget_text(npmaxID,value=npmax,uvalue=npmax,uname='npmax',/editable,xsize=10)
  
  
  infoID=widget_base(labID,/row, xsize=xsize) 
  tempID=widget_base(infoID,/row,xsize=xsize/2-25, frame=1)
  wmodeID=widget_base(tempID,/column, xsize=xsize/2-25)
  wmodelabel=widget_label(wmodeID, value='data weighting mode:',/ALIGN_LEFT)
  wmode=widget_droplist(wmodeID, value=['0: constant',$
                                        '1: 1-(r/r_max)',$
                                        '2: 1-(r/r_max)**2(default)',$
                                        '3: exp(-2.*(r**2/r_max**2))']) 
                                        
  tempID=widget_base(infoID,/row,xsize=xsize/2, frame=1)
  typeID=widget_base(tempID,/column, xsize=xsize/2)
  typelabel=widget_label(typeID, value='input and output data type:',/ALIGN_LEFT)
  type=widget_droplist(typeID, value=['0: FCOMPLEX',$
                                      '1: SCOMPLEX',$
                                      '2: FLOAT (default)',$
                                      '3: INT',$
                                      '4: SHORT'])
                                      
  infoID=widget_base(labID,/row, xsize=xsize)                                     
  tempID=widget_base(infoID,/row,xsize=xsize-15, frame=1)
  cpdataID=widget_base(tempID,/column, xsize=xsize)
  cpdatalabel=widget_label(cpdataID, value='copy data flag:',/ALIGN_CENTER)
  cpdata=widget_droplist(cpdataID, value=['0: do not copy input data values to output',$
                                          '1: copy input data values to output (default)'])                                    

  ;-Create ground control point data file input window
  gapsintID=widget_base(tlb,/row,xsize=xsize,frame=1)
  gapsint=widget_text(gapsintID,value=gapsint,uvalue=gapsint,uname='gapsint',/editable,xsize=62)
  opengapsint=widget_button(gapsintID,value='Input Gaps',uname='opengapsint',xsize=100)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={gaps:gaps,$
         opengaps:opengaps,$
         width:width,$
         rmax:rmax,$
         npmin:npmin,$
         npmax:npmax,$
         wmode:wmode,$
         type:type,$
         cpdata:cpdata,$
         gapsint:gapsint,$
         opengapsint:opengapsint,$
         ok:ok,$
         cl:cl $
        }

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_INTERPAD',tlb,/no_block

END