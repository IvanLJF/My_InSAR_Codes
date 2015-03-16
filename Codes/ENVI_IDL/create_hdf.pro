;+
;  《IDL程序设计》
;   -数据可视化与ENVI二次开发
;        
; 示例代码
;
; 作者: 董彦卿
;
; 联系方式：sdlcdyq@sina.com
;-
PRO CREATE_HDF
  ;获取当前文件所在目录
  curDir = FILE_DIRNAME(ROUTINE_FILEPATH('create_hdf'),$
    /mark_directory)    
  ;定义要读取的jpeg文件
  jpegfile =curDir+'data\idl.jpg'
  ;判断文件是否存在，不存在则提示信息然后退出
  IF ~FILE_TEST(jpegFile) THEN BEGIN
    void = DIALOG_MESSAGE('jpeg文件不存在！',/Error)
    RETURN
  ENDIF
  ;读取jpeg文件
  READ_JPEG, jpegFile,data
  ;获取数据信息
  dimensions = SIZE(data,/dimensions)
  ;构建保存的hdf文件
  hdfFile = curDir+'data\example.hdf'
  ;文件若已经存在则删除
  IF FILE_TEST(hdfFile) THEN FILE_DELETE, hdfFile
  ;创建HDF文件
  sd_id=HDF_SD_START(hdfFile,/CREATE)
  ;创建数据集'idl.jpg'
  sds_id=HDF_SD_CREATE(sd_id,'idl.jpg', $
    dimensions,/byte)
  ;添加数据信息
  HDF_SD_SETINFO,sds_id,LABEL=' each pixel value'
  ;写入数据每个维数的含义
  HDF_SD_DIMSET,HDF_SD_DIMGETID(sds_id,0),$
    NAME='RGB',$
    LABEL='nDimension of the JPEG'
  HDF_SD_DIMSET,HDF_SD_DIMGETID(sds_id,1),$
    NAME='Width',LABEL='Width of the JPEG'
  HDF_SD_DIMSET,HDF_SD_DIMGETID(sds_id,2),$
    NAME='Height',LABEL='Height of the JPEG'
  ;添加数据信息
  HDF_SD_ADDDATA, sds_id, data
  ;SDS_id添加操作完成 ，关闭sds
  HDF_SD_ENDACCESS,sds_id
  ;关闭
  HDF_SD_END,sd_id
END