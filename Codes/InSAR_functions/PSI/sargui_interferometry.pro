PRO SARGUI_INTERFEROMETRY_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'input_button':begin
    ;-选择输入文件
    infile=dialog_pickfile(title='请选择输入文件',filter='*.dat',file='itab.dat',/read)
    if n_elements(infile)eq 0 then return
    widget_control,(*pstate).input_text,set_uvalue=infile
    widget_control,(*pstate).input_text,set_value=infile
  end
  'size_button':begin
    ;-获取影像的行列号
    infile=dialog_pickfile(title='请选择输入文件',/read,filter='*.par')
    if infile eq '' then return
    if infile ne '' then begin
      openr,lun,infile,/get_lun
      temp=''
      for i=0,9 do begin
        readf,lun,temp
      endfor
      readf,lun,temp
      columns=(strsplit(temp,/extract))(1)
      readf,lun,temp
      lines=(strsplit(temp,/extract))(1) 
    widget_control,(*pstate).column_text,set_value=columns
    widget_control,(*pstate).column_text,set_uvalue=columns
    widget_control,(*pstate).line_text,set_value=lines
    widget_control,(*pstate).line_text,set_uvalue=lines
    endif
  end
  'out_button':begin
    ;-设置输出路径
    ;-检查是否选择了输入文件，若没有，则输入
    widget_control,(*pstate).input_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message('未选择输入文件，是否立即选择？',/question)
      if result eq 'Yes' then begin
        infile=dialog_pickfile(title='请选择输入文件',filter='*.dat',file='itab.dat',/read)
        if n_elements(infile)eq 0 then return
        widget_control,(*pstate).input_text,set_uvalue=infile
        widget_control,(*pstate).input_text,set_value=infile
      endif else begin
        return
      endelse
    endif else begin
    widget_control,(*pstate).input_text,get_uvalue=infile
    ;-获取存储路径
    temp=strsplit(infile,'\',/extract)
    temp_size=size(temp)
    out_path=''
    for i=0,temp_size(1)-2 do begin
      out_path=out_path+temp(i)+'\'
    endfor
    ;-将路径写入text控件
    widget_control,(*pstate).out_text,set_uvalue=out_path
    widget_control,(*pstate).out_text,set_value=out_path
    endelse
  end
  'ok':begin
    ;-获取控件值
    widget_control,(*pstate).input_text,get_uvalue=infile
    widget_control,(*pstate).out_text,get_uvalue=out_path
    widget_control,(*pstate).column_text,get_uvalue=column
    widget_control,(*pstate).line_text,get_uvalue=line
    column=long(column)
    line=long(line)
    ;-检测输入参数
    if infile eq '' then begin
      result=dialog_message('未选择影像配对文件',title='输入文件')
      return
    endif
    if out_path eq '' then begin
      result=dialog_message('未设置输出路径',title='输出路径')
      return
    endif
    if column*line eq 0 then begin
      result=dialog_message('请输入文件行列号',title='文件行列号')
      return
    endif
    ;-创建进度条
    wtlb = WIDGET_BASE(title = '进度条')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='处理中... 请稍等')
    Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0
    ;-读取干涉配对信息
    compu=file_lines(infile);获取文件行数
    itab=lonarr(5,compu)
    openr,lun,infile,/get_lun
    readf,lun,itab
    free_lun,lun
    Idlitwdprogressbar_setvalue, process,1 ;设置进度条

    ;slc文件大小
    width=column
    height=line
    temp0=intarr(width*2,height)
    pa=out_path
    list1=indgen(width)
    listr=list1*2
    listc=listr+1

    ;共轭相乘并输出结果
    for i=0,compu-1 do begin
    int_pair=itab(*,i)

    ;文件读写命名
    master_str=strcompress(string(int_pair(0)),/remove_all)+'.rslc'
    slave_str=strcompress(string(int_pair(1)),/remove_all)+'.rslc'
    int_str=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.int'
    
    ;读取主影像
    infile=pa+master_str
    
    openr,lun,infile,/get_lun,/swap_endian
    readu,lun,temp0
    free_lun,lun
    
    temp=long(temp0)
    a=temp(listr,*)
    b=temp(listc,*)
    master=complex(a,b)
    

    ;读取从影像
    infile=pa+slave_str
    
    openr,lun,infile,/get_lun,/swap_endian
    readu,lun,temp0
    free_lun,lun

    temp=long(temp0)
    a=temp(listr,*)
    b=temp(listc,*)
    slave=complex(a,0-b)
    

    ;干涉并分离相位信息
    int=master*slave

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
    ;输出干涉结果
    pa1=out_path
    intfile=pa1+int_str+'.int.dat'
    openw,lun,intfile,/get_lun
    printf,lun,int
    free_lun,lun

    phasefile=pa1+int_str+'.phase.dat'
    openw,lun,phasefile,/get_lun
    writeu,lun,phase
    free_lun,lun
    Idlitwdprogressbar_setvalue, process, 1+99*i/compu ;设置进度条
    endfor
    WIDGET_CONTROL,process,/Destroy
    WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
    ;- 给出处理结果
    result=dialog_message(title='输出完毕','时序干涉图、干涉相位输出完毕',/information)
  end
  'cl':begin
    result=dialog_message('确定退出？',title='退出',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif
  end
  else:return
endcase    
END

PRO SARGUI_INTERFEROMETRY,EVENT
;-计算差分干涉结果。
;-最终输出为差分干涉数据，以及相应的差分干涉图。
;-构建相关控件：
device,get_screen_size=screen_size
tlb=widget_base(column=1,title='时序干涉处理',tlb_frame_attr=1,xsize=300,xoffset=screen_size(0)/3,yoffset=screen_size(1)/3)
;-读取itab文件信息
itab_tlb=widget_base(tlb,tlb_frame_attr=1,row=1)
input_text=widget_text(itab_tlb,xsize=32,/editable,value='',uvalue='',uname='input_text')
input_button=widget_button(itab_tlb,xsize=80,value='输入itab文件',uname='input_button')
;-获取影像行列数
size_tlb=widget_base(tlb,tlb_frame_attr=1,row=1)
line_label=widget_label(size_tlb,xsize=40,value='行数:')
line_text=widget_text(size_tlb,xsize=8,/editable,value='0',uvalue='',uname='line_text')
column_label=widget_label(size_tlb,xsize=40,value='列数:')
column_text=widget_text(size_tlb,xsize=8,/editable,value='0',uvalue='',uname='column_text')
size_button=widget_button(size_tlb,xsize=80,value='从头文件导入',uname='size_button')
;-指定输出路径
out_tlb=widget_base(tlb,tlb_frame_attr=1,row=1)
out_text=widget_text(out_tlb,xsize=32,/editable,value='',uvalue='',uname='out_text')
out_button=widget_button(out_tlb,xsize=80,value='获取输出路径',uname='out_button')
;-相关功能按钮
fun_tlb=widget_base(tlb,tlb_frame_attr=1,row=1,/align_right)
ok=widget_button(fun_tlb,xsize=40,value='计算',uname='ok')
cl=widget_button(fun_tlb,xsize=40,value='退出',uname='cl')
;-创建指针，指针包含所有的控件名称，并设置tlb的值为pstate
state={input_text:input_text,input_button:input_button,out_text:out_text,out_button:out_button, $
       column_text:column_text,line_text:line_text,size_button:size_button,ok:ok,cl:cl}
pstate=ptr_new(state)
widget_control,tlb,set_uvalue=pstate
;-识别按钮
widget_control,tlb,/realize
xmanager,'SARGUI_INTERFEROMETRY',tlb,/no_block
END