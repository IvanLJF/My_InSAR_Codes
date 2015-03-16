FUNCTION Objfun,x,y,num_intf,dintf,ran,thit,bper,dt
  dph=DBLARR(num_intf)
  lamda=56.0
  l1=4*!pi/lamda
  fun=COMPLEX(0,0)
  dph=dintf[1,*]-dintf[0,*]
  coef_dv=l1*dt
  coef_ddh=l1*1000*bper/(ran*SIN(thit))
  FOR i=0,num_intf-1 DO BEGIN
    fun=fun+COMPLEX(COS(dph(i)-(coef_dv(i)*x+coef_ddh(i)*y)),SIN(dph(i)-(coef_dv(i)*x+coef_ddh(i)*y)))
  ENDFOR
  fun=ABS(fun)/num_intf
  RETURN,fun
END

PRO SARGUI_JHL_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'sarlist_button': begin
    ;- 同时设置slc影像列表文件路径，slc影像数目，干涉对数目，影像行列好
    infile=dialog_pickfile(title='影像列表文件',filter='*.dat',file='sarlist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).sarlist_text,set_uvalue=infile
    widget_control,(*pstate).sarlist_text,set_value=infile
    nlines=file_lines(infile)
    sarlist=strarr(nlines)
    numintf=nlines*(nlines-1)/2
    widget_control,(*pstate).numslc_text,set_uvalue=nlines
    nlines=strcompress(nlines,/remove_all)
    a=nlines
    widget_control,(*pstate).numslc_text,set_value=a
    widget_control,(*pstate).numintf_text,set_uvalue=numintf
    numintf=strcompress(numintf,/remove_all)
    widget_control,(*pstate).numintf_text,set_value=numintf
    ;- 获取文件行列号
    openr,lun,infile,/get_lun
    readf,lun,sarlist
    free_lun,lun
    slchead=sarlist(0)+'.par'
    files=findfile(slchead,count=numfiles)
    if numfiles eq 0 then begin
      result=dialog_message(title='头文件','未找到头文件',/information)
      return
    endif
    
    openr,lun,slchead,/get_lun
    temp=''
    for i=0,9 do begin
      readf,lun,temp
    endfor
    readf,lun,temp
    columns=(strsplit(temp,/extract))(1)
    readf,lun,temp
    lines=(strsplit(temp,/extract))(1)
    widget_control,(*pstate).numline_text,set_value=lines
    widget_control,(*pstate).numline_text,set_uvalue=lines
    widget_control,(*pstate).numpixel_text,set_value=columns
    widget_control,(*pstate).numpixel_text,set_uvalue=columns
    path=file_dirname(infile)
    files=file_search(path+'\*.incident',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='未找到入射角文件','请将入射角文件置于同一目录',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).incident_text,set_value=path+'\*.incident'
    files=file_search(path+'\*.range',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='未找到斜距文件','请将斜距文件置于同一目录',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).range_text,set_value=path+'\*.range'
    files=file_search(path+'\*.bperp.dat',count=filenum)
;    if filenum eq 0 then begin
;      result=dialog_message(title='未找到垂直基线文件','请将垂直基线文件置于同一目录',/information)
;      widget_control,(*pstate).sarlist_text,set_value=''
;      widget_control,(*pstate).sarlist_text,set_uvalue=''
;      return
;    endif
    widget_control,(*pstate).perp_text,set_value=path+'\*.bperp'
  end
  'itab_button': begin
    infile=dialog_pickfile(title='影像配对文件',filter='*.dat',file='itab.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).itab_text,set_uvalue=infile
    widget_control,(*pstate).itab_text,set_value=infile    
  end
  'plist_button': begin
    infile=dialog_pickfile(title='ps点列表文件',filter='*.dat',file='plist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).plist_text,set_value=infile
    widget_control,(*pstate).plist_text,set_uvalue=infile
    ;- 判断ps点的数目
    openr,lun,infile,/get_lun
    temp=''
    numps=0
    while ~eof(lun) do begin
      readf,lun,temp
      temp_str=strsplit(temp,')',/extract)
      temp_size=size(temp_str)
      if temp_size(1) eq 1 then begin
        numps=numps+1
      endif else begin
        numps=numps+2
      endelse
    endwhile
    widget_control,(*pstate).numps_text,set_uvalue=numps
    numps=strcompress(numps,/remove_all)
    widget_control,(*pstate).numps_text,set_value=numps
  end
  'arcs_button': begin
    infile=dialog_pickfile(title='弧段文件',filter='*.dat',file='arcs.dat',/read)
    if infile eq '' then return
    ;- 计算弧段数目
    openr,lun,infile,/get_lun
    temp=''
    numarcs=0D
    while ~eof(lun) do begin
      readf,lun,temp
      temp_str=strsplit(temp,')',/extract)
      temp_size=size(temp_str)
      if temp_size(1) eq 1 then begin
        numarcs=numarcs+1
      endif else begin
        numarcs=numarcs+2
      endelse
    endwhile
    widget_control,(*pstate).numarc_text,set_uvalue=numarcs
    numarcs=strcompress(numarcs,/remove_all)    
    widget_control,(*pstate).numarc_text,set_value=numarcs  
    widget_control,(*pstate).arcs_text,set_value=infile
    widget_control,(*pstate).arcs_text,set_uvalue=infile
  end
  'pscoor_button': begin
    infile=dialog_pickfile(title='输出ps坐标文件',filter='*.txt',file='pscoor.txt',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).pscoor_text,set_uvalue=infile
    widget_control,(*pstate).pscoor_text,set_value=infile    
  end


  'diff_button': begin
    widget_control,(*pstate).range_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='获取路径失败','请先指定斜距文件路径',/information)
    endif
    infile_path=file_dirname(infile)+'\'
    widget_control,(*pstate).diff_text,set_uvalue=infile_path
    widget_control,(*pstate).diff_text,set_value=infile_path
  end

  'dv_button': begin
    infile=dialog_pickfile(title='输出弧段解算增量',filter='*.txt',file='dv_ddh_coh.txt',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).dv_text,set_uvalue=infile
    widget_control,(*pstate).dv_text,set_value=infile
  end
  'ok': begin
    ;- 检测输入输出文件
    widget_control,(*pstate).sarlist_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请输入影像列表文件',/information)
      return
    endif
    widget_control,(*pstate).itab_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请输入影像配对文件',/information)
      return
    endif
    widget_control,(*pstate).plist_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请输入ps点列表文件',/information)
      return
    endif
    widget_control,(*pstate).arcs_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请输入弧段文件',/information)
      return
    endif
    widget_control,(*pstate).pscoor_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输出','请指定ps坐标输出路径',/information)
      return
    endif
    widget_control,(*pstate).dv_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输出','请指定弧段增量输入路径',/information)
      return
    endif    
  ;该程序利用ferretti相关系数模型来求解线性形变增量和高程误差增量。
  ;
  ;- 开始读取参数定义
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num_ps
  widget_control,(*pstate).numarc_text,get_uvalue=num_arc
  widget_control,(*pstate).numline_text,get_uvalue=nlines
  widget_control,(*pstate).numpixel_text,get_uvalue=npixels
;  num_slc=15
;  num_intf=num_slc*(num_slc-1)/2
;  num_ps=3211
;  num_arc=9597
;  nlines=500
;  npixels=500
  widget_control,(*pstate).incident_text,get_value=pathin
  if pathin eq '' then begin
    result=dialog_message(title='输入','未找到输入路径',/information)
    return
  endif
  pathin=file_dirname(pathin)+'\'
  widget_control,(*pstate).pscoor_text,get_value=pathout
  if pathout eq '' then begin
    result=dialog_message(title='输出','未找到输出路径',/information)
  endif
  pathout=file_dirname(pathout)+'\'
  ;数组定义
  pscoor=ULONARR(2,num_ps)
  wphi=FLTARR(npixels,nlines)
  wphi_ps=FLTARR(num_ps,num_intf)
  thi=FLTARR(npixels,1)
  thi_ps=FLTARR(num_ps,num_intf)
  range=DBLARR(npixels,1)
  range_ps=DBLARR(num_ps,num_intf)
  bperp=FLTARR(npixels,nlines)
  bperp_ps=FLTARR(num_ps,num_intf)
  thita=FLTARR(num_arc,num_intf)
  rg=DBLARR(num_arc,num_intf)
  bp=FLTARR(num_arc,num_intf)
  itab=LONARR(5,num_intf)
  dv_ddh_coh=FLTARR(3,num_arc)  
  ;读取itab文件
  widget_control,(*pstate).itab_text,get_uvalue=infile
  OPENR,lun,infile,/get_lun
  READF,lun,itab
  FREE_LUN,lun  
  ;获取itab中的时间基线数据，并将其存为dt列数组
  dt=itab[2,*]  
  ;读取PS坐标数据文件，将其保存为一个num_ps*2的数组pscoor[2,num_ps]
  plist=COMPLEXARR(num_ps)
  pscoor=INTARR(2,num_ps)
  widget_control,(*pstate).plist_text,get_uvalue=infile
  OPENR,lun,infile,/get_lun
  READF,lun,plist
  FREE_LUN,lun
  pscoor[0,*]=REAL_PART(plist)
  pscoor[1,*]=IMAGINARY(plist)
  widget_control,(*pstate).pscoor_text,get_uvalue=infile
;  OPENW,lun,pathout+'pscoor.txt',/get_lun
  OPENW,lun,infile,/get_lun
  PRINTF,lun,pscoor
  FREE_LUN,lun  
  ;读取弧段数据文件，并将其存为num_arcs*2的数组，其中共有num_arcs行
  ;两列，列元素对应于弧段两端点在plist文件中的PS点序列号。
  arctemp=COMPLEXARR(num_arc)
  noarc=INTARR(2,num_arc)
  widget_control,(*pstate).arcs_text,get_uvalue=infile
    OPENR,lun,infile,error=err,/get_lun
;  OPENR,lun,'D:\IDL\result\arcs.txt',error=err,/get_lun
  READF,lun,arctemp
  FREE_LUN,lun
  noarc[0,*]=REAL_PART(arctemp)
  noarc[1,*]=IMAGINARY(arctemp)
  
  
  
  ;- 创建进度条
  wtlb = WIDGET_BASE(title = '进度条')
  WIDGET_CONTROL,wtlb,/Realize
  process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='处理中... 请稍等')
  Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0  
  ;循环读取所有干涉组合的相关数据,分别包括入射角、斜距、垂直基线和差分干涉相位数据
  FOR m=0,num_intf-1 DO BEGIN
    int_pair=itab(*,m)
    master=STRCOMPRESS(STRING(int_pair(0)),/remove_all)
    slave=STRCOMPRESS(STRING(int_pair(1)),/remove_all)
    incid_angle_int=master+'-'+slave+'.incident'
    range_master_int=master+'-'+slave+'.range'
    diff_str=master+'-'+slave+'.diff.phase.dat'
    bperp_str=master+'-'+slave+'.bperp.dat'
    
    ;读取所有干涉组合的差分干涉相位，并提取相应PS点上的相位数据
    diffpath=pathin+diff_str
    OPENR,lun,diffpath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READU,lun,wphi
    FREE_LUN,lun
    wphi_ps[*,m]=wphi[pscoor[1,*],pscoor[0,*]]
    
    ;读取所有干涉组合的入射角数据文件，并提取相应PS点上的入射角数据
    incidentpath=pathin+incid_angle_int
    OPENR,lun,incidentpath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READF,lun,thi
    FREE_LUN,lun
    thi_temp=REBIN(thi,npixels,nlines)
    thi_ps[*,m]=thi_temp[pscoor[1,*],pscoor[0,*]]
    
    ;读取所有干涉组合的斜距数据文件
    rangepath=pathin+range_master_int
    OPENR,lun,rangepath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READF,lun,range
    FREE_LUN,lun
    range_temp=REBIN(range,npixels,nlines)
    range_ps[*,m]=range_temp[pscoor[1,*],pscoor[0,*]]
    
    ;读取所有干涉组合的垂直基线数据文件
    bperppath=pathin+bperp_str
    OPENR,lun,bperppath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READU,lun,bperp
    FREE_LUN,lun
    bperp_ps[*,m]=bperp[pscoor[1,*],pscoor[0,*]]
    Idlitwdprogressbar_setvalue, process, 10*m/num_intf;- 设置进度条进度
  ENDFOR
  ;-------------------------------------------
  ;以下为解空间搜索部分
  ;若需将上部分PS相位提取和下部分解空间搜索列为两个单独的菜单步骤
  ;则由此分开，但下部分需重写上半部分一些内容。合二为一，只为一次读取
  ;数据，后部分直接使用内存数据。
  ;-------------------------------------------
  ;设置速度增量和高程误差增量的搜索步长
  tt1=0.0
  tt2=0.0
  dv_low=-0.03
  dv_up=0.03
  ddh_low=-15.0
  ddh_up=15.0
  dv_size=21
  ddh_size=21
  dv_inc=(dv_up-dv_low)/(dv_size-1)
  ddh_inc=(ddh_up-ddh_low)/(ddh_size-1)
  dv_try=LINDGEN(21)*dv_inc+dv_low
  ddh_try=LINDGEN(21)*ddh_inc+ddh_low
  ;逐弧段求解
  FOR i=0D,num_arc-1D DO BEGIN    
    mm=noarc[0,i]     ;获取当前弧段的第一个PS点的序号
    nn=noarc[1,i]    ;获取当前弧段的第二个PS点的序号
    thita[i,*]=(thi_ps[mm,*]+thi_ps[nn,*])/2   ; 取当前弧段两PS点入射角的平均值
    rg[i,*]=(range_ps[mm,*]+range_ps[nn,*])/2       ;取当前弧段两PS点斜距的平均值
    bp[i,*]=(bperp_ps[mm,*]+bperp_ps[nn,*])/2     ;取当前弧段两PS点垂直基线的平均值
    ;将前面确定的解空间向量格网化成二维片面
    Meshgrid,dv_try,ddh_try,dv=dv,ddh=ddh
    xdv=REFORM(dv,1,N_ELEMENTS(dv))
    xddh=REFORM(ddh,1,N_ELEMENTS(ddh))
    ;调用相关性模型的对象函数
    y=Objfun(xdv,xddh,num_intf,[wphi_ps[mm,*],wphi_ps[nn,*]],rg[i,*],thita[i,*],bp[i,*],dt)
    coh=MAX(y,max_subscript)  ;获取解空间中模型相关系数最大值
    dv=xdv[max_subscript]      ;获取模型相关系数最大值所对应的线性形变速率增量
    ddh=xddh[max_subscript]    ;获取模型相关系数最大值所对应的高程误差增量
    dv_ddh_coh[*,i]=[dv,ddh,coh]
    value=long(10+90L*i/num_arc)
    Idlitwdprogressbar_setvalue, process, value ;- 设置进度条进度    
    
  ENDFOR
  ;输出线性形变速率和高程误差增量及各条弧段相关模型系数值的文件dv_ddh_coh.txt
  OPENW,lun,pathout+'dv_ddh_coh.txt',/get_lun
  PRINTF,lun,dv_ddh_coh
  FREE_LUN,lun
  WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
  result=dialog_message(title='输出完毕','输出弧段增量文件',/information)
  end
  'cl': begin
    result=dialog_message(title='退出','确定退出？',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif else begin
      return
    endelse
  end
  else: return
endcase

END



PRO Meshgrid,x,y,dv=dv,ddh=ddh
  x_dim = N_ELEMENTS(x)
  dv=FLTARR(x_dim,x_dim)
  FOR i=0,x_dim-1 DO BEGIN
    FOR j=0,x_dim-1 DO BEGIN
      dv[j,i]=x[j]
    ENDFOR
  ENDFOR
  y_dim=N_ELEMENTS(y)
  y=TRANSPOSE(y)
  ddh=FLTARR(y_dim,y_dim)
  FOR i=0,y_dim-1 DO BEGIN
    FOR j=0,y_dim-1 DO BEGIN
      ddh[j,i]=y[j]
    ENDFOR
  ENDFOR
END



PRO SARGUI_JHL,EVENT
;- 创建顶层组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='弧段增量求解',tlb_frame_attr=1,column=1,xsize=356,ysize=480,xoffset=xoffset,yoffset=yoffset)
;- 创建输入label
label=widget_label(tlb,value='——————————————————————————————',/align_center)
label=widget_label(tlb,value='输入文件:',/align_left)
;- 创建影像列表文件输入组件
sarlistID=widget_base(tlb,row=1)
sarlist_text=widget_text(sarlistID,value='',uvalue='',uname='sarlist_text',/editable,xsize=40)
sarlist_button=widget_button(sarlistID,value='影像列表文件',uname='sarlist_button',xsize=90)
;- 创建影像配对文件输入组件
itabID=widget_base(tlb,row=1)
itab_text=widget_text(itabID,value='',uvalue='',uname='itab_text',/editable,xsize=40)
itab_button=widget_button(itabID,value='影像配对文件',uname='itab_button',xsize=90)
;- 创建ps点列表文件输入组件
plistID=widget_base(tlb,row=1)
plist_text=widget_text(plistID,value='',uvalue='',uname='plist_text',/editable,xsize=40)
plist_button=widget_button(plistID,value='ps列表文件',uname='plist_button',xsize=90)
;- 创建弧段文件输入组件
arcsID=widget_base(tlb,row=1)
arcs_text=widget_text(arcsID,value='',uvalue='',uname='arcs_text',/editable,xsize=40)
arcs_button=widget_button(arcsID,value='弧段文件',uname='arcs_button',xsize=90)

;- 创建label组件
label=widget_label(tlb,value='——————————————————————————————',/align_center)
label=widget_label(tlb,value='参数文件路径:',/align_left)
;;- 创建干涉文件
;diffID=widget_base(tlb,row=1)
;label=widget_label(diffID,value='干涉输出路径:',xsize=90)
;diff_text=widget_text(diffID,value='',uvalue='',uname='diff_text',/editable,xsize=40)
;- 创建入射角文件
incidentID=widget_base(tlb,row=1)
label=widget_label(incidentID,value='入射角文件:',xsize=90)
incident_text=widget_text(incidentID,value='',uvalue='',uname='incident_text',/editable,xsize=40)
;- 创建斜距文件
rangeID=widget_base(tlb,row=1)
label=widget_label(rangeID,value='斜距文件:',xsize=90)
range_text=widget_text(rangeID,value='',uvalue='',uname='range_text',/editable,xsize=40)
;- 创建垂直基线文件
perpID=widget_base(tlb,row=1)
label=widget_label(perpID,value='垂直基线文件:',xsize=90)
perp_text=widget_text(perpID,value='',uvalue='',uname='perp_text',/editable,xsize=40)

;- 创建参数获取界面
label=widget_label(tlb,value='——————————————————————————————',/align_center)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='slc影像数目:',xsize=80)
numslc_text=widget_text(texttlb,value='',uvalue='',uname='numslc_text',xsize=12)
label=widget_label(texttlb,value='干涉对数目:',xsize=80)
numintf_text=widget_text(texttlb,value='',uvalue='',uname='numintf_text',xsize=12)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='ps点数目:',xsize=80)
numps_text=widget_text(texttlb,value='',uvalue='',uname='numps_text',xsize=12)
label=widget_label(texttlb,value='弧段数目:',xsize=80)
numarc_text=widget_text(texttlb,value='',uvalue='',uname='numarc_text',xsize=12)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='影像行数:',xsize=80)
numline_text=widget_text(texttlb,value='',uvalue='',uname='numline_text',xsize=12)
label=widget_label(texttlb,value='影像列数:',xsize=80)
numpixel_text=widget_text(texttlb,value='',uvalue='',uname='numpixel_text',xsize=12)
;- 创建输入label
label=widget_label(tlb,value='——————————————————————————————',/align_center)
label=widget_label(tlb,value='输出文件:',/align_left)

;- 创建ps坐标输入文件
pscoorID=widget_base(tlb,row=1)
pscoor_text=widget_text(pscoorID,value='',uvalue='',uname='pscoor_text',/editable,xsize=40)
pscoor_button=widget_button(pscoorID,value='ps坐标文件',uname='pscoor_button',xsize=90)
;- 创建形变速率文件
dvID=widget_base(tlb,row=1)
dv_text=widget_text(dvID,value='',uvalue='',uname='dv_text',/editable,xsize=40)
dv_button=widget_button(dvID,value='弧段增量',uname='dv_button',xsize=90)
;- 创建功能按钮
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='开始计算',uname='ok')
cl=widget_button(funID,value='退出',uname='cl')
;- 创建文件指针
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,arcs_text:arcs_text,arcs_button:arcs_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numarc_text:numarc_text,numline_text:numline_text,numpixel_text:numpixel_text, $
       pscoor_text:pscoor_text,incident_text:incident_text,range_text:range_text, $
       perp_text:perp_text,dv_text:dv_text,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_jhl',tlb,/no_block
END