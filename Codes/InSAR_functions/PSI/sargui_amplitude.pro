PRO SARGUI_AMPLITUDE_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of 
  'openinput':begin
    infile=dialog_pickfile(title='选择输入文件',/read,filter='*.rslc')
    if infile eq '' then return
    widget_control,(*pstate).input,set_value=infile
    widget_control,(*pstate).input,set_uvalue=infile
    end
  'headfile':begin
    widget_control,(*pstate).input,get_uvalue=infile
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
  'openoutput':begin
    widget_control,(*pstate).input,get_uvalue=input
    if input eq '' then begin
      result=dialog_message(title='选择文件','请先选择输入文件',/information)
      return
    endif
    file=file_basename(input)
    file=file+'.amplitude.bmp'
    outfile=dialog_pickfile(title='选择输出文件',/write,file=file,filter='*.bmp',/overwrite_prompt)
    
      widget_control,(*pstate).output,set_value=outfile
      widget_control,(*pstate).output,set_uvalue=outfile

    end
  'ok':begin
    widget_control,(*pstate).input,get_uvalue=infile
    widget_control,(*pstate).columns,get_value=columns
    widget_control,(*pstate).lines,get_value=lines
    widget_control,(*pstate).output,get_uvalue=output
    if infile eq '' then begin
      result=dialog_message('请选择输入文件',title='选择输入文件',/information)
      return
    endif
    if columns le 0 then begin
      result=dialog_message('文件行数为正',title='行数错误',/information)
      return
    endif
    if lines le 0 then begin
      reslut=dialog_message('文件列数为正',title='列数错误',/information)
      return
    endif
    if output eq '' then begin
      result=dialog_message('请选择输出文件',title='选择输出文件',/information)
      return
    endif
    slc=openslc(infile)
    rl_part=float(real_part(slc))
    img_part=float(imaginary(slc))
    slcamplitude=sqrt(rl_part^2+img_part^2)
;    phase=atan(img_part/rl_part)
    write_bmp,output,slcamplitude

    result=dialog_message('文件输出完毕,是否关闭对话框',title='文件输出',/question)
    widget_control,event.top,/destroy
    end
  'cl':begin
    result=dialog_message('确定退出？',title='退出',/question,/default_no)
    if result eq 'Yes'then begin
    widget_control,event.top,/destroy
    endif
    end
  else:return
endcase
END

PRO SARGUI_AMPLITUDE,EVENT
;-创建组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='SLC转化为振幅影像',tlb_frame_attr=1,column=1,xsize=260,ysize=150,xoffset=xoffset,yoffset=yoffset)
;-创建输入文件组件
inID=widget_base(tlb,row=1)
input=widget_text(inID,value='',uvalue='',uname='input',/editable,xsize=22)
openinput=widget_button(inID,value='输入',uname='openinput',xsize=90)
;-创建行列号组件
labID=widget_base(tlb,row=1)
collabel=widget_label(labID,value='文件列数:',/align_left,xsize=70)
lnlabel=widget_label(labID,value='文件行数:',/align_left,xsize=70)
collnID=widget_base(tlb,row=1)
columns=widget_text(collnID,value='0',uvalue='',uname='columns',/editable,xsize=10)
lines=widget_text(collnID,value='0',uvalue='',uname='lines',/editable,xsize=10)
headfile=widget_button(collnID,value='从头文件导入',uname='headfile',xsize=90)
;-创建输出文件组件
outID=widget_base(tlb,row=1)
;outlabel=widget_label(outID,value='输出文件名称')
output=widget_text(outID,value='',uvalue='',uname='output',/editable,xsize=22)
openoutput=widget_button(outID,value='输出',uname='openoutput',xsize=90)
;-创建一般按钮
funID=widget_base(tlb,row=1,/align_center)
ok=widget_button(funID,value='确定',uname='ok')
cl=widget_button(funID,value='退出',uname='cl')
;-识别组件
state={input:input,openinput:openinput,columns:columns,lines:lines,headfile:headfile,output:output,openoutput:openoutput,ok:ok,cl:cl}
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'SARGUI_AMPLITUDE',tlb,/no_block
END