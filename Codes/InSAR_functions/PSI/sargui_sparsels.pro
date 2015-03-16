

PRO SARGUI_SPARSELS_EVENT,EVENT
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
  'dv_button': begin
    infile=dialog_pickfile(title='弧段增量',filter='*.txt',file='dv_ddh_coh.txt')
    if infile eq '' then begin
      result=dialog_message(title='弧段增量文件','请选择弧段增量文件',/information)
      return
    endif
    widget_control,(*pstate).dv_text,set_value=infile
    widget_control,(*pstate).dv_text,set_uvalue=infile
  end
  'herr_button': begin
    infile=dialog_pickfile(title='输出高程误差',filter='*.txt',file='H.txt',/write,/overwrite_prompt)
    if infile eq '' then begin
      result=dialog_message(title='高程误差文件','请选择高程误差文件',/information)
      return
    endif
    widget_control,(*pstate).herr_text,set_value=infile
    widget_control,(*pstate).herr_text,set_uvalue=infile
  end
  'v_button': begin
    infile=dialog_pickfile(title='年形变速率',filter='*.txt',file='V.txt',/write,/overwrite_prompt)
    if infile eq '' then begin
      result=dialog_message(title='年形变速率','请选择年形变速率文件',/information)
      return
    endif
    widget_control,(*pstate).v_text,set_value=infile
    widget_control,(*pstate).v_text,set_uvalue=infile
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
    widget_control,(*pstate).dv_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输入','请输入弧段增量文件',/information)
      return
    endif
    widget_control,(*pstate).herr_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输出','请指定高程误差输出路径',/information)
      return
    endif
    widget_control,(*pstate).v_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='输出','请指定年形变速率输入路径',/information)
      return
    endif    
  ;- 开始读取参数定义
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num_ps
  widget_control,(*pstate).numarc_text,get_uvalue=num_arcs
  widget_control,(*pstate).numline_text,get_uvalue=nlines
  widget_control,(*pstate).numpixel_text,get_uvalue=npixels
   
;  ;参数定义
;  num_slc=15
;  num_intf=num_slc*(num_slc-1)/2
;  num_PS=3211
;  num_Arcs=9597
;  nlines=500
;  npixels=500
;  pathin='D:\IDL\result\'
;  pathout='D:\IDL\result\'
  
  dv_ddh_coh=fltarr(3,num_Arcs)

  ;输入线性形变速率和高程误差增量及各条弧段相关模型系数值的文件dv_ddh_coh.txt
  widget_control,(*pstate).dv_text,get_value=infile
  OPENR,lun,infile,/get_lun
  readf,lun,dv_ddh_coh
  FREE_LUN,lun
  dv=dv_ddh_coh(0,*)
  Inc=dv_ddh_coh(1,*)
  Wei=dv_ddh_coh(2,*)
;  starting=0
;  ending=0
;  thrsld=0.1

  arctemp=COMPLEXARR(num_Arcs)
  noarc=INTARR(2,num_Arcs)
  widget_control,(*pstate).arcs_text,get_value=infile
  OPENR,lun,infile,error=err,/get_lun
  READF,lun,arctemp
  FREE_LUN,lun
  noarc[0,*]=REAL_PART(arctemp)
  noarc[1,*]=IMAGINARY(arctemp)
 
;  ;权阵P的生成
;  P1=fltarr(num_Arcs,1)+1;生成num_Arcs个1，用来填充speye的对角线
;  P=diag_matrix(P1);用num_Arcs个1生成对角阵P=speye(num_Arcs,num_Arcs)
;  II=where(Wei lt thrsld);
;  SI=size(II);
;  II=where(Wei lt 0.4)
;    Wei(II)=(Wei(II))^5
;  if SI(3) GT 0 then begin
;    Wei(II)=0
;  endif
;  
;  for i=0,num_Arcs-1 do begin
;    P(i,i)=Wei(i);
;  endfor
;;  SP=SPRSIN(P);
  
  ;系数矩阵A的生成
  num_PS=DOUBLE(num_PS)
  num_Arcs=DOUBLE(num_Arcs)
  A=fltarr(num_PS,num_Arcs)
    for i=0,num_Arcs-1 do begin
      A(noarc(0,i),i)=1;
      A(noarc(1,i),i)=-1;
    endfor
  B=fltarr(num_Arcs-num_PS,num_Arcs);
  PA=[A,B]
  SA=SPRSIN(PA); 
  ;观测常量的生成
   L=Inc;
