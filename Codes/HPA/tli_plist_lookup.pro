; Create a lookup file. The elements in lookup is the same as that in plistfile_orig
; Find each point of plist_orig in plist_update.
;
; Parameters:
;  plistfile_orig  : Original plist file.
;  plistfile_update: Updated plist file.
;
; Keywords:
;  outputfile      : The lookup table file. Double arr, 2 lines.
;
; Written by:
;  T.LI @ SWJTU,
;
; History:
;  T.LI @ SWJTU
;  - Introduce tli_sort_complex to accomplish a fast lookup table creation., 20140225.
;
@tli_sort_complex
PRO TLI_PLIST_LOOKUP, plistfile_orig, plistfile_update, outputfile=outputfile

  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=FILE_DIRNAME(plistfile_orig)+PATH_SEP()+FILE_BASENAME(plistfile_orig) $
      +STRCOMPRESS(2,/REMOVE_ALL)+FILE_BASENAME(plistfile_update)
  ENDIF
  
  npt_orig=TLI_PNUMBER(plistfile_orig)
  npt_update=TLI_PNUMBER(plistfile_update)
  lookup=DBLARR(2, npt_orig)
  plist_orig=TLI_READMYFILES(plistfile_orig,type='plist')
  plist_update=TLI_READMYFILES(plistfile_update, type='plist')
  
  ;  ; For validation purpose
  ;  FOR i=0D, npt_orig-1D DO BEGIN
  ;    IF ~(i MOD 1000) THEN BEGIN
  ;      Print, 'Creating lookup table for two plist files.', STRCOMPRESS(i)+'/'+STRCOMPRESS(npt_orig-1)
  ;    ENDIF
  ;    ptcoor=plist_orig[i]
  ;    ind_update=WHERE(plist_update EQ ptcoor) ; If there is no according pts, return -1.
  ;    lookup[*, i]=[i, ind_update]
  ;  ENDFOR
  ;  TLI_WRITE, outputfile+'original', lookup
  
  ; Check the uniqness of the two input plistfiles.
  npt_orig_temp=N_ELEMENTS(UNIQ(plist_orig[SORT(plist_orig)]))
  npt_update_temp=N_ELEMENTS(UNIQ(plist_update[SORT(plist_update)]))
  
  IF npt_orig NE npt_orig_temp THEN Message, 'Error! We believe that there are dunplicated elements in the file:' $
    +plistfile_orig
  IF npt_update NE npt_update_temp THEN Message, 'Error! We believe that there are dunplicated elements in the file:' $
    +plistfile_update
    
  ; Sort the two plist.
  ind_orig=LINDGEN(npt_orig)
  plist_orig=TLI_SORT_COMPLEX(plist_orig, ind=ind_temp)
  ind_orig=ind_orig[ind_temp]
  
  ind_update=LINDGEN(npt_update)
  plist_update=TLI_SORT_COMPLEX(plist_update, ind=ind_temp)
  ind_update=ind_update[ind_temp]
  
  ; Create the lookup table
  j=0D
  result=[0,0]
  FOR i=0D, npt_orig-1D DO BEGIN
    
    IF ~(i MOD 100000) THEN Print, 'Creating the lookup table for two plist files:'+STRCOMPRESS(i)+'/'+STRCOMPRESS(npt_orig-1D)
    ; Compare the real part
    plist_i_orig=[REAL_PART(plist_orig[i]), IMAGINARY(plist_orig[i])]
    goon=1
    
    IF j GE npt_update THEN BEGIN
      ; No need to go on
      goon=0
      ; Assign the value
      result=[i, -1]
      lookup[*, i]=result
      continue
    ENDIF
    
    
    
    While goon DO BEGIN
    
      IF j GE npt_update THEN BEGIN
        ; No need to go on
        goon=0
        ; Assign the value
        result=[i, -1]
        lookup[*, i]=result
        Break
      ENDIF
      
      
      
      plist_j_update=[REAL_PART(plist_update[j]), IMAGINARY(plist_update[j])]
      IF plist_i_orig[1] LT plist_j_update[1] THEN BEGIN
        result=[ind_orig[i], -1] ; There is no according PTs. Return -1.
        ; Do not add 1 to j
        ; Do not go on.
        ;        goon=0
        
        ; Assign value
        lookup[*, i]=result
        break
      ENDIF ELSE BEGIN
        IF plist_i_orig[1] NE plist_j_update[1] THEN BEGIN ; The imaginary parts are not equal.
          ; Add 1 to j
          j=j+1D
        ; Go on
        ; Do not assign value
        ENDIF ELSE BEGIN ; The imaginary parts are equal.
          IF plist_i_orig[0] LT plist_j_update[0] THEN BEGIN
            result=[ind_orig[i], -1]
            ; Do not add 1 to j
            ; Do not go on
            ;            goon=0
            
            ; Assign value
            lookup[*, i]= result
            break
          ENDIF ELSE BEGIN
            IF plist_i_orig[0] NE plist_j_update[0] THEN BEGIN ; The real parts are not equal.
              ; Add 1 to j
              j=j+1D
              ; Do not assign value
           
            ; Go on
            ENDIF ELSE BEGIN  ; The real parts are equal
              result=[ind_orig[i], ind_update[j]]
              ; Add 1 to j
              j=j+1D
              ; Assign value
              lookup[*, i]=result
              ; Do not go on
              ;              goon=0
              break
            ENDELSE
            
          ENDELSE
          
          
        ENDELSE
        
      ENDELSE
      
      
      
      
    ENDWHILE
    
    
    
  ENDFOR
  
  
  
  
  lookup=lookup[*, SORT(lookup[0,*])]
  
  IF 0 THEN BEGIN
    ; Check the result
    plist_orig=TLI_READMYFILES(plistfile_orig,type='plist')
    plist_update=TLI_READMYFILES(plistfile_update, type='plist')
    plist_update=[[plist_update], [COMPLEXARR(1, npt_orig-npt_update)]]
    TLI_WRITE, plistfile_orig+'_compare.txt', [plist_orig, plist_update],/TXT
    TLI_WRITE, outputfile+'.txt', lookup,/txt
  ENDIF
  
  
  TLI_WRITE, outputfile, lookup
END