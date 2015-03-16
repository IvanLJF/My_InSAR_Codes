


PRO SARGUI_DIFF_INT_EVENT,EVENT
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
    files=file_search(path+'\*.base',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='未找到基线文件','请将基线文件置于同一目录',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).base_text,set_value=path+'\*.base'
    files=file_search(path+'\*.alfangle',count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='未找到基线倾角文件','请将基线倾角文件置于同一目录',/information)
      widget_control,(*pstate).sarlist_text,set_value=''
      widget_control,(*pstate).sarlist_text,set_uvalue=''
      return
    endif
    widget_control,(*pstate).perp_text,set_value=path+'\*.alfa'
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
  'pathout_button': begin
    widget_control,(*pstate).sarlist_text,get_uvalue=infile
    if infile eq '' then begin
      result=dialog_message(title='获取路径失败','请先指定斜距文件路径',/information)
    endif
    infile_path=file_dirname(infile)+'\'
    widget_control,(*pstate).pathout_text,set_uvalue=infile_path
    widget_control,(*pstate).pathout_text,set_value=infile_path
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
    widget_control,(*pstate).pathout_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='输出','请指定输出路径',/information)
    endif
    
    
    ;读取干涉配对信息
    widget_control,(*pstate).sarlist_text,get_value=infile
    day=file_lines(infile)
    compu=day(0)*(day(0)-1)/2
    itab=lonarr(5,compu)
    widget_control,(*pstate).itab_text,get_value=infile
    openr,lun,infile,/get_lun
    readf,lun,itab
    free_lun,lun

    ;int文件大小
  widget_control,(*pstate).numslc_text,get_uvalue=num_slc
  widget_control,(*pstate).numintf_text,get_uvalue=num_intf
  widget_control,(*pstate).numps_text,get_uvalue=num_ps
  widget_control,(*pstate).numarc_text,get_uvalue=num_arc
  widget_control,(*pstate).numline_text,get_uvalue=height
  widget_control,(*pstate).numpixel_text,get_uvalue=width
  widget_control,(*pstate).pathout_text,get_value=pathout
  pathin=pathout
  temp0=complexarr(width,height)
;width=500
;height=500
;pathin='D:\IDL\xiqing\'
;pathout='D:\IDL\result\'

high=fltarr(width,height)
flt=fltarr(width,height)
tphase=fltarr(width,height)
dphase=fltarr(width,height)
bperp=fltarr(width,height)
incident=fltarr(width)
base=fltarr(height)
range=fltarr(width)
alfa=fltarr(height)

;------------------read hight-------------------------
infile=pathin+'sim_sar_rdc'
openr,lun,infile,/get_lun,/swap_endian
readu,lun,high
free_lun,lun

;-创建进度条
    wtlb = WIDGET_BASE(title = '进度条')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='处理中... 请稍等')
    Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0
    
for m=0,compu-1 do begin
int_pair=itab(*,m)

;文件读写命名
master=strcompress(string(int_pair(0)),/remove_all)
slave=strcompress(string(int_pair(1)),/remove_all)
flt_str=master+'-'+slave+'.flt'
incid_angle_int=master+'-'+slave+'.incident'
range_master_int=master+'-'+slave+'.range'
alfa_angle_int=master+'-'+slave+'.alfangle'
baseline_int=master+'-'+slave+'.base'
diff_str=master+'-'+slave+'.diff'
baseline_perp=master+'-'+slave+'.bperp'
infile=pathout+incid_angle_int
openr,lun,infile,/get_lun
readf,lun,incident
free_lun,lun

infile=pathout+range_master_int
openr,lun,infile,/get_lun
readf,lun,range
free_lun,lun

;读取干涉对基线倾角与空间基线信息
infile=pathout+alfa_angle_int
openr,lun,infile,/get_lun
readf,lun,alfa
free_lun,lun

infile=pathout+baseline_int
openr,lun,infile,/get_lun
readf,lun,base
free_lun,lun

;计算干涉对去平相位信息
infile=pathout+flt_str+'.phase.dat'
openr,lun,infile,/get_lun
readu,lun,flt
free_lun,lun


