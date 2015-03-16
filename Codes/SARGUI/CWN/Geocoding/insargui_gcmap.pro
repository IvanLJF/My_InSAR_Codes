;   gc_map,call the command of gc_map in the GAMMA software
;usage: gc_map <MLI_par> <OFF_par> <DEM_par> <DEM> <DEM_seg_par> <DEM_seg> <lookup_table> [lat_ovr] [lon_ovr] [sim_sar] [u] [v] [inc] [psi] [pix] [ls_map] [frame] [ls_mode] [r_ovr]
;
;input parameters:
;MLI_par         (input) ISP MLI or SLC image parameter file (slant range geometry)
;OFF_par         (input) ISP offset/interferogram parameter file (enter - if geocoding SLC or MLI data)
;DEM_par         (input) DEM/MAP parameter file
;DEM             (input) DEM data file (or constant height value)
;DEM_seg_par     (input/output) DEM/MAP segment parameter file used for output products
;
;NOTE: If the DEM_seg_par already exists, then the output DEM parameters will be read from this file
;otherwise they are estimated from the image data.
;
;DEM_seg         (output) DEM segment used for output products, interpolated if lat_ovr > 1.0  or lon_ovr > 1.0
;lookup_table    (output) geocoding lookup table (fcomplex)
;lat_ovr         latitude or northing output DEM oversampling factor (enter - for default: 1.0)
;lon_ovr         longitude or easting output DEM oversampling factor (enter - for default: 1.0)
;sim_sar         (output) simulated SAR backscatter image in DEM geometry
;u               (output) zenith angle of surface normal vector n (angle between z and n)
;v               (output) orientation angle of n (between x and projection of n in xy plane)
;inc             (output) local incidence angle (between surface normal and look vector)
;psi             (output) projection angle (between surface normal and image plane normal)
;pix             (output) pixel area normalization factor
;ls_map          (output) layover and shadow map (in map projection)
;frame           number of DEM pixels to add around area covered by SAR image (enter - for default = 8)
;ls_mode         output lookup table values in regions of layover, shadow, or DEM gaps (enter - for default)
;                   0: set to (0.,0.)
;                   1: linear interpolation across these regions (default)
;                   2: actual value
;                   3: nn-thinned
;r_ovr           range over-sampling factor for nn-thinned layover/shadow mode(enter - for default: 2.0)
;
;    -   Done written by CWN in Sasmac
;    -   30/12/2014

