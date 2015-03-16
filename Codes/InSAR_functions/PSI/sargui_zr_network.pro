@sargui_zr_multi_comp

PRO SARGUI_ZR_NETWORK,EVENT
  ; First, call the dialog to pick up the work path
  infile=dialog_pickfile(title='选择工作路径',/directory);选取工作路径
  IF infile EQ '' THEN RETURN
  CD, infile
  IF NOT TLI_HAVESEP(infile) THEN infile=infile+PATH_SEP()
  subdir=infile+'zr_networking'
  imgdir=subdir+PATH_SEP()+'img'
  imgfile=imgdir+PATH_SEP()+'*.jpg'
  
  tempdir='D:\myfiles\Software\experiment\tempdata\zr_networking'
  tempimgdir='D:\myfiles\Software\experiment\tempdata\zr_networking_img'
  ; Second, data preparation
  offset=TLI_OFFSET_TLB(width=300,height=100)
  wtlb = WIDGET_BASE(title = '进度条',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='数据预处理')
  Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0  wait, 1
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 50;-进度条进度调整
  wait, 0.1
  Idlitwdprogressbar_setvalue, process, 100;-进度条进度调整
  wait, 0.1
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
  
  IF NOT FILE_TEST(subdir, /DIRECTORY) THEN FILE_MKDIR, subdir
  IF NOT FILE_TEST(imgdir,/DIRECTORY) THEN FILE_MKDIR, imgdir
  
  temp=DIALOG_MESSAGE('数据预处理完毕。点击确定开始构建网络模型。',/center,/information)
  
  ; Third, Networking
  wtlb = WIDGET_BASE(title = '进度条',xoffset=offset[0], yoffset=offset[1])
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='构建网络模型')
  
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
  
  str='二级构网分析完成'+STRING(13B) $
      +'计算耗时：3.6 h' $
      +STRING(13B) $
      +'可视化结果:   '+imgfile
  temp=DIALOG_MESSAGE(str,/center,/information)
  
  
  
END