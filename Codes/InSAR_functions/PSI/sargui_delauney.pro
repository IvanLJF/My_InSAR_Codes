PRO SARGUI_DELAUNEY_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'psbutton':begin
    infile=dialog_pickfile(title='打开文件',filter='*.dat',file='plist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).pstext,set_value=infile
    widget_control,(*pstate).pstext,set_uvalue=infile
  end
  'sarbutton':begin
    infile=dialog_pickfile(title='打开文件',filter='*.dat',file='sarlist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).sartext,set_value=infile
    widget_control,(*pstate).sartext,set_uvalue=infile
  end
  'outbutton':begin
    outfile=dialog_pickfile(title='输出文件',filter='*.dat',file='arcs.dat',/write,/overwrite_prompt)
    if outfile eq '' then return
    widget_control,(*pstate).outtext,set_value=outfile
    widget_control,(*pstate).outtext,set_uvalue=outfile
  end
  'debutton':begin
  ;-检查PS文件是否已经输入
    widget_control,(*pstate).pstext,get_uvalue=psinfile
    widget_control,(*pstate).sartext,get_uvalue=slcinfile
    if ((psinfile eq '' )and (slcinfile eq '')) then begin
      result=dialog_message('请选择PS文件以及SLC列表文件',title='打开文件',/information)
      return
    endif else begin
    ;-读取SLC文件，以均值图作为显示三角网的底图
      nlines=file_lines(slcinfile)
      names=strarr(nlines)
      openr,lun,slcinfile,/get_lun
      readf,lun,names
      free_lun,lun
      
      infile=names(0)
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
      if (numfiles eq 0) then begin
        result=dialog_message('未找到头文件，请将头文件置于相同文件夹下',title='头文件未找到')
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
        pwr=dblarr(columns,lines)
        for i=0,nlines-1 do begin
          slc=openslc(names(i))
          r_part=long(real_part(slc))
          i_part=long(imaginary(slc))
          amplitude=sqrt(r_part^2+i_part^2)
          pwr=pwr+amplitude/nlines
        endfor
        pwr=adapt_hist_equal(pwr)

      endelse
    ;-读取PS文件
      ;- 判断ps点的数目
      widget_control,(*pstate).pstext,get_uvalue=psinfile
      openr,lun,psinfile,/get_lun
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

      ps=complexarr(numps)
      openr,lun,psinfile,/get_lun
      readf,lun,ps
      free_lun,lun
      file_columns=columns
      file_lines=lines;将文件行列号另存至file_columns & file_lines
      columns=real_part(ps)
      rows=imaginary(ps)
    ;-创建三角网
      Triangulate,columns,rows,triangles,boundarypts
      s=size(triangles,/dimensions)
      num_triangles=s[1]
      window,/free,xsize=file_columns,ysize=file_lines,title='Delauney三角网'
      tv,pwr;显示底图
      device,get_decomposed=old_decomposed,decomposed=0;修改系统颜色参数
      TvLCT, 0,255,0,1;调取颜色表
      i=0D
      num_trangles=double(num_triangles)
      for i=0D,num_triangles-1D do begin
          thisTriangle=[triangles[*,i],triangles[0,i]]
          plots,columns[thistriangle],rows[thistriangle],color=1,/device
      ;    plots,columns[thistriangle],rows[thistriangle],/device
      endfor
      decomposed=old_decomposed
      num=numps
      zg=intarr(num,num)
      num=double(num)
      arcs=complexarr(num*5)

      arcs(0)=complex(triangles(0,0),triangles(1,0))
      zg(triangles(0,0),triangles(1,0))=1 & zg(triangles(1,0),triangles(0,0))=1
      arcs(1)=complex(triangles(1,0),triangles(2,0))
      zg(triangles(1,0),triangles(2,0))=1 & zg(triangles(2,0),triangles(1,0))=1
      arcs(2)=complex(triangles(2,0),triangles(0,0))
      zg(triangles(2,0),triangles(0,0))=1 & zg(triangles(0,0),triangles(2,0))=1

      j=1D & num_arcs=3D

      while j lt num_triangles do begin
       
        if ~zg(triangles(0,j),triangles(1,j)) && ~zg(triangles(1,j),triangles(0,j)) then begin
          arcs(num_arcs)=complex(triangles(0,j),triangles(1,j))
          num_arcs=num_arcs+1
          zg(triangles(0,j),triangles(1,j))=1 & zg(triangles(1,j),triangles(0,j))=1
        endif
      
        if ~zg(triangles(1,j),triangles(2,j)) && ~zg(triangles(2,j),triangles(1,j)) then begin
          arcs(num_arcs)=complex(triangles(1,j),triangles(2,j))
          num_arcs=num_arcs+1
          zg(triangles(1,j),triangles(2,j))=1 & zg(triangles(2,j),triangles(1,j))=1
        endif
      
        if ~zg(triangles(2,j),triangles(0,j)) && ~zg(triangles(0,j),triangles(2,j)) then begin
          arcs(num_arcs)=complex(triangles(0,j),triangles(2,j))
          num_arcs=num_arcs+1
          zg(triangles(2,j),triangles(0,j))=1 & zg(triangles(0,j),triangles(2,j))=1
        end
         
        j=j+1   
      endwhile
      bl=arcs(0:num_arcs-1)
      num_triangles=strcompress(num_triangles)
      num_arcs=strcompress(num_arcs)
      widget_control,(*pstate).tritext,set_value=num_triangles
;widget_control,(*pstate).delabel,set_value=num_triangles
      widget_control,(*pstate).linetext,set_value=num_arcs
      widget_control,(*pstate).psbutton,set_uvalue=bl
    endelse
  end
  'ok':begin
    widget_control,(*pstate).psbutton,get_uvalue=bl
    widget_control,(*pstate).outtext,get_uvalue=outfile
    if ((n_elements(bl) eq 0) or (outfile eq ''))then begin
      result=dialog_message('请先构建Delauney三角网',title='运行顺序错误',/information)
    endif else begin
      openw,lun,outfile,/get_lun
      printf,lun,bl
      free_lun,lun
      result=dialog_message('文件输出完毕,是否关闭对话框？',title='文件输出',/question)
      if result eq 'Yes' then widget_control,event.top,/destroy
      if result eq 'No' then return
    endelse
  end
  'cl':begin
    result=dialog_message('确定退出？',/question,/default_no)
    if result eq 'Yes' then begin
      widget_control,event.top,/destroy
    endif else begin
      return
    endelse
  end    
  else:return
endcase
END

PRO SARGUI_DELAUNEY,EVENT
device,get_screen_size=screen_size
;-创建组件
tlb=widget_base(xsize=380,ysize=275,column=1,tlb_frame_attr=1,xoffset=screen_size(0)/3)
;-读取PS点
pstlb=widget_base(tlb,row=1,tlb_frame_attr=1)
pstext=widget_text(pstlb,value='',uvalue='',/editable,xsize=45,uname='pstext')
psbutton=widget_button(pstlb,value='打开PS点文件',xsize=80,uname='psbutton')
;-读取SLC影像列表
sartlb=widget_base(tlb,row=1,tlb_frame_attr=1)
sartext=widget_text(sartlb,/editable,xsize=45,value='',uvalue='',uname='sartext')
sarbutton=widget_button(sartlb,value='打开SLC列表',xsize=80,uname='sarbutton')
;-构建Delayney三角网
;detlb=widget_base(tlb,row=1,tlb_frame_attr=1)
buttonbase=widget_base(tlb,tlb_frame_attr=1,xsize=380)
debutton=widget_button(buttonbase,value='构建Delauney三角网',uname='debutton',ysize=100,xsize=380)
detlb=widget_base(tlb,row=1,tlb_frame_attr=1)
delabel=widget_label(detlb,value='生成三角形数目(个):')
tritext=widget_text(detlb,value='',uvalue='',uname='tritext',xsize=8)
delabel=widget_label(detlb,value='生成基线数目(条):')
linetext=widget_text(detlb,value='',uvalue='',uname='linetext',xsize=10)
;-构建输出功能按钮
outtlb=widget_base(tlb,row=1,tlb_frame_attr=1)
outtext=widget_text(outtlb,value='',uvalue='',uname='outtext',/editable,xsize=45)
outbutton=widget_button(outtlb,value='输出弧段信息',uname='outbutton')
funtlb=widget_base(tlb,column=1,tlb_frame_attr=1,/align_right)
ok=widget_button(funtlb,value='确定',uvalue='',uname='ok',xsize=80)
cl=widget_button(funtlb,value='取消',uvalue='',uname='cl',xsize=80)
;-识别组件
state={pstext:pstext,psbutton:psbutton,sartext:sartext,sarbutton:sarbutton,$
       debutton:debutton,tritext:tritext,linetext:linetext,outtext:outtext,$
       ok:ok,cl:cl,outbutton:outbutton,delabel:delabel}
pstate=ptr_new(state)       
widget_control,tlb,set_uvalue=pstate       
widget_control,tlb,/realize
xmanager,'SARGUI_DELAUNEY',tlb,/no_block
END