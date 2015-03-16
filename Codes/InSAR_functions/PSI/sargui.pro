@sargui_tli_hpa
PRO SARGUI,IMAGE=IMAGE,XSIZE=XSIZE,YSIZE=YSIZE,BOTTOM=BOTTOM,NCOLORS=NCOLORS,TITLE=TITLE,TABLE=TABLE,DEGUB=DEBUG
  ;创建GUI，其中各变量分别为：
  ;XSIZE:确定widget_draw控件x方向长度
  ;YSIZE:确定widget_draw控件y方向长度
  ;TITLE:对话框标题
  ;TABLE:需调用的预定义的颜色表
  ;DEBUG:出现BUG后输出错误信息

  ;-检查系统是否支持组件建立
  if((!d.FLAGS and 65536)eq 0)then message,'Widgets are not supported on this device'
  ;如果!d.flags不等于65536,则不支持组件。
  
  device,get_screen_size=screen_size
  ;xsize=screen_size(0)*0.618
  xsize=750
  ;-创建组件
  tlb=widget_base(title='PSISWJTU',column=1,mbar=mbar,xsize=xsize,tlb_frame_attr=1,/tlb_size_event,xoffset=10, yoffset=10)
  ;创建顶层组件，其中各个关键字的功能为：
  ;column:使得子组件按列排列
  ;mbar:顶层组件的ID
  ;title：顶层组件的名称，已经在程序初始处定义完毕
  ;/tlb_size_event：当base组件大小改变时，返回一个事件
  ;-创建菜单
  fmenu=widget_button(mbar,value='文件')
  openID=widget_button(fmenu,value='打开',menu=2)
  slcID=widget_button(openID,value='SLC影像',event_pro='sargui_openslc')
  bmpID=widget_button(openID,value='BMP影像',event_pro='sargui_openbmp')
  ;  saveID=widget_button(fmenu,value='另存为...',menu=2)
  ;    jpegID=widget_button(saveID,value='JPEG图像',event_pro='sargui_jpeg')
  ;    bmpID=widget_button(saveID,value='BMP图像',event_pro='sargui_bmp')
  exitID=widget_button(fmenu,value='退出',event_pro='sargui_cancle')
  ;editmenu=widget_button(mbar,value='编辑')
  ;  copyID=widget_button(editmenu,value='复制')
  ;  cutID=widget_button(editmenu,value='剪切')
  ;  pasteID=widget_button(editmenu,value='粘贴')
  ;  zoominID=widget_button(editmenu,value='放大')
  ;  zoomoutID=widget_button(editmenu,value='缩小')
  presarmenu=widget_button(mbar,value='影像组合')
  plistID=widget_button(presarmenu,value='生成影像列表文件',event_pro='sargui_list')
  changeID=widget_button(presarmenu,value='单视复影像转换',menu=2)
  phaseID=widget_button(changeID,value='相位',event_pro='sargui_phase')
  amplitudeID=widget_button(changeID,value='振幅',event_pro='sargui_amplitude')
  baseID=widget_button(presarmenu,value='基线解算',event_pro='sargui_basemap')
  ;    timeID=widget_button(baseID,value='时间基线解算',event_pro='sargui_timebase')
  ;    spaceID=widget_button(baseID,value='空间基线解算',event_pro='sargui_spacebase')
  comID=widget_button(presarmenu,value='小基线干涉对组合',event_pro='sargui_smallbase')
  
  psmenu=widget_button(mbar,value='PS探测分析')
  psdetectID=widget_button(psmenu,value='PS点探测',event_pro='sargui_dtctps')
  psnetID=widget_button(psmenu,value='Delauney三角网构建',event_pro='sargui_delauney')
  
  dmenu=widget_button(mbar,value='差分干涉处理')
  inter=widget_button(dmenu,value='时序干涉处理',event_pro='sargui_interferometry')
  flattenning=widget_button(dmenu,value='去平地效应',event_pro='SARGUI_FLATTENNING')
  diff=widget_button(dmenu,value='时序差分干涉',event_pro='SARGUI_DIFF_INT')
  original=widget_button(dmenu,value='干涉相位分析',event_pro='sargui_inter')
  
  anspamenu=widget_button(mbar,value='PS线性分量解算')
  ;  interID=widget_button(anspamenu,value='原始干涉图计算',event_pro='sargui_inter')
  zengID=widget_button(anspamenu,value='弧段增量求解',event_pro='sargui_jhl')
  ;    psphase=WIDGET_BUTTON(zengID,value='PS点上差分干涉相位的提取')
  ;    dv_ddh=WIDGET_BUTTON(zengID,value='线性速率和高程误差增量估计',event_pro='sargui_jhl')
  pserrID=widget_button(anspamenu,value='PS网络平差分析',event_pro='sargui_sparsels')
  losmenu=widget_button(mbar,value='PS非线性分量解算')
  linID=widget_button(losmenu,value='线性形变和高程误差插值',event_pro='SARGUI_PSKRINGING')
  ;  filID=widget_button(losmenu,value='PS相位滤波')
  unwID=widget_button(losmenu,value='PS相位残差解缠',event_pro='sargui_unwrapres')
  tsID=widget_button(losmenu,value='PS时间序列分析',event_pro='sargui_svdls')
  atmID=widget_button(losmenu,value='大气相位分量分解',event_pro='SARGUI_NLDEF')
  losmenu=widget_button(mbar,value='LOS向地表形变分析')
  ;  psdID=widget_button(losmenu,value='PS形变量解算')
  kriID=widget_button(losmenu,value='LOS向形变计算',event_pro='sargui_deflos')
  diflos=widget_button(losmenu,value='LOS向形变查询',event_pro='sargui_deflos_alt',separator=1)
  
  ; The following info are added on 06-09-2013.
  ; Written by T.Li @ ISEIS
  advmenu=WIDGET_BUTTON(mbar, value='多级时序分析')  ; Advanced functions
  temp=WIDGET_BUTTON(advmenu, value='大区域网络化分析', event_pro='sargui_zr_network')
  temp=WIDGET_BUTTON(advmenu, value='多分量时序分析', event_pro='sargui_zr_multi_comp')
  temp=WIDGET_BUTTON(advmenu, value='层级化PS时序分析', event_pro='sargui_tli_hpa')
  
  helpmenu=widget_button(mbar,value='帮助')
  funID=widget_button(helpmenu,value='内容')
  upgradeID=widget_button(helpmenu,value='升级')
  versionID=widget_button(helpmenu,value='版本',event_pro='sargui_version')
  
  ;-创建widget_draw控件
  ;-/motion_events用于返回鼠标移动事件
  ;draw_id=widget_draw(tlb,xsize=draw_xsize,ysize=draw_ysize,uvalue='Draw')
  ;base=widget_base(tlb,row=1,/align_center)
  ;label_id=widget_label(base,value='',/align_left,/dynamic_resize)
  ;-设置画图组件窗口为当前窗口
  ;widget_control,draw_id,get_value=draw_window
  ;wset,draw_window
  ;device=!d.name
  ;widget_control,tlb,tlb_get_size=base_size
  
  slcamplitude=0
  slc=0
  version=!version.release
  ;-创建信息结构体
  ;info={slc:slc,slcamplitude:slcamplitude,debug:debug,version:version,$
  ;  draw_xsize:draw_xsize,draw_ysize:draw_ysize,tlb:tlb,draw_id:draw_id,draw_window:draw_window,$
  ;  label_id:label_id,device:device,base_size:base_size,out_pos:fltarr(4)}
  state={slc:slc,slcamplitude:slcamplitude,version:version,$
    tlb:tlb,out_pos:fltarr(4)}
    
  ;-将指针装载到变量infoptr中
  pstate=ptr_new(info,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'sargui',tlb,/no_block
;xmanager,'sargui',tlb,event_handler='sargui_label',/no_block
;if debug then print,'IMGUI startup is done'
END
