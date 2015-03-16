PRO CWN_SMC_GCMAP_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo

  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openmli':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.pwr', path=config.workpath)
    IF NOT FILE_TEST(infile) THEN return

    ; Update definitions
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile

    ; Update widget info.
    workpath=config.workpath
    inputfile=config.inputfile
    mparfile=inputfile+'.par'
    finfo=TLI_LOAD_SLC_PAR(mparfile)
    width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
    
    widget_control,(*pstate).mli,set_value=infile
    widget_control,(*pstate).mli,set_uvalue=infile
    
    widget_control,(*pstate).mlipar,set_value=mparfile
    widget_control,(*pstate).mlipar,set_uvalue=mparfile

  END
  'openoff':begin
  infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=config.workpath)
  IF NOT FILE_TEST(infile) THEN return

  ; Update definitions
  TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile

  ; Update widget info.
  workpath=config.workpath
  inputfile=config.inputfile
  widget_control,(*pstate).off,set_value=infile
  widget_control,(*pstate).off,set_uvalue=infile

END

'opendem':begin
  infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.dem', path=config.workpath)
  IF NOT FILE_TEST(infile) THEN return

  ; Update definitions
;  TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile

  inputfile=config.inputfile
  dempar=infile+'.par'
  
  widget_control,(*pstate).dem,set_value=infile
  widget_control,(*pstate).dem,set_uvalue=infile
  
  widget_control,(*pstate).dempar,set_value=dempar 
  widget_control,(*pstate).dempar,set_uvalue=dempar
  
  widget_control,(*pstate).mli,get_value=mli
  widget_control,(*pstate).mlipar,get_value=mlipar
  widget_control,(*pstate).off,get_uvalue=off
  widget_control,(*pstate).dem,get_value=dem
  widget_control,(*pstate).dempar,get_value=dempar  

  if mli eq '' then begin
    result=dialog_message(['Please select the mli file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if mlipar eq '' then begin
    result=dialog_message(['can not find the mlipar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if off eq '' then begin
    result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dem eq '' then begin
    result=dialog_message(['Please select the dem file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dempar eq '' then begin
    result=dialog_message(['can not find the dempar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif

  outdem=workpath+'dem_seg'
  outdempar=outdem+'.par'
  outlkup=workpath+'lookup'
  outsimsar=workpath+'sim_sar'
  widget_control,(*pstate).outdem,set_value=outdem
  widget_control,(*pstate).outdem,set_uvalue=outdem
  widget_control,(*pstate).outdempar,set_value=outdempar
  widget_control,(*pstate).outdempar,set_uvalue=outdempar
  widget_control,(*pstate).outlkup,set_value=outlkup
  widget_control,(*pstate).outlkup,set_uvalue=outlkup
  widget_control,(*pstate).outsimsar,set_value=outsimsar
  widget_control,(*pstate).outsimsar,set_uvalue=outsimsar

END

'openoutdem':begin
;-Check if input master parfile
  widget_control,(*pstate).mli,get_value=mli
  widget_control,(*pstate).mlipar,get_value=mlipar
  widget_control,(*pstate).off,get_uvalue=off
  widget_control,(*pstate).dem,get_value=dem
  widget_control,(*pstate).dempar,get_value=dempar  

  if mli eq '' then begin
    result=dialog_message(['Please select the mli file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if mlipar eq '' then begin
    result=dialog_message(['can not find the mlipar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if off eq '' then begin
    result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dem eq '' then begin
    result=dialog_message(['Please select the dem file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dempar eq '' then begin
    result=dialog_message(['can not find the dempar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif

  workpath=config.workpath
  dem='dem_seg'
  outputfile=dialog_pickfile(title='',/write,file=dem,path=workpath,filter='dem_seg',/overwrite_prompt)
  dempar='dem_seg.par'
  outputparfile=dialog_pickfile(title='',/write,file=dempar,path=workpath,filter='*.par',/overwrite_prompt)
  widget_control,(*pstate).outdem,set_value=outputfile
  widget_control,(*pstate).outdem,set_uvalue=outputfile
  widget_control,(*pstate).outdempar,set_value=outputparfile
  widget_control,(*pstate).outdempar,set_uvalue=outputparfile
END

'openoutdem':begin
;-Check if input master parfile
  widget_control,(*pstate).mli,get_value=mli
  widget_control,(*pstate).mlipar,get_value=mlipar
  widget_control,(*pstate).off,get_uvalue=off
  widget_control,(*pstate).dem,get_value=dem
  widget_control,(*pstate).dempar,get_value=dempar  

  if mli eq '' then begin
    result=dialog_message(['Please select the mli file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if mlipar eq '' then begin
    result=dialog_message(['can not find the mlipar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if off eq '' then begin
    result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dem eq '' then begin
    result=dialog_message(['Please select the dem file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dempar eq '' then begin
    result=dialog_message(['can not find the dempar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif

  workpath=config.workpath
  file='dem_seg.par'
  outputfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.par',/overwrite_prompt)
  widget_control,(*pstate).outdempar,set_value=outputfile
  widget_control,(*pstate).outdempar,set_uvalue=outputfile
END

'openoutlkup':begin
;-Check if input master parfile
  widget_control,(*pstate).mli,get_value=mli
  widget_control,(*pstate).mlipar,get_value=mlipar
  widget_control,(*pstate).off,get_uvalue=off
  widget_control,(*pstate).dem,get_value=dem
  widget_control,(*pstate).dempar,get_value=dempar  

  if mli eq '' then begin
    result=dialog_message(['Please select the mli file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if mlipar eq '' then begin
    result=dialog_message(['can not find the mlipar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if off eq '' then begin
    result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dem eq '' then begin
    result=dialog_message(['Please select the dem file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dempar eq '' then begin
    result=dialog_message(['can not find the dempar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif

  workpath=config.workpath
  file='lookup'
  outputfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='lookup',/overwrite_prompt)
  widget_control,(*pstate).outlkup,set_value=outputfile
  widget_control,(*pstate).outlkup,set_uvalue=outputfile
END

'openoutsimsar':begin
;-Check if input master parfile
  widget_control,(*pstate).mli,get_value=mli
  widget_control,(*pstate).mlipar,get_value=mlipar
  widget_control,(*pstate).off,get_uvalue=off
  widget_control,(*pstate).dem,get_value=dem
  widget_control,(*pstate).dempar,get_value=dempar  

  if mli eq '' then begin
    result=dialog_message(['Please select the mli file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if mlipar eq '' then begin
    result=dialog_message(['can not find the mlipar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if off eq '' then begin
    result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dem eq '' then begin
    result=dialog_message(['Please select the dem file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dempar eq '' then begin
    result=dialog_message(['can not find the dempar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif

  workpath=config.workpath
  file='sim_sar'
  outputfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='sim_sar',/overwrite_prompt)
  widget_control,(*pstate).outsimsar,set_value=outputfile
  widget_control,(*pstate).outsimsar,set_uvalue=outputfile
END


'ok': begin
  widget_control,(*pstate).mli,get_value=mli
  widget_control,(*pstate).mlipar,get_value=mlipar
  widget_control,(*pstate).off,get_uvalue=off
  widget_control,(*pstate).dem,get_value=dem
  widget_control,(*pstate).dempar,get_value=dempar
  
  widget_control,(*pstate).outdem,get_value=outdem
  widget_control,(*pstate).outdempar,get_value=outdempar
  widget_control,(*pstate).outlkup,get_uvalue=outlkup
  widget_control,(*pstate).outsimsar,get_value=outsimsar

  widget_control,(*pstate).latovr,get_value=latovr
  widget_control,(*pstate).lonovr,get_value=lonovr
  widget_control,(*pstate).frame,get_value=frame
  widget_control,(*pstate).rovr,get_value=rovr
  
  lsmod=WIDGET_INFO((*pstate).lsmod,/droplist_select)
  Case lsmode OF
    0: lsmode='1'
    1: lsmode='0'
    2: lsmode='2'
    3: lsmode='3'
  ELSE: Message, 'ls_mode for gc_map is not supported:'+STRCOMPRESS(lsmode)
  ENDCASE

  if mli eq '' then begin
    result=dialog_message(['Please select the mli file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if mlipar eq '' then begin
    result=dialog_message(['Can not find the mli par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if off eq '' then begin
    result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dem eq '' then begin
    result=dialog_message(['Please select the DEM file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if dempar eq '' then begin
    result=dialog_message(['Can not find the dem par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  
  if outdem eq '' then begin
    result=dialog_message(['Please specify  the output dem file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if outdempar eq '' then begin
    result=dialog_message(['Please specify  the output dem par file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if outlkup eq '' then begin
    result=dialog_message(['Please specify  the output lookup file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if outsimsar eq '' then begin
    result=dialog_message(['Please specify  the output simulate sar image file.'],title='Sasmac InSAR',/information,/center)
    return
  endif

    

  if latovr ne '-' then begin
    if latovr lt 0 then begin
      result=dialog_message(['latitude  oversampling factor should be greater than 0:',$
        STRCOMPRESS(latovr)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if lonovr ne '-' then begin
    if lonovr lt 0 then begin
      result=dialog_message(['longitude  oversampling factor  should be greater than 0:',$
        STRCOMPRESS(lonovr)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif
  if frame ne '-' then begin
    if frame lt 0 then begin
      result=dialog_message(['DEM pixels to add around area covered by SAR image should be greater than 0:',$
        STRCOMPRESS(frame)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif

  if rovr ne '-' then begin
    if rovr lt 0 then begin
      result=dialog_message(['range over-sampling factor for nn-thinned layover/shadow mode should be greater than 0:',$
        STRCOMPRESS(rovr)],title='Sasmac InSAR',/information,/center)
      return
    endif
  endif

  scr="gc_map " +mlipar +' '+off +' '+dempar+' '+dem+' '+outdempar+' '+outdem+' '+outlkup+' '+latovr+' '+lonovr+' '+outsimsar+' - - - - - - '+frame+' '+lsmod+' '+rovr
  TLI_SMC_SPAWN, scr,info='Calculate lookup table and DEM related products for terrain-corrected geocoding, Please wait...'

  ;stop
end

'cl':begin
;result=dialog_message('Sure exit?',title='Exit',/question,/default_no,/center)
;if result eq 'Yes'then begin
  widget_control,event.top,/destroy
;endif
end
else: begin
  return
end
endcase
END


PRO CWN_SMC_GCMAP
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo

  ; --------------------------------------------------------------------
  ; Assignment

  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=565
  ysize=700

  ; Get config info
    mli=''
    off=''
    dem=''
    mlipar=''
    dempar=''
    
    latovr='1.0'
    lonovr='1.0'
    frame='8.0'
    lsmod='1'
    rovr='2.0'
    
    outdem=''
    outdempar=''
    outlkup=''
    outsimsar=''




  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='gc_map',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)

  mliID=widget_base(tlb,/row,xsize=xsize,frame=1)
  mli=widget_text(mliID,value=mli,uvalue=mli,uname='mli',/editable,xsize=73)
  openmli=widget_button(mliID,value='Input Mli',uname='openmli',xsize=100)
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=73)
  openoff=widget_button(offID,value='Input OFF_par',uname='openoff',xsize=100)

  demID=widget_base(tlb,/row,xsize=xsize,frame=1)
  dem=widget_text(demID,value=dem,uvalue=dem,uname='dem',/editable,xsize=73)
  opendem=widget_button(demID,value='Input DEM',uname='opendem',xsize=100)


  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)

  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize)

  mliparID=widget_base(labID,/row,xsize=xsize,frame=1)
  mlipar=widget_text(mliparID,value=mlipar,uvalue=mlipar,uname='mlipar',/editable,xsize=90)
  
  demparID=widget_base(labID,/row, xsize=xsize,frame=1)
  dempar=widget_text(demparID,value=dempar,uvalue=dempar,uname='dempar',/editable,xsize=90) 
  
  ;-----------------------------------------------------------------------------------------
  ; input parameters
  infoID=widget_base(labID,/row, xsize=xsize)

  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  latovrID=widget_base(tempID,/column, xsize=xsize/4-10)
  latovrlabel=widget_label(latovrID, value='Latitude Oversample:',/ALIGN_LEFT)
  latovr=widget_text(latovrID, value=latovr,uvalue=latovr, uname='latovr',/editable,xsize=10)

  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  lonovrID=widget_base(tempID,/column, xsize=xsize/4-10)
  lonovrlabel=widget_label(lonovrID, value='Longitude Oversample:',/ALIGN_LEFT)
  lonovr=widget_text(lonovrID, value=lonovr,uvalue=lonovr, uname='lonovr',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  frameID=widget_base(tempID,/column, xsize=xsize/4-10)
  framelabel=widget_label(frameID, value='Number of DEM pixels:',/ALIGN_LEFT)
  frame=widget_text(frameID, value=frame,uvalue=frame, uname='frame',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-17, frame=1)
  rovrID=widget_base(tempID,/column, xsize=xsize/4-10)
  rovrlabel=widget_label(rovrID, value='Range Oversample:',/ALIGN_LEFT)
  rovr=widget_text(rovrID, value=rovr,uvalue=rovr, uname='rovr',/editable,xsize=10)
  ;-----------------------------------------------------------------------------------------
  ; input parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize-15, frame=1)
  lsmodID=widget_base(tempID,/column, xsize=xsize-20)
  lsmodlabel=widget_label(lsmodID, value='output lookup table values in regions of layover, shadow, or DEM gaps:',/ALIGN_LEFT)
  lsmod=widget_droplist(lsmodID, value=['linear interpolation across these regions',$
                                        'set to (0.,0.)',$
                                        'actual value',$
                                        'nn-thinned'],xoffset=xsize-100)

  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)

  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Forward geocoding transformation using a lookup table:',/align_left,/dynamic_resize)

  
  outdemID=widget_base(tlb,row=1, frame=1)
  outdem=widget_text(outdemID,value=outdem,uvalue=outdem,uname='outdem',/editable,xsize=73)
  openoutdem=widget_button(outdemID,value='Output DEM',uname='openoutdem',xsize=100)
  
  outdemparID=widget_base(tlb,row=1, frame=1)
  outdempar=widget_text(outdemparID,value=outdempar,uvalue=outdempar,uname='outdempar',/editable,xsize=73)
  openoutdempar=widget_button(outdemparID,value='Output DEM_par',uname='openoutdempar',xsize=100)
  
  outlkupID=widget_base(tlb,row=1, frame=1)
  outlkup=widget_text(outlkupID,value=outlkup,uvalue=outlkup,uname='outlkup',/editable,xsize=73)
  openoutlkup=widget_button(outlkupID,value='Output Lookup',uname='openoutlkup',xsize=100)
  
  outsimsarID=widget_base(tlb,row=1, frame=1)
  outsimsar=widget_text(outsimsarID,value=outsimsar,uvalue=outsimsar,uname='outsimsar',/editable,xsize=73)
  openoutsimsar=widget_button(outsimsarID,value='Output sim_sar',uname='openoutsimsar',xsize=100)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30)

  ;Recognize components
  state={mli:mli,$
    openmli:openmli,$
    off:off,$
    openoff:openoff,$
    dem:dem,$
    opendem:opendem,$
    mlipar:mlipar,$
    dempar:dempar,$
    
    latovr:latovr,$
    lonovr:lonovr,$
    frame:frame,$
    lsmod:lsmod,$
    rovr:rovr,$
;    zenith:zenith,$
;    orient:orient,$
;    incide:incide,$
;    proj:proj,$
;    normal:normal,$
;    lsmap:lsmap,$
    
    outdem:outdem,$
    openoutdem:openoutdem,$
    outdempar:outdempar,$
    openoutdempar:openoutdempar,$
    outlkup:outlkup,$
    openoutlkup:openoutlkup,$
    outsimsar:outsimsar,$
    openoutsimsar:openoutsimsar,$

    ok:ok,$
    cl:cl $
  }

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_GCMAP',tlb,/no_block
END