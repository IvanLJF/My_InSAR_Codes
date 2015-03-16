@tli_hpa_checkfiles
PRO TLI_HPA_PDIFF, hpapath, plistfile,master, $
    plistfile_GAMMA=plistfile_GAMMA, pdifile_GAMMA=pdifile_GAMMA, pdifffile=pdifffile, force=force
    
  COMPILE_OPT idl2
  IF N_PARAMS() NE 3 THEN BEGIN
    Message, 'Error!'
  ENDIF
  
  path_havesep=TLI_HAVESEP(hpapath)
  IF NOT path_havesep THEN BEGIN
    hpapath=hpapath+PATH_SEP()
  ENDIF
  
  IF NOT KEYWORD_SET(plistfile_GAMMA) THEN BEGIN
    plistfile_GAMMA=plistfile+'_GAMMA'
  ENDIF
  IF NOT KEYWORD_SET(pdifile_GAMMA) THEN BEGIN
    pdifile_GAMMA=plistfile_GAMMA+'.pdiff'
  ENDIF
  IF NOT KEYWORD_SET(pdifffile) THEN BEGIN
    pdifffile=pdifffile+'pdiff.swap'
  ENDIF
  
  pdiffshfile=hpapath+'hpa_pdiff.sh'
  ; Check files
  npt=TLI_PNUMBER(plistfile)
  ppath=FILE_DIRNAME(hpapath)+PATH_SEP()
  itabfile=ppath+'itab'
  hgtfile=ppath+STRCOMPRESS(master,/REMOVE_ALL)+'.hgt'
  IF NOT FILE_TEST(itabfile) THEN Message, 'Error: file not found:'+itabfile
  IF NOT FILE_TEST(hgtfile) THEN Message, 'Error: file not found:'+hgtfile
  nintf=FILE_LINES(itabfile)
  fsize=npt*nintf*8
  IF FILE_TEST(pdifffile) THEN BEGIN
    finfo=FILE_INFO(pdifffile)
    IF finfo.size EQ fsize THEN BEGIN
      IF NOT KEYWORD_SET(force) THEN BEGIN
        Print, 'The file is believed to be created before. No duplicated file written.'
        Print, 'If you want to do the process again, please add the keyword "/force"'
        RETURN
      ENDIF
    ENDIF
  ENDIF
  
  
  TLI_GAMMA2MYFORMAT_PLIST, plistfile, plistfile_GAMMA,/REVERSE
  
  Print, 'Calculating the differential phase for each point. Please wait...'
  Print, 'Workpath:', hpapath
  Print, 'Point list file:', plistfile
  Print, 'Outputfile:',pdifffile
  OPENW, lun, pdiffshfile,/GET_LUN
  PrintF, lun,'#! /bin/sh'
  PrintF, lun,''
  PrintF, lun,'source gamma_source.sh'
  PrintF, lun,'ptfile='+plistfile_GAMMA
  PrintF, lun,'master='+STRCOMPRESS(master,/REMOVE_ALL)
  PrintF, lun,'pdifffile='+pdifile_GAMMA
  PrintF, lun,'pdifffile_swap='+pdifffile
  PrintF, lun,'mslc_par=../piece/$master.rslc.par'
  PrintF, lun,'masterpwr=../piece/$master.rslc.pwr'
  PrintF, lun,''
  PrintF, lun,'type=0'
  PrintF, lun,"format=$(awk '"+'$1 == "image_format:"'+" {print $2}' $mslc_par)"
  PrintF, lun,'if [ "$format"=="SCOMPLEX" ]'
  PrintF, lun,'then'
  PrintF, lun,' type=1'
  PrintF, lun,'fi'
  PrintF, lun,''
  PrintF, lun,'rm -f pSLC pbase pdem pint psim_unw0 $pdifffile'
  PrintF, lun,'SLC2pt ../SLC_tab $ptfile - pSLC_par pSLC -'
  PrintF, lun,'base_orbit_pt pSLC_par ../itab - pbase'
  PrintF, lun,'npt $ptfile >numberp'
  PrintF, lun,"np=$(awk '"+'$1 == "total_number_of_points:"'+" {print $2}' numberp)"
  PrintF, lun,'rm -f numberp'
  PrintF, lun,'data2pt ../$master.hgt $masterpwr.par $ptfile $mslc_par pdem 1 2'
  PrintF, lun,'intf_pt $ptfile - ../itab - pSLC pint $type pSLC_par'
  PrintF, lun,'# pdismph_pwr24 pt - $mslc_par pint 25 $masterpwr.par ave.pwr 1 '
  PrintF, lun,'phase_sim_pt $ptfile - pSLC_par - ../itab - pbase pdem psim_unw0 - 0 0 '
  PrintF, lun,'sub_phase_pt $ptfile - pint - psim_unw0 $pdifffile 1 0'
  PrintF, lun,'swap_bytes $pdifffile $pdifffile_swap 4'
  PrintF, lun, 'rm -f pint psim_unw0 $pdifffile'
  FREE_LUN, lun
  
  cd, hpapath
  SPAWN, pdiffshfile
END