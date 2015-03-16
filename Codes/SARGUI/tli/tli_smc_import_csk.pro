;
; par_tx_slc
;
PRO TLI_SMC_IMPORT_CSK_EVENT, EVENT

  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  WIDGET_CONTROL,event.top,get_uvalue=pstate
  workpath=config.workpath
  
  uname=WIDGET_INFO(event.id,/uname)
  Case STRLOWCASE(uname) OF
    'opencos':BEGIN
    cosfile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.h5',/must_exist,path=workpath)
    IF NOT FILE_TEST(cosfile) THEN return
    
    ;------------------------------------------------------
    ; Get some useful information from filename
    cosinfo=TLI_CSK_INFO(cosfile)
    mission=cosinfo.mission
    prod=cosinfo.product
    mode=cosinfo.mode
    Case STRUPCASE(mode) OF
      'HI' : mode=mode+'(Himage)'
      'PP' : mode=mode+'(PingPong)'
      'WR' : mode=mode+'(WideRegion)'
      'HR' : mode=mode+'(HugeRegion)'
      'S2' : mode=mode+'(Spotlight 2)'
    Else :
  ENDCASE
  swath=cosinfo.swath
  pol=cosinfo.pol
  look_dir=cosinfo.look_dir
  Case STRUPCASE(look_dir) OF
    'L' : look_dir='LEFT'
    'R' : look_dir='RIGHT'
    ELSE:
  ENDCASE
  orb_dir=cosinfo.orb_dir
  Case STRUPCASE(orb_dir) OF
    'A' : orb_dir='Ascending'
    'D' : orb_dir='Descending'
    ELSE:
  ENDCASE
  delivery=cosinfo.delivery
  Case delivery OF
    'F' : delivery='Fast Delivery Mode'
    'S' : delivery='Standard Delivery Mode'
    ELSE:
  ENDCASE
  gps=cosinfo.gps
  Case gps OF
    'N' : gps='ON'
    'F' : gps='OFF'
    ELSE:
  ENDCASE
  start_utc=cosinfo.start_time
  end_utc=cosinfo.end_time
  
  cosinfo1=$
    'Mission       : '+mission+STRING(10b)+$
    'Product       : '+prod+STRING(10b)+$
    'Mode          : '+mode+STRING(10b)+$
    'Swath         : '+swath+STRING(10b)+$
    'Polarization  : '+pol
  cosinfo2=$
    'Look Direction: '+look_dir+STRING(10b)+$
    'Orb. Direction: '+orb_dir+STRING(10b)+$
    'Delivery      : '+delivery+STRING(10b)+$
    'GPS           : '+gps+STRING(10b)+$
    'Start UTC     : '+start_utc+STRING(10b)+$
    'End UTC       : '+end_utc
  date=STRMID(start_utc, 0, 8)
  
  slcfile=workpath+date+'.slc'
  TLI_SMC_DEFINITIONS_UPDATE, inputfile=slcfile
  widget_control, (*pstate).costxt, set_value=cosfile, set_uvalue=cosfile
  widget_control, (*pstate).output, set_value=slcfile, set_uvalue=slcfile
  
  widget_control, (*pstate).labinfo1, set_value=cosinfo1
  widget_control, (*pstate).labinfo2, set_value=cosinfo2
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
widget_control, (*pstate).output, get_value=outputfile
if NOT FILE_TEST(cosfile) then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select cos file and xml file.'
  RETURN
endif

if outputfile EQ '' then begin
  TLI_SMC_DUMMY, inputstr='ERROR! Please select output file.'
  RETURN
endif

date=TLI_FNAME(outputfile, /remove_all_suffix, all_suffix=all_suffix)

scr='par_CS_SLC '+cosfile+' '+date

TLI_SMC_SPAWN, scr,info='Importing Cosmo-SkyMed data, Please wait...'

temp=FILE_SEARCH(config.workpath+date+'*'+all_suffix+'*', count=count)
IF count EQ 0 THEN TLI_SMC_DUMMY, inputstr='Error! No results were genereated.'
For i=0, count-1 DO BEGIN
  temp_i=temp[i]
  temp_i=TLI_FNAME(temp_i, all_suffix=all_suffix)
  FILE_MOVE, temp_i, config.workpath+date+all_suffix,/allow_same
ENDFOR

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

PRO TLI_SMC_IMPORT_CSK

  COMPILE_OPT idl2
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size[0]/3
  yoffset=screen_size[1]/3
  xsize=560
  ysize=280
  
  ; Information
  
  mission='CSKS?'
  prod='Unknow'
  mode='Unknown'
  swath='Unknow'
  pol='Unknown'
  look_dir='Unknown'
  orb_dir='Unknown'
  delivery='Unknown'
  gps='ON/OFF'
  start_utc='Unknown'
  end_utc='Unknown'
  
  cosinfo1=$
    'Mission       : '+mission+STRING(10b)+$
    'Product       : '+prod+STRING(10b)+$
    'Mode          : '+mode+STRING(10b)+$
    'Swath         : '+swath+STRING(10b)+$
    'Polarization  : '+pol
  cosinfo2=$
    'Look Direction: '+look_dir+STRING(10b)+$
    'Orb. Direction: '+orb_dir+STRING(10b)+$
    'Dilivery      : '+delivery+STRING(10b)+$
    'GPS           : '+gps+STRING(10b)+$
    'Start UTC     : '+start_utc+STRING(10b)+$
    'End UTC       : '+end_utc
    
  ; Get config info
    
  workpath='/mnt/data_tli/ForExperiment/Tangjia_Cosmo/CSK'+PATH_SEP()
  config.workpath=workpath
  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='Import Cosmo-SkyMed Data',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
  
  temp=widget_base(tlb,/row,xsize=xsize,frame=1)
  costxt=widget_text(temp,value='',uvalue='',uname='costxt',/editable,xsize=73)
  opencos=widget_button(temp,value='Open',uname='opencos',xsize=90)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Some useful information.
  labID=widget_base(tlb, /row,xsize=xsize,/frame)
  labinfo1=WIDGET_LABEL(labID, value=cosinfo1,xsize=xsize/2,/align_left)
  labinfo2=WIDGET_LABEL(labID, value=cosinfo2,xsize=xsize/2,/align_left)
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
    labinfo1:labinfo1,$
    labinfo2:labinfo2,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl $
    }
  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'TLI_SMC_IMPORT_CSK',tlb,/no_block
  
END