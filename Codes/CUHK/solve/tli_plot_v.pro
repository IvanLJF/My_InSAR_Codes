PRO TLI_PLOT_V, vdhfile
  
  v= TLI_READDATA(vdhfile, samples=5, format='DOUBLE')
  x= v[1,*]
  y= v[2,*]
  z= v[3,*]
  show_z= BYTSCL(z) 
  Print, '[max min] of z:',MAX(z), MIN(z)
  LOADCT, 33, RGB_TABLE= COLORS
  IPLOT,  x, y,VERT_COLORS=TRANSPOSE(COLORS[show_z, *]), LINESTYLE=6, SYM_SIZE=0.3, SYM_INDEX=1, $
    TITLE=vfile;, RGB_TABLE=COLORS,INSERT_COLORBAR=[-0.5,-0.9]
END