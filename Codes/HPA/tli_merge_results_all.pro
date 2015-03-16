;-
;- Merge all the results in HPA processing
;- e.g.
;-workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA'
;  workpath=workpath+PATH_SEP()
;  plistfinalfile=workpath+'plist_merge_all'
;-
@tli_hpa_level
@tli_write
PRO TLI_MERGE_RESULTS_ALL,workpath, type,level=level,outputfile=outputfile,recursive=recursive

  IF N_PARAMS() NE 2 THEN Message, 'TLI_MERGE_RESULTS_ALL: Usage error!'
  
  IF ~TLI_HAVESEP(workpath) THEN workpath=workpath+PATH_SEP()
  
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=workpath+type+'_merge_all'
  ENDIF
  
  IF NOT KEYWORD_SET(level) THEN BEGIN
    level=TLI_HPA_LEVEL(workpath)
  ENDIF
  ; Merge files
  IF level EQ 1 THEN BEGIN
    Message, 'No need to merge the results. Returning.'
  ENDIF
  
  Print, 'The final results are in level:', STRCOMPRESS(level)
  ind=INDGEN(level-1)+2
  Case type of
    'plist': BEGIN
      files=['plistupdate','lel'+STRCOMPRESS(ind,/REMOVE_ALL)+'plist_update']
    END
    'ptattr': BEGIN
    
    
      IF KEYWORD_SET(old_version) THEN BEGIN
        ; The old version. Because the iteration is based on the fomer level instead of the merged levels, indices should be updated each time.
        files=['ptattrupdate','lel'+STRCOMPRESS(ind,/REMOVE_ALL)+'ptattr_update']
        plistfiles_orig=['plist', 'lel'+STRCOMPRESS(ind,/REMOVE_ALL)+'plist']
        plistfiles_update=['plistupdate','lel'+STRCOMPRESS(ind,/REMOVE_ALL)+'plist_update']
        files=workpath+files
        plistfiles_orig=workpath+plistfiles_orig
        plistfiles_update=workpath+plistfiles_update
        npt=0
        OPENW, lun, outputfile,/GET_LUN
        plist_orig=TLI_READMYFILES(plistfiles_orig[0],type='plist')
        FOR i=0, n_elements(files)-1 DO BEGIN
          Print, STRCOMPRESS((i)),'/',STRCOMPRESS(n_elements(files)-1)
          
          ;        IF i EQ 0 THEN BEGIN
          ;          ptattr=TLI_READMYFILES(files[i], type='ptattr')
          ;          plist_update=TLI_READMYFILES(plistfiles_update[i], type='plist')
          ;          npt_i=N_ELEMENTS(ptattr)
          ;          FOR j=0D, npt_i-1D DO BEGIN
          ;            p_ind_orig=ptattr[j].parent ; Index in the last level.
          ;            IF p_ind_orig NE -1 THEN BEGIN
          ;              p_coor_orig=plist_orig[p_ind_orig] ; Coor in the last level.
          ;              p_ind_update=WHERE(plist_update EQ p_coor_orig) ; Find the index in this level.
          ;              IF p_ind_update EQ -1 THEN Message, 'This should never happen.'
          ;              ptattr[j].parent=ptattr[j].parent+npt
          ;            ENDIF
          ;          ENDFOR
          ;          npt=npt+npt_i
          ;        ENDIF ELSE BEGIN
          ;          IF i EQ 1 THEN BEGIN
          ;            ; Do nothing. But read the files.
          ;            ptattr=TLI_READMYFILES(files[i],type='ptattr')
          ;          ENDIF ELSE BEGIN
          ;            ptattr=TLI_READMYFILES(files[i], type='ptattr')
          ;            ptattr.parent=ptattr.parent+npt
          ;            npt_i=N_ELEMENTS(ptattr)
          ;            npt=npt+npt_i
          ;          ENDELSE
          ;        ENDELSE
          CASE i OF
            0: BEGIN
              ptattr=TLI_READMYFILES(files[i], type='ptattr')
              npt_i=N_ELEMENTS(ptattr)
            END
            1: BEGIN
              npt=npt+npt_i;///////////////////////////////
              ptattr=TLI_READMYFILES(files[i], type='ptattr')
              npt_i=N_ELEMENTS(ptattr)
              IF KEYWORD_SET(recursive) THEN BEGIN
                FILE_COPY, files[i-1], files[i]+'_merge',/OVERWRITE
                OPENW, wlun, files[i]+'_merge',/GET_LUN,/APPEND
                WRITEU, wlun, ptattr
                FREE_LUN, wlun
              ENDIF              
            END
            ELSE: BEGIN            
              ptattr=TLI_READMYFILES(files[i], type='ptattr')
              ptattr.parent=ptattr.parent+npt
              npt_i=N_ELEMENTS(ptattr)
              npt=npt+npt_i;///////////////////////////////              
              IF KEYWORD_SET(recursive) THEN BEGIN
                FILE_COPY, files[i-1]+'_merge', files[i]+'_merge',/OVERWRITE
                OPENW, wlun, files[i]+'_merge',/GET_LUN,/APPEND
                WRITEU, wlun, ptattr
                FREE_LUN, wlun
              ENDIF              
            END            
          ENDCASE          
          WRITEU, lun, ptattr
        ENDFOR
        Print, 'The points after merging:', STRCOMPRESS(npt)
        FREE_LUN, lun
        RETURN
      ENDIF
      
      
      
      
      
      
      files=['ptattrupdate','lel'+STRCOMPRESS(ind,/REMOVE_ALL)+'ptattr_update']
