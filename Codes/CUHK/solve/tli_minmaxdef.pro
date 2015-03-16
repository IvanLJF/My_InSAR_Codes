PRO TLI_MINMAXDEF
  
  vdhfile= '/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/vdh'

 v= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
  x= v[1,*]
  y= v[2,*]
  z= v[3,*]
  Print, '[max min] of v:',MAX(z), MIN(z)
  
  z_std= STDDEV(z)
  z_m= MEAN(z)
  
  ind= WHERE((z GE z_m-z_std*3) AND (z LE z_m+3*z_std))
  
  z_n= z[*, ind]
  Print, '[max min] of v(optimized):',MAX(z_n), MIN(z_n)
  Print, 'STD of v(optimized):', STDDEV(z_n)
  
  z= v[4,*]
  Print, '[max min] of dh:',MAX(z), MIN(z)
  
  z_std= STDDEV(z)
  z_m= MEAN(z)
  
  ind= WHERE((z GE z_m-z_std*3) AND (z LE z_m+3*z_std))
  
  z_n= z[*, ind]
  Print, '[max min] of dh(optimized):',MAX(z_n), MIN(z_n)
  Print, 'STD of dh(optimized):', STDDEV(z_n)

END