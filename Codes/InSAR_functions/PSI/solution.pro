PRO solution
  ;该程序利用ferretti相关系数模型来求解线性形变增量和高程误差增量。
  ;
  ;参数定义
  num_slc=15
  num_intf=num_slc*(num_slc-1)/2
  num_ps=3211
  num_arc=9597
  nlines=500
  npixels=500
  pathin='D:\IDL\result\'
  pathout='D:\IDL\result\'
  
  ;数组定义
  pscoor=ULONARR(2,num_ps)
  wphi=FLTARR(npixels,nlines)
  wphi_ps=FLTARR(num_ps,num_intf)
  thi=FLTARR(npixels,1)
  thi_ps=FLTARR(num_ps,num_intf)
  range=DBLARR(npixels,1)
  range_ps=DBLARR(num_ps,num_intf)
  bperp=FLTARR(npixels,nlines)
  bperp_ps=FLTARR(num_ps,num_intf)
  thita=FLTARR(num_arc,num_intf)
  rg=DBLARR(num_arc,num_intf)
  bp=FLTARR(num_arc,num_intf)
  itab=LONARR(5,num_intf)
  dv_ddh_coh=FLTARR(3,num_arc)
  
  ;读取itab文件
  OPENR,lun,'D:\IDL\result\itab.txt',/get_lun
  READF,lun,itab
  FREE_LUN,lun
  
  ;获取itab中的时间基线数据，并将其存为dt列数组
  dt=itab[2,*]
  
  ;读取PS坐标数据文件，将其保存为一个num_ps*2的数组pscoor[2,num_ps]
  plist=COMPLEXARR(num_ps)
  pscoor=INTARR(2,num_ps)
  OPENR,lun,'D:\IDL\result\plist.txt',/get_lun
  READF,lun,plist
  FREE_LUN,lun
  pscoor[0,*]=REAL_PART(plist)
  pscoor[1,*]=IMAGINARY(plist)
  OPENW,lun,pathout+'pscoor.txt',/get_lun
  PRINTF,lun,pscoor
  FREE_LUN,lun
  
  ;读取弧段数据文件，并将其存为num_arcs*2的数组，其中共有num_arcs行
  ;两列，列元素对应于弧段两端点在plist文件中的PS点序列号。
  arctemp=COMPLEXARR(num_arc)
  noarc=INTARR(2,num_arc)
  OPENR,lun,'D:\IDL\result\arcs.txt',error=err,/get_lun
  READF,lun,arctemp
  FREE_LUN,lun
  noarc[0,*]=REAL_PART(arctemp)
  noarc[1,*]=IMAGINARY(arctemp)
  
  ;循环读取所有干涉组合的相关数据,分别包括入射角、斜距、垂直基线和差分干涉相位数据
  FOR m=0,num_intf-1 DO BEGIN
    int_pair=itab(*,m)
    PRINT,m
    master=STRCOMPRESS(STRING(int_pair(0)),/remove_all)
    slave=STRCOMPRESS(STRING(int_pair(1)),/remove_all)
    incid_angle_int=master+'-'+slave+'.incident'
    range_master_int=master+'-'+slave+'.range'
    diff_str=master+'-'+slave+'.diff.phase.dat'
    bperp_str=master+'-'+slave+'.bperp.dat'
    
    ;读取所有干涉组合的差分干涉相位，并提取相应PS点上的相位数据
    diffpath=pathin+diff_str
    OPENR,lun,diffpath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READU,lun,wphi
    FREE_LUN,lun
    wphi_ps[*,m]=wphi[pscoor[1,*],pscoor[0,*]]
    
    ;读取所有干涉组合的入射角数据文件，并提取相应PS点上的入射角数据
    incidentpath=pathin+incid_angle_int
    OPENR,lun,incidentpath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READF,lun,thi
    FREE_LUN,lun
    thi_temp=rebin(thi,npixels,nlines)
    thi_ps[*,m]=thi_temp[pscoor[1,*],pscoor[0,*]]
    
    ;读取所有干涉组合的斜距数据文件
    rangepath=pathin+range_master_int
    OPENR,lun,rangepath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READF,lun,range
    FREE_LUN,lun
    range_temp=rebin(range,npixels,nlines)
    range_ps[*,m]=range_temp[pscoor[1,*],pscoor[0,*]]
    
    ;读取所有干涉组合的垂直基线数据文件
    bperppath=pathin+bperp_str
    OPENR,lun,bperppath,error=err,/get_lun
    IF(err NE 0) THEN PRINTF,-2,!error_state.msg
    READU,lun,bperp
    FREE_LUN,lun
    bperp_ps[*,m]=bperp[pscoor[1,*],pscoor[0,*]]
  ENDFOR
  ;-------------------------------------------
  ;以下为解空间搜索部分
  ;若需将上部分PS相位提取和下部分解空间搜索列为两个单独的菜单步骤
  ;则由此分开，但下部分需重写上半部分一些内容。合二为一，只为一次读取
  ;数据，后部分直接使用内存数据。
  ;-------------------------------------------
  FOR i=0,num_arc-1 DO BEGIN
    PRINT,'be processing the'+STRING(i)+'th arc!'
    mm=noarc[0,i]     ;获取当前弧段的第一个PS点的序号
    nn=noarc[1,i]    ;获取当前弧段的第二个PS点的序号
    thita[i,*]=(thi_ps[mm,*]+thi_ps[nn,*])/2   ; 取当前弧段两PS点入射角的平均值
    rg[i,*]=(range_ps[mm,*]+range_ps[nn,*])/2       ;取当前弧段两PS点斜距的平均值
    bp[i,*]=(bperp_ps[mm,*]+bperp_ps[nn,*])/2     ;取当前弧段两PS点垂直基线的平均值
    Incsolut,num_intf,[wphi_ps[mm,*],wphi_ps[nn,*]],rg[i,*],thita[i,*],bp[i,*],dt,dv=dv,ddh=ddh,coh=coh
    dv_ddh_coh[*,i]=[dv,ddh,coh]
    PRINT,dv_ddh_coh[*,i]
  ENDFOR
  ;输出线性形变速率和高程误差增量及各条弧段相关模型系数值的文件dv_ddh_coh.txt
  OPENW,lun,pathout+'dv_ddh_coh.txt',/get_lun
  PRINTF,lun,dv_ddh_coh
  FREE_LUN,lun