;        plistfiles_orig=['plist', 'lel'+STRCOMPRESS(ind,/REMOVE_ALL)+'plist']
;        plistfiles_update=['plistupdate','lel'+STRCOMPRESS(ind,/REMOVE_ALL)+'plist_update']
;        files=workpath+files
;        plistfiles_orig=workpath+plistfiles_orig
;        plistfiles_update=workpath+plistfiles_update
      
      
      
      
      
      
    END
    'vdh': BEGIN
      IF KEYWORD_SET(recursive) THEN BEGIN
      
        files=['vdh','lel'+STRCOMPRESS(ind,/REMOVE_ALL)+'vdh']
        files=workpath+files
        npt=0
        FOR i=0, N_ELEMENTS(files)-1 DO BEGIN
          Print, 'Merge the results. Processing files...', STRCOMPRESS(i),'/', STRCOMPRESS(N_ELEMENTS(files)-1)
          temp=TLI_READMYFILES(files[i],type='vdh')
          sz=SIZE(temp,/DIMENSIONS)
          npt_i=sz[1]
          temp[0,*]=FINDGEN(npt_i)+npt
          Case i OF
            0: BEGIN
              TLI_WRITE, files[i]+'_merge', temp
              TLI_WRITE, files[i]+'_merge.txt', temp,/txt
            END
            ELSE: BEGIN
              FILE_COPY, files[i-1]+'_merge', files[i]+'_merge',/overwrite
              TLI_WRITE, files[i]+'_merge', temp,/APPEND
              TLI_WRITE, files[i]+'_merge.txt', temp,/APPEND,/TXT
            END
            
          ENDCASE
          
          npt=npt+npt_i
        ENDFOR
        
        FILE_COPY, files[i-1]+'_merge', outputfile,/overwrite
        TLI_DAT2ASCII, outputfile, samples=5, format='double'
        RETURN
      ENDIF ELSE BEGIN
        ; Check if ptattr file exists.
        ptattrfile=FILE_DIRNAME(outputfile)+PATH_SEP()+'ptattr_merge_all'
        IF NOT FILE_TEST(ptattrfile) THEN BEGIN
          Message, 'File does not exist: ptattr_merge_all'
        ENDIF
        plistfile=FILE_DIRNAME(outputfile)+pATH_SEP()+'plist_merge_all'
        IF NOT FILE_TEST(plistfile) THEN BEGIN
          Message, 'File does not exist: plist_merge_all'
        ENDIF
        npt=TLI_PNUMBER(plistfile)
        plist=TLI_READMYFILES(plistfile,type='plist')
        ptattr=TLI_READMYFILES(ptattrfile,type='ptattr')
        ind=DINDGEN(1, npt)
        x=REAL_PART(plist)
        y=IMAGINARY(plist)
        v=ptattr.v
        dh=ptattr.dh
        vdh=[ind, x,y,TRANSPOSE(v),TRANSPOSE(dh)]
        OPENW, lun, outputfile,/GET_LUN
        WRITEU, lun, vdh
        FREE_LUN, lun
        RETURN
      ENDELSE
      
      
    END
    
    ELSE: BEGIN
      Message, 'Error: File type not supported!'
    END
  ENDCASE
  
  
  files=workpath+files
  OPENW, lun, outputfile,/GET_LUN
  FOR i=0,level-1 DO BEGIN
    Print, STRCOMPRESS(i), '/', STRCOMPRESS(level-1)
    temp=TLI_READMYFILES(files[i], type=type)
    
    IF KEYWORD_SET(recursive) THEN BEGIN
      IF i EQ 0 THEN BEGIN
        FILE_COPY, files[i], files[i]+'_merge',/OVERWRITE
      ENDIF ELSE BEGIN
        FILE_COPY, files[i-1]+'_merge',files[i]+'_merge',/OVERWRITE
        OPENW, wlun, files[i]+'_merge',/APPEND,/GET_LUN
        WRITEU, wlun, temp
        FREE_LUN, wlun
      ENDELSE
    ENDIF
    
    WRITEU, lun, temp
  ENDFOR
  FREE_LUN, lun
  
END