PRO SARGUI_INTER_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'master_button': begin
    infile=dialog_pickfile(title='请选择主影像',filter='*.rslc',/read)
    if infile eq '' then return
    widget_control,(*pstate).master_text,set_value=infile
    widget_control,(*pstate).master_text,set_uvalue=infile
  end
  'slave_button': begin
    infile=dialog_pickfile(title='请选择从影像',filter='*.rslc',/read)
    if infile eq '' then return
    widget_control,(*pstate).slave_text,set_value=infile
    widget_control,(*pstate).slave_text,set_uvalue=infile
  end
  'headfile':begin
    ;-检测是否输入主像
    widget_control,(*pstate).master_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='主影像','请选择主影像',/information)
      return
    endif
    if infile eq '' then result=dialog_message('请先输入文件名',title='输入文件',/information)
    if infile ne '' then begin
      fpath=strsplit(infile,'\',/extract);将文件路径以‘\’为单位划分
      pathsize=size(fpath)
      fname=fpath(pathsize(1)-1)
      file=strsplit(fname,'.',/extract)
      hdrfile=file(0)+'.rslc.par';头文件名称
      hdrpath=''
      for i=0,pathsize(1)-2 do begin
        hdrpath=hdrpath+fpath(i)+'\'
      endfor
      hpath=hdrpath+hdrfile
      files=findfile(hpath,count=numfiles)
      ;-找不到头文件，交互输入文件行列号
      if (numfiles eq 0) then begin
        result=dialog_message('未找到头文件，请输入行列号',title='头文件未找到')
      ;-找到头文件，读取对应行列号
      endif else begin
        openr,lun,hpath,/get_lun
        temp=''
        for i=0,9 do begin
          readf,lun,temp
        endfor
        readf,lun,temp
        columns=(strsplit(temp,/extract))(1)
        readf,lun,temp
        lines=(strsplit(temp,/extract))(1) 
      endelse
      widget_control,(*pstate).columns,set_value=columns
      widget_control,(*pstate).columns,set_uvalue=columns
      widget_control,(*pstate).lines,set_value=lines
      widget_control,(*pstate).lines,set_uvalue=lines
    endif
  end
  'out_button':begin
    widget_control,(*pstate).master_text,get_uvalue=master
    if master eq '' then begin
      result=dialog_message(title='主影像','请选择主影像',/information)
      return
    endif
    widget_control,(*pstate).slave_text,get_uvalue=slave
    if slave eq '' then begin
      result=dialog_message(title='从影像','请选择从影像',/information)
      return
    endif
    temp=file_basename(master)
    temp=strsplit(temp,'.',/extract)
    master=temp(0)
    temp=file_basename(slave)
    temp=strsplit(temp,'.',/extract)
    slave=temp(0)
    file=master+'-'+slave+'.int.dat'
    infile=dialog_pickfile(title='输出干涉复数据',filter='*.int.dat',file=file,/write,/overwrite_prompt)
    if infile eq '' then return
    widget_control,(*pstate).out_text,set_value=infile
    widget_control,(*pstate).out_text,set_uvalue=infile
  end  
  'ok': begin
    ;- 检测输入文件
    widget_control,(*pstate).master_text,get_uvalue=master
    if master eq '' then begin
      result=dialog_message(title='主影像','请选择主影像',/information)
      return
    endif
    widget_control,(*pstate).slave_text,get_uvalue=slave
    if slave eq '' then begin
      result=dialog_message(title='从影像','请选择从影像',/information)
      return
    endif
    widget_control,(*pstate).columns,get_value=columns
    columns=long(columns)
    if columns le 0 then begin
      result=dialog_message(title='文件列数','文件列数大于0',/information)
      return
    endif
    widget_control,(*pstate).lines,get_value=lines
    lines=long(lines)
    if lines le 0 then begin
      result=dialog_message(title='文件行数','文件行数大于0',/information)
      return
    endif
    widget_control,(*pstate).out_text,get_uvalue=outfile
    if outfile eq '' then begin
      result=dialog_message(title='输出文件','请选择输出文件',/information)
      return
    end
    height=lines(0)
    width=columns(0)
    master_slc=openslc(master)
    slave_slc=openslc(slave)
    slave_real=real_part(slave_slc)
    slave_imaginary=imaginary(slave_slc)*(-1)
    slave_slc=complex(slave_real,slave_imaginary)
    int=master_slc*slave_slc
    phase=atan(imaginary(int)/real_part(int))
    
    ;附加相位判断
    for k=0,height-1 do begin
    for j=0,width-1 do begin
      int1=int(j,k)
      if real_part(int1) lt 0 then begin
      if imaginary(int1) ge 0 then begin
        phase(j,k)=phase(j,k)+!pi
      endif else begin
        phase(j,k)=phase(j,k)-!pi
      endelse
      endif
    endfor
    endfor
   ;- 影像显示

   device,get_decomposed=old_decomposed
   device,decomposed=0
   !p.background='FFFFFF'XL
   !p.color='000000'XL
   loadct,25;可用色度条：13,25,23,39
   xsft=60
   ysft=175
   window,/free,ysize=height+100,xsize=width,title='干涉相位图'
   tvscl,phase,0,100
   

;;- 竖向色度条
;cb = bindgen(255)
;cb = extrac(cb,0,200)
;cb = cb#replicate(1b, 15)
;cb=transpose(cb)
;device,get_decomposed=old_decomposed
;;- 构建色度条外边框
;x0=width+80
;y0=100
;CONTOUR, cb,xrange=[ 0,1], xstyle=1, yrange=[-!pi,!pi], ystyle=1,level=300,$
;        position = [x0,y0,x0+15,y0+200], /NOERASE, /DEVICE, font=0,$
;        xticklen=0.2,yticklen=0.02,yticks = 2,xticks=1,$
;        ytickname = [-!pi,0,!pi],xtickname = [' ',' ']


    ;- 横向色度条
    cb = bindgen(255)
    cb = extrac(cb, 0,200)
    cb = cb#replicate(1b, 15)
    device,get_decomposed=old_decomposed
    ;- 构建色度条外边框
    x0=120
    y0=50
    CONTOUR, cb,yrange=[ 0,1], ystyle=1, xrange=[-!pi,!pi], xstyle=1,level=300,$
        position = [x0,y0,x0+200,y0+15], /NOERASE, /DEVICE, font=0,$
        xticklen=0.2,yticklen=0.02,xticks = 2,yticks=1,$
        xtickname = ['-π','0','π'],ytickname = [' ',' ']
    ;- 显示色度条
    tv,cb,x0,y0
    device,decomposed=old_decomposed
    openw,lun,outfile,/get_lun
    printf,lun,int
    free_lun,lun
    temp='干涉复数据输出至'+outfile
    result=dialog_message(title='输出',temp,/information)
    device, decomposed=0
  end
  'cl':begin
    result=dialog_message('确定退出？',title='退出',/question,/default_no)
    if result eq 'Yes'then begin
    widget_control,event.top,/destroy
    endif
  end
  else: begin
    return
  end
endcase
END

PRO SARGUI_INTER,EVENT
;-创建组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='干涉相位分析',tlb_frame_attr=1,column=1,xsize=356,ysize=180,xoffset=xoffset,yoffset=yoffset)
;-创建主影像文件组件
masterID=widget_base(tlb,row=1)
master_text=widget_text(masterID,value='',uvalue='',uname='master_text',/editable,xsize=40)
master_button=widget_button(masterID,value='主影像',uname='master_button',xsize=90)
;-创建从影像文件组件
slaveID=widget_base(tlb,row=1)
slave_text=widget_text(slaveID,value='',uvalue='',uname='slave_text',/editable,xsize=40)
slave_button=widget_button(slaveID,value='从影像',uname='slave_button',xsize=90)
;-创建行列号组件
labID=widget_base(tlb,row=1)
collabel=widget_label(labID,value='文件列数:',/align_left,xsize=125)
lnlabel=widget_label(labID,value='文件行数:',/align_left,xsize=125)
collnID=widget_base(tlb,row=1)
columns=widget_text(collnID,value='0',uvalue='',uname='columns',/editable,xsize=19)
lines=widget_text(collnID,value='0',uvalue='',uname='lines',/editable,xsize=19)
headfile=widget_button(collnID,value='从头文件导入',uname='headfile',xsize=90)

;- 创建输出路径组件
outID=widget_base(tlb,row=1)
out_text=widget_text(outID,value='',uvalue='',uname='out_text',/editable,xsize=40)
out_button=widget_button(outID,value='输出文件',uname='out_button',xsize=90)

;-创建一般按钮
funID=widget_base(tlb,row=1,/align_center)
ok=widget_button(funID,value='显示并输出',uname='ok')
cl=widget_button(funID,value='退出',uname='cl')
;-识别组件
state={master_text:master_text,master_button:master_button,slave_text:slave_text,slave_button:slave_button,$
       columns:columns,lines:lines,headfile:headfile,ok:ok,cl:cl,out_button:out_button,out_text:out_text}
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'SARGUI_INTER',tlb,/no_block
END