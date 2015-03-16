@tli_defingoogle
PRO TLI_DEFINGOOGLE_GAMMA, pmapllfile, pdeffile, pmaskfile=pmaskfile, cptfile=cptfile,  colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
    maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
    refine_data=refine_data,delta=delta,refined_data=refined_data, minus=minus
  ;, pmapllfile, vdhfile, cptfile=cptfile,  colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
  ;    maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
  ;    refine_data=refine_data,delta=delta,refined_data=refined_data

  ; Create a pusdo vdhfile
  pmapll=TLI_READDATA(pmapllfile, samples=1, format='FCOMPLEX',/swap_endian)
  npt=N_ELEMENTS(pmapll)
  pdef=(TLI_READDATA(pdeffile, samples=1, format='Float',/swap_endian))*1000  ; Change the unit from m/yr to mm/yr.
  IF npt NE N_ELEMENTS(pdef) THEN BEGIN
    Message, 'The number of the points are not the same.'+STRING(13b)+$
      'Please check the files:'+STRING(13b)+$
      pmapllfile+STRING(13b)+$
      pdeffile
  ENDIF
  indices=DINDGEN(npt)
  IF KEYWORD_SET(pmaskfile) THEN BEGIN
    pmask=TLI_READDATA(pmaskfile,samples=1, format='BYTE',/swap_endian)
    indices=WHERE(pmask EQ 1)
    IF indices[0] EQ -1 THEN Message, 'There is no points accepted by pmaskfile:'+pmaskfile
  ENDIF
  pmapll=pmapll[*, indices]
  pdef=pdef[*, indices]
  npt=N_ELEMENTS(indices)
  vdhfile=pdeffile+'.tempvdh'
  vdh=DBLARR(5, npt)
  vdh[3, *]=pdef
  TLI_WRITE, vdhfile, vdh
  TLI_WRITE, pmapllfile+'.tmp', (pmapll),/swap_endian
  
  ; Call tli_defingoogle to plot
  TLI_DEFINGOOGLE,pmapllfile+'.tmp', vdhfile, cptfile=cptfile,  colorbarfile=colorbarfile, kmlfile=kmlfile, phgtfile=phgtfile, gamma=gamma,$
    maxv=maxv, minv=minv,colortable_name=colortable_name,unit=unit,color_inverse=color_inverse,vacuate=vacuate,npt_final=npt_final,$
    refine_data=refine_data,delta=delta,refined_data=refined_data, minus=minus
   FILE_DELETE, pmapllfile+'.tmp'
END