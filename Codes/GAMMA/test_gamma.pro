PRO TEST_GAMMA

  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA'
  ptmapfile=workpath+'/plistupdate_GAMMA'
  ptmap=TLI_READDATA(ptmapfile,format='LONG',samples=2, /swap_endian)
  x=ptmap[0,*]
  y=ptmap[1,*]
  xmin=MIN(x,max=xmax)
  ymin=MIN(y, max=ymax)
  Print, 'X range:', xmin, xmax
  Print, 'Y range:', ymin, ymax
END
