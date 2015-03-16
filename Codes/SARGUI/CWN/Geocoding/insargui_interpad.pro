;   interp_ad,call the command of interp_ad in the GAMMA software
;     usage: interp_ad <data_in> <data_out> <width> [r_max] [np_min] [np_max] [w_mode] [type] [cp_data]
;       input parameters:
;           data_in  (input) data with gaps
;           data_out (output) data with gaps filled by interpolation
;           width    number of samples/row
;           r_max    maximum interpolation window radius (default(-): 16)
;           np_min   minimum number of points used for the interpolation (default(-): 16)
;           np_max   maximum number of points used for the interpolation (default(-): 16)
;           w_mode   data weighting mode (enter - for default):
;                      0: constant
;                      1: 1 - (r/r_max)
;                      2: 1 - (r/r_max)**2 (default)
;                      3: exp(-2.*(r**2/r_max**2))
;           type     input and output data type:
;                      0: FCOMPLEX
;                      1: SCOMPLEX
;                      2: FLOAT(default)
;                      3: INT
;                      4: SHORT
;           cp_data  copy data flag:
;                      0: do not copy input data values to output
;                      1: copy input data values to output (default)
;
;    -   Done written by CWN in Sasmac
;    -   29/12/2014

PRO INSARGUI_INTERPAD_EVENT,EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)
  case uname of
    ;-check input file

    'gaps_button':begin
      infile=dialog_pickfile(title='Please input gaps file',filter='',/read)
      if infile eq '' then return
        widget_control,(*pstate).gaps_text,set_value=infile
        widget_control,(*pstate).gaps_text,set_uvalue=infile
        if infile eq '' then result=dialog_message('input filename',title='input file',/information)
        if infile ne '' then begin
        fpath=strsplit(infile,'\',/extract)
        pathsize=size(fpath)
        fname=fpath(pathsize(1)-1)
        file=strsplit(fname,'.',/extract)
        length=strlen(file(0))
        fname=strmid(file(0),length-8)
        workpath=FILE_DIRNAME(infile)+PATH_SEP()
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
          widget_control,(*pstate).width_text,set_value=width
          widget_control,(*pstate).width_text,set_uvalue=width
        endif  
      end
      
    'gapsint_button':begin
      widget_control,(*pstate).gaps_text,get_uvalue=gaps
      if gaps eq '' then begin
        result=dialog_message(title='gaps file','Please input gaps file',/information)
        return
      endif
        workpath=file_dirname(gaps)+path_sep()
        file=gaps+'.interp'
        infiles=dialog_pickfile(title='output interpolation gaps data file',filter='*.interp',path=workpath,file=file,/write,/overwrite_prompt)
      if infiles eq '' then return
        widget_control,(*pstate).gapsint_text,set_value=infiles
        widget_control,(*pstate).gapsint_text,set_uvalue=infiles
    end
    'ok':begin
      if 1 then begin
        ;check input parameters
        widget_control,(*pstate).gaps_text,get_uvalue=gaps
        if gaps eq '' then begin
          result=dialog_message(title='gaps file','Please input gaps file',/information)
          return
        endif
        
        widget_control,(*pstate).width_text,get_value=width
          width=long(width)
          if width lt 0 then begin
            result=dialog_message(title='number of samples','number of samples should large than 0',/information)
            return
            widget_control,(*pstate).width_text,set_value=width
            widget_control,(*pstate).width_text,set_uvalue=width
          endif
          
        widget_control,(*pstate).rmax_text,get_value=rmax
          if rmax ne '-' then begin
            rmax=long(rmax)
            if rmax lt 0 then begin
              result=dialog_message(title='maximum interpolation','maximum interpolation window radius should large than 0',/information)
              return
              widget_control,(*pstate).rmax_text,set_value=rmax
              widget_control,(*pstate).rmax_text,set_uvalue=rmax
            endif
          endif  
        widget_control,(*pstate).npmin_text,get_value=npmin
          if npmin ne '-' then begin
            npmin=long(npmin)
            if npmin lt 0 then begin
              result=dialog_message(title='minimum number of points','minimum number of points used for interpolation should large than 0',/information)
              return
              widget_control,(*pstate).npmin_text,set_value=npmin
              widget_control,(*pstate).npmin_text,set_uvalue=npmin
            endif
          endif
        widget_control,(*pstate).npmax_text,get_value=npmax
          if npmax ne '-' then begin
            npmax=long(npmax)
            if npmax lt 0 then begin
              result=dialog_message(title='maximum number of points','maximum number of points used for interpolation should large than 0',/information)
              return
              widget_control,(*pstate).npmax_text,set_value=npmax
              widget_control,(*pstate).npmax_text,set_uvalue=npmax
            endif
          endif
        widget_control,(*pstate).wmode_text,get_value=wmode
          if wmode ne '-' then begin
            wmode=long(wmode)
            if wmode ge 4 then begin
              result=dialog_message(title='data weighting mode','data weighting mode should be 0 1 2 or 3',/information)
              return
              widget_control,(*pstate).wmode_text,set_value=wmode
              widget_control,(*pstate).wmode_text,set_uvalue=wmode
            endif
          endif  
        widget_control,(*pstate).type_text,get_value=type
          if type ne '-' then begin
            type=long(type)
            if type ge 5 then begin
              result=dialog_message(title='input and output data type','input and output data type should be 0 1 2 3 or 4',/information)
              return
              widget_control,(*pstate).type_text,set_value=type
              widget_control,(*pstate).type_text,set_uvalue=type
            endif
          endif
        widget_control,(*pstate).cpdata_text,get_value=cpdata
          if cpdata ne '-' then begin
            cpdata=long(cpdata)
            if cpdata ge 2 then begin
              result=dialog_message(title='copy data flag','copy data flag should be 0 or 1',/information)
              return
              widget_control,(*pstate).cpdata_text,set_value=cpdata
              widget_control,(*pstate).cpdata_text,set_uvalue=cpdata
            endif
          endif
                
        ;check output parameters
        widget_control,(*pstate).gapsint_text,get_uvalue=gapsint
        if gapsint eq '' then begin
          result=dialog_message(title='interpolation gaps data file','Please input interpolation gaps data file',/information)
          return
        endif        
      endif
      
      width=strcompress(string(width),/remove_all)
      rmax=strcompress(string(rmax),/remove_all)
      npmin=strcompress(string(npmin),/remove_all)
      npmax=strcompress(string(npmax),/remove_all)
      wmode=strcompress(string(wmode),/remove_all)
      type=strcompress(string(type),/remove_all)
      cpdata=strcompress(string(cpdata),/remove_all)
      
      wtlb = widget_base(title='process bar')
      widget_control,wtlb,/realize
      process = idlitwdprogressbar(group_leader=wtlb,time=0,title='processing...Please wait')
      idlitwdprogressbar_setvalue,process,0 ;-initialize the process bar,initial value=0
        scr='interp_ad '+gaps+' '+gapsint+' '+width+' '+rmax+' '+npmin+' '+npmax+' '+wmode+' '+type+' '+cpdata
        spawn,scr
      idlitwdprogressbar_setvalue,process,100 ;finish
;      stop     
    end
        
      
    'cl':begin
    result=dialog_message('Sure exit?',title='Exit',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
    end
    else:begin
      return
    end
  endcase

END
;-create the components
; input the paraments window
; deal with window
PRO INSARGUI_INTERPAD,EVENT

  ;Create components
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  tlb=widget_base(title='interp_ad',tlb_frame_attr=1,column=1,xsize=345,ysize=335,xoffset=xoffset,yoffset=yoffset)

  ;input window
  ;Create print flag input window
  inputID=widget_base(tlb,row=1)
  inputlabel=widget_label(inputID,value='input file:',/align_left,xsize=179)

  ;-Create ras input window
  gapsID=widget_base(tlb,row=1)
  gaps_text=widget_text(gapsID,value='',uvalue='',uname='gaps_text',/editable,xsize=37)
  gaps_button=widget_button(gapsID,value='Gaps',uname='gaps_button',xsize=96)

  ;-Create number of samples input window
  widthID=widget_base(tlb,row=1)
  widthlabel=widget_label(widthID,value='number of samples:',/align_left,xsize=179)
  width_text=widget_text(widthID,value='',uvalue='',uname='width_text',/editable,xsize=10)
  
  ;-Create number of points used for the interpolation input window
  numID=widget_base(tlb,row=1)
  numlabel=widget_label(numID,value='r_max,np_min,np_max:',/align_left,xsize=179)
  rmax_text=widget_text(numID,value='-',uvalue='',uname='rmax_text',/editable,xsize=5)
  npmin_text=widget_text(numID,value='-',uvalue='',uname='npmin_text',/editable,xsize=5)
  npmax_text=widget_text(numID,value='-',uvalue='',uname='npmax_text',/editable,xsize=5)
  
  ;-Create data type flag input window
  flagID=widget_base(tlb,row=1)
  flaglabel=widget_label(flagID,value='w_mode,type,cp_data:',/align_left,xsize=179)
  wmode_text=widget_text(flagID,value='-',uvalue='',uname='wmode_text',/editable,xsize=5)
  type_text=widget_text(flagID,value='-',uvalue='',uname='type_text',/editable,xsize=5)
  cpdata_text=widget_text(flagID,value='-',uvalue='',uname='cpdata_text',/editable,xsize=5)

  ;-output window
  ;Create print flag input window
  outputID=widget_base(tlb,row=1)
  outputlabel=widget_label(outputID,value='output file:',/align_left,xsize=179)

  ;-Create ground control point data file input window
  gapsintID=widget_base(tlb,row=1)
  gapsint_text=widget_text(gapsintID,value='',uvalue='',uname='gapsint_text',/editable,xsize=37)
  gapsint_button=widget_button(gapsintID,value='Gaps_interp',uname='gapsint_button',xsize=96)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={gaps_text:gaps_text,gaps_button:gaps_button,width_text:width_text,rmax_text:rmax_text,npmin_text:npmin_text,npmax_text:npmax_text,$
    wmode_text:wmode_text,type_text:type_text,cpdata_text:cpdata_text,gapsint_text:gapsint_text,gapsint_button:gapsint_button,ok:ok,cl:cl}

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'INSARGUI_INTERPAD',tlb,/no_block

END