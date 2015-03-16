;
; par_tx_slc
;
PRO TLI_SMC_IMPORT_TSX_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  WIDGET_CONTROL,event.top,get_uvalue=pstate
  workpath=config.workpath
  
  uname=WIDGET_INFO(event.id,/uname)
  Case STRLOWCASE(uname) OF
    'opencos':BEGIN
    cosfile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.cos',/must_exist,path=workpath)
    IF NOT FILE_TEST(cosfile) THEN return
    
    ;------------------------------------------------------
    ; Get some useful information from cos filename
    cospath=FILE_DIRNAME(FILE_DIRNAME(cosfile))+PATH_SEP()
    folder=FILE_BASENAME(cospath)+PATH_SEP()
    
    xmlfile=FILE_SEARCH(cospath+'*.xml', count=count)
    IF count EQ 1 THEN BEGIN
      xmlinfo=TLI_TSX_INFO(xmlfile)
      sensor=xmlinfo.sensor
      start_utc=xmlinfo.start_time
      end_utc=xmlinfo.end_time
      pol=xmlinfo.pol
      mode=xmlinfo.mode
      type=xmlinfo.class
      mission=xmlinfo.mission
      
      cosinfo=$
        'Mission     :'+mission+STRING(10b)+$
        'Sensor      :'+sensor+STRING(10b)+$
        'Start UTC   :'+start_utc+'    End UTC:'+end_utc+STRING(10b)+$
        'Polarization:'+pol+STRING(10b)+$
        'Mode        :'+mode+STRING(10b)+$
        'Data Type   :'+type
        
      ; Update widget info.
      date=xmlinfo.start_time
      date=(STRMID(date, 0,8))[0]
      slcfile=workpath+date+'.slc'
      
      widget_control, (*pstate).output, set_value=slcfile, set_uvalue=slcfile
      widget_control, (*pstate).xmltxt, set_value=xmlfile, set_uvalue=xmlfile
      widget_control, (*pstate).labinfo, set_value=cosinfo
    ENDIF
    widget_control, (*pstate).costxt, set_value=cosfile, set_uvalue=cosfile
  END
  'openxml':begin
  xmlfile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.xml',/must_exist,path=workpath)
  IF NOT FILE_TEST(xmlfile) THEN return
  
  xmlinfo=TLI_TSX_INFO(xmlfile)
  sensor=xmlinfo.sensor
  start_utc=xmlinfo.start_time
  end_utc=xmlinfo.end_time
  pol=xmlinfo.pol
  mode=xmlinfo.mode
  type=xmlinfo.class
  mission=xmlinfo.mission
  
  cosinfo=$ 
    'Mission     :'+mission+STRING(10b)+$
    'Sensor      :'+sensor+STRING(10b)+$
    'Start UTC   :'+start_utc+'    End UTC:'+end_utc+STRING(10b)+$
    'Polarization:'+pol+STRING(10b)+$
    'Mode        :'+mode+STRING(10b)+$
    'Data Type   :'+type
    
  ; Update widget info.
    
  widget_control, (*pstate).xmltxt, set_value=xmlfile, set_uvalue=xmlfile
  widget_control, (*pstate).labinfo, set_value=cosinfo
END
'openoutput':begin
widget_control,(*pstate).xmltxt, get_uvalue=xmlfile
xmlinfo=TLI_TSX_INFO(xmlfile)
date=xmlinfo.start_time
date=(STRMID(date, 0,8))[0]
slcfile=workpath+date+'.slc'

outputfile=dialog_pickfile(title='Sasmac InSAR',/write,filter='*.slc', file=slcfile)
IF NOT FILE_TEST(outputfile) THEN return
; Update workpath
TLI_SMC_DEFINITIONS_UPDATE, inputfile=outputfile

widget_control, (*pstate).output, set_value=outputfile, set_uvalue=outputfile

end

'ok':begin

widget_control,(*pstate).costxt,get_value=cosfile
widget_control, (*pstate).xmltxt, get_value=xmlfile
widget_control, (*pstate).output, get_value=outputfile
if NOT FILE_TEST(cosfile) OR NOT FILE_TEST(xmlfile) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select cos file and xml file.'
  RETURN
endif

if outputfile EQ '' then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select output file.'
  RETURN
endif


scr='par_TX_SLC '+xmlfile+' '+cosfile+' '+outputfile+'.par'+' '+outputfile

TLI_SMC_SPAWN, scr,info='Importing TSX data, Please wait...'

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

PRO TLI_SMC_IMPORT_TSX

  COMPILE_OPT idl2
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size[0]/3
  yoffset=screen_size[1]/3
  xsize=560
  ysize=300
  
  ; Information
  mission='Unknown'
  pol='Unknown'
  mode='Unknown'
  date='Unknown'
  sensor='Unknown'
  start_utc='Unknown'
  end_utc='Unknown'
  type='Unknown'
  cosinfo=$
    'Mission     :'+mission+STRING(10b)+$
    'Sensor      :'+sensor+STRING(10b)+$
    'Start UTC   :'+start_utc+'    End UTC:'+end_utc+STRING(10b)+$
    'Polarization:'+pol+STRING(10b)+$
    'Mode        :'+mode+STRING(10b)+$
    'Data Type   :'+type
    
  ; Get config info
  workpath='/mnt/data_tli/Data/Original_data/TSX_Tianjin/dims_op_oc_dfd2_203830440_1/TSX-1.SAR.L1B/TSX1_SAR__SSC______SM_S_SRA_20090327T221736_20090327T221744/IMAGEDATA'+PATH_SEP()
  config.workpath=workpath
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='Import TerraSAR/TadDEM-X Data',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  costxt=widget_text(temp,value='',uvalue='',uname='costxt',/editable,xsize=73)
  opencos=widget_button(temp,value='COS',uname='opencos',xsize=90)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  xmltxt=widget_text(temp,value='',uvalue='',uname='xmltxt',/editable,xsize=73)
  openxml=widget_button(temp, value='XML', uname='openxml',xsize=90)
  
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Some useful information.
  labID=widget_base(tlb, /column,xsize=xsize)
  labinfo=WIDGET_LABEL(labID, value=cosinfo, uvalue='labinfo',xsize=xsize-10,/align_left)
  ;--------------------------------------------------------------
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  outID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outID,value=outputfile,uvalue=outputfile,uname='output',/editable,xsize=73)
  openoutput=widget_button(outID,value='Output SLC',uname='openoutput',xsize=90)
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={costxt:costxt,$
    opencos:opencos,$
    xmltxt:xmltxt,$
    openxml:openxml,$
    labinfo:labinfo,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl $
    }
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_IMPORT_TSX',tlb,/no_block
  
END