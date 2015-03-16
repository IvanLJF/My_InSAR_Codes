PRO solution
; Solution of deformation rates and height errors
; Input
; V=Gridded velocity values (matrix)
; H=Gridded elevation values (matrix)
; DifInt=Gridded differential phase values (matrix)
; dT=Time separations for all interferograms (vector)
; B=Perpendicular-baseline values for all interferograms (vector)
; M=The total number of interferograms
; N=Square-image size
; num_PS=Total number of PS points
; XY=Coordinates of PS Points
;
; Output
; V_PS=Deformation velocity at all PS points
; H_PS=Height error at all PS points
; XY=Coordinates of all PS points
; TRI=Vertex information of all triangles
; Arcs=All final arcs without arc duplication
; dv_ddh=Increments of velocity and height error along arcs

; Simulating discrete points to be estimated
;infile='F:\Phoniex\PS_Points\test\simulation\PSCoor.dat';
;[pathstr, name] = fileparts(infile);
;fwritebk(XY, infile, 'uint16');          ; saving PS coordinates
;disp(['; Saving coordinates of all PS points into ', infile, ', OK!']);

; Simulating discrete points to be estimated
;N=64;         ; Matrix dimension of interferogram=N by N
;num_PS=50;    ; Total number of discrete points
;XY=[1+round(rand(num_PS, 1)*(N-1)), 1+round(rand(num_PS,1)*(N-1))];  ; Image coordinate, column and row
;XY=unique(XY, 'rows');   ; remove duplication
;num_PS=length(XY(:,1));    ; Final total number of PS points without duplication
;disp(' ');
;disp(['; Total number of all PS points == ', num2str(num_PS)]);

; Extracting deformation velocity and and height error at all PS points
IJ=(XY[0,*]-1)*N+XY[1,*];计算PS点的索引
V_PS=V(IJ);依据索引取得PS点的形变速率
H_PS=H(IJ);依据索引取得PS点的高程误差

TRI=delaunay(XY[0,*], XY[1,*]);生成Delaunay三角网
S=size(TRI);取得三角网TRI矩阵的信息
num_TRI=S[2];取得三角网的个数，亦即TRI的行数
C=S[1];取得TRI的列数，一般是3

arc=[[TRI[0,*], TRI[1,*]],[TRI[0,*], TRI[2,*]],[TRI[1,*],TRI[2,*]]];生成初始弧段,含有冗余项

;对数组进行排序
 Row3_sort,arc
;去除弧段冗余项



;Arcs=unique(arc, 'rows');     ; removing the row-along repetitions

;获取总的弧段数
S1=size(Arcs);
num_Arcs=S1[2];
C=S1[1];
;删除变量 arc c
delvar,arc,c;

;Some interferometric parameters
Lamda=56;   ; ERS C-band radar wavelength in mm
R0=850000;      ; mid-range in meters
thita=23;            ; ERS radar loook angle in degree
L1=4*pi/Lamda;                ; Constant 1
L2=R0*sin(thita*pi/180);   ; Constant 2
j=complex(0,1); 定义复数值

dv_ddh=zeros(num_Arcs, 3);   ; initialize variable
;options=optimset('Display','off');   ; set up optimization without any display
;options = optimset(options, 'TolFun',1e-8);
;;options = optimset(options,'Display','iter');
;options = optimset(options,'TolX', 1e-5);
;;options = optimset(options,'Diagnostics', 'on');
;;options = optimset(options, 'GradConstr', 'on'); ;, 'Jacobian', 'on');
;options = optimset(options, 'DiffMaxChange', 0.0001);
;;options = optimset(options, 'NodeSearchStrategy', 'df'); 

