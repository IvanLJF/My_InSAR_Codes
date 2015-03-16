PRO SARGUI_BASEMAP,EVENT
infile=dialog_pickfile(title='影像列表文件',filter='*.dat',file='sarlist.dat',/read)
if infile eq '' then return
nlines=file_lines(infile)
names=strarr(nlines)
openr,lun,infile,/get_lun
readf,lun,names
free_lun,lun
file=names(0)

data_num=nlines
date_str=lonarr(data_num)
pa=file_dirname(file)+'\'
;pa='D:\InSARIDL\SARGUI\IMAGES\'

for i=0,nlines-1 do begin
  temp=names(i)
  temp=file_basename(temp)
  temp=strsplit(temp,'.',/extract)
  date_str(i)=temp(0);读取影像名称
endfor


year=floor(date_str/10000)
month=floor(date_str/100)-year*100
day=date_str-year*10000-month*100
date_num=julday(month,day,year)

;绌洪棿鍩虹嚎 space baseline


s=fix(size(date_str,/dimensions))
dim=s(0)

x_center=dblarr(dim)
y_center=dblarr(dim)
z_center=dblarr(dim)
basel=dblarr((dim-1)*dim/2)

for k=0,dim-1 do begin
pa1=strcompress(string(date_str(k)),/remove_all)
infile=pa+pa1+'.rslc.par'

openr,lun,infile,error=err,/get_lun
print,lun
temp=''
if(err ne 0)then printf,-2,!error_state.msg               ;print error messages if ever have
x=dblarr(12)
y=x
z=x
t=dblarr(12)
;------------------skip the first 4 lines of the file-------------------
for i=0,3 do begin
readf, lun, temp
endfor
;------------------get the time of the image----------------------------
readf, lun, temp
line=strsplit(temp,' ',/extract)
year=line(1)
month=line(2)
day=line(3)
;------------------get the center time--------------------------
readf, lun, temp
readf, lun, temp
line=strsplit(temp,' ',/extract)
center_time=line(1)
;------------------skip the following 39 lines--------------------------
for i=7,46 do begin
readf, lun, temp
endfor
;------------------skip the following 43 lines--------------------------

;------------------all the times----------------------------------------
readf, lun, temp
line=strsplit(temp,' ',/extract)
time_of_first_state_vector=double(line(1))
;a=time_of_first_state_vector
print, time_of_first_state_vector
readf, lun, temp
line=strsplit(temp,' ',/extract)
state_vector_interval=double(line(1))
;b=state_vector_interval
print,state_vector_interval
;------------------all the times----------------------------------------


;------------------get the state_vector_position_1----------------------
;for i=49,71 do begin
for i=0,11 do begin
readf, lun, temp
line=strsplit(temp,' ',/extract)
    x(i)=double(line(1))            ;get x coordinate at the i-th orbit position
    y(i)=double(line(2))            ;get y .....
    z(i)=double(line(3))            ;get z .....
    t(i)=time_of_first_state_vector+state_vector_interval*i
    print,x(i),y(i),z(i),'The time is',t(i)
readf, lun, temp
endfor
coefx=svdfit(t,x,3,/double)
;;coefx=poly_fit(x,t,4,/double)
;coefy=poly_fit(t,y,4,/double)
;coefz=poly_fit(t,z,4,/double)

;coefx=linfit(t,x)
;coefx=poly_fit(x,t,4,/double)
coefy=svdfit(t,y,3,/double)
coefz=svdfit(t,z,3,/double)

;----------------------------------------------------------------------
x_center(k)=poly(center_time,coefx)
;print,x_center(k),'  The time is ',center_time
;if (x_center(k)-x(1) gt 1000) then begin
;print, 'Error! Poly_fit is wrong!'
;end
y_center(k)=poly(center_time,coefy)
z_center(k)=poly(center_time,coefz)
;print,'The center position of the slc',date_str(k),' is', x_center(k),y_center(k),z_center(k),'The time is',center_time
;print,lun
free_lun,lun

endfor


flagnum=floor(data_num/2)

spaceline=fltarr(data_num)
for i=0,data_num-1 do begin
  if i ne flagnum then begin
    if z_center(i) gt z_center(flagnum) then begin
    ff=-1
    endif else begin
    ff=1
    endelse
    spaceline(i)=ff*((x_center(i)-x_center(flagnum))^2+(y_center(i)-y_center(flagnum))^2+(z_center(i)-z_center(flagnum))^2)^0.5
  endif