;  LL=fltarr(num_Arcs);
;  LL=L(0,*);
   LL=reform(L,num_Arcs);
   VV=reform(dv,num_Arcs);
  ;最小二乘平差求解
  ; Forming normal equation ...
;A*x=L
;x=invert(transpose(A)##P##A)##transpose(A)##P##L
x=fltarr(1,num_Arcs);
vd=fltarr(1,num_Arcs);
x= SPRSAX(SA,LL);
H=x(0:num_PS-1);
vd=SPRSAX(SA,VV);
v=vd(0:num_PS-1);
;VV=A##x-L;               ; corrections to observations along all arcs 
;VTPV=transpose(VV)##P##VV;
;delta=sqrt(VTPV/(num_Arcs-num_PS));     ; standard deviation

;;年形变速率与高程误差平滑  20110404 修改
;;读取PS点位信息
  plist=COMPLEXARR(num_PS)
  pscoor=INTARR(2,num_PS)
  ppp=file_dirname(infile)+'\plist.dat'
  ppp=ppp(0)
  openr,lun,ppp,/get_lun
  readf,lun,plist
  free_lun,lun
 
  x1=long(real_part(plist))
  y1=long(imaginary(plist))
  pscoor[0,*]=REAL_PART(plist)
  pscoor[1,*]=IMAGINARY(plist)


array=indgen(floor(num_PS/20))*20
vv=v(array)
vv=abs(vv)
hh=H(array)
hh=abs(hh)
x=x1(array)
y=y1(array)
;print,'Insert processing is doing...'

;分别内插线性形变增量和高程误差
e=[60,0]
width=npixels
height=nlines
;V_map=krig2d(V,x1,y1,expon=e,GS=[1,1],Bounds=[0,0,width,height])
V_map=krig2d(vv,x,y,expon=e,GS=[1,1],Bounds=[0,0,width-1,height-1])
v=V_map[pscoor[0,*],pscoor[1,*]]
v=v-max(v)
;print,'First step is over. Please waiting a moment!'
e=[40,10]
H_map=krig2d(hh,x,y,expon=e,GS=[1,1],Bounds=[0,0,width-1,height-1])
H=H_map[pscoor[0,*],pscoor[1,*]]


  widget_control,(*pstate).herr_text,get_value=infile
  OPENW,lun,infile,/get_lun
  PRINTF,lun,H
  FREE_LUN,lun  
  widget_control,(*pstate).v_text,get_value=infile
  OPENW,lun,infile,/get_lun
  PRINTF,lun,v
  FREE_LUN,lun
;print,mean(v),stddev(v)
;print,max(v),min(v)
;print,mean(H),stddev(H)
;print,max(H),min(H) 


 
  result=dialog_message(title='输出','年形变速率以及高程误差输出完毕',/information) 
  
  end
  'cl': begin
    result=dialog_message(title='退出','确定退出？',/question)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
  end
  else: return
endcase
END

PRO SARGUI_SPARSELS, EVENT
;- 最小二乘平差，用于求解高程误差分量以及年形变速率。
;- 创建顶层组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='PS网络平差分析',tlb_frame_attr=1,column=1,xsize=356,ysize=400,xoffset=xoffset,yoffset=yoffset)
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
;- 创建弧段增量输入组件
dvID=widget_base(tlb,row=1)
dv_text=widget_text(dvID,value='',uvalue='',uname='dv_text',/editable,xsize=40)
dv_button=widget_button(dvID,value='弧段增量文件',uname='dv_button',xsize=90)


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

;- 创建高程误差控件
herrID=widget_base(tlb,row=1)
herr_text=widget_text(herrID,value='',uvalue='',uname='herr_text',/editable,xsize=40)
herr_button=widget_button(herrID,value='高程误差文件',uname='herr_button',xsize=90)
;- 创建形变速率文件
vID=widget_base(tlb,row=1)
v_text=widget_text(vID,value='',uvalue='',uname='v_text',/editable,xsize=40)
v_button=widget_button(vID,value='年形变速率文件',uname='v_button',xsize=90)
;- 创建功能按钮
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='开始计算',uname='ok')
cl=widget_button(funID,value='退出',uname='cl')
;- 创建文件指针
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,arcs_text:arcs_text,arcs_button:arcs_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numarc_text:numarc_text,numline_text:numline_text,numpixel_text:numpixel_text, $
       herr_text:herr_text,herr_button:herr_button,v_text:v_text,v_button:v_button,ok:ok,cl:cl , $
       dv_text:dv_text,dv_button:dv_button   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_sparsels',tlb,/no_block

END