END
PRO Incsolut,num_intf,dintf,r,thi,bperp,dt,dv=dv,ddh=ddh,coh=coh
  ;设置速率维和高程误差增量维的搜索粗步长
  tt1=0.0
  tt2=0.0
  dv_low=-0.03
  dv_up=0.03
  ddh_low=-15.0
  ddh_up=15.0
  dv_size=21
  ddh_size=21
  dv_inc=(dv_up-dv_low)/(dv_size-1)
  ddh_inc=(ddh_up-ddh_low)/(ddh_size-1)
  dv_try=LINDGEN(21)*dv_inc+dv_low
  ddh_try=LINDGEN(21)*ddh_inc+ddh_low
  ;设置初始解空间粗格网
  Meshgrid,dv_try,ddh_try,dv=dv,ddh=ddh
  xdv=REFORM(dv,1,N_ELEMENTS(dv))
  xddh=REFORM(ddh,1,N_ELEMENTS(ddh))
  y=Objfun(xdv,xddh,num_intf,dintf,r,thi,bperp,dt)
  coh=MAX(y,max_subscript)
  tt1=xdv[max_subscript]
  tt2=xddh[max_subscript]      ;从粗格网获得的初始解
  ;------------------------------------
  ;  设置精细的解空间搜索步长
  dvinc=2*dv_inc/20
  ddhinc=2*ddh_inc/20
  nv=CEIL(ABS(tt1-dv_inc)/dvinc)+1l
  nh=CEIL(ABS(tt2-ddh_inc)/ddhinc)+1l
  dv_tryn=[tt1-LINDGEN(nv)*dvinc+dv_inc]           ;all possible veclocity increments at all grid points
  ddh_tryn=[tt2-LINDGEN(nh)*ddhinc+ddh_inc]        ;all possible height-error increments at all grid points
  Meshgrid,dv_tryn,ddh_tryn,dv=dv,ddh=ddh
  xdv=REFORM(dv,N_ELEMENTS(dv),1)
  xddh=REFORM(ddh,N_ELEMENTS(ddh),1)
  y=Objfun(xdv,xddh,num_intf,dintf,r,thi,bperp,dt)
  coh=MAX(y,max_subscript)
  x1=xdv[max_subscript]
  x2=xddh[max_subscript]
  ;返回形变速率增量和高程误差增量及模型相关系数值
  dv=x1          ;单位: mm/day, 形变速率增量
  ddh=x2         ;单位: m, 高程误差增量
  coh=ABS(coh)
END
PRO Meshgrid,x,y,dv=dv,ddh=ddh
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
FUNCTION Objfun,x,y,num_intf,dintf,ran,thit,bper,dt
  dph=DBLARR(num_intf)
  lamda=56.0
  l1=4*!pi/lamda
  fun=COMPLEX(0,0)
  dph=dintf[1,*]-dintf[0,*]
  coef_dv=l1*dt
  coef_ddh=l1*1000*bper/(ran*SIN(thit))
  FOR i=0,num_intf-1 DO BEGIN
    fun=fun+COMPLEX(COS(dph(i)-(coef_dv(i)*x+coef_ddh(i)*y)),SIN(dph(i)-(coef_dv(i)*x+coef_ddh(i)*y)))
  ENDFOR
  fun=ABS(fun)/num_intf
  RETURN,fun
END