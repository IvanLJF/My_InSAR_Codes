PRO LAYOVER
;- 根据雷达的叠掩信息获取建筑物高程
;- 本实验的目的是为PS提供精确的地面高程信息
;- 程序包含两个部分，即叠掩信息的提取以及高程的计算。
  infile='D:\myfiles\My_InSAR_Tools\InSAR\Images\testbuilding.bmp'
;  infile='/mnt/software/myfiles/My_InSAR_Tools/InSAR/Images/testbuilding.bmp'
  layover_th=240;- 设定叠掩像素的像素阈值
  layover_r=5;- 设定叠掩像素搜索半径
  layover_gray_change=10;- 设定叠掩像素的灰度变化范围
  im=read_bmp(infile)
  im_size=size(im)
  im_columns=im_size(1)
  im_columns=im_columns(0)
  im_lines=im_size(2)
  im_lines=im_lines(0)
  layover_im=intarr(im_columns,im_lines);- 矩阵layover_im用来存储判断信息
  x=0;- 用来存储每个点x方向的坐标
  y=0;- 用来存储每个点y方向的坐标
  z=0;- 用来存储每个点z方向的坐标
  layover_p=create_struct('startx',-1,'starty',-1,'length',-1);- 用来存储每个点的父节点信息
  uniq_x=0;-用来存储叠掩起始点x
  uniq_y=0;-用来存储叠掩起始点y
  uniq_z=0;;-用来存储叠掩起始点z
;  window,xsize=im_columns,ysize=im_lines
;  tv,im ;- 显示原始的图像
  ;- 开始进行叠掩像素分析
  wtlb = WIDGET_BASE(title = '进度条')
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='处理中... 请稍等')
  Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0
  for i=0, im_lines-1 do begin
    p_value=double(i)/double(im_lines)*100D
    Idlitwdprogressbar_setvalue, process, p_value ;- 设置进度条的值

    j=im_columns-1
    while j ge layover_r do begin
      if (im(j,i) ge layover_th) then begin
        if layover_p.startx eq -1 then layover_p.startx=j
        if layover_p.starty eq -1 then layover_p.starty=i
        if layover_p.startx eq -1 then layover_p.length=0
        temp=im(j-layover_r:j-1,i)
        result=where(temp ge im(j,i)-layover_gray_change)
        if total(result) eq -1 then  begin        ;- 找不到下一叠掩点
          layover_im(j,i)=0
          layover_p.startx=-1
          layover_p.starty=-1
          layover_p.length=0
          j=j-1
        endif
        if total(result) ge 0 then begin    ;- 找到下一叠掩点
;          layover_im(j-layover_r+result(0):j,i)=1
          x=[x,replicate(layover_p.startx,n_elements(result))]
          y=[y,replicate(layover_p.starty,n_elements(result))]
          z=[z,layover_r-result+layover_p.length]
          layover_p.length=layover_p.length+layover_r-result(0);- 叠掩长度变化
          layover_im([j-layover_r+result],i)=1
          layover_im(j,i)=1
          j=j-layover_r+result(0)
        endif
      endif
      if (im(j,i) lt layover_th) then begin
        layover_im(j,i)=0
        layover_p.startx=-1
        layover_p.starty=-1
        layover_p.length=0
        j=j-1
      endif      
    endwhile 
  endfor 

  uniq_index=uniq(x)
  temp=size(uniq_index)
  for i=1,temp(1)-2 do begin
    a=0
    uniq_z_temp=max(z(uniq_index(i):uniq_index(i+1)))
    uniq_z=[uniq_z,uniq_z_temp]
    a=[a,uniq_index(i)-uniq_index(i-1)]
  endfor
  uniq_z=uniq_z(1:*)
  layover_im=layover_im*255
  write_bmp,'D:\myfiles\My_InSAR_Tools\InSAR\testbuilding_layover.bmp',layover_im
  device,decomposed=1
  !p.background='FFFFFF'XL
  !p.color='000000'XL
  window,/free
  tv,im
  window,/free
  PLOT_3DBOX,x,y,z,psym=1
  result= TVRD()
  WRITE_BMP, 'D:\myfiles\My_InSAR_Tools\InSAR\Images\3DBOX.bmp', result

  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
  window,/free
  plot,uniq_z(where(uniq_z ge 50))
;  plot,uniq_z(where(uniq_z ge 50 && uniq_z le 80))
  print,mean(uniq_z(where(uniq_z ge 80)))
  window,/free
  plot,uniq_z
  result= TVRD()
  WRITE_BMP, 'D:\myfiles\My_InSAR_Tools\InSAR\Images\height.bmp', result

END

