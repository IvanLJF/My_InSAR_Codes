;
; par_tx_slc
;
PRO TLI_SMC_IMPORT_ERS_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  WIDGET_CONTROL,event.top,get_uvalue=pstate
  workpath=config.workpath
  
  uname=WIDGET_INFO(event.id,/uname)
  Case STRLOWCASE(uname) OF
    'openers':BEGIN
    erspath=dialog_pickfile(title='Sasmac InSAR',/read,filter='SCENE1',/must_exist,path=workpath,/directory)
    IF erspath EQ '' THEN return
    ;------------------------------------------------------
    ; Get some useful information from ers folder name.
    datafile=FILE_SEARCH(erspath,'DAT_01.001', count=count)
    IF count NE 1 THEN BEGIN
      TLI_SMC_DUMMY, inputstr='Error! Please select folding containing only ONE DAT_01.001 file.',/err
      RETURN
    ENDIF
    
    workpath=FILE_DIRNAME(datafile)+PATH_SEP()
    config.workpath=workpath
    
    leaderfile=workpath+'LEA_01.001'
    IF NOT FILE_TEST(leaderfile) THEN TLI_SMC_DUMMY,inputstr=['Error! Header file not found:', leaderfile]
    
    temp=FILE_BASENAME(FILE_DIRNAME(workpath))
    
    date=TLI_ERS_DATE(temp, mission=miss)
    slcfile=workpath+date+'.slc'
    
    TLI_SMC_DEFINITIONS_UPDATE, inputfile=slcfile
    
    IF STRLOWCASE(miss) EQ 'e1' THEN BEGIN
      orbit='/mnt/data_tli/Data/orbits/ODR/ODR.ERS-1/dgm-e04'
    ENDIF ELSE BEGIN
      orbit='/mnt/data_tli/Data/orbits/ODR/ODR.ERS-2/dgm-e04'
    ENDELSE
    
    ersinfo=$
      'Mission      : '+miss+STRING(10b)+$
      'Data File    : '+datafile+STRING(10b)+$
      'Header File  : '+leaderfile+STRING(10b)+$
      'Date         : '+date
    ersinfo=ersinfo[0]
    ; Update widget info.
    ersfiles=[datafile, leaderfile]
    widget_control, (*pstate).erstxt, set_value=erspath, set_uvalue=ersfiles
    widget_control, (*pstate).orbittxt, set_value=orbit, set_uvalue=orbit
    widget_control, (*pstate).labinfo, set_value=ersinfo
    widget_control, (*pstate).output, set_value=slcfile, set_uvalue=slcfile
  END
  'openorbit':begin
  orbit=dialog_pickfile(title='Sasmac InSAR',/read,filter='dgm-e04',/must_exist,path=workpath,/directory)
  IF orbit EQ '' THEN return
  widget_control, (*pstate).orbittxt, set_value=orbit, set_uvalue=orbit
END
'openoutput':begin

slcfile=config.inputfile

outputfile=dialog_pickfile(title='Sasmac InSAR',/write,filter='*.slc', file=slcfile)
IF outputfile EQ '' THEN return
widget_control, (*pstate).output, set_value=outputfile, set_uvalue=outputfile

end

'ok':begin



widget_control,(*pstate).erstxt,get_uvalue=ersfiles
widget_control, (*pstate).orbittxt, get_value=orbitpath
widget_control, (*pstate).output, get_value=outputfile
if NOT FILE_TEST(ersfiles[0]) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select ERS folder and Orbit folder.'
  RETURN
endif

if outputfile EQ '' then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select output file.'
  RETURN
endif

datafile=ersfiles[0]
leaderfile=ersfiles[1]
scr1='par_ESA_ERS '+leaderfile+' '+outputfile+'.par '+datafile+' '+outputfile
IF FILE_TEST(orbitpath,/directory) THEN BEGIN ; Using precise orbit
  scr2='DELFT_vec2 '+outputfile+'.par'+orbitpath
  scr=[scr1, scr2]
ENDIF ELSE BEGIN
  scr=scr1
ENDELSE

TLI_SMC_SPAWN, scr,info='Importing ERS data, Please wait...'

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

PRO TLI_SMC_IMPORT_ERS

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
  datfile='Unknown'
  leafile='Unknown'
  date='Unknown'
  
  ersinfo=$
    'Mission      : '+mission+STRING(10b)+$
    'Data File    : '+datfile+STRING(10b)+$
    'Header File  : '+leafile+STRING(10b)+$
    'Date         : '+date
    
  ; Get config info
  workpath='/mnt/data_tli/Data/Liuyi/ERS_ShangHai/E1_96_Mar25'+PATH_SEP()
  config.workpath=workpath
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='Import ERS Data',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  erstxt=widget_text(temp,value='',uvalue='',uname='erstxt',/editable,xsize=73)
  openers=widget_button(temp,value='ERS',uname='openers',xsize=90)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  orbittxt=widget_text(temp,value='',uvalue='',uname='orbittxt',/editable,xsize=73)
  openorbit=widget_button(temp,value='Orbit',uname='openorbit',xsize=90)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Some useful information.
  labID=widget_base(tlb, /column,xsize=xsize)
  labinfo=WIDGET_LABEL(labID, value=ersinfo, uvalue='labinfo',xsize=xsize-10,/align_left)
  ;--------------------------------------------------------------
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  
  outID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outID,value=outputfile,uvalue=outputfile,uname='output',/editable,xsize=73)
  openoutput=widget_button(outID,value='Output SLC',uname='openoutput',xsize=90)
  
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='OK',xsize=90,uname='ok')
  cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
  
  state={erstxt:erstxt,$
    openers:openers,$
    orbittxt:orbittxt,$
    openorbit:openorbit,$
    labinfo:labinfo,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl $
    }
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_IMPORT_ERS',tlb,/no_block
  
END