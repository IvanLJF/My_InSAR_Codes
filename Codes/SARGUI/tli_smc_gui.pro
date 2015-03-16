;
; GUI for Sasmac InSAR Analysis.
;
; Written by:
;   T.LI @ Sasmac, 20141218
;
@tli/compile
PRO TLI_SMC_GUI_EVENT, event

  COMMON TLI_SMC_GUI, types, file, wid, config
  
  IF TAG_NAMES(event, /STRUCTURE_NAME) eq 'WIDGET_KILL_REQUEST' THEN BEGIN
    IF 0 THEN BEGIN
      info=' InSAR Tools Using GAMMA Software. '+STRING(10b)+$
        ' For development users only.'+STRING(10b)+$
        ' R&D Dept., Sasmac'
      void=DIALOG_MESSAGE(info,/cancel, DIALOG_PARENT = wid.base, TITLE='Exit Sasmac InSAR',/INFORMATION)
    ENDIF
    ; delete main window
    
    widget_control, /destroy, wid.base
    ; free pointers from parameters sturcture
    
    heap_free, wid
    RETURN
  ENDIF
  
  WIDGET_CONTROL, event.id, GET_UVALUE=uval
  
  IF (SIZE(uval))[1] EQ 7 THEN BEGIN
    case uval of
    
      ; BUTTON DISPLAY
      'button.file.open' : TLI_SMC_OPEN_SLC
      'button.file.efh'  : whatisthis
      ;      'button.edit.zoom' : zoom_region
      'button.edit.zoom' : TLI_SMC_ZOOM
      'button.edit.zoomin':
      'button.edit.zoomout':
      
      'button.tool.layer': tool_box ,/select_channel ;select_channels_new ;data_management
      'button.tool.data' : tool_box ,/data_management ;select_channels_new ;data_management
      'button.tool.color': tool_box ,/color_table ;select_channels_new ;data_management
      
      ; FILE MENU
      'io': BEGIN
        Case STRLOWCASE(event.value) OF
          'open gamma slc'                      : TLI_SMC_OPEN_SLC
          'import slc data.terrasar-x(.cos)'                   : TLI_SMC_IMPORT_TSX
          'import slc data.ers(dat_01.001)'                    : TLI_SMC_IMPORT_ERS
          'import slc data.palsar(.raw)'                       : TLI_SMC_IMPORT_PLS
          'import slc data.cosmo-skymed(.h5)'                  : TLI_SMC_IMPORT_CSK
          'write files'                                        : TLI_FINDPRO,'tli_write'
          ELSE: TLI_SMC_DUMMY, inputstr='Function was not designed!'
        ENDCASE
      END
      'general': BEGIN
        Case STRLOWCASE(event.value) OF
          'multi look'                        : TLI_SMC_ML
          'cut out region'                    : TLI_SMC_SLC_COPY
          'swap endian'                       : TLI_SMC_SWAP_BYTES
          'complex -> amplitude'              : TLI_SMC_DUMMY, inputstr='Functions are not found!'
          'complex -> phase'                  : TLI_SMC_DUMMY, inputstr='Functions are not found!'
          'format convert'                    : TLI_SMC_DUMMY, inputstr='Functions are not found!'
          ELSE: TLI_SMC_DUMMY, inputstr='Function was not designed!'
        ENDCASE
      END
      
      ;-------------------------------------------------------------------
      ;  Chen Weinan
      'coreg': BEGIN
        Case STRLOWCASE(event.value) OF
          'initial offset.create_offset'       : CWN_SMC_CREATEOFFSET
          'initial offset.init_offset_orbit'   : CWN_SMC_INITOFFSETORBIT
          'initial offset.init_offset'         : CWN_SMC_INITOFFSET
          'offset_pwr'                         : CWN_SMC_OFFSETPWR
          'offset_fit'                         : CWN_SMC_OFFSETFIT
          'offset_pwr_tracking'                : CWN_SMC_OFFSETPWRTRAC
          'slc_interp'                         : CWN_SMC_SLCINTERP
          'slc_intf'                           : CWN_SMC_SLCINTF
          'cc_wave'                            : CWN_SMC_CCWAVE
          ELSE: TLI_SMC_DUMMY, inputstr='Functions are not found!'
        ENDCASE
      END
      'geo': BEGIN
        Case STRLOWCASE(event.value) OF
          'gcp_method.srtm data.tli_gcp_dem'      : CWN_SMC_TLIGCPDEM
          'gcp_method.srtm data.gcp_phase'        : CWN_SMC_GCPPHASE
          'gcp_method.srtm data.base_ls'          : CWN_SMC_BASELS
          'gcp_method.manually selected.gcp_ras'  : CWN_SMC_GCPRAS
          'gcp_method.manually selected.gcp_phase': CWN_SMC_GCPPHASE
          'gcp_method.manually selected.base_ls'  : CWN_SMC_BASELS
          'gcp_method.tli_base_ls'                : CWN_SMC_TLIBASELS
          'interp_ad'                             : CWN_SMC_INTERPAD
          'hgt_map'                               : CWN_SMC_HGTMAP   
          'gc_map'                                : CWN_SMC_GCMAP
          'res_map'                               : CWN_SMC_RESMAP
          'geocode'                               : CWN_SMC_GEOCODE
          'create diff par.create_diff_par'       : CWN_SMC_CREATEDIFFPAR
          'create diff par.offset_pwrm'           : CWN_SMC_OFFSETPWRM
          'create diff par.offset_fitm'           : CWN_SMC_OFFSETFITM
          'gc_map_fine'                           : CWN_SMC_GCMAPFINE
          'backward geocoding'                    : CWN_SMC_GEOCODEBACK
          'forward geocoding'                     : CWN_SMC_GEOCODE
          
          ELSE: TLI_SMC_DUMMY, inputstr='Functions are not found!'
        ENDCASE 
      END
      ; Chen Weinan
      ;-------------------------------------------------------------------
      
      ;-------------------------------------------------------------------
      ; Chen Wei
      'flat': BEGIN
        Case STRLOWCASE(event.value) OF
          'base_init'                          : cw_smc_base_init     ; change 'offset method' to widget_dropbox
          ; Good, pay attention to definitions. And information dialog should be centered.
          'base_perp'                          : cw_smc_base_perp
          'phase_slope_base'                   : cw_smc_ph_slope_base ; Change interferogram type to dropbox.inverse flag to dropbox.outputfile should be *.flt
          
          ELSE: TLI_SMC_DUMMY, inputstr='Function was not designed!'
        ENDCASE
      END
      
      'unw': BEGIN
      
        Case STRLOWCASE(event.value) OF
          
          'adf'                                          :  cw_smc_adf   ; Title of tlb.
          'branch cut.corr_flag'                                :    cw_smc_corr_flag   ; Attention when matching case statement.
          'branch cut.neutron'                               :   cw_smc_neutron
          'branch cut.residue'                                 :  cw_smc_residue
          'branch cut.tree_cc'                                  : cw_smc_tree_cc
          'branch cut.grasses'                                  : cw_smc_grasses
          'mcf.rascc_mask'                             : cw_smc_rascc_mask
          'mcf.rascc_mask_thining'            : cw_smc_rascc_mask_thinning
          'mcf.mcf'                                          : cw_smc_mcf
          'mcf.interp_ad'                               : cw_smc_interp_ad
          'mcf.unw_model'                           : cw_smc_unw_model
          'snaphu.gamma2snaphu.interferogram'            : cw_smc_gamma2snaphu_int
          'snaphu.gamma2snaphu.cc'              : cw_smc_gamma2snaphu_cc
          'snaphu.snaphu'                                    : cw_smc_snaphu
          'snaphu.snaphu2gamma.unw'                    : cw_smc_snaphu2gamma_UNW
          
          ELSE: TLI_SMC_DUMMY, inputstr='Function was not designed!'
        ENDCASE
      END
      ; Chenwei
      ;--------------------------------------------------------------------------
      
      
      
      'qa': BEGIN
        Case STRLOWCASE(event.value) OF
          'report dem error'               : TLI_SMC_REPORT_INT_DEM_ERROR
          
          'plot geocoded.int dem'                             : TLI_SMC_PLOT_INT_DEM
          'plot geocoded.ref dem'                             : TLI_SMC_PLOT_REF_DEM
          'plot geocoded.dem error'                           : TLI_SMC_PLOT_INT_DEM_ERROR
          
          ELSE: TLI_SMC_DUMMY, inputstr='Function was not designed!'
        ENDCASE
      END
      
      'help': BEGIN
        Case STRLOWCASE(event.value) OF
          'sasmac user guide'                                  :
          'contact'                                            :
          'about sasmac insar'                                 :
          ELSE: TLI_SMC_DUMMY, inputstr='Function was not designed!'
        ENDCASE
        
      END
      
      ELSE: TLI_SMC_DUMMY, inputstr='Designing is ongoing.'
      
    ENDCASE
  ENDIF ELSE BEGIN
    TLI_SMC_DUMMY, inputstr='Error! Function was not designed.'
  ENDELSE
  
  widget_control,wid.draw,draw_button_events=1, draw_motion_events = 1,event_pro='tli_smc_draw_event',bad_id = dummy
  out:
  
