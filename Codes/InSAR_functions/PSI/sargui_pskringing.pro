
PRO SARGUI_PSKRINGING_EVENT,EVENT
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
  'herr_button': begin
    infile=dialog_pickfile(title='输入高程误差文件',filter='*.txt',file='H.txt',/read)
    if infile eq '' then return
    widget_control,(*pstate).herr_text,set_uvalue=infile
    widget_control,(*pstate).herr_text,set_value=infile
  end
  'v_button': begin
    infile=dialog_pickfile(title='输入年形变速率文件',filter='*.txt',file='V.txt',/read)
    if infile eq '' then return
    widget_control,(*pstate).v_text,set_uvalue=infile
    widget_control,(*pstate).v_text,set_value=infile
  end
  'interh_button': begin
    infile=dialog_pickfile(title='高程误差插值输出',filter='*.dat',file='H_map.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).interh_text,set_uvalue=infile
    widget_control,(*pstate).interh_text,set_value=infile
  end
  'interv_button': begin
    infile=dialog_pickfile(title='年形变速率插值输出',filter='*.dat',file='V_map.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).interv_text,set_uvalue=infile
    widget_control,(*pstate).interv_text,set_value=infile
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
    widget_control,(*pstate).herr_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请指定高程误差输入路径',/information)
      return
    endif    
    widget_control,(*pstate).v_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请指定年形变速率输入路径',/information)
      return
    endif 
  ;该程序利用ferretti相关系数模型来求解线性形变增量和高程误差增量。
  ;
  ;- 开始读取参数定义
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num_ps
  widget_control,(*pstate).numline_text,get_uvalue=nlines
  widget_control,(*pstate).numpixel_text,get_uvalue=npixels
;  num_slc=15
;  num_intf=num_slc*(num_slc-1)/2
;  num_ps=3211
;  num_arc=9597
;  nlines=500
;  npixels=500
  
  widget_control,(*pstate).sarlist_text,get_value=infile
  day=file_lines(infile)  
;  day=15
compu=day(0)*(day(0)-1)/2
itab=lonarr(5,compu)
  widget_control,(*pstate).numps_text,get_uvalue=num
;num=3211
PS=complexarr(num)

dh=fltarr(num)
V=fltarr(num)
  widget_control,(*pstate).itab_text,get_value=infile
openr,lun,infile,/get_lun
readf,lun,itab
free_lun,lun
  widget_control,(*pstate).numline_text,get_uvalue=height
  widget_control,(*pstate).numpixel_text,get_uvalue=width
;  - 文件大小
;  width=500
;  height=500

;pathin='D:\IDL\xiqing\'
;pathout='D:\IDL\result\'

;读取PS点位信息
  widget_control,(*pstate).plist_text,get_value=infile
  openr,lun,infile,/get_lun
  readf,lun,PS
  free_lun,lun
  
  x1=long(real_part(PS))
  y1=long(imaginary(PS))
  
;读取干涉对线性形变速率V和高程误差dh
;-----------------------------------------
  widget_control,(*pstate).herr_text,get_value=infile
  openr,lun,infile,/get_lun
  readf,lun,dh
  FREE_LUN,lun  
  widget_control,(*pstate).v_text,get_value=infile
  openr,lun,infile,/get_lun
  readf,lun,V
  FREE_LUN,lun  

;-----------------------------------------
array=indgen(floor(num/20))*20
vv=V(array)
vv=abs(vv)
hh=dh(array)
hh=abs(hh)
x=x1(array)
y=y1(array)
;print,'Insert processing is doing...'

;分别内插线性形变增量和高程误差
e=[60,0]
;V_map=krig2d(V,x1,y1,expon=e,GS=[1,1],Bounds=[0,0,width,height])
V_map=krig2d(vv,x,y,expon=e,GS=[1,1],Bounds=[0,0,width-1,height-1])
;window,/free
;shade_surf,V_map

;print,'First step is over. Please waiting a moment!'
e=[40,10]
H_map=krig2d(hh,x,y,expon=e,GS=[1,1],Bounds=[0,0,width-1,height-1])
;window,/free
;shade_surf,H_map  
  
;保存线性形变增量和高程误差
widget_control,(*pstate).interv_text,get_value=infile
openw,lun,infile,/get_lun
writeu,lun,V_map
free_lun,lun
widget_control,(*pstate).interh_text,get_value=infile
openw,lun,infile,/get_lun
writeu,lun,H_map
free_lun,lun
  result=dialog_message(title='线性形变增量和高程误差','文件输出完毕',/information)
    
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


PRO SARGUI_PSKRINGING,EVENT
;- 克里金插值，利用PS点的年形变速率以及高程误差插值得到
;- 整幅影像的年形变速率以及高程误差。输入文件包括itab.
;- txt, plist.txt, H.txt, V.txt。输出文件包括V_
;- map.dat, H_map.dat
;- 创建顶层组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='线性形变和高程误差插值',tlb_frame_attr=1,column=1,xsize=356,ysize=390,xoffset=xoffset,yoffset=yoffset)
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
;- 创建高程误差文件输入组件
herrID=widget_base(tlb,row=1)
herr_text=widget_text(herrID,value='',uvalue='',uname='herr_text',/editable,xsize=40)
herr_button=widget_button(herrID,value='高程误差文件',uname='herr_button',xsize=90)
;- 创建年形变速率文件输入组件
vID=widget_base(tlb,row=1)
v_text=widget_text(vID,value='',uvalue='',uname='v_text',/editable,xsize=40)
v_button=widget_button(vID,value='年形变速率文件',uname='v_button',xsize=90)

;- 创建参数获取界面
label=widget_label(tlb,value='——————————————————————————————',/align_center)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='slc影像数目:',xsize=80)
numslc_text=widget_text(texttlb,value='',uvalue='',uname='numslc_text',xsize=12)
label=widget_label(texttlb,value='干涉对数目:',xsize=80)
numintf_text=widget_text(texttlb,value='',uvalue='',uname='numintf_text',xsize=12)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='影像行数:',xsize=80)
numline_text=widget_text(texttlb,value='',uvalue='',uname='numline_text',xsize=12)
label=widget_label(texttlb,value='影像列数:',xsize=80)
numpixel_text=widget_text(texttlb,value='',uvalue='',uname='numpixel_text',xsize=12)
texttlb=widget_base(tlb,tlb_frame_attr=1,column=4)
label=widget_label(texttlb,value='ps点数目:',xsize=80)
numps_text=widget_text(texttlb,value='',uvalue='',uname='numps_text',xsize=12)

;- 创建输入label
label=widget_label(tlb,value='——————————————————————————————',/align_center)
label=widget_label(tlb,value='输出文件:',/align_left)

;- 创建插值高程误差
pscoorID=widget_base(tlb,row=1)
interh_text=widget_text(pscoorID,value='',uvalue='',uname='interh_text',/editable,xsize=40)
interh_button=widget_button(pscoorID,value='插值高程误差',uname='interh_button',xsize=90)
;- 创建插值年形变速率
intervID=widget_base(tlb,row=1)
interv_text=widget_text(intervID,value='',uvalue='',uname='interv_text',/editable,xsize=40)
interv_button=widget_button(intervID,value='插值年形变速率',uname='interv_button',xsize=90)
;- 创建功能按钮
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='开始计算',uname='ok')
cl=widget_button(funID,value='退出',uname='cl')
;- 创建文件指针
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,herr_text:herr_text,herr_button:herr_button, $
       v_text:v_text,v_button:v_button,numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numline_text:numline_text,numpixel_text:numpixel_text,interh_text:interh_text,interh_button:interh_button, $
       interv_text:interv_text,interv_button:interv_button,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_pskringing',tlb,/no_block

END
