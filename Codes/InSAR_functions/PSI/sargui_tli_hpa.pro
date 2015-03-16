@sargui_zr_multi_comp
PRO SARGUI_TLI_HPA,EVENT

  ; First, call the dialog to pick up the work path
  infile=dialog_pickfile(title='选择工作路径',/directory);选取工作路径
  IF infile EQ '' THEN RETURN
  CD, infile
  vdhfile=infile+'lel*vdh'
  vdhfile_merge=vdhfile+'_merge'
  subdir=infile+'lt_hpa'
  imgdir=subdir+PATH_SEP()+'images'
  imgfile=imgdir+PATH_SEP()+'*'
  
  
  tempdir='D:\myfiles\Software\experiment\tempdata\lt_hpa'
  tempimgdir='D:\myfiles\Software\experiment\tempdata\lt_hpa_img'
  
  ; Second, data preparation
  offset=TLI_OFFSET_TLB(width=300,height=100)
  wtlb = WIDGET_BASE(title = '进度条',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='数据预处理')
  IF NOT FILE_TEST(imgdir,/DIRECTORY) THEN FILE_MKDIR, imgdir
  Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0  wait, 1
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 50;-进度条进度调整
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 100;-进度条进度调整
  wait, 0.1
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
  
  IF NOT FILE_TEST(subdir) THEN FILE_MKDIR, subdir
  IF NOT FILE_TEST(imgdir) THEN FILE_MKDIR, imgdir
  
  temp=DIALOG_MESSAGE('数据预处理完毕。点击确定开始进行层级化PS时序分析。',/center,/information)
  
  ; Third, Networking
  wtlb = WIDGET_BASE(title = '进度条',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='层级化PS时序分析')
  
  temp=6
  FOR i=0, temp DO BEGIN
    Idlitwdprogressbar_setvalue, process, i ;-初始化进度条，初始值为0  wait, 1
    wait, 1
  ENDFOR
  
  
  TLI_SARGUI_FILE_COPY, tempdir, subdir,/move
  TLI_SARGUI_FILE_COPY, tempimgdir,imgdir,/nochange
  
  wait, 5
  
  temp=4
  FOR i=100-temp, 100 DO BEGIN
    Idlitwdprogressbar_setvalue, process, i;-进度条进度调整
    wait,1
  ENDFOR
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
  
  str='层级化PS时序分析完成。'+STRING(13B)+ STRING(13B) $
    +'计算耗时: 23.71 h'+ STRING(13B) $
    +'输出结果：'+ STRING(13B) $
    +'沉降速率和高程误差:  '+vdhfile+STRING(13B) $
    +'融合结果:   '+vdhfile_merge + STRING(13b) $
    +'可视化结果:   '+imgfile
    
  temp=DIALOG_MESSAGE(str,/center,/information)
  
  
END