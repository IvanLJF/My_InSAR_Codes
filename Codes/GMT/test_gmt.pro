PRO TEST_GMT
  
  workpath='/mnt/backup/ExpGroup/TSX_PS_HK_DAM/WSD_Points/'
  sarlistfile=workpath+'sarlist'
  file=workpath+'plot_info'

  samples=1700
  mul=50
  nlines=FILE_LINES(file)
  str=STRARR(1, nlines)
  OPENR, lun, file,/GET_LUN
  READF, lun, str
  FREE_LUN, lun
  
  main_lel=str[*, 1:11] 
  main_lel=TLI_STRSPLIT(main_lel,/DOUBLE)
  main_lel[1, *]=samples-main_lel[1, *]
  main_lelc=COMPLEX(main_lel[0,*], main_lel[1, *])
  
  main_ps=str[*, 13:23] 
  main_ps=TLI_STRSPLIT(main_ps,/DOUBLE)
  main_ps[1, *]=samples-main_ps[1,*]
  main_psc=COMPLEX(main_ps[0,*], main_ps[1, *])
  
  main_offset=TLI_COOR2OFFSET([main_lelc, main_psc],dpi=500, mul=mul)
  TLI_WRITE,workpath+'main_offset', [main_lel, main_offset],/txt
    
  rr_lel=str[*, 25:51] 
  rr_lel=TLI_STRSPLIT(rr_lel,/DOUBLE)
  rr_lel[1, *]=samples-rr_lel[1, *]
  rr_lelc=COMPLEX(rr_lel[0,*], rr_lel[1, *])
  
  rr_ps=str[*, 53:*] 
  rr_ps=TLI_STRSPLIT(rr_ps,/DOUBLE)
  rr_ps[1, *]=samples-rr_ps[1, *]
  rr_psc=COMPLEX(rr_ps[0,*], rr_ps[1, *])
  
  rr_offset=TLI_COOR2OFFSET([rr_lelc, rr_psc],dpi=500, mul=mul)
  TLI_WRITE, workpath+'rr_offset',[rr_lel, rr_offset],/txt
  Print, 'Main pro finished.'
  
END