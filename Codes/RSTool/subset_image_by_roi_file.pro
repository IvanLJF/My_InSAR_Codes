;***************************************************************************
; ROI文件裁剪，ROI要与文件对应才能正确执行
;***************************************************************************
PRO Subset_Image_By_ROI_File
  ENVI, /RESTORE_BASE_SAVE_FILES
  ENVI_BATCH_INIT, LOG_FILE='batch.txt'
  
  defaultPath = 'E:\IDL&ENVI\IDLWorkspace71\ImageROISubset\testData\'
  imgFile = DIALOG_PICKFILE(PATH=defaultPath,TITLE='Select File for Subset',FILTER=['*.img;*.hdf;*.tif'])    
  IF (imgFile EQ "") THEN BEGIN
    MsgBox,"Failed to Open Image FILE"
    ENVI_BATCH_EXIT
    RETURN
  ENDIF

  ; Open Image Files,Only for single file
  ENVI_OPEN_FILE,imgFile,R_FID=imgFid
  ENVI_FILE_QUERY,imgFid,NB=nb
  pointPos = STRPOS(imgFile,'.',/REVERSE_SEARCH)
  fileExt = STRMID(imgFile,pointPos,STRLEN(imgFile)-pointPos) ; Keep the '.' In ext type.
  baseName = FILE_BASENAME(imgFile,fileExt) ; here need '.'

  ; open the roi file
  roi_file = DIALOG_PICKFILE(PATH=defaultPath,TITLE='Select ROI file',FILTER=['*.roi'])
  IF (roi_file EQ "") THEN BEGIN
    MsgBox,"Failed to Open ROI FILE"
    ENVI_BATCH_EXIT
    RETURN
  ENDIF  
  ; restore roi
  ENVI_RESTORE_ROIS,roi_file  
  
  roi_ids = ENVI_GET_ROI_IDS(FID=imgFid,ROI_NAMES=roi_names)
  IF roi_ids[0] EQ -1 THEN BEGIN
    MsgBox,"THE ROI is Valid"
    ENVI_BATCH_EXIT
    RETURN
  ENDIF    
  ; 获取ROI信息
  ENVI_GET_ROI_INFORMATION,roi_ids,NL=nl,NPTS=npts,NS=ns    
  ENVI_ROI_COMPUTE_SPATIAL_BOUNDRY,roi_ids,out_dims
  
  ;Create Mask File.
  ENVI_MASK_DOIT,AND_OR=1,/IN_MEMORY, ROI_IDS=roi_ids, NS=ns,NL=nl,/INSIDE,R_FID=msk_fid
  
  ;输出
  outFile = defaultPath+baseName + "_Subset.img"
  ENVI_MASK_APPLY_DOIT, FID=imgFid, POS=INDGEN(nb),DIMS=out_dims,M_FID=msk_fid,M_POS=[0],$
  VALUE =-1000,OUT_BNAME= nBandNames,OUT_NAME=outFile,R_FID=r_fid
    
  ENVI_FILE_MNG, ID=msk_fid,/REMOVE,/DELETE
  
  ENVI_BATCH_EXIT  
END