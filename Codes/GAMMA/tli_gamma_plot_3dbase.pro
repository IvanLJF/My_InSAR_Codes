@tli_hpa_checkfiles
Function TLI_GAMMA_SBASE_VECS, sarlistfile, itabfile, basepath,insert_master=insert_master
; sarlistfile   : sarlistfile
; itabfile      : itabfile
; basepath      : Path for baselines
; insert_master : Insert master baseline vectors for every line.

  IF ~TLI_HAVESEP(basepath) THEN basepath=basepath+PATH_SEP()
  int_pairs=TLI_GAMMA_INT(sarlistfile, itabfile,/DATE)
  basenames=STRCOMPRESS(STRJOIN(int_pairs, '-')+'.txt',/REMOVE_ALL)
  nintf=FILE_LINES(itabfile)
  ; Read files
  vects=DBLARR(3)
  FOR i=0, nintf-1 DO BEGIN
    IF KEYWORD_SET(insert_master) THEN vects=[[vects], [0,0,0]]
    file_i=basepath+basenames[i]
    IF NOT FILE_TEST(file_i) THEN Message, 'Error, No such file:'$
      +STRING(13b)+file_i
    OPENR, lun, file_i,/GET_LUN
    ; Jump 4 lines. Read the 5-th line.
    FOR j=0, 4 DO BEGIN
      temp=''
      READF, lun, temp
    ENDFOR
    FREE_LUN, lun
    temp=STRSPLIT(temp, ' ',/extract)
    ntemp=N_ELEMENTS(temp)
    vects=[[vects],[(temp[ntemp-1-2:ntemp-1])]]
  ENDFOR
  RETURN, vects[*, 1:*]
END



PRO TLI_GAMMA_PLOT_3DBASE

  workpath='K:\Software\ForExperiment\TSX_PS_SH'
  
  workpath=workpath+PATH_SEP()
  hpapath=workpath+'HPA'+PATH_SEP()
  basepath=hpapath+'base'+PATH_SEP()
  resultpath='D:\myfiles\相关论文\Modern_Transportation\图表\'
  
  sarlistfile=workpath+'sarlist_Win'
  itabfile=workpath+'itab'
  nintf=FILE_LINES(itabfile)
  ; Get the 3-D vectors of baselines.
  vects_insert=TLI_GAMMA_SBASE_VECS(sarlistfile, itabfile,basepath,/insert_master)
  vects=TLI_GAMMA_SBASE_VECS(sarlistfile, itabfile,basepath)
  ; Get the temporal baselines
  tb=TBASE_ALL(sarlistfile, itabfile)
  
  ; The slave date
  s_dates=TLI_GAMMA_INT(sarlistfile, itabfile,/onlyslave,/date)
  
  results=[TRANSPOSE(s_dates), tb, vects]
  
  TLI_WRITE, resultpath+'baseline_vects.txt',results,/txt
  TLI_WRITE, resultpath+'baseline_vects_insert.txt',vects_insert,/txt
  ; Plot data
  x=vects[0,*]
  y=vects[1,*]
  z=vects[2,*]
  fig=PLOT3D(x,y,z,linestyle=6, symbol='S',symsize=2.0,/SYM_FILLED, $
             axis_style=1,/perspective,SHADOW_COLOR='deep sky blue', $
             xy_shadow=0, yz_shadow=0, xz_shadow=0, xtitle='x', ytitle='y', ztitle='z')
;  ax=fig.axes
;  ax[2].hide=1
;  ax[6].hide=1
;  ax[7].hide=1
  ; Plot the baselines
  FOR i=0, nintf-1 DO BEGIN
    start_coor=[0,0,0]
    end_coor=vects[*, i]
    x=[start_coor[0],end_coor[0]]
    y=[start_coor[1],end_coor[1]]
    z=[start_coor[2],end_coor[2]]
    fig=PLOT3D(x,y,z,/overplot,SHADOW_COLOR='deep sky blue', $
             xy_shadow=1, yz_shadow=1, xz_shadow=1)
  
  ENDFOR
  STOP
END