END


PRO TLI_SMC_GUI,STARTFILE=startfile, FILE=startfile_tmp, $
    BLOCK=block, $
    nw=batch, $             ; nw == no window
    no_preview_image=no_preview_image
    
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  TLI_SMC_DEFINITIONS
  
  IF config.os EQ 'unix' THEN BEGIN
    default_path='/mnt/data_tli/ForExperiment/InSARGUI/int_ERS_shanghai_2000_10000/'  ; For test
    ;default_path='/mnt/data_tli/ForExperiment/'  ; For test
  ENDIF ELSE BEGIN
    default_path='H:\ForExperiment\InSARGUI\int_ERS_shanghai_2000_10000\'
  ENDELSE
  config.workpath=default_path
  
  workpath=FILE_DIRNAME(ROUTINE_FILEPATH('tli_smc_gui'))+PATH_SEP()
  imagedir=workpath+'icons'+PATH_SEP()
  
  ;--------------------------------------------
  ; Definitions
  
  
  wid.base      = WIDGET_BASE(TITLE='Sasmac - InSAR Tools', $
    MBAR=bar, UVALUE='base', $
    TLB_frame_attr=1,/column, $
    /TLB_KILL_REQUEST_EVENTS,/ALIGN_CENTER)
  io_menu       = WIDGET_BUTTON(bar, VALUE=' IO', /MENU)
  general_menu  = WIDGET_BUTTON(bar, VALUE=' General', /MENU)
  coreg_menu    = WIDGET_BUTTON(bar, VALUE=' Coregistration', /MENU)
  flat_menu     = WIDGET_BUTTON(bar, VALUE=' Flattenning' , /MENU )
  unw_menu      = WIDGET_BUTTON(bar, VALUE=' Phase Unwrapping', /MENU)
  geo_menu      = WIDGET_BUTTON(bar, value=' Geocoding',/MENU)
  qa_menu       = WIDGET_BUTTON(bar, value=' DEM Assessment',/MENU)
  dinsar_menu   = WIDGET_BUTTON(bar, value=' DInSAR',/Menu)
  psi_menu      = WIDGET_BUTTON(bar, value=' PSInSAR',/MENU)
  sbas_menu     = WIDGET_BUTTON(bar, value=' SBAS',/MENU)
  stamps_menu   = WIDGET_BUTTON(bar, value=' StaMPS',/MENU)
  tomo_menu     = WIDGET_BUTTON(bar, value=' Tomo-SAR',/MENU)
  help_menu     = WIDGET_BUTTON(bar, VALUE=' Help', /MENU, /HELP)
  
  desc_io_menu=[ '5\Import SLC Data',$
    '0\TerraSAR-X(.cos)',$
    '0\ERS(DAT_01.001)',$
    '0\Cosmo-SkyMED(.h5)',$
    '2\PALSAR(.raw)',$
    '0\Open GAMMA SLC' $
    ]
    
  desc_general_menu =[ '4\Multi Look',$
    '0\Cut Out Region',$
    '0\Swap Endian',$
    '4\Statistics',$
    '4\Complex -> Amplitude' , $
    '0\Complex -> Phase', $
    '2\Format convert' $
    ]
    
  ;--------------------------------------------------------------------
  ; Chen Weinan
  desc_coreg_menu= [ '5\initial offset', $
    '0\create_offset', $
    '0\init_offset_orbit',$
    '2\init_offset',$
    '4\offset_pwr',$
    '0\offset_fit',$
    '0\offset_pwr_tracking',$
    '4\SLC_interp', $
    '4\SLC_intf', $
    '0\cc_wave'$
    ]
    
  desc_geo_menu=[ '1\gcp_method',$
    '1\srtm data',$
    '0\tli_gcp_dem',$ 
    '0\gcp_phase',$
    '2\base_ls',$    
    '1\manually selected',$
     '0\gcp_ras',$
     '0\gcp_phase',$
     '2\base_ls',$ 
     '2\tli_base_ls',$
    '0\interp_ad',$
    '0\hgt_map',$
    '0\res_map',$
    '4\gc_map',$
    '0\geocode',$
    '5\create diff par',$
    '0\create_diff_par',$
    '0\offset_pwrm',$
    '2\offset_fitm',$
    '0\gc_map_fine',$
    '0\Backward geocoding',$
    '0\Forward geocoding' $
    ]
  
  ; Chen Weinan
  ;------------------------------------------------------------------
    
    
    
  ;------------------------------------------------------------------
  ; Chen Wei
  desc_flat_menu=[$
    '0\base_init' ,$
    '0\base_perp' ,$
    '4\phase_slope_base' $
    ]
    
  desc_unw_menu=[$
    '4\adf', $
    '5\branch cut', $
    '0\corr_flag',$
    '0\neutron',$
    '0\residue',$
    '0\tree_cc',$
    '2\grasses',$
    '5\mcf',$
    '0\rascc_mask',$
    '0\rascc_mask_thining',$
    '0\mcf',$
    '0\interp_ad',$
    '2\unw_model',$
    '5\snaphu',$
    '5\gamma2snaphu',$
    '0\interferogram',$
    '2\cc',$
    '0\snaphu',$
    '5\snaphu2gamma',$
    '0\unw'$
    ]
  ; Chen Wei
  ;-----------------------------------------------------------
    
  desc_qa_menu=[ '0\Report DEM Error',$
    '5\Plot geocoded',$
    '0\Int DEM',$
    '0\Ref DEM', $
    '2\DEM Error', $
    '5\Plot un-geocoded',$
    '0\Int DEM',$
    '0\Ref DEM'$
    ]
   
  desc_dinsar_menu=[ '0\On Designing' ]
  
  desc_psi_menu=['0\On Designing']
  
  desc_sbas_menu=['0\On Designing']
  
  desc_tomo_menu=['0\On Designing']
  
  desc_stamps_menu=['0\On Designing']
    
  desc_help_menu = [ $
    '0\Sasmac User Guide', $
    '4\Contact', $
    '0\About Sasmac InSAR' $
    ]
    
    
    
  m_file     = CW_PDMENU(io_menu,desc_io_menu,/MBAR,/RETURN_FULL_NAME,UVALUE = 'io')
  m_general  = CW_PDMENU(general_menu,desc_general_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'general')
  m_coreg      = CW_PDMENU(coreg_menu,desc_coreg_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'coreg')
  m_flat = CW_PDMENU(flat_menu,desc_flat_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'flat')
  m_unw    = CW_PDMENU(unw_menu,desc_unw_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'unw')
  m_geo    = CW_PDMENU(geo_menu,desc_geo_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'geo')
  m_qa    = CW_PDMENU(qa_menu,desc_qa_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'qa')
  m_dinsar=CW_PDMENU(dinsar_menu,desc_dinsar_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'dinsar')
  m_psi=CW_PDMENU(psi_menu,desc_psi_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'psi')
  m_sbas=CW_PDMENU(sbas_menu,desc_sbas_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'sbas')
  m_stamps=CW_PDMENU(stamps_menu,desc_stamps_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'stamps')
  m_tomo=CW_PDMENU(tomo_menu,desc_tomo_menu,/MBAR,/RETURN_FULL_NAME, UVALUE = 'tomo')  
  m_help     = CW_PDMENU(help_menu,desc_help_menu,/MBAR,/RETURN_FULL_NAME,UVALUE = 'help')
  
  ; Button bar
  widbuttonx = widget_base(wid.base,/row)
  widbutton = widget_base(widbuttonx,/row,/toolbar)
  widButFile = widget_base(widbutton,/row,/frame,/toolbar)
  button_open = widget_button(widButFile,value=imagedir+'open.bmp',/bitmap,tooltip='Open SLC file',uvalue='button.file.open')
  widButEdit = widget_base(widbutton,/row,/frame,/toolbar)
  button_zoom  = widget_button(widButEdit,value=imagedir+'zoom.bmp',/bitmap,tooltip='Zoom',uvalue='button.edit.zoom')
  button_zoomin=widget_button(widButEdit, value=imagedir+'zoom_in.bmp',/bitmap, tooltip='Zoom In', uvalue='button.edit.zoomin')
  button_zoomout=widget_button(widButEdit, value=imagedir+'zoom_out.bmp',/bitmap,tooltip='Zoom out', uvalue='button.edit.zoomout')
  
  widButTool = widget_base(widbutton,/row,/frame,/toolbar)
  button_data_man = widget_button(widButTool,value=imagedir+'mcr.bmp',/bitmap,tooltip='Data management',uvalue='button.tool.data')
  button_color    = widget_button(widButTool,value=imagedir+'palette.bmp',/bitmap,tooltip='Color table',uvalue='button.tool.color')
  ;     widRatBase = widget_base(widbuttonx,/row)
  ;       widSpacebase = widget_base(widRatBase,xsize=wid.base_xsize - 280,ysize=1)
  ;  ;      widRATDraw = widget_draw(widRatBase,xsize=80,ysize=35)
  
  ;---- preview window ----
  
  widinner = widget_base(wid.base,/column)
  
  ;
  wid.draw = TLI_SMC_DRAW(widinner,wid.base_xsize,wid.base_ysize,XSCROLL=wid.base_xsize+2,YSCROLL=wid.base_ysize,RETAIN=2,color_model=1)
  
  ;---- info box ----
  
  lower    = widget_base(widinner,/row)
  wid.txt  = WIDGET_TEXT(lower,SCR_XSIZE=(wid.base_xsize-135)>300, YSIZE=3)  ; Large txt widget
  wid.label= WIDGET_LABEL(lower, xsize=135, /align_left,$                   ; Small label widget
    value    ='Coordinate:'+STRING(10b)+$
    '(0.0, 0.0)'+STRING(10b)+$
    STRING(10b)+$
    'Value: '+STRING(10b)+$
    '0.0')
    
  ;image_rat_draw = widget_draw(lower,xsize=130,ysize=57)
    
  ;---- Realize everything ----
    
  WIDGET_CONTROL, /REALIZE, wid.base ;, XOFFSET=200
  
  ;switch back to main draw widget
  widget_control,wid.draw,get_value=index,draw_button_events=1, draw_motion_events = 1,event_pro='tli_smc_draw_event'
  wset,index
  
  device,/cursor_original
  
  if float(strmid(!version.release,0,3)) lt 6.2 then begin
    error = DIALOG_MESSAGE(["Sorry, IDL / IDL virtual machine version >= 6.2 required!",$
      "Enjoy the errors which will occur... (most things will work)"], DIALOG_PARENT = wid.base, TITLE='Error')
  endif
  
  
  if n_elements(startfile_tmp) ne 0 then startfile=startfile_tmp
  
  XMANAGER, 'tli_smc_gui', wid.base, /no_block
  
END