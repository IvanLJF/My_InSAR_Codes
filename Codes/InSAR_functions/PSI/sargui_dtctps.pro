

PRO SARGUI_DTCTPS_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname(0) of
  'listbutton':begin
    infile=dialog_pickfile(title='请选择输入文件',file='sarlist.dat',filter='*.dat',/read)
    if infile eq '' then return
    if infile ne '' then begin
      nlines=file_lines(infile)
      names=strarr(nlines)
      openr,lun,infile,/get_lun
      readf,lun,names
      free_lun,lun
      widget_control,(*pstate).list,set_uvalue=names
      widget_control,(*pstate).list,set_value=names
    endif
  end
  'outbutton':begin
    outfile=dialog_pickfile(title='请选择输出文件',filter='*.dat',file='plist.dat',/overwrite_prompt,/write)
    if outfile ne '' then begin
      widget_control,(*pstate).outpath,set_value=outfile
      widget_control,(*pstate).outpath,set_uvalue=outfile
    endif
  end
  'cl':begin
    result=dialog_message('确定退出？',title='退出',/question,/default_no)
    if result eq 'Yes'then begin
      widget_control,event.top,/destroy
    endif else begin
    return
    endelse
  end
  'ok':begin
    ;-创建进度条
    wtlb = WIDGET_BASE(title = '进度条')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='处理中... 请稍等')
    Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0
    ;-获取文件的行列号
    list_num=widget_info((*pstate).list,/list_number);判断list中是否有文件
    if list_num eq 0 then begin
      result=dialog_message('未找到输入文件',title='请输入文件',/information)
    endif else begin
      widget_control,(*pstate).list,get_uvalue=names
      widget_control,(*pstate).outpath,get_value=outfile
      if outfile eq '' then begin
      result=dialog_message('请选择输出文件',title='文件输出',/information)
      endif else begin
      infile=names(0)
      infiles=names
      fpath=strsplit(infile,'\',/extract);将文件路径以‘\’为单位划分
      pathsize=size(fpath)
      fname=fpath(pathsize(1)-1)
      file=strsplit(fname,'.',/extract)
      hdrfile=file(0)+'.rslc.par';头文件名称
      hdrpath=''
      for i=0,pathsize(1)-2 do begin
        hdrpath=hdrpath+fpath(i)+'\'
      endfor
      hpath=hdrpath+hdrfile;-头文件全路径
      files=findfile(hpath,count=numfiles)
      ;-找不到头文件给出提示
      if (numfiles eq 0) then begin
        result=dialog_message('未找到头文件，请将头文件置于相同文件夹下',title='头文件未找到')
      endif else begin
      ;-找到头文件，读取文件行列号
        openr,lun,hpath,/get_lun
        temp=''
        for i=0,9 do begin
          readf,lun,temp
        endfor
        readf,lun,temp
        columns=(strsplit(temp,/extract))(1)
        columns=double(columns)
        readf,lun,temp
        lines=(strsplit(temp,/extract))(1)
        lines=double(lines)     
        num=0
        temp0=intarr(columns*2,lines);也可以创建其他数组，但是大小不能有错误
        ;infiles=dialog_pickfile(filter='*.rslc',/read)
        plist=complexarr(2000000)
        ave_pwr=lonarr(columns,lines)
        infiles=names
        dim=list_num
        image=lonarr(columns,lines,dim)
        pwr=lonarr(dim)
        Idlitwdprogressbar_setvalue, process, 5;-进度条进度调整
;        infiles=strarr(dim)
        ;-开始计算PS点
        for k=0,dim-1 do begin
          infile=infiles(k)
          slc=openslc(infile)
          r_part=real_part(slc)
          i_part=imaginary(slc)
          image(*,*,k)=sqrt(r_part^2+i_part^2)
          ave_pwr=ave_pwr+image(*,*,k)/dim;获取平均振幅影像
          progressbar_value=5+80*(k+1)/dim
          Idlitwdprogressbar_setvalue, process, progressbar_value;-设置进度条进度
        endfor
        ave_pwr=adapt_hist_equal(ave_pwr)
        Idlitwdprogressbar_setvalue, process, 88;-设置进度条进度
        ;-阈值条件1：sta_flag
        ave_im=mean(image)
        Idlitwdprogressbar_setvalue, process, 91;-设置进度条进度
        da_im=stddev(image)
        Idlitwdprogressbar_setvalue, process, 94;-设置进度条进度
        sta_flag=ave_im+da_im*2
        ;-阈值条件2：det
        columns_lines=columns*lines
        for i=0,columns-1 do begin
        for j=0,lines-1 do begin
          pwr=image(i,j,*)
          ;a=0.0 & da=0.0
          a= mean(pwr)
          da= stddev(pwr)
          det=a/da
          if det GE 2.5 && a GE sta_flag then begin
            plist(num)=complex(i,j)
            num=num+1;num用来计算所有PS点的数目
          endif
        endfor
        Idlitwdprogressbar_setvalue, process, 94+4*i/500;-设置进度条进度
        endfor
        Idlitwdprogressbar_setvalue, process, 98;-设置进度条进度
        
        if num GE 1 then begin
          ps=plist(0:num-1)
          openw,lun,outfile,/get_lun
          printf,lun,ps
          free_lun,lun
          Idlitwdprogressbar_setvalue, process, 100;-设置进度条进度
          WIDGET_CONTROL,process,/Destroy
          WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
          result=dialog_message('文件输出完毕',title='文件输出',/information)
          widget_control,(*pstate).resulttext,set_value=string(num)
          widget_control,(*pstate).resulttext,set_uvalue=string(num)
;          widget_control,(*pstate).resultlabel,set_value=string(num)
          widget_control,(*pstate).outbutton,set_uvalue=ave_pwr
        endif else begin
          result=dialog_message('未找到PS点，文件未输出',title='文件输出',/information)  
        endelse
        endelse
      endelse
    endelse   
  end 
  'disyes':begin
    widget_control,(*pstate).outbutton,get_uvalue=pwr
    widget_control,(*pstate).outpath,get_uvalue=outpath
    if n_elements(pwr) eq 1 then result=dialog_message('请做完PS探测再显示',title='显示错误',/information)
;    if outpath eq '' then result=dialog_message('请做完PS探测再显示',title='显示错误',/information)
    if (n_elements(pwr) gt 1) then begin
        window_size=size(pwr)
        window,xsize=window_size(1),ysize=window_size(2),title='PS点分布图'
        tv,pwr
        widget_control,(*pstate).resulttext,get_uvalue=psnum
        ps=complexarr(psnum)
        openr,lun,outpath,/get_lun
        readf,lun,ps
        free_lun,lun
        
        device,get_decomposed=old_decomposed,decomposed=0
        TvLCT, 0,255,0,1
        r_part=real_part(ps)
        i_part=imaginary(ps)
        plots,r_part,i_part,psym=1,/device,color=1
        device,decomposed=old_decomposed
        result=dialog_message('是否保存文件',title='保存文件',/question)
        if (result eq 'Yes') then begin
          ps_layover=tvrd(0,0,500,500,true=1)
          outpath=dialog_pickfile(title='输出文件',filter='*.bmp',file='pslayover.bmp',/write,/overwrite_prompt)
          write_bmp,outpath,ps_layover
          result=dialog_message('文件输出完毕')
        endif else begin
        return
        endelse
    endif
  end
  else:return
endcase
END


PRO SARGUI_DTCTPS,EVENT
;-创建顶层组件
device,get_screen_size=screen_size
;xsize=screen_size(0)/3
xsize=300
tlb=widget_base(title='PS探测',column=1,tlb_frame_attr=1,xsize=xsize,ysize=470,xoffset=screen_size(0)/3,yoffset=screen_size(1)/5)
;-创建PS探测相关组件
dettlb=widget_base(tlb,column=1,tlb_frame_attr=1,ysize=380)

labeltlb=widget_base(dettlb,row=1)
dtct=widget_label(labeltlb,value='PS探测')

inputtlb=widget_base(dettlb,column=1,tlb_frame_attr=1)
listbutton=widget_button(inputtlb,value='打开影像列表文件',uname='listbutton')
list=widget_list(inputtlb,value='',uname='list',ysize=20,xsize=42)

resulttlb=widget_base(dettlb,row=1,tlb_frame_attr=1)
resultlabel=widget_label(resulttlb,value='探测到的PS点数目：',xsize=203)
resulttext=widget_text(resulttlb,value='0',uname='resulttext',xsize=11)

outtlb=widget_base(dettlb,row=1,tlb_frame_attr=1)
outpath=widget_text(outtlb,value='',uvalue='',uname='outpath',/editable,xsize=32)
outbutton=widget_button(outtlb,value='输出文件',uvalue='',uname='outbutton',xsize=80)

funtlb=widget_base(dettlb,row=1,tlb_frame_attr=1,/align_right)
ok=widget_button(funtlb,value='计算',uname='ok',xsize=80)
;dis=widget_button(funtlb,value='显示结果',uname='disp',xsize=80)
cl=widget_button(funtlb,value='退出',uname='cl',xsize=80)

;-创建PS显示相关组件
labeltlb_second=widget_base(tlb)
fengexian=widget_label(labeltlb_second,value='————————————————————————')

disptlb=widget_base(tlb,column=1,tlb_frame_attr=1)
labeltlb_third=widget_base(disptlb)
dispID=widget_label(labeltlb_third,value='PS显示')

choosetlb=widget_base(disptlb,row=1,tlb_frame_attr=1)
buttonbase=widget_label(choosetlb,value='是否显示PS叠加图：',xsize=200)
disyes=widget_button(choosetlb,value='显示并输出',uname='disyes',xsize=80)
;buttonbase=widget_base(choosetlb,row=1,/exclusive)
;dispyes=widget_button(buttonbase,value='是',uname='dispyes')
;dispno=widget_button(buttonbase,value='否',uname='dispno')
;
;choosetlb=widget_base(disptlb,row=1,tlb_frame_attr=1)
;buttonbase=widget_label(choosetlb,value='是否输出PS叠加图：',xsize=200)
;outyes=widget_button(choosetlb,value='输出',uname='outyes',xsize=80)
;buttonbase=widget_base(choosetlb,row=1,/exclusive)
;outyes=widget_button(buttonbase,value='是')
;outno=widget_button(buttonbase,value='否')


;buttonbase=widget_base(disptlb,row=1,tlb_frame_attr=1)
;dispout=widget_text(buttonbase,value='',uname='dispout',/editable,xsize=32)
;dispbutton=widget_button(buttonbase,value='输出文件',uname='dispbutton',xsize=80)

;-创建指针
state={listbutton:listbutton,list:list,outpath:outpath,outbutton:outbutton,$
       resulttext:resulttext,ok:ok,cl:cl,resultlabel:resultlabel}
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate       
widget_control,tlb,/realize
xmanager,'sargui_dtctps',tlb,/no_block
END