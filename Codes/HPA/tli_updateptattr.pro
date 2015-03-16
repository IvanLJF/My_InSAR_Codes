;-
;- Update ptattr file according to plist file
;-  
;- inputfile                : File to update
;- plistfile_orig           : The plist file used to calculate this ptattrfile.
;- plistfile_update         : The updated version of the plistfile. 
;-                            plistfile_orig and plistfile_update are all used for level1.
;- outputfile               : inputfile+'_update'
;- change_weight_to_level    : Change the filed 'weight' to 'level' , just for level 1.
;-
;- Changed by T. LI @ ISEIS, 20130705
PRO TLI_UPDATEPTATTR, inputfile, plistfile_orig=plistfile_orig, plistfile_update=plistfile_update, outputfile=outputfile,$
                      change_weight_to_level=change_weight_to_level

  IF  N_PARAMS() NE 1 THEN BEGIN
    Message, 'Usage ERROR!'
  ENDIF
  ;  ON_ERROR, 2
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=inputfile+'.update'
  ENDIF
  
  IF KEYWORD_SET(plistfile_orig) THEN BEGIN; Not the first level
    ; The new version
    ; Read the files
    plist=TLI_READMYFILES(plistfile_orig,type='plist')
    plist_update=TLI_READMYFILES(plistfile_update, type='plist')
    ptattr=TLI_READMYFILES(inputfile,type='ptattr')
    ind=WHERE(ptattr.accepted EQ 1)
    npt=N_ELEMENTS(ind)
    ptattr=ptattr[ind]
    FOR i=0D, npt-1D DO BEGIN
      IF ~(i MOD 1000) THEN Print, 'Updating the ptattrfile, processing:', STRCOMPRESS(i),'/', STRCOMPRESS(npt-1D)
      p_ind=ptattr[i].parent
      IF p_ind EQ -1 THEN BEGIN
        CONTINUE
      ENDIF
      p_coor=plist[p_ind]
      p_ind_true=WHERE(plist_update EQ p_coor) ; p_ind_true there is and only one.
      IF p_ind_true EQ -1 THEN Message, 'Error: There should be and only be one p_ind_true'
      ptattr[i].parent=p_ind_true
    ENDFOR
    IF KEYWORD_SET(change_weight_to_level) THEN ptattr.weight=1
    OPENW, lun, outputfile,/GET_LUN
    WRITEU, lun, ptattr
    FREE_LUN, lun
  ENDIF ELSE BEGIN
  
  
    ; The old version
    pt_attr= TLI_READMYFILES(inputfile,type='ptattr')
    
    index= WHERE(pt_attr.accepted EQ 1)
    pt_attr=pt_attr[index]
    OPENW, lun, outputfile,/GET_LUN
    WRITEU, lun, pt_attr
    FREE_LUN, lun
  ENDELSE
END