endfor

Cn2=data_num*(data_num-1)
X=lonarr(Cn2)
Y=fltarr(Cn2)
numb=0

;  axis, xaxis=0,xrange=[date_num(0),date_num(data_num-1)]
;  axis, yaxis=0,yrange=[-2000,2000]
for i=0,data_num-2 do begin
  for j=i+1,data_num-1 do begin
;    X(numb)=date_num(i)-date_num(0) & X(numb+1)=date_num(j)-date_num(0)
    X(numb)=date_num(i) & X(numb+1)=date_num(j)
    Y(numb)=spaceline(i) & Y(numb+1)=spaceline(j)
;    s1=[X(numb)-date_num(0),X(numb+1)-date_num(0)]
;    s1=[X(numb),X(numb+1)]
;    s2=[Y(numb),Y(numb+1)]
  
;    plots,columns[thistriangle],rows[thistriangle],color=1,/device
;    plots,columns[thistriangle],rows[thistriangle],color=1,/device
    numb=numb+2
  endfor
endfor

device,decomposed=1
;!P.BACKGROUND='FFFFFF'XL
;!P.COLOR='000000'XL
;!P.BACKGROUND='000000'XL
;!P.COLOR='FFFFFF'XL

date_time=X & displacement=Y
date_lable=label_date(date_format=['%M,%Y'])
start=julday(1,1,year(0))

oPlotWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, DIMENSIONS = [800,600]) 
oPlotView = OBJ_NEW('IDLgrView', /DOUBLE) 
oPlotModel = OBJ_NEW('IDLgrModel') 
oPlot = OBJ_NEW('IDLgrPlot', date_time, displacement, /DOUBLE) 

oPlot->GetProperty, XRANGE = xr, YRANGE = yr 
xs = NORM_COORD(xr) 
xs[0] = xs[0] - 0.5 
ys = NORM_COORD(yr) 
ys[0] = ys[0] - 0.5 
oPlot->SetProperty, XCOORD_CONV = xs, YCOORD_CONV = ys 

; X-axis title. 
oTextXAxis = OBJ_NEW('IDLgrText', 'Image Date (Month/Year)') 
; X-axis (date/time axis). 
oPlotXAxis = OBJ_NEW('IDLgrAxis', 0, /EXACT, RANGE = xr, $ 
   XCOORD_CONV = xs, YCOORD_CONV = ys, TITLE = oTextXAxis, $ 
   LOCATION = [xr[0], yr[0]], TICKDIR = 0, $ 
   TICKLEN = (0.02*(yr[1] - yr[0])), $ 
   TICKFORMAT = ['LABEL_DATE'], TICKINTERVAL = 2, $ 
   TICKUNITS = ['Time']) 
; Y-axis title. 
oTextYAxis = OBJ_NEW('IDLgrText', 'Space Baseline (Meters)') 
; Y-axis. 
oPlotYAxis = OBJ_NEW('IDLgrAxis', 1, /EXACT, RANGE = yr, $ 
   XCOORD_CONV = xs, YCOORD_CONV = ys, TITLE = oTextYAxis, $ 
   LOCATION = [xr[0], yr[0]], TICKDIR = 0, $ 
   TICKLEN = (0.02*(xr[1] - xr[0]))) 
; Plot title. 
oPlotText = OBJ_NEW('IDLgrText', 'Base Map', $ 
   LOCATIONS = [(xr[0] + xr[1])/2., $ 
      (yr[1] - (0.1*(yr[0] + yr[1])))], $ 
   XCOORD_CONV = xs, YCOORD_CONV = ys, $ 
   ALIGNMENT = 0.5) 

oPlotModel->Add, oPlot 
oPlotModel->Add, oPlotXAxis 
oPlotModel->Add, oPlotYAxis 
oPlotModel->Add, oPlotText 
oPlotView->Add, oPlotModel 

oPlotWindow->Draw, oPlotView 

;plot,X,Y,linestyle=5,psym=-6

;result=dialog_message('是否输出文件？',/question,/default_no)
;if result eq 'No' then return
;if result eq 'Yes' then  begin
;  outfile=dialog_pickfile(title='请选择输出文件',filter='*.bmp',file='basemap.bmp',/overwrite_prompt)
;  if outfile eq '' then return
;  write_bmp,outfile,tvrd()
;endif
end