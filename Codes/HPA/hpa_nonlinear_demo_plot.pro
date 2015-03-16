;-
;- Explain the NONLINAER Filtering for Prof. Liu
;-
;PRO TLI_PLOT_NETWORK_PROFLIU, arcfile, xrange=xrange, yrange=yrange
;
;  ; Read the arcs file
;  arcs=TLI_READMYFILES(arcfile, type='arcs') ; start_coor, end_coor, [start_ind, end_ind]
;  
;  ; Plot the arcs
;  arcs_no=TLI_ARCNUMBER(arcfile)
;  scale=1
;  FOR i=0, arcs_no-1 DO BEGIN
;    coor= arcs[*, i]*scale
;    IF i EQ 0 THEN BEGIN
;      ; Prepare the image basemap.
;      temp=PLOT([REAL_PART(coor[0]),REAL_PART(coor[1])], [IMAGINARY(coor[0]), IMAGINARY(coor[1])], $
;        xrange=xrange, yrange=yrange,line_style=0, position=[0.1,0.1,0.9,0.9],$
;        xminor=0,yminor=0)
;        
;    ENDIF ELSE BEGIN
;    
;      temp=PLOT([REAL_PART(coor[0]),REAL_PART(coor[1])], [IMAGINARY(coor[0]), IMAGINARY(coor[1])], $
;        /overplot)
;    ENDELSE
;    
;  ENDFOR
;END

PRO HPA_NONLINEAR_DEMO_PLOT
  COMPILE_OPT idl2
  workpath='D:\myresults\HPA\'
  plistfile=workpath+'plist2013_7_30_22_30_19'
  arcfile=workpath+'arc'
  ; Generate some uniformly distributed points.
  npt=30
  x= RANDOMU(seed, 1,npt)
  x= TLI_STRETCH_DATA(x, [0, 499])
  
  y= RANDOMU(seed, 1,npt)
  y= TLI_STRETCH_DATA(y, [0, 499])
  
  plist=COMPLEX(x, y)
  
  ; Add four corners
  corners=COMPLEX([10,10,490,480], [20,490,10,490])
  plist=[[plist], [TRANSPOSE(corners)]]
  
  ;  TLI_WRITE, plistfile,plist
  plist=TLI_READMYFILES(plistfile, type='plist')
  ; Generate the Delaunay network.
  result=TLI_DELAUNAY(plistfile,outname=arcfile,0,0,dist_thresh=1000)
  
  ; Plot the network.
  xrange=[0,499]
  yrange=[0,499]
;  TLI_PLOT_NETWORK, arcfile, xrange=xrange, yrange=yrange
  
  ; Find exact pt coor for (300, 300)
  center_coor=COMPLEX(300, 300)
  dis=ABS(plist-center_coor)
  min_dis=MIN(dis, center_ind)  
  center_coor=plist[center_ind]
  arcs=TLI_READMYFILES(arcfile,type='arcs')
  dis_start=ABS(arcs[0,*]-center_coor)
  dis_end=ABS(arcs[1, *]-center_coor)
  dis_thresh=150
  ind=WHERE(dis_start LE dis_thresh AND dis_end LE dis_thresh)
  arcs=arcs[*, ind]
  TLI_WRITE, arcfile+'subset', arcs
  all_coors=arcs[0:1, *]
  x=REAL_PART(all_coors) &  y=IMAGINARY(all_coors)
  minx=MIN(x, max=maxx) & miny=MIN(y, max=maxy)
  border=20
  xrange=[minx-border, maxx+border]
  yrange=[miny-border, maxy+border]
;  TLI_PLOT_NETWORK_PROFLIU, arcfile+'subset', xrange=xrange, yrange=yrange
  
  ; Find (260, 200)   -   (318,281)
  coor_UR=TLI_PROX_PT_SINGLE(COMPLEX(260,200), plist)
  ; Plot a line to connect center_coor and coor_UR
  coors=[center_coor, coor_UR]
  temp=PLOT(REAL_PART(coors), IMAGINARY(coors), xrange=[250, 330],yrange=[180, 300] )
  
  STOP
END