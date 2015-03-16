@tli_hpa_checkfiles
PRO TLI_REFRESH_MSK, HPAPATH, level=level

  IF ~KEYWORD_SET(level) THEN level=3
  IF ~TLI_HAVESEP(hpapath) THEN hpapath=hpapath+PATH_SEP()
  ; Create a mask file
  mskfile=hpapath+'msk'
  sarlistfile=hpapath+'sarlist'
  IF ~FILE_TEST(sarlistfile) THEN sarlistfile=hpapath+'sarlist_Linux'
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  IF FILE_TEST(mskfile) THEN FILE_DELETE, mskfile
  ; Update it
  Print, 'Updating the mask file, please wait...'
  FOR i=2, level DO BEGIN
    files=TLI_HPA_FILES(hpapath, level=i-1)
    vdhfile=files.vdh
    TLI_UPDATEMSK, mskfile, vdhfile, finfo.range_samples, finfo.azimuth_lines
  ENDFOR
  
END