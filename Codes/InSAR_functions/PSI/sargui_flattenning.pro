PRO SARGUI_FLATTENNING_EVENT,EVENT
widget_control,event.top,get_uvalue=pstate
uname=widget_info(event.id,/uname)
case uname of
  'sarlist_button': begin
    infile=dialog_pickfile(title='影像列表文件',filter='*.dat',file='sarlist.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).sarlist_text,set_value=infile
    widget_control,(*pstate).sarlist_text,set_uvalue=infile
  end
  'itab_button': begin
    infile=dialog_pickfile(title='影像配对文件',filter='*.dat',file='itab.dat',/read)
    if infile eq '' then return
    widget_control,(*pstate).itab_text,set_value=infile
    widget_control,(*pstate).itab_text,set_uvalue=infile
  end
  'path_button': begin
    widget_control,(*pstate).itab_text,get_value=infile
    if infile eq '' then begin
      result=dialog_message(title='影像列表文件','请选择影像列表文件',/information)
      return
    endif
    infile=file_dirname(infile)+'\'
    widget_control,(*pstate).pathin_text,set_value=infile
    widget_control,(*pstate).pathin_text,set_uvalue=infile
    widget_control,(*pstate).pathout_text,set_value=infile
    widget_control,(*pstate).pathout_text,set_uvalue=infile
  end
  'ok': begin
    ;- 以下为变量初始化
    widget_control,(*pstate).sarlist_text,get_value=sarlist
    if sarlist eq '' then begin
      result=dialog_message(title='影像列表文件','请选择影像列表文件',/information)
      return
    endif
    widget_control,(*pstate).itab_text,get_value=itabfile
    if itabfile eq '' then begin
      result=dialog_message(title='影像配对文件','请选择影像配对文件',/information)
      return
    endif
    widget_control,(*pstate).pathin_text,get_value=pathin
    if pathin eq '' then begin
      result=dialog_message(title='输入路径','请选择干涉文件路径',/information)
      return
    endif
    widget_control,(*pstate).pathout_text,get_value=pathout
    if pathout eq '' then begin
      result=dialog_message(title='输出路径','请选择参数输出路径',/information)
      return
    endif
    openr,lun,sarlist,/get_lun
    slcfile=''
    readf,lun,slcfile
    slcfile=slcfile+'.par'
    files=file_search(slcfile,count=filenum)
    if filenum eq 0 then begin
      result=dialog_message(title='头文件','未找到头文件',/information)
      return
    endif
    openr,lun,slcfile,/get_lun
    temp=''
    for i=0,9 do begin
      readf,lun,temp
    endfor
    readf,lun,temp
    columns=(strsplit(temp,/extract))(1)
    readf,lun,temp
    lines=(strsplit(temp,/extract))(1)     
    ;读取干涉配对信息
    day=file_lines(sarlist)
;    day=15
    compu=day(0)*(day(0)-1)/2
    itab=lonarr(5,compu)
    openr,lun,itabfile,/get_lun
    readf,lun,itab
    free_lun,lun
    ;int文件大小
    width=long(columns(0))
    height=long(lines(0))
    temp0=complexarr(width,height)
    fphase=fltarr(width,height)
    phase=fltarr(width,height)
;    pathin='D:\IDL\xiqing\'
;    pathout='D:\IDL\result\'
    ;- 以上为变量初始化


    ;- 创建进度条
    wtlb = WIDGET_BASE(title = '进度条')
    WIDGET_CONTROL,wtlb,/Realize
    process = Idlitwdprogressbar( GROUP_LEADER=wTlb, TIME=0, TITLE='处理中... 请稍等')
    Idlitwdprogressbar_setvalue, process, 0 ;-初始化进度条，初始值为0
    
    
    for m=0,compu-1 do begin
    int_pair=itab(*,m)

    ;文件读写命名
    ;- 读文件 master_slc.par&slave_slc.par
    master_par=strcompress(string(int_pair(0)),/remove_all)+'.rslc.par'
    slave_par=strcompress(string(int_pair(1)),/remove_all)+'.rslc.par'
    int_str=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.int'
    ;- 写文件
    flt_str=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.flt'
    incid_angle_int=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.incident'
    range_master_int=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.range'
    alfa_angle_int=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.alfangle'
    baseline_int=strcompress(string(int_pair(0)),/remove_all)+'-'+strcompress(string(int_pair(1)),/remove_all)+'.base'


;读取主影像成像时刻与位置参数
infile=pathin+master_par

openr,lun,infile,error=err,/get_lun
temp=''
if(err ne 0)then printf,-2,!error_state.msg               ;print error messages if ever have

;设置位置与时间变量空间
x=dblarr(12)
y=x
z=x
t=dblarr(12)
vx=dblarr(12)
vy=vx
vz=vx
;------------------skip the first 4 lines of the file-------------------
for i=0,3 do begin
readf, lun, temp
endfor
;------------------get the time of the image----------------------------
readf, lun, temp
;line=strsplit(temp,' ',/extract)
;year=line(1)
;month=line(2)
;day=line(3)
;------------------get the time paraments--------------------------
readf, lun, temp
line=strsplit(temp,' ',/extract)
start_time=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
center_time=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
end_time=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
azimuth_line_time=line(1)
readf, lun, temp
readf, lun, temp
line=strsplit(temp,' ',/extract)
range_samples=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
azimuth_lines=line(1)

;设立SLC时间坐标参数
time=dindgen(long(azimuth_lines))*double(azimuth_line_time)+double(start_time)

;------------------skip the following 11 lines--------------------------
for i=12,22 do begin
readf, lun, temp
endfor
;------------------all the times----------------------------------------

;获取斜距R信息
readf, lun, temp
line=strsplit(temp,' ',/extract)
near_range_slc=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
center_range_slc=line(1)
readf, lun, temp
line=strsplit(temp,' ',/extract)
far_range_slc=line(1)
;------------------all the times----------------------------------------

readf, lun, temp
readf, lun, temp
readf, lun, temp

;获取incidence_angle
readf, lun, temp
line=strsplit(temp,' ',/extract)
incidence_angle=double(line(1))
;------------------all the times----------------------------------------


;------------------skip the following 17 lines--------------------------
for i=30,46 do begin
readf, lun, temp
endfor
;------------------all the times----------------------------------------


;获取卫星轨道参数信息
readf, lun, temp
line=strsplit(temp,' ',/extract)
time_of_first_state_vector=double(line(1))

readf, lun, temp
line=strsplit(temp,' ',/extract)
state_vector_interval=double(line(1))

;------------------all the times----------------------------------------

;获取12个时刻的卫星状态矢量
for i=0,11 do begin
readf, lun, temp
line=strsplit(temp,' ',/extract)
    x(i)=double(line(1))            ;get x coordinate at the i-th orbit position
    y(i)=double(line(2))            ;get y .....
    z(i)=double(line(3))            ;get z .....
    t(i)=time_of_first_state_vector+state_vector_interval*i
readf, lun, temp
line=strsplit(temp,' ',/extract)
    vx(i)=double(line(1))            ;get x coordinate at the i-th orbit position
    vy(i)=double(line(2))            ;get y .....
    vz(i)=double(line(3))            ;get z .....
endfor
free_lun,lun
;----------------------------------------------------------------------

;空间位置内插建模
coefx=svdfit(t,x,3,/double)
coefy=svdfit(t,y,3,/double)
coefz=svdfit(t,z,3,/double)

;获得每个azimuth_pixel上卫星位置
x_postion=poly(time,coefx)
y_postion=poly(time,coefy)
z_postion=poly(time,coefz)
;----------------------------------------------------------------------

;速度矢量内插建模
coefvx=svdfit(t,vx,3,/double)
coefvy=svdfit(t,vy,3,/double)
coefvz=svdfit(t,vz,3,/double)

;获得每个azimuth_pixel上卫星速度矢量
x_velocity=poly(time,coefvx)
y_velocity=poly(time,coefvy)
z_velocity=poly(time,coefvz)
;----------------------------------------------------------------------

;斜距R内插建模
range_data=[double(near_range_slc),double(center_range_slc),double(far_range_slc)]
r1=[0,(width-1.0)/2,width-1]
rn=indgen(width)

;获得每个range_pixel上的斜距R
coefr=svdfit(r1,range_data,2,/double)
range=float(poly(rn,coefr))

;获取每个range_pixel上的入射角(/弧度)
dd=double(center_range_slc)*cos(incidence_angle)
incident=float(acos(dd/range))

;保存干涉对入射角与斜距
outfile=pathout+incid_angle_int
openw,lun,outfile,/get_lun
printf,lun,incident
free_lun,lun

outfile=pathout+range_master_int
openw,lun,outfile,/get_lun
printf,lun,range
free_lun,lun
;----------------------------------------------------------------------


;读取从影像成像时刻与位置参数
infile=pathin+slave_par

openr,lun,infile,error=err,/get_lun
temp=''
if(err ne 0)then printf,-2,!error_state.msg               ;print error messages if ever have

;设置位置与时间变量空间
xs=dblarr(12)
ys=xs
zs=xs
ts=dblarr(12)
;------------------skip the first 4 lines of the file-------------------
for i=0,3 do begin
readf, lun, temp
endfor
;------------------get the time of the image----------------------------
readf, lun, temp

;------------------get the time paraments--------------------------
readf, lun, temp
line=strsplit(temp,' ',/extract)
start_time=line(1)

readf, lun, temp
readf, lun, temp

readf, lun, temp
line=strsplit(temp,' ',/extract)
azimuth_line_time=line(1)

readf, lun, temp
readf, lun, temp
line=strsplit(temp,' ',/extract)
range_samples=line(1)

readf, lun, temp
line=strsplit(temp,' ',/extract)
azimuth_lines=line(1)

;设立SLC时间坐标参数
times=dindgen(long(azimuth_lines))*double(azimuth_line_time)+double(start_time)

;------------------skip the following 11 lines--------------------------
for i=12,46 do begin
readf, lun, temp
endfor
;------------------all the times----------------------------------------


;获取卫星轨道参数信息
readf, lun, temp
line=strsplit(temp,' ',/extract)
time_of_first_state_vector=double(line(1))
;a=time_of_first_state_vector

readf, lun, temp
line=strsplit(temp,' ',/extract)
state_vector_interval=double(line(1))

;------------------all the times----------------------------------------

;获取12个时刻的卫星状态矢量
for i=0,11 do begin
readf, lun, temp
line=strsplit(temp,' ',/extract)
    xs(i)=double(line(1))            ;get x coordinate at the i-th orbit position
    ys(i)=double(line(2))            ;get y .....
    zs(i)=double(line(3))            ;get z .....
    ts(i)=time_of_first_state_vector+state_vector_interval*i
readf, lun, temp
endfor
free_lun,lun
;----------------------------------------------------------------------

;空间位置内插建模
coefxs=svdfit(ts,xs,3,/double)
coefys=svdfit(ts,ys,3,/double)
coefzs=svdfit(ts,zs,3,/double)

;获得每个azimuth_pixel上卫星位置
xs_postion=poly(times,coefxs)
ys_postion=poly(times,coefys)
zs_postion=poly(times,coefzs)
;----------------------------------------------------------------------

;获得每个azimuth_pixel上的基线倾角

alfa=float(atan((zs_postion-z_postion)/sqrt((xs_postion-x_postion)^2+(ys_postion-y_postion)^2)))

;附加2pi整周判断
for s=0,azimuth_lines-1 do begin

  if ys_postion(s)-y_postion(s)+(xs_postion(s)-x_postion(s))*y_velocity(s)/x_velocity(s) lt 0 then begin
  
    alfa(s)=!pi-alfa(s)
    
  endif
  
endfor

;计算获取空间基线信息
base=float(sqrt((xs_postion-x_postion)^2+(ys_postion-y_postion)^2+(zs_postion-z_postion)^2))

;去参考椭球相位趋势贡献: flatenning
;逐点(pixel)计算
for j=0,width-1 do begin
  for k=0,height-1 do begin
    fphase(j,k)=base(k)*sin(incident(j)-alfa(k))*4*!pi/3.1e-2
  endfor
endfor

;保存干涉对基线倾角与空间基线信息
outfile=pathout+alfa_angle_int
openw,lun,outfile,/get_lun
printf,lun,alfa
free_lun,lun

outfile=pathout+baseline_int
openw,lun,outfile,/get_lun
printf,lun,base
free_lun,lun

;计算干涉对去平相位信息并保存
infile=pathout+int_str+'.phase.dat'
openr,lun,infile,/get_lun
readu,lun,phase
free_lun,lun

flt=(phase-fphase+!pi)mod(!pi*2)-!pi
;if MEAN( flt, /DOUBLE , /NAN) lt -6.2 then begin
;   flt=flt+2*!pi
;endif
;if MEAN( flt, /DOUBLE , /NAN) gt 6.2 then begin
;   flt=flt-2*!pi
;endif
II=where(flt lt (-1)*!pi)
s1=size(II)
III=where(flt gt !pi)
s2=size(III)

if s1(0) ne 0 then begin
flt(II)=flt(II)+2*!pi
endif
if s2(0) ne 0 then begin
flt(III)=flt(III)-2*!pi
endif
 
outfile=pathout+flt_str+'.phase.dat'
openw,lun,outfile,/get_lun
writeu,lun,flt
free_lun,lun

;----------------------------------------------------------------------
;print,m, MEAN( flt, /DOUBLE , /NAN) 
value=100*m/compu
Idlitwdprogressbar_setvalue, process, value
endfor
    WIDGET_CONTROL,process,/Destroy
    WIDGET_CONTROL,wTlb, /Destroy  ;-销毁进度条
    result=dialog_message(title='处理完毕','输出去平相位，入射角文件，斜距，斜距倾角，基线文件，ps坐标文件',/information)
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


PRO SARGUI_FLATTENNING,EVENT
;- 干涉数据去平
;- 输出去平相位，入射角文件，斜距，斜距倾角，基线文件，ps坐标文件
;- 创建顶层组件
device,get_screen_size=screen_size
xoffset=screen_size(0)/3
yoffset=screen_size(1)/3
tlb=widget_base(title='去平地效应',tlb_frame_attr=1,column=1,xsize=320,ysize=150,xoffset=xoffset,yoffset=yoffset)
;- 创建sarlist组件
sarlistID=widget_base(tlb,tlb_frame_attr=1,row=1)
sarlist_text=widget_text(sarlistID,value='',uvalue='',uname='sarlist_text',/editable,xsize=33)
sarlist_button=widget_button(sarlistID,value='影像列表文件',uname='sarlist_button',xsize=100)
;- 创建itab组件
itabID=widget_base(tlb,tlb_frame_attr=1,row=1)
itab_text=widget_text(itabID,value='',uvalue='',uname='itab_text',/editable,xsize=33)
itab_button=widget_button(itabID,value='影像配对文件',uname='itab_button',xsize=100)
;- 创建输入输出路径组件
pathID=widget_base(tlb,tlb_frame_attr=1,column=2)
pathtext=widget_base(pathID,column=1)
pathin_text=widget_text(pathtext,value='',uvalue='',uname='pathin_text',/editable,xsize=32)
pathout_text=widget_text(pathtext,value='',uvalue='',uname='pathout_text',/editable,xsize=32)
path_button=widget_button(pathID,value='获取输入输出路径',uname='path_button',ysize=50,xsize=100)
;- 创建功能组件
funID=widget_base(tlb,tlb_frame_attr=1,row=1,/align_right)
ok=widget_button(funID,value='计算',xsize=50,uname='ok')
cl=widget_button(funID,value='退出',xsize=50,uname='cl')
state={sarlist_text:sarlist_text,sarlist_button:sarlist_button, $
       itab_text:itab_text,itab_button:itab_button,pathin_text:pathin_text,$
       pathout_text:pathout_text,path_button:path_button}
pstate=ptr_new(state,/no_copy)
widget_control,tlb,set_uvalue=pstate
widget_control,tlb,/realize
xmanager,'SARGUI_FLATTENNING',tlb,/no_block
END