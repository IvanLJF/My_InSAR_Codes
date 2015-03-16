PRO TLI_SMC_ML_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  
  uname=widget_info(event.id,/uname)
  Case uname OF
    'openinput':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter=['*.slc;*.rslc'], path=config.workpath)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
    
    ; Update widget info.
    workpath=config.workpath
    inputfile=config.inputfile
    parfile=inputfile+'.par'
    finfo=TLI_LOAD_SLC_PAR(parfile)
    samples=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
    format=finfo.image_format
    aps=STRCOMPRESS(finfo.azimuth_pixel_spacing,/REMOVE_ALL)
    rps=STRCOMPRESS(finfo.range_pixel_spacing,/REMOVE_ALL)
    inc=STRCOMPRESS(finfo.incidence_angle,/REMOVE_ALL)
    temp=TLI_MLFACTOR(parfile=parfile)
    mlr=STRCOMPRESS(temp[0],/REMOVE_ALL)
    mlazi=STRCOMPRESS(temp[1],/REMOVE_ALL)
    rps_grd=STRCOMPRESS(finfo.range_pixel_spacing/SIN(DEGREE2RADIANS(finfo.incidence_angle)))
    rps_grd_lab='Multi-look factors calculated using RPS and APS.'+STRING(13b)+$
      'The corresponding ground range pixel spacing is '+rps_grd
    outputfile=workpath+TLI_FNAME(infile, /nosuffix)+'.pwr'
    
    widget_control,(*pstate).input,set_value=infile
    widget_control,(*pstate).input,set_uvalue=infile
    widget_control, (*pstate).parlabel, set_value='SLC par:'+parfile, set_uvalue=parfile
    widget_control, (*pstate).samples, set_value=samples, set_uvalue=samples
    widget_control, (*pstate).lines, set_value=lines, set_uvalue=lines
    widget_control, (*pstate).format, set_value=format, set_uvalue=format
    widget_control, (*pstate).rps, set_value=rps, set_uvalue=rps
    widget_control, (*pstate).aps, set_value=aps, set_uvalue=aps
    widget_control, (*pstate).inc, set_value=inc, set_uvalue=inc
    widget_control, (*pstate).mlr, set_value=mlr, set_uvalue=mlr
    widget_control, (*pstate).mlazi, set_value=mlazi, set_uvalue=mlazi
    widget_control, (*pstate).output, set_value=outputfile, set_uvalue=outputfile
    
  END
  'headfile':begin
  widget_control,(*pstate).input,get_uvalue=infile
  
  widget_control,(*pstate).columns,set_value=columns
  widget_control,(*pstate).columns,set_uvalue=columns
  widget_control,(*pstate).lines,set_value=lines
  widget_control,(*pstate).lines,set_uvalue=lines
END
'openoutput':begin
widget_control,(*pstate).input,get_uvalue=input
if input eq '' then begin
  result=dialog_message('',title='',/information)
  return
endif
file=file_basename(input)
file=file+'.amplitude.bmp'
outfile=dialog_pickfile(title='',/write,file=file,filter='*.bmp',/overwrite_prompt)

widget_control,(*pstate).output,set_value=outfile
widget_control,(*pstate).output,set_uvalue=outfile

end

'ok':begin
widget_control,(*pstate).input,get_uvalue=inputfile
widget_control,(*pstate).samples,get_value=samples
widget_control,(*pstate).lines,get_value=lines
widget_control,(*pstate).output,get_uvalue=outputfile
widget_control, (*pstate).mlr, get_uvalue=mlr
widget_control, (*pstate).mlazi, get_uvalue=mlazi

