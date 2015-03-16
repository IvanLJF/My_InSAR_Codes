PRO SARGUI_LIST_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'add':begin
    widget_control,(*pstate).list,get_uvalue=names
    infiles=dialog_pickfile(title='请选择输入文件',filter='*.rslc',/read,/multiple_files)
    if n_elements(infiles) eq 0 then return
    if n_elements(names)eq 0 then begin
      names=infiles
    endif else begin    
      names=[names,infiles];将输入文件存入数组names
    endelse
    widget_control,(*pstate).list,set_uvalue=names
    widget_control,(*pstate).list,set_value=names
    end
;  'close':begin
;    widget_control,(*pstate).list,get_uvalue=list_name
;    print,'All the list names are:',list_name
;    end
  'del':begin
    widget_control,(*pstate).list,get_uvalue=names
    list_num=widget_info((*pstate).list,/list_number)
;    if list_num lt 2 then result=dialog_message('请选择至少两幅影像',title='影像数目过少',/information)
    list_select=widget_info((*pstate).list,/list_select)
    if n_elements(list_select)eq 0 then begin
      result=dialog_message('请选择所要删除的影像名称',title='删除影像',/information)
    endif
    if (n_elements(list_select)eq list_num)then begin
      names=''
    endif else begin
    if min(list_select)eq 0 then names=names(max(list_select)+1:list_num-1)
    if max(list_select)eq list_num-1 then names=names(0:min(list_select)-1)
    if (min(list_select)gt 0 and max(list_select)lt (list_num-1)) then names=[names(0:min(list_select)-1),names(max(list_select)+1:list_num-1)]
    endelse
    widget_control,(*pstate).list,set_value=names
    widget_control,(*pstate).list,set_uvalue=names
    end
  'cl':begin
    result=dialog_message('确定退出？',title='退出计算',/question,/default_no)
    widget_control,event.top,/destroy
    end
  'input':begin
    widget_control,(*pstate).list,get_uvalue=names
    infiles=dialog_pickfile(title='请选择影像列表文件',filter='*.dat',file='sarlist.dat',/read)
    if infiles eq '' then return
    nlines=file_lines(infiles)
    names=strarr(nlines)
    openr,lun,infiles,/get_lun
    readf,lun,names
    free_lun,lun
    widget_control,(*pstate).list,set_value=names
    widget_control,(*pstate).list,set_uvalue=names
    end
  'output':begin
    widget_control,(*pstate).list,get_uvalue=names
    outfile=dialog_pickfile(title='请选择输出路径',filter='*.dat',file='sarlist.dat',/write,/overwrite_prompt)
    if outfile eq '' then return
    openw,lun,outfile,/get_lun
    printf,lun,names,format='(A)'
;    printf,lun,names
    free_lun,lun
    result=dialog_message('文件输出完毕',title='输出文件',/information)
    end
  else: return
endcase
END

PRO SARGUI_LIST,EVENT
;-创建组件
device,get_screen_size=screen_size
tlb=widget_base(row=1,title='生成影像列表文件',tlb_frame_attr=1,xsize=330,xoffset=screen_size(0)/3,yoffset=screen_size(1)/3)
;-列表组件
list=widget_list(tlb,uname='lst',xsize=32,ysize=20,/multiple)
;-OK以及Cancel按钮
fun=widget_base(tlb,tlb_frame_attr=1,column=1,xsize=100,/align_bottom)
;adddel=widget_base(fun,column=1,tlb_frame_attr=1,xsize=100,/align_center)
addID=widget_button(fun,value='添加',uname='add')
delID=widget_button(fun,value='删除',uname='del')
;okcl=widget_base(fun,column=1,tlb_frame_attr=1,xsize=100,/align_bottom)
inID=widget_button(fun,value='导入文件列表',uname='input')
outID=widget_button(fun,value='导出文件列表',uname='output')
clID=widget_button(fun,value='退出',uname='cl')
;okID=widget_button(fun,value='关闭',uname='close')

;-创建结构体
state={list:list}
pstate=ptr_new(state)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'SARGUI_LIST',tlb,/no_block
END