;去地形起伏引起相位趋势贡献: diff-insar
;逐点(pixel)计算
for j=0,width-1 do begin
  for k=0,height-1 do begin
    tphase(j,k)=base(k)*cos(incident(j)-alfa(k))*high(j,k)*4*!pi/(range(j)*sin(incident(j))*3.1e-2)
    bperp(j,k)=base(k)*cos(incident(j)-alfa(k))
  endfor
endfor

dphase=(flt-tphase-!pi)mod(!pi*2)+!pi

II=where(dphase lt (-1)*!pi)
s1=size(II)
III=where(dphase gt !pi)
s2=size(III)

if s1(0) ne 0 then begin
dphase(II)=dphase(II)+2*!pi
endif
if s2(0) ne 0 then begin
dphase(III)=dphase(III)-2*!pi
endif

;保存差分干涉相位
outfile=pathout+diff_str+'.phase.dat'
openw,lun,outfile,/get_lun
writeu,lun,dphase
free_lun,lun

;保存垂直基线
outfile=pathout+baseline_perp+'.dat'
openw,lun,outfile,/get_lun
writeu,lun,bperp
free_lun,lun

;outfile=pathout+diff_str+'.phase.txt'
;openw,lun,outfile,/get_lun
;printf,lun,dphase
;free_lun,lun

;print,m, MEAN( dphase, /DOUBLE , /NAN) 
Idlitwdprogressbar_setvalue, process, 100*m/compu
endfor
WIDGET_CONTROL,process,/Destroy
WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
;print,'Ok. Different Interferometry is completed!'
result=dialog_message(title='差分计算','差分计算完毕',/information)

  
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


PRO SARGUI_DIFF_INT,EVENT
;- 创建顶层组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='时序差分干涉',tlb_frame_attr=1,column=1,xsize=356,ysize=480,xoffset=xoffset,yoffset=yoffset)
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

;- 创建label组件
label=widget_label(tlb,value='——————————————————————————————',/align_center)
label=widget_label(tlb,value='参数文件路径:',/align_left)
;;- 创建干涉组件
;diffID=widget_base(tlb,row=1)
;label=widget_label(diffID,value='干涉输出路径:',xsize=90)
;diff_text=widget_text(diffID,value='',uvalue='',uname='diff_text',/editable,xsize=40)
;- 创建入射角组件
incidentID=widget_base(tlb,row=1)
label=widget_label(incidentID,value='入射角文件:',xsize=90)
incident_text=widget_text(incidentID,value='',uvalue='',uname='incident_text',/editable,xsize=40)
;- 创建斜距组件
rangeID=widget_base(tlb,row=1)
label=widget_label(rangeID,value='斜距文件:',xsize=90)
range_text=widget_text(rangeID,value='',uvalue='',uname='range_text',/editable,xsize=40)
;- 创建基线组件
perpID=widget_base(tlb,row=1)
label=widget_label(perpID,value='基线文件:',xsize=90)
base_text=widget_text(perpID,value='',uvalue='',uname='base_text',/editable,xsize=40)
;- 创建基线倾角组件
perpID=widget_base(tlb,row=1)
label=widget_label(perpID,value='基线倾角文件:',xsize=90)
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
label=widget_label(tlb,value='输出:',/align_left)

;- 创建输出路径
pathoutID=widget_base(tlb,row=1)
pathout_text=widget_text(pathoutID,value='',uvalue='',uname='pathout_text',/editable,xsize=40)
pathout_button=widget_button(pathoutID,value='获取输出路径',uname='pathout_button')
;- 创建功能按钮
funID=widget_base(tlb,row=1,/align_right)
ok=widget_button(funID,value='开始计算',uname='ok')
cl=widget_button(funID,value='退出',uname='cl')
;- 创建文件指针
state={sarlist_button:sarlist_button,sarlist_text:sarlist_text,itab_text:itab_text,itab_button:itab_button, $
       plist_text:plist_text,plist_button:plist_button,arcs_text:arcs_text,arcs_button:arcs_button, $
       numslc_text:numslc_text,numintf_text:numintf_text,numps_text:numps_text, $
       numarc_text:numarc_text,numline_text:numline_text,numpixel_text:numpixel_text, $
       incident_text:incident_text,range_text:range_text,pathout_button:pathout_button, $
       pathout_text:pathout_text,base_text:base_text,perp_text:perp_text,ok:ok,cl:cl   }
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'SARGUI_DIFF_INT',tlb,/no_block
END