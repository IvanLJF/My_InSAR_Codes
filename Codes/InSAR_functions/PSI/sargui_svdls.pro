function svd, A

zi=size(A)
SVDC, A, W, U, V 

k=zi(1)
sv=fltarr(k,k)

FOR i = 0, k-1 DO sv[i,i] = W[i] 

result = U ## sv ## TRANSPOSE(V) 

return,result

end

PRO SARGUI_SVDLS_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of 
  'sarlist_button': begin
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
  'unw_button': begin
    infile=dialog_pickfile(title='输入相位解缠文件',filter='*.dat',file='res.unwrap.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).unw_text,set_value=infile
    widget_control,(*pstate).unw_text,set_uvalue=infile
  end  
  'out_button': begin
    infile=dialog_pickfile(title='输出文件',filter='*.dat',file='res.temporal.dat',/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).out_text,set_value=infile
    widget_control,(*pstate).out_text,set_uvalue=infile
  end
  'ok': begin
    widget_control,(*pstate).sarlist_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='影像列表文件','请选择影像列表文件',/information)
      return
    endif
    widget_control,(*pstate).plist_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='ps列表文件','请选择ps列表文件',/information)
      return
    endif
    widget_control,(*pstate).unw_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='ps点解缠文件','请选择ps点解缠文件',/information)
      return
    endif
  
    widget_control,(*pstate).numslc_text,get_uvalue=day
    widget_control,(*pstate).numintf_text,get_uvalue=compu
    widget_control,(*pstate).numps_text,get_uvalue=num_ps
;- SVD的最小二乘解缠，恢复时间序列
;day=15
;compu=day*(day-1)/2
;num_PS=3211


res=fltarr(num_PS,compu)
rdate=fltarr(day,num_PS)
;pathin='D:\IDL\xiqing\'
;pathout='D:\IDL\result\'

;构建系数矩阵A
B=intarr(day,compu)

m=0
for i=0,day-2 do begin
for j=i+1,day-1 do begin
B(i,m)=1
B(j,m)=-1
m=m+1
endfor
endfor

A=svd(B)

C=fltarr(compu-day,compu);
PA=[A,C]
SA=SPRSIN(PA); 

x=fltarr(1,compu);


;读取解缠后的相位残差res
widget_control,(*pstate).unw_text,get_value=infile
;outfile=pathout+'res.unwrap.dat'
openr,lun,infile,/get_lun
readu,lun,res
free_lun,lun

;计算各PS点上的相位时间序列rdate
for i=0,num_PS-1 do begin
; print,i
  ;观测常量的生成
  L=res(i,*)
  LL=reform(L,compu)
  ;最小二乘平差求解
  x=SPRSAX(SA,LL)
;  rdate(*,i)=abs(x(0:day-1))
  rdate(*,i)=(x(0:day-1))
endfor

;保存rdate
widget_control,(*pstate).out_text,get_value=infile
;outfile=pathout+'res.temporal.dat'
openw,lun,infile,/get_lun
writeu,lun,rdate
free_lun,lun

    result=dialog_message(title='ps点时间序列分析','文件输出完毕',/information)

  end
  'cl': begin
    result=dialog_message(title='退出','确定退出？',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
  end
  else: return
endcase
END


;svd.pro



PRO SARGUI_SVDLS,EVENT
;- 创建顶层组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/7
tlb=widget_base(title='PS时间序列分析',tlb_frame_attr=1,column=1,xsize=356,ysize=340,xoffset=xoffset,yoffset=yoffset)
;- 创建输入label
label=widget_label(tlb,value='——————————————————————————————',/align_center)
label=widget_label(tlb,value='输入文件:',/align_left)
;- 创建影像列表文件输入组件
sarlistID=widget_base(tlb,row=1)
sarlist_text=widget_text(sarlistID,value='',uvalue='',uname='sarlist_text',/editable,xsize=40)
sarlist_button=widget_button(sarlistID,value='影像列表文件',uname='sarlist_button',xsize=90)
;- 创建ps点列表文件输入组件
plistID=widget_base(tlb,row=1)
plist_text=widget_text(plistID,value='',uvalue='',uname='plist_text',/editable,xsize=40)
plist_button=widget_button(plistID,value='ps列表文件',uname='plist_button',xsize=90)
;- 创建相位解缠文件输入组件
unwID=widget_base(tlb,row=1)
unw_text=widget_text(unwID,value='',uvalue='',uname='unw_text',/editable,xsize=40)
unw_button=widget_button(unwID,value='ps点解缠文件',uname='unw_button',xsize=90)
;- 创建label组件
label=widget_label(tlb,value='——————————————————————————————',/align_center)
label=widget_label(tlb,value='参数文件路径:',/align_left)
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
;- 创建输出路径
outID=widget_base(tlb,row=1)
out_text=widget_text(outID,value='',uvalue='',uname='out_text',/editable,xsize=40)
out_button=widget_button(outID,value='输出文件',uname='out_button',xsize=90)
;- 创建功能按钮
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='开始计算',uname='ok')
cl=widget_button(funID,value='退出',uname='cl')
;- 创建文件指针
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text, $
       plist_text:plist_text,plist_button:plist_button,$
       unw_text:unw_text,unw_button:unw_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numline_text:numline_text,numpixel_text:numpixel_text, $
       out_button:out_button,out_text:out_text,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'sargui_svdls',tlb,/no_block
END
