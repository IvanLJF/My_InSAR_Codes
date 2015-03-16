FUNCTION CreateTieObjectImage, data, index, dims
; 
imageLoc = dims*index
oImage = OBJ_NEW('IDLgrImage',BYTSCL(data),location = [0,imageLoc[1]])
oText = OBJ_NEW('IDLgrText',STRCOMPRESS(index),location = [dims[0]/2,imageLoc[1]], $
    color = [255,0,0],CHAR_DIMENSIONS = [dims[1]*.4,dims[1]*.5])
    
oSepLine = OBJ_NEW('IDLgrPolyLine',[[0,imageLoc[1],1],[dims[0],imageLoc[1],1]],$
    color = [1,1,200])
;
oModel = OBJ_NEW('IDLgrModel') 
oModel->Add,[oImage,oText,oSepLine]

RETURN,oModel
END
PRO test_ENVI_TIE
;
COMPILE_OPT idl2
;初始化ENVI
envi,/Restore_Base_Save_files
ENVI_BATCH_INIT
;打开数据文件
ENVI_OPEN_FILE,file,r_fid = fid
IF fid EQ -1 THEN RETURN
ENVI_FILE_QUERY,fid,ns = ns,nl = nl
;仅仅显示第一个波段
pos = 0
;确定分块ID
tile_id=ENVI_INIT_TILE(fid, pos, num_tiles=num_tiles)
;计算显示比例
scale = 800./ns
tileYsize = 600./(num_tiles) >1
;创建显示窗口
oModel = OBJ_NEW('IDLgrModel')

;依次读取分块并显示
FOR i=0, num_tiles-1 DO BEGIN
    tile_data=ENVI_GET_TILE(tile_id, i)
    IF i EQ 0 THEN dims = SIZE(tile_data,/dimension)
    
    oModel->Add, CreateTieObjectImage(tile_data, i, dims)
    
ENDFOR
;结束分块
ENVI_TILE_DONE, Tile_id
;
XObjView, oModel,/block
Obj_Destroy,oModel
;关闭ENVI
ENVI_BATCH_EXIT
    
END