if inputfile eq '' then begin
  result=dialog_message(['Please select the input file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if samples le 0 then begin
  result=dialog_message(['Samples should be greater than 0:',$
    STRCOMPRESS(columns)],title='Sasmac InSAR',/information,/center)
  return
endif
if lines le 0 then begin
  result=dialog_message(['Lines should be greater than 0:',$
    STRCOMPRESS(lines)],title='Sasmac InSAR',/information,/center)
  return
endif
if outputfile eq '' then begin
  result=dialog_message('Please specify output file',title='Sasmac InSAR',/information,/center)
  return
endif

config.ml_r=mlr
config.ml_azi=mlazi

scr='multi_look '+inputfile+' '+inputfile+'.par '+outputfile+' '+outputfile+'.par '+mlr+' '+mlazi
TLI_SMC_SPAWN, scr, info='Multi Looking, please wait...'

; Display the results
pwrfile=outputfile
pwrparfile=outputfile+'.par'
pwrpar=TLI_LOAD_PAR(pwrparfile)
pwr=TLI_READDATA(pwrfile, samples=pwrpar.range_samples,  format='float',/swap_endian)

TLI_SMC_DISPLAY, pwr^0.1
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




PRO TLI_SMC_ML

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=450
  
  ; Get config info
;  IF config.workpath EQ '' THEN BEGIN
;    workpath='/mnt/data_tli/ForExperiment/InSARGUI/int_ERS_shanghai_2000_10000'
;  ENDIF ELSE BEGIN
;    workpath = config.workpath
;  ENDELSE
  workpath=config.workpath
  inputfile=''
  parfile=''
  parlab='Par file not found'
  samples='0'
  lines='0'
  format=''
  aps='0.0'
  rps='0.0'
  inc='0'
  mlr='1'
  mlazi='1'
  rps_grd='0.0'
  rps_grd_lab=''+STRING(10b)+''
  IF FILE_TEST(config.inputfile) THEN BEGIN
    workpath=config.workpath
    inputfile=config.inputfile
    temp=TLI_FNAME(inputfile,suffix=suffix)
    IF suffix EQ '.rslc' OR suffix EQ '.slc' THEN BEGIN
      parfile=inputfile+'.par'
      parlab='Par file:'+parfile
      finfo=TLI_LOAD_SLC_PAR(parfile)
      samples=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
      lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
      format=finfo.image_format
      aps=STRCOMPRESS(finfo.azimuth_pixel_spacing,/REMOVE_ALL)
      rps=STRCOMPRESS(finfo.range_pixel_spacing,/REMOVE_ALL)
      inc=STRCOMPRESS(finfo.incidence_angle,/REMOVE_ALL)
      temp=TLI_MLFACTOR(parfile=parfile)
      mlr=STRCOMPRESS(temp[0],/REMOVE_ALL)
      mlazi=STRCOMPRESS(temp[1],/REMOVE_ALL)
      rps_grd=STRCOMPRESS(finfo.range_pixel_spacing/SIN(DEGREE2RADIANS(finfo.incidence_angle)))
      rps_grd_lab='Multi-look factors calculated using RPS and APS.'+STRING(10b)+$
        'The corresponding ground range pixel spacing is '+rps_grd
;      rps_grd_lab='Multi-look factors calculated using RPS and APS.'+STRING(13b)+$
;        'The corresponding ground range pixel spacing is '+rps_grd
          
      outputfile=workpath+TLI_FNAME(inputfile, /nosuffix)+'.pwr'
    ENDIF
  ENDIF
  config.workpath=workpath
  
  
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='Multi Look',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  inID=widget_base(tlb,/row,xsize=xsize,frame=1)
  input=widget_text(inID,value=inputfile,uvalue=inputfile,uname='input',/editable,xsize=73)
  openinput=widget_button(inID,value='Input SLC',uname='openinput',xsize=90)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information extracted from par file
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value=parlab,/align_left,/dynamic_resize)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  sampID=widget_base(tempID, /column, xsize=xsize/3-10)
  samplabel=widget_label(sampID, value='Samples:',/ALIGN_LEFT)
  samples=widget_text(sampID,value=samples, uvalue=samples, uname='samples',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  lineID=widget_base(tempID,/column, xsize=xsize/3-10)
  linelabel=widget_label(lineID, value='Lines:',/ALIGN_LEFT)
  lines=widget_text(lineID, value=lines,uvalue=lines, uname='lines',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  fmID=widget_base(tempID,/column, xsize=xsize/3-10)
  fmlabel=widget_label(fmID,value='Format:',/ALIGN_LEFT)
  format=widget_text(fmID, value=format, uvalue=format,/editable,xsize=10)
  
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  rpsID=widget_base(tempID, /column, xsize=xsize/3-10)
  rpslabel=widget_label(rpsID, value='Range Pixel Spacing:',/ALIGN_LEFT)
  rps=widget_text(rpsID,value=rps, uvalue=rps, uname='rps',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  apsID=widget_base(tempID, /column, xsize=xsize/3-10)
  apslabel=widget_label(apsID, value='Azimuth Pixel Spacing:',/ALIGN_LEFT)
  aps=widget_text(apsID,value=aps, uvalue=aps, uname='aps',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  incID=widget_base(tempID,/column, xsize=xsize/3-10)
  inclabel=widget_label(incID, value='Incidence Angle:',/ALIGN_LEFT)
  inc=widget_text(incID, value=inc,uvalue=inc, uname='inc',/editable,xsize=10)
  
  ;--------------------------------------------------------------
  ; Multi look factors.
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value=rps_grd_lab,/align_left,/dynamic_resize)
  
  tempID=widget_base(mlID,/row,xsize=xsize)
  
  mlrID=widget_base(tempID, /row, xsize=xsize/2-20, frame=1)
  mlrlabel=widget_label(mlrID, value='Range ML:',/ALIGN_LEFT)
  mlr=widget_text(mlrID,value=mlr, uvalue=mlr, uname='mlr',/editable,xsize=20)
  
  mlaziID=widget_base(tempID, /row, xsize=xsize/2-20, frame=1)
  mlazilabel=widget_label(mlaziID, value='Azimuth ML:',/ALIGN_LEFT)
  mlazi=widget_text(mlaziID,value=mlazi, uvalue=mlazi, uname='mlazi',/editable,xsize=20)
  
  outID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outID,value=outputfile,uvalue=outputfile,uname='output',/editable,xsize=73)
  openoutput=widget_button(outID,value='Output pwr',uname='openoutput',xsize=90)
  
  ; non exclusive box
  temp=widget_base(outID,tab_mode=1,/column,/nonexclusive)
  show=widget_button(temp, value='show', uvalue='show')
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={input:input,$
    openinput:openinput,$
    parlabel:parlabel,$
    samples:samples,$
    lines:lines,$
    format: format,$
    rps:rps,$
    aps:aps,$
    inc:inc, $
    mlr:mlr,$
    mlazi:mlazi,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl $
    }
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_ML',tlb,/no_block
  
END
