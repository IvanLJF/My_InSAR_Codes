PRO ISODAT, infile, outfile
  ;- 利用IDL进行分类
  ;- 本实验选用的示例数据，分类方法为ISODATA
  
  ;- 初始化envi
  COMPILE_OPT idl2
  envi, /restore_base_save_files
  envi_batch_init, log_file='batch.txt'
  ;- envi打开数据
;  input_file=FILEPATH('can_tmr.img', SUBDIRECTORY=['products','envi45','data']);- 输入文件路径
  input_file=infile
;  output_file=FILEPATH('test.img', SUBDIRECTORY=['products','envi45','data']);- 输出文件路径
  output_file=outfile
  envi_open_file, input_file, r_fid=fid ;- 利用ENVI打开文件，将文件逻辑号r_fid存到变量fid中
  ;- 检查文件是否可以被打开
  if (fid eq -1) then begin
    temp=DIALOG_MESSAGE('openfile error!', /error)
    envi_batch_exit
    RETURN
  endif
  envi_file_query,fid, ns=ns, nl=nl, nb=nb ;-获取文件信息。ns为number of samples，即列数，nl为number of lines，你懂的。
  dims = [-1l, 0, ns-1, 0, nl-1];-dims的五个数字分别代表：
                                ;-1、指向ROI的指针，若没有，则设为-1L
                                ;-2、起始列
                                ;-3、终止列
                                ;-4、起始行
                                ;-5、终止行
  pos =LINDGEN(nb);-要进行处理的波段。例如要处理第1个波段，赋值pos=0；要处理3、4波段，赋值pos=[2,3]
  envi_doit,'class_doit',dims=dims,fid=fid,method=4,pos=pos,out_name=output_file,change_thresh=1.00,iso_merge_dist=2,$
    iso_merge_pairs=2,iso_min_pixels=1.00,iso_split_smult=1,iterations=5,min_classes=5,num_classes=10,$
    ISO_SPLIT_STD  =2.0       
  ;- 打开窗口并显示原始图像
  img=INTARR(ns, nl, 3)
  img[*,*,0]=ENVI_GET_DATA(fid=fid, dims=dims, pos=3)
  img[*,*,1]=ENVI_GET_DATA(fid=fid, dims=dims, pos=2)
  img[*,*,2]=ENVI_GET_DATA(fid=fid, dims=dims, pos=1)  
  WINDOW, XSIZE=ns, YSIZE=nl*2, title='上半部分为原始图像，下半部分为分类图像'
  TVSCL, img, true=3, 0
  ;- 显示分类图像
  ENVI_OPEN_FILE, output_file, r_fid=fid
  ENVI_FILE_QUERY,fid, ns=ns, nl=nl
  out=ENVI_GET_DATA(fid=fid, dims=dims, POS=0) 
  DEVICE, DECOMPOSED=0
  LOADCT, 5
  TVSCL, out, 1
  DEVICE, DECOMPOSED=1
  WAIT, 10
  envi_batch_exit
END
