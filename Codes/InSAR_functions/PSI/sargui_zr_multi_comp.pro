FUNCTION TLI_OFFSET_TLB,width=width, height=height
  ;Return the offset value of the top level button.
  IF NOT KEYWORD_SET(width) THEN width=0
  IF NOT KEYWORD_SET(height) THEN height=0
  
  screensize=GET_SCREEN_SIZE()
  c_pos=screensize/2
  tlb_size=[width, height]
  offset=c_pos-tlb_size/2
  RETURN, offset
END

PRO TLI_SARGUI_FILE_COPY,sourcedir, targetdir,nochange=nochange, move=move

  files=FILE_SEARCH(sourcedir, '*')
  find=STRMID(files, 0,1)
  
  find_final=SORT(find)
  nfiles=N_ELEMENTS(find_final)
  
  FOR i=0, nfiles-1 DO BEGIN
  
    fname_i=FILE_BASENAME(files[i])
    fname_orig=fname_i
    str_len=STRLEN(fname_i)
    fname_i=STRMID(fname_i, 2, str_len-2)
    fname_tar=targetdir+PATH_SEP()+fname_i
    
    IF KEYWORD_SET(nochange) THEN fname_tar=targetdir+PATH_SEP()+fname_orig
    
    IF KEYWORD_SET(move) THEN BEGIN
      fname_tar=targetdir+PATH_SEP()+fname_orig
      FILE_MOVE, files[i], fname_tar,/overwrite
    ENDIF ELSE BEGIN
      FILE_COPY, files[i], fname_tar,/overwrite
    ENDELSE
  ;    wait, 0.5
  ENDFOR
  
  
END

PRO SARGUI_ZR_MULTI_COMP,EVENT
  ; First, call the dialog to pick up the work path
  infile=dialog_pickfile(title='选择工作路径',/directory);选取工作路径
  IF infile EQ '' THEN RETURN
  CD, infile
  IF NOT TLI_HAVESEP(infile) THEN infile=infile+PATH_SEP()
  subdir=infile+'zr_multi_comp'
  imgdir=subdir+PATH_SEP()+'img'
  imgfile=imgdir+PATH_SEP()+'*.jpg
  
  IF NOT TLI_HAVESEP(subdir) THEN subdir=subdir+PATH_SEP()
  
  vfile=subdir+'zr_v'
  dvfile=subdir+'zr_dv'
  seasonfile=subdir+'zr_season'
  
  
  tempdir='D:\myfiles\Software\experiment\tempdata\zr_components'
  tempimgdir='D:\myfiles\Software\experiment\tempdata\zr_components_img'
  ; Second, data preparation
  offset=TLI_OFFSET_TLB(width=300,height=100)
  wtlb = WIDGET_BASE(title = '进度条',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='数据预处理')
  
  IF NOT FILE_TEST(subdir) THEN FILE_MKDIR, subdir
  IF NOT FILE_TEST(imgdir) THEN FILE_MKDIR, imgdir
  
  Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0  wait, 1
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 50;-进度条进度调整
  wait, 0.1
  
  
  wait, 5
  Idlitwdprogressbar_setvalue, process, 98;-进度条进度调整
  wait, 0.1
  
  Idlitwdprogressbar_setvalue, process, 99;-进度条进度调整
  wait, 0.1
  
  
  
  Idlitwdprogressbar_setvalue, process, 100;-进度条进度调整
  wait, 0.1
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
  
  temp=DIALOG_MESSAGE('数据预处理完毕。点击确定开始进行多分量时序分析。',/center,/information)
  
  ; Third, Networking
  wtlb = WIDGET_BASE(title = '进度条',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='多分量时序分析')
  
  temp=6
  FOR i=0, temp DO BEGIN
    Idlitwdprogressbar_setvalue, process, i ;-初始化进度条，初始值为0  wait, 1
    wait, 1
  ENDFOR
  
  
  ;  Idlitwdprogressbar_setvalue, process, 50;-进度条进度调整
  
  
  TLI_SARGUI_FILE_COPY, tempdir, subdir
  TLI_SARGUI_FILE_COPY, tempimgdir, imgdir
  
  
  wait, 5
  temp=4
  FOR i=100-temp, 100 DO BEGIN
    Idlitwdprogressbar_setvalue, process, i;-进度条进度调整
    wait,1
  ENDFOR
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
  
  str='多分量时序分析完成，输出结果：'+ STRING(13B)+STRING(13B) $
    +'沉降速率:  '+vfile+STRING(13B) $
    +'加速度分量:   '+dvfile + STRING(13b) $
    +'季节性沉降分量:   '+seasonfile+ STRING(13b) $
    +STRING(13B) $
    +'可视化结果:   '+ imgfile
    
  temp=DIALOG_MESSAGE(str,/center,/information)
  
  
  
END