;-
;- Generate the files that needed by HPA analysis.
;- Return the full path of the file.
;-

@tli_hpa_checkfiles

FUNCTION TLI_HPA_FILES, workpath,level=level
  
  COMPILE_OPT idl2
  
  IF NOT FILE_TEST(workpath,/DIRECTORY) THEN BEGIN
    Message, 'Input file path error:'+workpath
  ENDIF
  IF N_ELEMENTS(level) EQ 0 THEN BEGIN
    level=TLI_HPA_LEVEL(workpath)
  ENDIF
  workpath_c=workpath
  IF NOT TLI_HAVESEP(workpath) THEN workpath_c=workpath_c+PATH_SEP()
  
  p_path=FILE_DIRNAME(workpath_c)
  itabfile=p_path+PATH_SEP()+'itab'
  IF STRCOMPRESS(level,/REMOVE_ALL) NE 'final' THEN BEGIN
    Case level OF
      0: BEGIN
        Message, 'The level starts from 1.'
      END
      1: BEGIN
        lel='lel'+STRCOMPRESS(level,/REMOVE_ALL)
        str=workpath_c+lel
        result=CREATE_STRUCT('pbase_update', str+'pbase',$
          'itab', itabfile,$
          'plist',workpath_c+'plist',$
          'pdiff', workpath_c+'pdiff',$
          'pdiff_swap', workpath_c+'pdiff_swap',$
          'ptstruct', workpath_c+'ptstruct',$
          'vdh_merge', workpath_c+'vdh',$
          'pdef', workpath_c+'pdef',$
          'plist_update',workpath_c+'plistupdate',$
          'plist_merge',workpath_c+'plistupdate_merge',$
          'ptstruct_update', str+'ptstruct_update',$
          'pslc_update', str+'pslc_update',$
          'vdh', workpath_c+'vdh',$
          'pla', workpath_c+'pla',$
          'pbase', workpath_c+'pbase',$
          'ptattr', workpath_c+'ptattr',$
          'pla_update', str+'pla_update',$   ; The followings are kept the same as before.
          'arcs_res', str+'arcs_res',$
          'res_phase', str+'res_phase',$
          'time_series_linear', str+'time_series_linear',$
          'res_phase_sl', str+'res_phase_sl', $
          'res_phase_tl', str+'res_phase_tl',$
          'final_result', str+'final_result',$
          'nonlinear', str+'nonlinear',$
          'atm', str+'atm',$
          'time_seriestxt', str+'Time_Series.txt',$
          'dhtxt',str+'HeightError.txt',$
          'vtxt', str+'Deformation_Rate.txt',$
          'ptattr_update', str+'ptattr_update'$
          )
      END
      ELSE: BEGIN
        lel='lel'+STRCOMPRESS(level,/REMOVE_ALL)
        str=workpath_c+lel
        result=CREATE_STRUCT('pbase_update', str+'pbase_update',$
          'itab', itabfile,$
          'plist',str+'plist_update',$
          'pdiff', str+'pdiff',$
          'pdiff_swap', str+'pdiff_swap',$
          'ptstruct', str+'ptstruct',$
          'vdh_merge', str+'vdh_merge',$
          'pdef', str+'pdef',$
          'plist_update',str+'plist_update',$
          'ptstruct_update', str+'ptstruct_update',$
          'pslc_update', str+'pslc_update',$
          'vdh', str+'vdh',$
          'pla', str+'pla',$
          'pbase', str+'pbase',$
          'ptattr', str+'ptattr',$
          'pla_update', str+'pla_update',$
          'arcs_res', str+'arcs_res',$
          'res_phase', str+'res_phase',$
          'time_series_linear', str+'time_series_linear',$
          'res_phase_sl', str+'res_phase_sl', $
          'res_phase_tl', str+'res_phase_tl',$
          'final_result', str+'final_result',$
          'nonlinear', str+'nonlinear',$
          'atm', str+'atm',$
          'time_seriestxt', str+'Time_Series.txt',$
          'dhtxt',str+'HeightError.txt',$
          'vtxt', str+'Deformation_Rate.txt',$
          'plist_merge', str+'plist_update_merge',$
          'ptattr_update', str+'ptattr_update'$
          )
      END
      
    ENDCASE
    
  ENDIF ELSE BEGIN
    str=workpath_c
    result=CREATE_STRUCT('pbase',str+'pbase_merge_all',$
      'itab', itabfile,$
      'sarlist', workpath_c+'sarlist', $
      'plist',str+'plist_merge_all',$
      'pdiff', str+'pdiff_merge_all',$
      'pdiff_swap', str+'pdiff_merge_all_swap',$
      'ptstruct', str+'ptstruct_merge_all',$
      'vdh_merge', str+'vdh_merge_all',$
      'pdef', str+'pdef_merge_all',$
      'pslc', str+'pslc_merge_all',$
      'vdh', str+'vdh_merge_all',$
      'pla', str+'pla_merge_all',$
      'ptattr', str+'ptattr_merge_all',$
      'arcs_res', str+'arcs_res_merge_all',$
      'res_phase', str+'res_phase_merge_all',$
      'time_series_linear', str+'time_series_linear_merge_all',$
      'res_phase_sl', str+'res_phase_sl_merge_all', $
      'res_phase_tl', str+'res_phase_tl_merge_all',$
      'final_result', str+'final_result_merge_all',$
      'nonlinear', str+'nonlinear_merge_all',$
      'atm',str+'atm_merge_all',$
      'time_seriestxt', str+'Time_Series_merge_all.txt',$
      'dhtxt',str+'HeightError_merge_all.txt',$
      'vtxt', str+'Deformation_Rate_merge_all.txt'$
      )
  ENDELSE
  
  RETURN, result
