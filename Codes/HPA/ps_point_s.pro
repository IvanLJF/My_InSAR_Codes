PRO PS_POINT_S
;- Script that:
;-      Find PS in Slave SLCs
;-
;- Usage:
;-
;- By:
;      Tao Li @ InSAR Team in SWJTU
;-      2011-7-29 20:06
;-   
  ;------------------------Initialization-------------------  
  master_file='D:\myfiles\My_InSAR_Tools\InSAR\Images\20090327.rslc'
  slave_file='D:\myfiles\My_InSAR_Tools\InSAR\Images\20090407.rslc'
  m_plist='D:\myfiles\My_InSAR_Tools\InSAR\Images\plist.dat'
  
;  master_file='/mnt/software/myfiles/My_InSAR_Tools/InSAR/Images/20090327.rslc'
;  slave_file='/mnt/software/myfiles/My_InSAR_Tools/InSAR/Images/20090407.rslc'  
;  m_plist='/mnt/software/myfiles/My_InSAR_Tools/InSAR/Images/plist.dat'
  s_plist=STRSPLIT(slave_file, '.',/EXTRACT)
  s_plist=s_plist(0)+'_plist.dat'
  s_offset=0
  l_offset=0
  winsub=3
  winsearch=10
;  cc_thresh=0.8
  
  ;------------------------Start Searching-------------------
  ;- Creat Progressbar
  wTlb= WIDGET_BASE(title='Search Candidate PS From Slave File', TLB_FRAME_ATTR=31)
  WIDGET_CONTROL, wTlb, /REALIZE
  process= idlitwdprogressbar(GROUP_LEADER=wTlb, Time=0, TITLE='Searching Point by Point...')
  idlitwdprogressbar_setvalue, process, 0
  
  temp= LONARR(2)
  
;  info= FILE_INFO(m_plist)
;  n_points= info.size/8
  n_points= FILE_LINES(m_plist)
  IF FILE_TEST(s_plist) THEN FILE_DELETE, s_plist
  OPENR, lun_m_plist, m_plist,/GET_LUN
  OPENW, lun_s_plist, s_plist,/GET_LUN

  FOR i=0D,n_points-1D DO BEGIN
    READF, lun_m_plist, temp    ;-Get PS index from master SLC.
    result= FINE_COREGISTRATION(master_file, slave_file, temp(0), temp(1),  $
                                s_offset, l_offset, winsub=winsub, winsearch=winsearch)
    write_r=[temp,result]
    PRINTF, lun_s_plist, write_r
    idlitwdprogressbar_setvalue, process, i/n_points*100
  ENDFOR
  
  FREE_LUN, lun_m_plist
  FREE_LUN, lun_s_plist
  WIDGET_CONTROL, process,/DESTROY
  WIDGET_CONTROL, wtlb, /DESTROY
  
  ;- Data Visualization
  SLC= OPENSLC(slave_file)
  pwr= ABS(SLC)
  pwr= HIST_EQUAL(pwr)
  sz= SIZE(pwr)
  points= DBLARR(5, n_points)
  OPENR, lun, s_plist, /GET_LUN
  READF, lun, points
  FREE_LUN, lun
  points= points(2:3, *)
  WINDOW, 0, XPOS=0, YPOS=0, XSIZE=sz(1), YSIZE=sz(2) & TV, pwr
  PLOTS, points(0,*), points(1,*), PSYM=1, SYMSIZE=1, COLOR= 200,/DEVICE
STOP
  
END