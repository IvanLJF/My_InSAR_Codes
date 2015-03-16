;
; par_tx_slc
;
PRO TLI_SMC_IMPORT_PLS_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  WIDGET_CONTROL,event.top,get_uvalue=pstate
  workpath=config.workpath
  
  uname=WIDGET_INFO(event.id,/uname)
  Case STRLOWCASE(uname) OF
    'openpls':BEGIN
    rawfile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.raw',/must_exist,path=workpath)
    IF rawfile EQ '' THEN return
    ;------------------------------------------------------
    ; Get some useful information from pls file name.
    
    workpath=FILE_DIRNAME(rawfile)+PATH_SEP()
    config.workpath=workpath
    
    file_base=FILE_BASENAME(rawfile, '.raw')
    
    date='20'+STRMID(file_base, 7, 6)
    date=date[0]
    
    slcfile=workpath+date+'.slc'
    
    TLI_SMC_DEFINITIONS_UPDATE, inputfile=slcfile
    
    ; Information
    mission='PALSAR'
    datfile=rawfile
    antfile=(FILE_SEARCH(TLI_GAMMA_PATH(),'palsar_ant_20061024.dat'))[0]
    IF NOT FILE_TEST(antfile) THEN TLI_SMC_DUMMY, inputstr=['ERROR! Palsar antenna file not found:', antfile],/error
    date=date
    
    plsinfo=$
      'Mission      : '+mission+STRING(10b)+$
      'Raw Data     : '+datfile+STRING(10b)+$
      'Antenna File : '+antfile+STRING(10b)+$
      'Date         : '+date
    
    ; Update widget info.
    widget_control, (*pstate).plstxt, set_value=rawfile, set_uvalue=rawfile
    widget_control, (*pstate).anttxt, set_value=antfile, set_uvalue=antfile
    widget_control, (*pstate).labinfo, set_value=plsinfo
    widget_control, (*pstate).output, set_value=slcfile, set_uvalue=slcfile
  END
  'openant':begin
  orbit=dialog_pickfile(title='Sasmac InSAR',/read,filter='palsar_ant_20061024.dat',/must_exist,path=TLI_GAMMA_PATH())
  IF orbit EQ '' THEN return
  widget_control, (*pstate).anttxt, set_value=ant, set_uvalue=ant
END
'openoutput':begin

slcfile=config.inputfile

outputfile=dialog_pickfile(title='Sasmac InSAR',/write,filter='*.slc', file=slcfile)
TLI_SMC_DEFINITIONS_UPDATE,inputfile=outputfile 
IF outputfile EQ '' THEN return
widget_control, (*pstate).output, set_value=outputfile, set_uvalue=outputfile

end

'ok':begin



widget_control,(*pstate).plstxt,get_uvalue=plsfile
widget_control, (*pstate).anttxt, get_value=antfile
widget_control, (*pstate).output, get_value=outputfile
if NOT FILE_TEST(plsfile) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select PALSAR raw data.'
  RETURN
endif

if NOT FILE_TEST(antfile) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select PALSAR antenna data.'
  RETURN
endif

scr='tli_par_PALSAR '+plsfile+' '+outputfile+' '+antfile
CD, FILE_DIRNAME(outputfile), current=curr
TLI_SMC_SPAWN, scr,info='Importing PALSAR data, Please wait...'
CD, curr
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

PRO TLI_SMC_IMPORT_PLS

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
  mission='PALSAR'
  datfile='Unknown'
  antfile=(FILE_SEARCH(TLI_GAMMA_PATH(),'palsar_ant_20061024.dat'))[0]
  IF NOT FILE_TEST(antfile) THEN TLI_SMC_DUMMY, inputstr=['ERROR! Palsar antenna file not found:', antfile],/error
  date='Unknown'
  
  plsinfo=$
    'Mission      : '+mission+STRING(10b)+$
    'Raw Data     : '+datfile+STRING(10b)+$
    'Antenna File : '+antfile+STRING(10b)+$
    'Date         : '+date
    
  ; Get config info
  workpath='/mnt/data_tli/Data/Original_data/Palsar-447-77-test/PASL10C0810221436590911260088'+PATH_SEP()
  config.workpath=workpath
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='Import PALSAR Data',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  plstxt=widget_text(temp,value='',uvalue='',uname='plstxt',/editable,xsize=73)
  openpls=widget_button(temp,value='PALSAR',uname='openpls',xsize=90)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  anttxt=widget_text(temp,value='',uvalue='',uname='anttxt',/editable,xsize=73)
  openant=widget_button(temp,value='Antenna',uname='openant',xsize=90)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Some useful information.
  labID=widget_base(tlb, /column,xsize=xsize)
  labinfo=WIDGET_LABEL(labID, value=plsinfo, uvalue='labinfo',xsize=xsize-10,/align_left)
  ;--------------------------------------------------------------
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  outID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outID,value=outputfile,uvalue=outputfile,uname='output',/editable,xsize=73)
  openoutput=widget_button(outID,value='Output SLC',uname='openoutput',xsize=90)
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={plstxt:plstxt,$
    openpls:openpls,$
    anttxt:anttxt,$
    openant:openant,$
    labinfo:labinfo,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl $
    }
    
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_IMPORT_PLS',tlb,/no_block
  
END