KK=0;            ; counter of fail number 
GB_arc=ones(num_Arcs, 1);            ; flag of goodness or badness for solution along each arc
dv_low=-0.2;          ; mm/day; for velocity increment
dv_up=0.2;
ddh_low=-20;        ; in meters, for height-error increment
ddh_up=20;
dv_size=100;        ; grid size for searching solution
ddh_size=100;
dv_inc=(dv_up-dv_low)/(dv_size-1);            ; get tiny velocity increment corresponding to each grid size
ddh_inc=(ddh_up-ddh_low)/(ddh_size-1);     ; get tiny height-error increment corresponding to each grid size
;dv_try=[dv_low:dv_inc:dv_up];                   ; all possible veclocity increments at all grid points
dv_try=LINDGEN(dv_size)*dv_inc+dv_low;
;ddh_try=[ddh_low:ddh_inc:ddh_up];          ; all possible height-error increments at all grid points
ddh_try=LINDGEN(ddh_size)*ddh_inc+ddh_low;
y=intarr(1,dv_size*ddh_size);                         
Meshgrid,dv_try,ddh_try,dv=dv,ddh=ddh;           
xdv=REFORM(dv,1,N_ELEMENTS(dv));
xddh=REFORM(ddh,1,N_ELEMENTS(ddh));
for i=1,num_Arcs,1 do begin   ; loop on all arcs
    PS1=Arcs(0, i);
    PS2=Arcs(1, i);
    x1=XY(0,PS1);    ; column coordinate
    y1=XY(1,PS1);    ; row coordinate
    x2=XY(0,PS2);
    y2=XY(1,PS2);
  
        for k=1,M,1 do begin    ;for M interferograms
        dpm=DifInt(x2, y2, k)-DifInt(x1, y1, k);   ; Phase increament from differential interferogram along arc (wrapped phase in radians)
        dpc=L1*dT(k);                                       ; Coefficient for deformation
        dph=L1*1000*B(k)/L2;                          ; Coefficient for height error
        str=COMPLEX(0,0);
        str=str+COMPLEX(COS(dpm-(dpc*x+dph*y)),SIN(dpm-dpc*x+dph*y));
    endfor 
    
    for k=1,M,1 do begin    ;for M interferograms
        dpm=DifInt(x2, y2, k)-DifInt(x1, y1, k);   ; Phase increament from differential interferogram along arc (wrapped phase in radians)
        dpc=L1*dT(k);                                       ; Coefficient for deformation
        dph=L1*1000*B(k)/L2;                          ; Coefficient for height error
        str1=COMPLEX(0,0);
        str1=fun1+complex(cos(dmp-(dpc*x(1)+dph*x(2))),sin(dmp-(dpc*x(1)+dph*x(2))));
    endfor
   endfor
    fun=ABS(str)/M;
    y=feval(fun, Xdv, Xddh);
    coh_max=max(y,II);
    tt(1)=Xdv(II);
    tt(2)=Xddh(II);
    fun=ABS(str1)/M; 
    nobj=fun;
    x=[tt(1),tt(2)];
    xbnd=[-dv_inc+tt(1), -ddh_inc+tt(2), dv_inc+tt(1), ddh_inc+tt(2)];
    gbnd=0;
    nobj=fun;
    gcop='fmincon';
    constrained_min, x, xbnd, gbnd, nobj, gcop;
    dv_ddh(0,i)=x(1);
    dv_ddh(1,i)=x(2);
    dv_ddh(2,i)=abs(coh_max);
    end 

function ROW3_SORT,arc
infor=size(arc)
clom_num=infor(2)
row=sort(arc(1,*))
;a2=arc(1,row)
b=arc(*,row)
;基于第1列结果的相同项，依照第0列进行排列
k=0
for c=1,clom_num-1 do begin
if b(1,c) eq b(1,c-1) then begin
  k=k+1
endif
if b(1,c) ne b(1,c-1) && k gt 0 then begin  
    tmp1=intarr(k)
    tmp1=b(0,c-1-k:c-1)
    row1=sort(tmp1)
    ;调换基于第0列的位置
    m=intarr(3,k)
    m=b(*,c-1-k:c-1)
    m1=m(*,row1)
    b(*,c-1-k:c-1)=m1
    ;基于第0列结果的相同项，依照第2列进行排列
    k1=0
    for c1=c-k,c-1 do begin
    if b(0,c1) eq b(0,c1-1) then begin
      k1=k1+1
    endif
    if k1 gt 0 && b(0,c1) ne b(0,c1-1) then begin
         tmp2=intarr(k1)
         tmp2=b(2,c1-1-k1:c1-1)
         row2=sort(tmp2)
         ;调换基于第2列的位置
         m=intarr(3,k1)
         m=b(*,c1-1-k1:c1-1)
         m1=m(*,row2)
         b(*,c1-1-k1:c1-1)=m1
         k1=0    
    endif
    endfor
   k=0 
endif
endfor
arc=b;
end

pro Meshgrid,x,y,dv=dv,ddh=ddh
  x_dim = N_ELEMENTS(x)
  dv=FLTARR(x_dim,x_dim)
  FOR i=0,x_dim-1 DO BEGIN
    FOR j=0,x_dim-1 DO BEGIN
      dv[j,i]=x[j]
    ENDFOR
  ENDFOR
  y_dim=N_ELEMENTS(y)
  y=TRANSPOSE(y)
  ddh=FLTARR(y_dim,y_dim)
  FOR i=0,y_dim-1 DO BEGIN
    FOR j=0,y_dim-1 DO BEGIN
      ddh[j,i]=y[j]
    ENDFOR
  ENDFOR
END

FUNCTION Objfun,x,y,num_intf,dintf,r,thi,bperp,dt
  dph=DBLARR(num_intf)
  lamda=56
  l1=4*!pi/lamda
  fun=COMPLEX(0,0)
  dph=dintf[1,*]-dintf[0,*]
  coef_dv=l1*dt
  coef_ddh=l1*1000*bperp/(r*SIN(thi))
  FOR i=0,num_intf-1 DO BEGIN
    fun=fun+COMPLEX(COS(dph(i)-(coef_dv(i)*x+coef_ddh(i)*y)),SIN(dph(i)-(coef_dv(i)*x+coef_ddh(i)*y)))
  ENDFOR
  fun=ABS(fun)/num_intf
  RETURN,fun
END



