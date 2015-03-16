PRO CWN_SMC_OFFSETFITM_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openoffs':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.offs', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
  
    widget_control,(*pstate).offs,set_value=infile
    widget_control,(*pstate).offs,set_uvalue=infile

    
  END
  'opensnr':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.snr', path=workpath)
    IF NOT FILE_TEST(infile) THEN return

    widget_control,(*pstate).snr,set_value=infile
    widget_control,(*pstate).snr,set_uvalue=infile
   
  END
  'openoff':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.diff_par', path=workpath)
    IF NOT FILE_TEST(infile) THEN return

    widget_control,(*pstate).off,set_value=infile
    widget_control,(*pstate).off,set_uvalue=infile
    
    widget_control,(*pstate).offs,get_value=offs 
    widget_control,(*pstate).snr,get_value=snr
    widget_control,(*pstate).off,get_value=off
    if offs eq '' then begin
        result=dialog_message(['Please select the offsets estimates file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
    if snr eq '' then begin
        result=dialog_message(['Please select the SNR values file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
    if off eq '' then begin
        result=dialog_message(['Please select the ISP offset/interferogram parameter file.'],title='Sasmac InSAR',/information,/center)
        return
      endif 
    coffs=workpath+PATH_SEP()+'coffs'
    coffsets=workpath+PATH_SEP()+'coffsets'
    widget_control,(*pstate).coffs,set_value=coffs
    widget_control,(*pstate).coffs,set_uvalue=coffs
    widget_control,(*pstate).coffsets,set_value=coffsets
    widget_control,(*pstate).coffsets,set_uvalue=coffsets       
  end
   'opencoffs':begin
    ;-Check if input master parfile
    widget_control,(*pstate).offs,get_value=offs
    if offs eq '' then begin
      result=dialog_message(['Please select the offsets estimates file.'],title='Sasmac InSAR',/information,/center)
      return
    endif
    widget_control,(*pstate).snr,get_value=snr
    if snr eq '' then begin
      result=dialog_message(['Please select the SNR values file.'],title='Sasmac InSAR',/information,/center)
      return
    endif
    widget_control,(*pstate).off,get_value=off
    if off eq '' then begin
      result=dialog_message(['Please select the ISP offset/interferogram parameter file.'],title='Sasmac InSAR',/information,/center)
      return
    endif

      file='coffs'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='coffs',/overwrite_prompt)
    widget_control,(*pstate).coffs,set_value=outfile
    widget_control,(*pstate).coffs,set_uvalue=outfile   
  END
  'opencoffsets':begin
    ;-Check if input master parfile
    widget_control,(*pstate).offs,get_value=offs
    if offs eq '' then begin
      result=dialog_message(['Please select the offsets estimates file.'],title='Sasmac InSAR',/information,/center)
      return
    endif
    widget_control,(*pstate).snr,get_value=snr
    if snr eq '' then begin
      result=dialog_message(['Please select the SNR values file.'],title='Sasmac InSAR',/information,/center)
      return
    endif
    widget_control,(*pstate).off,get_value=off
    if off eq '' then begin
      result=dialog_message(['Please select the ISP offset/interferogram parameter file.'],title='Sasmac InSAR',/information,/center)
      return
    endif

      file='coffsets'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='coffsets',/overwrite_prompt)
    widget_control,(*pstate).coffsets,set_value=outfile
    widget_control,(*pstate).coffsets,set_uvalue=outfile   
  END

    'ok': begin
      widget_control,(*pstate).off,get_value=off
      widget_control,(*pstate).offs,get_value=offs
      widget_control,(*pstate).snr,get_value=snr
      widget_control,(*pstate).coffs,get_value=coffs
      widget_control,(*pstate).coffsets,get_value=coffsets
      
      widget_control,(*pstate).thres,get_value=thres
      widget_control,(*pstate).npoly,get_value=npoly
      widget_control,(*pstate).inter,get_value=inter
      
      inter=WIDGET_INFO((*pstate).inter,/droplist_select)
      inter=STRCOMPRESS(inter,/REMOVE_ALL)
      
      npoly=WIDGET_INFO((*pstate).npoly,/droplist_select)
      npoly_d=long(npoly)
      if npoly_d eq 0 then begin
        npoly=STRCOMPRESS(string(npoly_d+4),/REMOVE_ALL)
      endif
      if npoly_d eq 1 then begin
        npoly=STRCOMPRESS(string(npoly_d),/REMOVE_ALL)
      endif
      if npoly_d eq 2 then begin
        npoly=STRCOMPRESS(string(npoly_d+1),/REMOVE_ALL)
      endif
      if npoly_d eq 3 then begin
        npoly=STRCOMPRESS(string(npoly_d*2),/REMOVE_ALL)
      endif
  
      if offs eq '' then begin
        result=dialog_message(['Please select the offset estimates file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      if snr eq '' then begin
        result=dialog_message(['Please select the snr values file.'],title='Sasmac InSAR',/information,/center)
        return
      endif     
      if off eq '' then begin
        result=dialog_message(['Please select the offset par file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      if coffs eq '' then begin
        result=dialog_message('Please specify culled offset estimates file',title='Sasmac InSAR',/information,/center)
        return
      endif
      if coffsets eq '' then begin
        result=dialog_message('Please specify culled offset estimates and snr file',title='Sasmac InSAR',/information,/center)
        return
      endif
      
      if thres ne '-' then begin
        if thres le 0 then begin
          result=dialog_message(['SNR threshold should be greater than 0:',$
          STRCOMPRESS(thres)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif     
      coreg_quality=workpath+PATH_SEP()+'coreg_quality_DEM'
      
        scr="offset_fitm " +offs +' '+snr +' '+off+' '+coffs+' '+coffsets+' '+thres+' '+npoly+' '+inter+' >> '+coreg_quality
        TLI_SMC_SPAWN, scr,info='Range and azimuth offset polynomial estimation, Please wait...'
;stop
     end
     
    'cl':begin
;      result=dialog_message('Sure exit？',title='Exit',/question,/default_no,/center)
;      if result eq 'Yes'then begin
        widget_control,event.top,/destroy
;      endif
      end
      else: begin
        return
      end
   endcase
END


PRO CWN_SMC_OFFSETFITM
COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=500
  ysize=440
  
  ; Get config info
  offs=''
  snr=''
  off=''
  thres='-'
  npoly='4'
  inter='0'
  coffs=''
  coffsets=''

  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='offset_fitm',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  offsID=widget_base(tlb,row=1, frame=1)
  offs=widget_text(offsID,value=outputfile,uvalue=outputfile,uname='offs',/editable,xsize=62)
  openoffs=widget_button(offsID,value='Input Offs',uname='openoffs',xsize=100)
  
  snrID=widget_base(tlb,row=1, frame=1)
  snr=widget_text(snrID,value=outputfile,uvalue=outputfile,uname='snr',/editable,xsize=62)
  opensnr=widget_button(snrID,value='Input offsnr',uname='opensnr',xsize=100) 
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=inputfile,uvalue=inputfile,uname='off',/editable,xsize=62)
  openoff=widget_button(offID,value='Input Diff_par',uname='openoff',xsize=100)
    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize)   
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
   
  tempID=widget_base(infoID,/row,xsize=xsize/3-70, frame=1)
  thresID=widget_base(tempID,/column, xsize=xsize/3-75)
  threslabel=widget_label(thresID, value='SNR Threshold:',/ALIGN_LEFT)
  thres=widget_text(thresID, value=thres,uvalue=thres, uname='thres',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  npolyID=widget_base(tempID,/column, xsize=xsize/3+15)
  npolylabel=widget_label(npolyID, value='Polynomial parameters:',/ALIGN_LEFT)
  
  npoly=widget_droplist(npolyID, value=['4:(default)',$
                                        '1',$
                                        '3',$
                                        '6'])

  tempID=widget_base(infoID,/row,xsize=xsize/3+45, frame=1)
  interID=widget_base(tempID,/column, xsize=xsize/3+35)
  interlabel=widget_label(interID, value='interactive culling of input data:',/ALIGN_LEFT)
  
  inter=widget_droplist(interID, value=['off:(default)',$
                                        'on'])
  ;inter=widget_text(interID, value=inter,uvalue=inter, uname='inter',/editable,xsize=10) 
  
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Range and azimuth offset polynomial estimation:',/align_left,/dynamic_resize)
  
  coffsID=widget_base(tlb,row=1, frame=1)
  coffs=widget_text(coffsID,value=outputfile,uvalue=outputfile,uname='coffs',/editable,xsize=62)
  opencoffs=widget_button(coffsID,value='Output Coffs',uname='opencoffs',xsize=100)
  
  coffsetsID=widget_base(tlb,row=1, frame=1)
  coffsets=widget_text(coffsetsID,value=outputfile,uvalue=outputfile,uname='coffsets',/editable,xsize=62)
  opencoffsets=widget_button(coffsetsID,value='Output Coffsets',uname='opencoffsets',xsize=100)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30) 
  
  ;Recognize components
   state={offs:offs,$
    openoffs:openoffs,$
    snr:snr,$
    opensnr:opensnr,$
    off:off,$
    openoff:openoff,$
    thres:thres,$
    npoly:npoly,$
    inter:inter,$
    coffs:coffs,$
    opencoffs:opencoffs,$
    coffsets:coffsets,$
    opencoffsets:opencoffsets,$
    
    ok:ok,$
    cl:cl $
   }
    
  pstate=ptr_new(state,/no_copy) 
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_OFFSETFITM',tlb,/no_block
END