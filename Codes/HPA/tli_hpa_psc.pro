; Select PSC using DA and amplitude.
; 
;- sarlistfile: sarlist file
;- da       : threshold of DA
;- amp      : threshold of amplitude=amp*mean(amp)
;- dafile   : DA map.
;- ampfile  : mean amp. map.
;- outputfile: PSC.

@tli_load_slc_par_sarlist
@tli_hpa_da

PRO TLI_HPA_PSC,sarlistfile, da=da, amp=amp, tempfile=tempfile, outputfile=outputfile

  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  workpath=FILE_DIRNAME(sarlistfile)+PATH_SEP()
  
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=workpath+'plist'
  IF NOT KEYWORD_SET(da) THEN da=0.25
  IF NOT KEYWORD_SET(amp) THEN amp=1
  IF NOT KEYWORD_SET(tempfile) THEN tempfile=outputfile+'.da'
  ampfile=tempfile+'_mean_amp'
  ; Generate DA file and ampfile
  TLI_HPA_DA, sarlistfile,outputfile=tempfile,/force
; Choose points.
  data=TLI_READDATA(tempfile, samples=finfo.range_samples, format='float')
  psc=WHERE(data LE da)
  IF psc[0] EQ -1 THEN Message, 'Error: da is too small.'
  data=TLI_READDATA(ampfile, samples=finfo.range_samples, format='float')
  mean_amp=MEAN(data)
  data=data[psc]
  data_ind=WHERE(data GE mean_amp*amp)
  IF data_ind[0] EQ -1 THEN Message, 'Error: amp is too small.'
  psc=psc[data_ind]
  
  
  psc= COMPLEX((psc MOD finfo.range_samples), FLOOR(psc/finfo.range_samples))
  
  psc=TRANSPOSE(psc)
  
  OPENW, lun, outputfile,/GET_LUN
  WRITEU, lun, psc
  FREE_LUN, lun
END