PRO INSARGUI_GCMAP_EVENT,EVENT
  widget_control,event.top,get_uvalue=pstate
  uname=widget_info(event.id,/uname)

  case uname of
  
    'mlipar_button':begin
      infile=dialog_pickfile(title='Please input mli parfile',filter='*.pwr.par',/read)
      if infile eq '' then return
        widget_control,(*pstate).mlipar_text,set_value=infile
        widget_control,(*pstate).mlipar_text,set_uvalue=infile
    end
    'offset_button':begin
      infile=dialog_pickfile(title='Please input offset parfile',filter='*.off',/read)
      if infile eq '' then return
        widget_control,(*pstate).offset_text,set_value=infile
        widget_control,(*pstate).offset_text,set_uvalue=infile
    end
    'dem_button':begin
      infile=dialog_pickfile(title='Please input DEM file',filter='*.dem',/read)
      if infile eq '' then return
        widget_control,(*pstate).dem_text,set_value=infile
        widget_control,(*pstate).dem_text,set_uvalue=infile
    end
    'dempar_button':begin
      infile=dialog_pickfile(title='Please input DEM parfile',filter='*.dem.par',/read)
      if infile eq '' then return
        widget_control,(*pstate).dempar_text,set_value=infile
        widget_control,(*pstate).dempar_text,set_uvalue=infile
    end
    
    ;output file
    'demseg_button':begin
      widget_control,(*pstate).mlipar_text,get_uvalue=mlipar
      if mlipar eq '' then begin
        result=dialog_message(title='mli parfile','please input mli parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      widget_control,(*pstate).dem_text,get_uvalue=dem
      if dem eq '' then begin
        result=dialog_message(title='dem file','please input dem file',/information)
        return
      endif      
      widget_control,(*pstate).dempar_text,get_uvalue=dempar
      if dempar eq '' then begin
        result=dialog_message(title='dem parfile','please input dem parfile',/information)
        return
      endif
      workpath=FILE_DIRNAME(offset)+PATH_SEP()
      file='dem_seg'
      infile=dialog_pickfile(title='output dem_seg file',filter='',path=workpath,file=file,/write,/overwrite_prompt)
      if infile eq '' then return
        widget_control,(*pstate).demseg_text,set_value=infile
        widget_control,(*pstate).demseg_text,set_uvalue=infile
    end
    'demsegpar_button':begin
      widget_control,(*pstate).mlipar_text,get_uvalue=mlipar
      if mlipar eq '' then begin
        result=dialog_message(title='mli parfile','please input mli parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      widget_control,(*pstate).dem_text,get_uvalue=dem
      if dem eq '' then begin
        result=dialog_message(title='dem file','please input dem file',/information)
        return
      endif
      widget_control,(*pstate).dempar_text,get_uvalue=dempar
      if dempar eq '' then begin
        result=dialog_message(title='dem parfile','please input dem parfile',/information)
        return
      endif
      widget_control,(*pstate).demseg_text,get_uvalue=demseg
      if demseg eq '' then begin
        result=dialog_message(title='dem_seg file','please input dem_seg file',/information)
        return
      endif
        workpath=FILE_DIRNAME(demseg)+PATH_SEP()
        temp=file_basename(demseg)
        file=temp+'.par'
        infile=dialog_pickfile(title='output dem_seg parfile',filter='*.par',path=workpath,file=file,/write,/overwrite_prompt)
      if infile eq '' then return
        widget_control,(*pstate).demsegpar_text,set_value=infile
        widget_control,(*pstate).demsegpar_text,set_uvalue=infile
    end
    'lookup_button':begin
      widget_control,(*pstate).mlipar_text,get_uvalue=mlipar
      if mlipar eq '' then begin
        result=dialog_message(title='mli parfile','please input mli parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      widget_control,(*pstate).dem_text,get_uvalue=dem
      if dem eq '' then begin
        result=dialog_message(title='dem file','please input dem file',/information)
        return
      endif
      widget_control,(*pstate).dempar_text,get_uvalue=dempar
      if dempar eq '' then begin
        result=dialog_message(title='dem parfile','please input dem parfile',/information)
        return
      endif
      widget_control,(*pstate).demseg_text,get_uvalue=demseg
      if demseg eq '' then begin
        result=dialog_message(title='dem_seg file','please input dem_seg file',/information)
        return
      endif
      widget_control,(*pstate).demsegpar_text,get_uvalue=demsegpar
      if demsegpar eq '' then begin
        result=dialog_message(title='dem_seg parfile','please input dem_seg parfile',/information)
        return
      endif
        workpath=FILE_DIRNAME(demseg)+PATH_SEP()
        temp=file_basename(demseg)
        file='lookup'
        infile=dialog_pickfile(title='output dem_seg parfile',filter='',path=workpath,file=file,/write,/overwrite_prompt)
      if infile eq '' then return
        widget_control,(*pstate).lookup_text,set_value=infile
        widget_control,(*pstate).lookup_text,set_uvalue=infile
    end
    'simsar_button':begin
      widget_control,(*pstate).mlipar_text,get_uvalue=mlipar
      if mlipar eq '' then begin
        result=dialog_message(title='mli parfile','please input mli parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      widget_control,(*pstate).dem_text,get_uvalue=dem
      if dem eq '' then begin
        result=dialog_message(title='dem file','please input dem file',/information)
        return
      endif
      widget_control,(*pstate).dempar_text,get_uvalue=dempar
      if dempar eq '' then begin
        result=dialog_message(title='dem parfile','please input dem parfile',/information)
        return
      endif
      widget_control,(*pstate).demseg_text,get_uvalue=demseg
      if demseg eq '' then begin
        result=dialog_message(title='dem_seg file','please input dem_seg file',/information)
        return
      endif
      widget_control,(*pstate).demsegpar_text,get_uvalue=demsegpar
      if demsegpar eq '' then begin
        result=dialog_message(title='dem_seg parfile','please input dem_seg parfile',/information)
        return
      endif
      widget_control,(*pstate).lookup_text,get_uvalue=lookup
      if lookup eq '' then begin
        result=dialog_message(title='lookup table file','please input lookup table parfile',/information)
        return
      endif
        workpath=FILE_DIRNAME(demseg)+PATH_SEP()
        file='sim_sar'
        infile=dialog_pickfile(title='output simsar parfile',filter='',path=workpath,file=file,/write,/overwrite_prompt)
      if infile eq '' then return
        widget_control,(*pstate).simsar_text,set_value=infile
        widget_control,(*pstate).simsar_text,set_uvalue=infile
    end
    
    
    'ok':begin
      widget_control,(*pstate).mlipar_text,get_uvalue=mlipar
      if mlipar eq '' then begin
        result=dialog_message(title='mli parfile','please input mli parfile',/information)
        return
      endif
      widget_control,(*pstate).offset_text,get_uvalue=offset
      if offset eq '' then begin
        result=dialog_message(title='offset parfile','please input offset parfile',/information)
        return
      endif
      widget_control,(*pstate).dem_text,get_uvalue=dem
      if dem eq '' then begin
        result=dialog_message(title='dem file','please input dem file',/information)
        return
      endif
      widget_control,(*pstate).dempar_text,get_uvalue=dempar
      if dempar eq '' then begin
        result=dialog_message(title='dem parfile','please input dem parfile',/information)
        return
      endif
      widget_control,(*pstate).demseg_text,get_uvalue=demseg
      if demseg eq '' then begin
        result=dialog_message(title='dem_seg file','please input dem_seg file',/information)
        return
      endif
      widget_control,(*pstate).demsegpar_text,get_uvalue=demsegpar
      if demsegpar eq '' then begin
        result=dialog_message(title='dem_seg parfile','please input dem_seg parfile',/information)
        return
      endif
      widget_control,(*pstate).lookup_text,get_uvalue=lookup
      if lookup eq '' then begin
        result=dialog_message(title='lookup table file','please input lookup table parfile',/information)
        return
      endif
      widget_control,(*pstate).simsar_text,get_uvalue=simsar
      if simsar eq '' then begin
        result=dialog_message(title='sim_sar file','please input sim_sar parfile',/information)
        return
      endif
      widget_control,(*pstate).latovr_text,get_value=latovr
      if latovr ne '-' then begin
        latovr=long(latovr)
        if latovr lt 0 then begin
          result=dialog_message(title='latlitude output DEM oversampling factor','latlitude output DEM oversampling factor should large than 0',/information)
          return
          widget_control,(*pstate).latovr_text,set_value=latovr
          widget_control,(*pstate).latovr_text,set_uvalue=latovr
        endif
      endif
      widget_control,(*pstate).lonovr_text,get_value=lonovr
      if lonovr ne '-' then begin
        lonovr=long(lonovr)
        if lonovr lt 0 then begin
          result=dialog_message(title='longiltude output DEM oversampling factor','longiltude output DEM oversampling factor should large than 0',/information)
          return
          widget_control,(*pstate).lonovr_text,set_value=lonovr
          widget_control,(*pstate).lonovr_text,set_uvalue=lonovr
        endif
      endif
      widget_control,(*pstate).frame_text,get_value=frame
      if frame ne '-' then begin
        frame=long(frame)
        if frame lt 0 then begin
          result=dialog_message(title='number of DEM pixels to add','number of DEM pixels to add should large than 0',/information)
          return
          widget_control,(*pstate).frame_text,set_value=lonovr
          widget_control,(*pstate).frame_text,set_uvalue=lonovr
        endif
      endif
      widget_control,(*pstate).lsmode_text,get_value=lsmode
      if lsmode ne '-' then begin
        lsmode=long(lsmode)
        if lsmode ge 4 then begin
          result=dialog_message(title='output lookup table values','output lookup table values should be 0 1 2 or 3',/information)
          return
          widget_control,(*pstate).lsmode_text,set_value=lsmode
          widget_control,(*pstate).lsmode_text,set_uvalue=lsmode
        endif
      endif
      widget_control,(*pstate).rovr_text,get_value=rovr
      if rovr ne '-' then begin
        rovr=long(rovr)
        if rovr lt 0 then begin
          result=dialog_message(title='range oversampling factor','range oversampling factor should large than 0',/information)
          return
          widget_control,(*pstate).rovr_text,set_value=rovr
          widget_control,(*pstate).rovr_text,set_uvalue=rovr
        endif
      endif
      
      widget_control,(*pstate).u_text,get_value=u
      if u ne '-' then begin
        u=long(u)
        if u lt 0 then begin
          result=dialog_message(title='zenith angle of surface normal vector n','zenith angle of surface normal vector n should large than 0',/information)
          return
          widget_control,(*pstate).u_text,set_value=u
          widget_control,(*pstate).u_text,set_uvalue=u
        endif
      endif
      widget_control,(*pstate).v_text,get_value=v
      if v ne '-' then begin
        v=long(v)
        if v lt 0 then begin
          result=dialog_message(title='orientation angle of n','orientation angle of n should large than 0',/information)
          return
          widget_control,(*pstate).v_text,set_value=v
          widget_control,(*pstate).v_text,set_uvalue=v
        endif
      endif
      widget_control,(*pstate).inc_text,get_value=inc
      if inc ne '-' then begin
        inc=long(inc)
        if inc lt 0 then begin
          result=dialog_message(title='local incidence angle','local incidence angle should large than 0',/information)
          return
          widget_control,(*pstate).inc_text,set_value=inc
          widget_control,(*pstate).inc_text,set_uvalue=inc
        endif
      endif
      
      widget_control,(*pstate).psi_text,get_value=psi
      if psi ne '-' then begin
        psi=long(psi)
        if psi lt 0 then begin
          result=dialog_message(title='projection angle','projection angle should large than 0',/information)
          return
          widget_control,(*pstate).psi_text,set_value=psi
          widget_control,(*pstate).psi_text,set_uvalue=psi
        endif
      endif
      widget_control,(*pstate).pix_text,get_value=pix
      if pix ne '-' then begin
        pix=long(pix)
        if pix lt 0 then begin
          result=dialog_message(title='pixel area normalization factor','pixel ares normalization factor should large than 0',/information)
          return
          widget_control,(*pstate).pix_text,set_value=pix
          widget_control,(*pstate).pix_text,set_uvalue=pix
        endif
      endif
      widget_control,(*pstate).lsmap_text,get_value=lsmap
      if lsmap ne '-' then begin
        lsmap=long(lsmap)
        if lsmap lt 0 then begin
          result=dialog_message(title='layover and shadow map','layover and shadow map should large than 0',/information)
          return
          widget_control,(*pstate).lsmap_text,set_value=lsmap
          widget_control,(*pstate).lsmap_text,set_uvalue=lsmap
        endif
      endif
      
      latovr=strcompress(string(latovr),/remove_all)
      lonovr=strcompress(string(lonovr),/remove_all)
      u=strcompress(string(u),/remove_all)
      v=strcompress(string(v),/remove_all)
      inc=strcompress(string(inc),/remove_all)     
      psi=strcompress(string(psi),/remove_all)
      pix=strcompress(string(pix),/remove_all)
      lsmap=strcompress(string(lsmap),/remove_all)
      frame=strcompress(string(frame),/remove_all)
      lsmode=strcompress(string(lsmode),/remove_all)
      rovr=strcompress(string(rovr),/remove_all)

      wtlb = widget_base(title='process bar')
      widget_control,wtlb,/realize
      process = idlitwdprogressbar(group_leader=wtlb,time=0,title='processing...Please wait')
      idlitwdprogressbar_setvalue,process,0 ;-initialize the process bar,initial value=0
      scr='gc_map '+mlipar+' '+offset+' '+dempar+' '+dem+' '+demsegpar+' '+demseg+' '+lookup+' '+latovr+' '+lonovr+' '+simsar+' '+$
        u+' '+v+' '+inc+' '+psi+' '+pix+' '+lsmap+' '+frame+' '+lsmode+' '+rovr
;      spawn,scr
      idlitwdprogressbar_setvalue,process,100 ;finish
      stop
      
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
PRO INSARGUI_GCMAP,EVENT

  ;Create components
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  tlb=widget_base(title='gc_map',tlb_frame_attr=1,column=1,xsize=350,ysize=575,xoffset=xoffset,yoffset=yoffset)

  ;input window
  ;Create print flag input window
  inputID=widget_base(tlb,row=1)
  inputlabel=widget_label(inputID,value='input file:',/align_left,xsize=179)

  ;-Create mli or slc image parrameter file input window
  mliID=widget_base(tlb,row=1)
  mlipar_text=widget_text(mliID,value='',uvalue='',uname='mlipar_text',/editable,xsize=37)
  mlipar_button=widget_button(mliID,value='MLI_par',uname='mlipar_button',xsize=96)

  ;-Create offset parfile input window
  offsetID=widget_base(tlb,row=1)
  offset_text=widget_text(offsetID,value='',uvalue='',uname='offset_text',/editable,xsize=37)
  offset_button=widget_button(offsetID,value='OFF_par',uname='offset_button',xsize=96)
  
  ;-Create DEM file input window
  demID=widget_base(tlb,row=1)
  dem_text=widget_text(demID,value='',uvalue='',uname='dem_text',/editable,xsize=37)
  dem_button=widget_button(demID,value='DEM',uname='dem_button',xsize=96)
  
  ;-Create DEM parameter file input window
  demparID=widget_base(tlb,row=1)
  dempar_text=widget_text(demparID,value='',uvalue='',uname='dempar_text',/editable,xsize=37)
  dempar_button=widget_button(demparID,value='DEM_par',uname='dempar_button',xsize=96)
  
  ;-Create oversampling factor of points used for the interpolation input window
  ovrID=widget_base(tlb,row=1)
  ovrlabel=widget_label(ovrID,value='ovr factor(lat,lon):',/align_left,xsize=199)
  latovr_text=widget_text(ovrID,value='-',uvalue='',uname='latovr_text',/editable,xsize=5)
  lonovr_text=widget_text(ovrID,value='-',uvalue='',uname='lonovr_text',/editable,xsize=5)

  ;-Create number of DEM pixels to add around area input window
  numID=widget_base(tlb,row=1)
  numlabel=widget_label(numID,value='frame,ls_mode,r_ovr:',/align_left,xsize=199)
  frame_text=widget_text(numID,value='-',uvalue='',uname='frame_text',/editable,xsize=5)
  lsmode_text=widget_text(numID,value='-',uvalue='',uname='lsmode_text',/editable,xsize=5)
  rovr_text=widget_text(numID,value='-',uvalue='',uname='rovr_text',/editable,xsize=5)
  
  ;-output window
  ;Create print flag input window
  outputID=widget_base(tlb,row=1)
  outputlabel=widget_label(outputID,value='output file:',/align_left,xsize=179)

  ;-Create DEM segment file input window
  demsegID=widget_base(tlb,row=1)
  demseg_text=widget_text(demsegID,value='',uvalue='',uname='demseg_text',/editable,xsize=37)
  demseg_button=widget_button(demsegID,value='DEM_seg',uname='demseg_button',xsize=96)

  ;-Create DEM segment parameter file input window
  demsegparID=widget_base(tlb,row=1)
  demsegpar_text=widget_text(demsegparID,value='',uvalue='',uname='demsegpar_text',/editable,xsize=37)
  demsegpar_button=widget_button(demsegparID,value='DEM_seg_par',uname='demsegpar_button',xsize=96)

  ;-Create lookup_table input window
  lookupID=widget_base(tlb,row=1)
  lookup_text=widget_text(lookupID,value='',uvalue='',uname='lookup_text',/editable,xsize=37)
  lookup_button=widget_button(lookupID,value='lookup_table',uname='lookup_button',xsize=96)
  
  ;-Create simulated SAR backscatter image in DEM geometry input window
  simsarID=widget_base(tlb,row=1)
  simsar_text=widget_text(simsarID,value='',uvalue='',uname='simsar_text',/editable,xsize=37)
  simsar_button=widget_button(simsarID,value='sim_sar',uname='simsar_button',xsize=96)
  
  ;-Create output parameters input window
  outID=widget_base(tlb,row=1)
  outlabel=widget_label(outID,value='zenith,orient,incidence:',/align_left,xsize=199)
  u_text=widget_text(outID,value='-',uvalue='',uname='u_text',/editable,xsize=5)
  v_text=widget_text(outID,value='-',uvalue='',uname='v_text',/editable,xsize=5)
  inc_text=widget_text(outID,value='-',uvalue='',uname='inc_text',/editable,xsize=5)
  
  ;-Create output parameters input window
  out1ID=widget_base(tlb,row=1)
  out1label=widget_label(out1ID,value='proj,pixel,layover:',/align_left,xsize=199)
  psi_text=widget_text(out1ID,value='-',uvalue='',uname='psi_text',/editable,xsize=5)
  pix_text=widget_text(out1ID,value='-',uvalue='',uname='pix_text',/editable,xsize=5)
  lsmap_text=widget_text(out1ID,value='-',uvalue='',uname='lsmap_text',/editable,xsize=5)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=70,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=70,ysize=30)

  ;Recognize components
  state={mlipar_text:mlipar_text,mlipar_button:mlipar_button,offset_text:offset_text,offset_button:offset_button,dem_text:dem_text,$
    dem_button:dem_button,dempar_text:dempar_text,dempar_button:dempar_button,demseg_text:demseg_text,demseg_button:demseg_button,$
    demsegpar_text:demsegpar_text,demsegpar_button:demsegpar_button,lookup_text:lookup_text,lookup_button:lookup_button,simsar_text:simsar_text,$
    simsar_button:simsar_button,latovr_text:latovr_text,lonovr_text:lonovr_text,frame_text:frame_text,lsmode_text:lsmode_text,rovr_text:rovr_text,$
    u_text:u_text,v_text:v_text,inc_text:inc_text,psi_text:psi_text,pix_text:pix_text,lsmap_text:lsmap_text,ok:ok,cl:cl}

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'INSARGUI_GCMAP',tlb,/no_block

END
