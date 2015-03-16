PRO SHOW_REALPHASE_PDF

  plist= 'D:\ForExperiment\PALSAR_PS_Beijing\piece\plist' ; GAMMA plist file
  psno= TLI_PNUMBER(plist)
  pscoor= LONARR(2, psno)
  OPENR, lun, plist,/GET_LUN, /SWAP_ENDIAN
  READU, lun, pscoor
  FREE_LUN, lun
  
  
END