END
;-
;- Generate the files that needed by HPA analysis.
;- Return the full path of the file.
;-

@tli_hpa_checkfiles
FUNCTION TLI_HPA_FILES, workpath,level=level

  IF NOT FILE_TEST(workpath,/DIRECTORY) THEN BEGIN
    Message, 'File path not exist:'+workpath
  ENDIF
  IF N_ELEMENTS(level) EQ 0 THEN BEGIN
    level=TLI_HPA_LEVEL(workpath)
  ENDIF
  workpath_c=workpath
  IF NOT TLI_HAVESEP(workpath) THEN workpath_c=workpath_c+PATH_SEP()
  
  p_path=FILE_DIRNAME(workpath_c)
  itabfile=p_path+PATH_SEP()+'itab'
  IF STRCOMPRESS(level,/REMOVE_ALL) NE 'final' THEN BEGIN
    Case level OF
      0: BEGIN
        Message, 'The level starts from 1.'
      END
      1: BEGIN
        lel='lel'+STRCOMPRESS(level,/REMOVE_ALL)
        str=workpath_c+lel
        result=CREATE_STRUCT('pbase_update', str+'pbase',$
          'itab', itabfile,$
          'plist',workpath_c+'plist',$
          'pslc',workpath_c+'pSLC',$
          'pdiff', workpath_c+'pdiff',$
          'pdiff_swap', workpath_c+'pdiff_swap',$
          'ptstruct', workpath_c+'ptstruct',$
          'vdh_merge', workpath_c+'vdh',$
          'pdef', workpath_c+'pdef',$
          'plist_update',workpath_c+'plistupdate',$
          'plist_merge',workpath_c+'plistupdate_merge',$
          'ptstruct_update', str+'ptstruct_update',$
          'pslc_update', str+'pslc',$
          'vdh', workpath_c+'vdh',$
          'pla', workpath_c+'pla',$
          'pbase', workpath_c+'pbase',$
          'ptattr', workpath_c+'ptattr',$
          'pla_update', str+'pla_update',$   ; The followings are kept the same as before.
          'arcs_res', str+'arcs_res',$
          'res_phase', str+'res_phase',$
          'time_series_linear', str+'time_series_linear',$
          'res_phase_sl', str+'res_phase_sl', $
          'res_phase_tl', str+'res_phase_tl',$
          'final_result', str+'final_result',$
          'nonlinear', str+'nonlinear',$
          'atm', str+'atm',$
          'time_seriestxt', str+'Time_Series.txt',$
          'dhtxt',str+'HeightError.txt',$
          'vtxt', str+'Deformation_Rate.txt',$
          'ptattr_update', str+'ptattr_update'$
          )
      END
      ELSE: BEGIN
        lel='lel'+STRCOMPRESS(level,/REMOVE_ALL)
        str=workpath_c+lel
        result=CREATE_STRUCT('pbase_update', str+'pbase_update',$
          'itab', itabfile,$
          'plist',str+'plist',$
          'pdiff', str+'pdiff',$
          'pdiff_swap', str+'pdiff_swap',$
          'ptstruct', str+'ptstruct',$
          'vdh_merge', str+'vdh_merge',$
          'pdef', str+'pdef',$
          'plist_gamma', str+'plist_GAMMA', $
          'plist_update',str+'plist_update',$
          'ptstruct_update', str+'ptstruct_update',$
          'pslc', str+'pslc',$
          'pslc_update', str+'pslc_update',$
          'vdh', str+'vdh',$
          'pla', str+'pla',$
          'pbase', str+'pbase',$
          'ptattr', str+'ptattr',$
          'pla_update', str+'pla_update',$
          'arcs_res', str+'arcs_res',$
          'res_phase', str+'res_phase',$
          'time_series_linear', str+'time_series_linear',$
          'res_phase_sl', str+'res_phase_sl', $
          'res_phase_tl', str+'res_phase_tl',$
          'final_result', str+'final_result',$
          'nonlinear', str+'nonlinear',$
          'atm', str+'atm',$
          'time_seriestxt', str+'Time_Series.txt',$
          'dhtxt',str+'HeightError.txt',$
          'vtxt', str+'Deformation_Rate.txt',$
          'plist_merge', str+'plist_update_merge',$
          'ptattr_update', str+'ptattr_update'$
          )
      END
      
    ENDCASE
    
  ENDIF ELSE BEGIN
    str=workpath_c
    result=CREATE_STRUCT('pbase',str+'pbase_merge_all',$
      'itab', itabfile,$
      'sarlist', workpath_c+'sarlist', $
      'plist',str+'plist_merge_all',$
      'pdiff', str+'pdiff_merge_all',$
      'pdiff_swap', str+'pdiff_merge_all_swap',$
      'ptstruct', str+'ptstruct_merge_all',$
      'vdh_merge', str+'vdh_merge_all',$
      'pdef', str+'pdef_merge_all',$
      'pslc', str+'pslc_merge_all',$
      'vdh', str+'vdh_merge_all',$
      'pla', str+'pla_merge_all',$
      'ptattr', str+'ptattr_merge_all',$
      'arcs_res', str+'arcs_res_merge_all',$
      'res_phase', str+'res_phase_merge_all',$
      'time_series_linear', str+'time_series_linear_merge_all',$
      'res_phase_sl', str+'res_phase_sl_merge_all', $
      'res_phase_tl', str+'res_phase_tl_merge_all',$
      'final_result', str+'final_result_merge_all',$
      'nonlinear', str+'nonlinear_merge_all',$
      'atm',str+'atm_merge_all',$
      'time_seriestxt', str+'Time_Series_merge_all.txt',$
      'dhtxt',str+'HeightError_merge_all.txt',$
      'vtxt', str+'Deformation_Rate_merge_all.txt'$
      )
  ENDELSE
  
  RETURN, result
END