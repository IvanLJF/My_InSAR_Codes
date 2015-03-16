;lspsunw.pro
Function lspsunw, num_PS, num_Arcs, Arcs, wphi_PS

;  系数矩阵A的生成
  A=lonarr(num_PS,num_Arcs)
  
    for j=0,num_Arcs-1 do begin
      A[Arcs[0,j],j]=1
      A[Arcs[1,j],j]=-1
    endfor
  
;    for i=0,num_Arcs-1 do begin
;      A(noarc(0,i),i)=1;
;      A(noarc(1,i),i)=-1;
;    endfor

  B=fltarr(num_Arcs-num_PS,num_Arcs);
  PA=[A,B]
  SA=SPRSIN(PA); 
  ;观测常量的生成
   L=wphi_PS[Arcs[0,*]]-wphi_PS[Arcs[1,*]];
   LL=reform(L,num_Arcs);
  ;最小二乘平差求解
  ; Forming normal equation ...
;A*x=L
;x=invert(transpose(A)##P##A)##transpose(A)##P##L
x=fltarr(1,num_Arcs);
x= SPRSAX(SA,LL);
unw_x=x(0:num_PS-1);

;unw_xc=congruence(Arcs, unw_x, wphi_PS)

return, unw_x
end
PRO SARGUI_UNWRAPRES_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'sarlist_button': begin
    ;- 同时设置slc影像列表文件路径，slc影像数目，干涉对数目，影像行列号
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
    
    files=file_search(path+'\*.alfangle',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='未找到基线倾角文件','请将基线倾角文件置于同一目录',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).alf_text,set_value=path+'\*.alfangle'
    files=file_search(path+'\*.base',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='未找到基线文件','请将基线文件置于同一目录',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).base_text,set_value=path+'\*.base'
    files=file_search(path+'\*.diff.phase.dat',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='未找到差分文件','请将差分文件置于同一目录',/information)
      widget_control,(*pstate).diff_text,set_value=''
      widget_control,(*pstate).diff_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).diff_text,set_value=path+'\*.diff.phase.dat'
    
    files=file_search(path+'\*.bperp.dat',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='未找到垂直基线文件','请将垂直基线文件置于同一目录',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
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
    numarcs=0
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
  'interv_button': begin
    infile=dialog_pickfile(title='插值年形变速率',filter='*.dat',file='V_map.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).interv_text,set_value=infile
    widget_control,(*pstate).interv_text,set_uvalue=infile
  end
  'interh_button': begin
    infile=dialog_pickfile(title='插值高程误差速率',filter='*.dat',file='H_map.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).interh_text,set_value=infile
    widget_control,(*pstate).interh_text,set_uvalue=infile
  end
  'unw_button': begin
    infile=dialog_pickfile(title='解缠文件',filter='*.dat',file='res.unwrap.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).unw_text,set_value=infile
    widget_control,(*pstate).unw_text,set_uvalue=infile
  end
  'ok': begin
    ;- 创建进度条
    wtlb = WIDGET_BASE(title = '进度条')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='处理中... 请稍等')
    Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0
    
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
    widget_control,(*pstate).interv_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请输入插值年形变速率文件',/information)
      return
    endif
    widget_control,(*pstate).interh_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请输入插值高程误差文件',/information)
      return
    endif
    widget_control,(*pstate).unw_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输出','请指定解缠文件输出路径',/information)
      return
    endif    
  ;该程序利用ferretti相关系数模型来求解线性形变增量和高程误差增量。
  ;
  ;- 开始读取参数定义
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num
  widget_control,(*pstate).numarc_text,get_uvalue=num_arc
  widget_control,(*pstate).numline_text,get_uvalue=width
  widget_control,(*pstate).numpixel_text,get_uvalue=height
  
  
  ;文件大小
;width=500
;height=500
;pathin='D:\IDL\xiqing\'
widget_control,(*pstate).sarlist_text,get_value=infile
pathout=file_dirname(infile)+'\'
;pathout='D:\IDL\result\'
;定义滤波器
kernelSize=[3,3]     ;卷积核应该可以预定义
kernel=REPLICATE((1./(kernelSize[0]*kernelSize[1])),kernelSize[0],kernelSize[1])  ;3*3卷积核
  
;PS点个数，前面可知
;num=3211
;num_arc=9597
  
day=file_lines(infile)
compu=day(0)*(day(0)-1)/2
itab=lonarr(5,compu)
V_map=fltarr(width,height)
H_map=fltarr(width,height)
  widget_control,(*pstate).itab_text,get_value=infile
openr,lun,infile,/get_lun
readf,lun,itab
free_lun,lun


;读取干涉对线性形变增量和高程误差
  widget_control,(*pstate).interv_text,get_value=infile 
;infile=pathout+'V_map.dat'
openr,lun,infile,/get_lun
readu,lun,V_map
free_lun,lun
  widget_control,(*pstate).interh_text,get_value=infile
;infile=pathout+'H_map.dat'
openr,lun,infile,/get_lun
readu,lun,H_map
free_lun,lun


PS=complexarr(num)
;arc_line=complexarr(num_arc)
;plist=intarr(2,num)
arc=lonarr(2,num_arc)
wphi_PS=fltarr(num)
res=fltarr(width,height)
diff=fltarr(width,height)
fres=fltarr(width,height)
unwrap=fltarr(num,compu)

bperp=fltarr(width,height)
incident=fltarr(width)
base=fltarr(height)
range=fltarr(width)

;读取PS点位信息
  widget_control,(*pstate).plist_text,get_value=infile
;  infile=pathout+'plist.txt'
  openr,lun,infile,/get_lun
  readf,lun,PS
  free_lun,lun
  
xlist=Uint(real_part(PS))
ylist=Uint(imaginary(PS))

;读取弧段信息
  arctemp=COMPLEXARR(num_arc)
  arc=lonarr(2,num_arc) 
  widget_control,(*pstate).arcs_text,get_value=infile
  OPENR,lun,infile,error=err,/get_lun
  READF,lun,arctemp
  FREE_LUN,lun
  arc[0,*]=REAL_PART(arctemp)
  arc[1,*]=IMAGINARY(arctemp)
;  infile=pathout+'arc.txt'
;  openr,lun,infile,/get_lun
;  readf,lun,arctemp
;  free_lun,lun
;  
;arc(0,*)=Uint(real_part(arc_line))
;arc(1,*)=Uint(imaginary(arc_line))


for i=0,compu-1 do begin
int_pair=itab(*,i)
;print,i
ti=int_pair(2)

;文件读写命名
;master_slc.par&slave_slc.par
master=strcompress(string(int_pair(0)),/remove_all)
slave=strcompress(string(int_pair(1)),/remove_all)
incid_angle_int=master+'-'+slave+'.incident'
range_master_int=master+'-'+slave+'.range'
alfa_angle_int=master+'-'+slave+'.alfangle'
baseline_int=master+'-'+slave+'.base'
diff_str=master+'-'+slave+'.diff'
baseline_perp=master+'-'+slave+'.bperp'

;读取垂直基线、入射角、斜距等参数
;-----------------------------------
infile=pathout+incid_angle_int
openr,lun,infile,/get_lun
readf,lun,incident
free_lun,lun

infile=pathout+range_master_int
openr,lun,infile,/get_lun
readf,lun,range
free_lun,lun

infile=pathout+baseline_int
openr,lun,infile,/get_lun
readf,lun,base
free_lun,lun

infile=pathout+baseline_perp+'.dat'
openr,lun,infile,/get_lun
readu,lun,bperp
free_lun,lun
;-----------------------------------


;读取差分干涉相位
infile=pathout+diff_str+'.phase.dat'
openr,lun,infile,/get_lun
readu,lun,diff
free_lun,lun

  for j=0,width-1 do begin
    for k=0,height-1 do begin
    ;逐点计算相位残差
      res(j,k)=diff(j,k)-bperp(j,k)*H_map(j,k)*4*!pi/(0.031*range(j)*sin(incident(j)))-ti/365*4*!pi*V_map(j,k)*cos(incident(j))/0.031
    endfor
  endfor

  res=(res+!pi)mod(!pi*2)-!pi
;  if MEAN( res, /DOUBLE , /NAN) lt -6.0 then begin
;   res=res+2*!pi
;  endif
;  if MEAN( res, /DOUBLE , /NAN) gt 6.0 then begin
;   res=res-2*!pi
;  endif 
  II=where(res lt (-1)*!pi)
  s1=size(II)
  III=where(res gt !pi)
  s2=size(III)

  if s1(0) ne 0 then begin
  res(II)=res(II)+2*!pi
  endif
  if s2(0) ne 0 then begin
  res(III)=res(III)-2*!pi
  endif
  
;相位残差滤波解缠
  
;卷积处理，空间低通滤波
fres=CONVOL(float(res),kernel,/CENTER,/EDGE_TRUNCATE)


;依据PS坐标提取PS点上的相位
;for n=0,num-1 do begin
;wphi_PS(n)=fres(xlist(n),ylist(n))
;endfor
wphi_PS=fres[xlist,ylist]

;-----------------------------------------
result=lspsunw(num, num_arc, arc, wphi_PS)

unwrap(*,i)=abs(result)

Idlitwdprogressbar_setvalue, process, 100*i/compu ;- 设置进度条进度
endfor
;保存经滤波、解缠后的相位残差
outfile=pathout+'res.unwrap.dat'
openw,lun,outfile,/get_lun
writeu,lun,unwrap
free_lun,lun
WIDGET_CONTROL,process,/Destroy
  WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
result=dialog_message(title='输出','解缠文件输出完毕',/information)

  end
  'cl': begin
    result=dialog_message(title='退出','确定退出？',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
  end
  else:return
endcase
END




PRO SARGUI_UNWRAPRES,EVENT
;- 创建顶层组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/7
tlb=widget_base(title='PS相位残差解缠',tlb_frame_attr=1,column=1,xsize=356,ysize=595,xoffset=xoffset,yoffset=yoffset)
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
;- 创建插值年形变速率
intervID=widget_base(tlb,row=1)
interv_text=widget_text(intervID,value='',uvalue='',uname='interv_text',/editable,xsize=40)
interv_button=widget_button(intervID,value='插值年形变速率',uname='interv_button',xsize=90)
;- 创建插值高程误差
interhID=widget_base(tlb,row=1)
interh_text=widget_text(interhID,value='',uvalue='',uname='interh_text',/editable,xsize=40)
interh_button=widget_button(interhID,value='插值高程误差',uname='interh_button',xsize=90)

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
;- 创建基线倾角文件
alfID=widget_base(tlb,row=1)
label=widget_label(alfID,value='基线倾角文件:',xsize=90)
alf_text=widget_text(alfID,value='',uvalue='',uname='alf_text',/editable,xsize=40)
;- 创建基线文件
baseID=widget_base(tlb,row=1)
label=widget_label(baseID,value='基线文件:',xsize=90)
base_text=widget_text(baseID,value='',uvalue='',uname='base_text',/editable,xsize=40)
;- 创建差分文件
diffID=widget_base(tlb,row=1)
label=widget_label(diffID,value='差分文件:',xsize=90)
diff_text=widget_text(diffID,value='',uvalue='',uname='diff_text',/editable,xsize=40)
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
;- 创建解缠路径
unwID=widget_base(tlb,row=1)
unw_text=widget_text(unwID,value='',uvalue='',uname='unw_text',/editable,xsize=40)
unw_button=widget_button(unwID,value='解缠输出文件',uname='unw_button',xsize=90)
;- 创建功能按钮
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='开始计算',uname='ok')
cl=widget_button(funID,value='退出',uname='cl')
;- 创建文件指针
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,arcs_text:arcs_text,arcs_button:arcs_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numarc_text:numarc_text,numline_text:numline_text,numpixel_text:numpixel_text, $
       unw_text:unw_text,unw_button:unw_button,incident_text:incident_text,range_text:range_text, $
       alf_text:alf_text,base_text:base_text,diff_text:diff_text,perp_text:perp_text,$
       interv_text:interv_text,interv_button:interv_button,$
       interh_text:interh_text,interh_button:interh_button,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_unwrapres',tlb,/no_block
END