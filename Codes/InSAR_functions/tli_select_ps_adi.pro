; 
; Select PSs using ADI
; 
; Parameters: 
;   imlistfile   : TXT file containing all of the pwr file.
;
; Keywords:
;   adi          : Amplitude dispersion index threshold. Ommitted value is 0.25.
;   amp          : Amplitude threshold. Ommitted value is 1.
;   plistfile    : Output results. Two other files are provied: plistfile.txt, plistfile.gamma
;   
; Written by:
;   T.LI @ SWJTU, 20140331
; 
PRO TLI_SELECT_PS_ADI, imlistfile, adi=adi, amp=amp, plistfile=plistfile,force=force
  
  IF KEYWORD_SET(plistfile) THEN BEGIN
    workpath=FILE_DIRNAME(plistfile)+PATH_SEP()
  ENDIF ELSE BEGIN
    workpath=FILE_DIRNAME(imlistfile)+PATH_SEP()
  ENDELSE
  
  adifile=workpath+'adi'
  ampfile=adifile+'_mean_amp'
  
  IF N_ELEMENTS(adi) EQ 0 THEN adi=0.25
  IF N_ELEMENTS(amp) EQ 0 THEN amp=1
  IF NOT KEYWORD_SET(plistfile) THEN plistfile=workpath+'plist'
  pwr=''
  OPENR, lun, imlistfile,/GET_LUN
  READF, lun, pwr
  FREE_LUN, lun
  finfo=TLI_LOAD_SLC_PAR(pwr+'.par')
  ; Create files  
  TLI_HPA_DA, imlistfile, samples=finfo.range_samples, format=finfo.image_format,/swap_endian,outputfile=workpath+'adi',force=force
  
  ; Select using ADI
  adi_all=TLI_READDATA(adifile, samples=finfo.range_samples, format='float')
  amp_all=TLI_READDATA(ampfile, samples=finfo.range_samples, format='float')
  mean_amp=MEAN(amp_all)
  plist=WHERE(adi_all LE adi AND amp_all GE mean_amp*DOUBLE(amp))
  IF plist[0] EQ -1 THEN Message, 'TLI_SELECT_PS_ADI: Error! No valid point found within the given threshold.'
  plist=ARRAY_INDICES(adi_all, plist)
  
  TLI_WRITE, plistfile+'.gamma', plist,/SWAP_ENDIAN
  TLI_WRITE, plistfile+'.txt', plist,/TXT
  TLI_WRITE, plistfile, COMPLEX(plist[0, *], plist[1, *])
  
  npt=TLI_PNUMBER(plistfile)
  Print, 'Number of PSs:', npt
  
END