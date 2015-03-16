PRO TestMNFTransform,infile
;- 最小噪声变换
  ;HighPassFilter函数的作用是进行高通滤波
  ;返回值为 imageinfo 结构体
  ;里面包括有效波段的索引值 和有效波段所对应的图像
  imageinfo=HighPassFilter(infile)
  
  samples=imageinfo.SAMPLES
  lines=imageinfo.LINES
  dataType=imageinfo.DATATYPE
  filteredImage = imageinfo.FILTEREDIMAGE
  filteredNoiseImage = imageinfo.FILTEREDNOISEIMAGE
  GoodBandsIndex = imageinfo.GOODBANDSINDEX
  
  ;使用reform命令将有效图像改变成为 N_ELEMENTS(GoodBandsIndex) x（samples*lines）大小的矩阵
  bandfilteredImage = REFORM(filteredImage,[samples*lines,N_ELEMENTS(GoodBandsIndex)])
  bandNoiseImage = REFORM(filteredNoiseImage,[samples*lines,N_ELEMENTS(GoodBandsIndex)])
  
  
  ;求取滤波后图像和噪声的协方差矩阵
  covarFilteredImage=IMSL_COVARIANCES(bandfilteredImage,/double)
  covarNoiseImage=IMSL_COVARIANCES(bandNoiseImage,/double)
  
  ;-----------------------------
  ;MNF 算法
  ;-----------------------------
  ;第一步
  ;求取滤波后图像的特征值和特征向量
  FilteredEigval = IMSL_EIG(covarFilteredImage, Vectors = FilteredEigvec)
  HELP,FilteredEigval,/structure
  
  ;升序返回 FilteredEigval（滤波后图像协方差阵的特征值）
  sortFilteredEigval = SORT(FilteredEigval)
  ;降序 返回相应的索引值
  sortIndexFilteredEigval=REVERSE(sortFilteredEigval)
  ;得到降序特征值排列书数组
  NewFilteredEigval=FilteredEigval[sortIndexFilteredEigval]
  
  newFilteredEigvec=MAKE_ARRAY(DIMENSION=SIZE(FilteredEigvec,/DIMENSION),/DCOMPLEX)
  ;得到降序特征向量排列矩阵
  FOR i=0,N_ELEMENTS(GoodBandsIndex)-1 DO BEGIN
    newFilteredEigvec[i,*] = FilteredEigvec[sortIndexFilteredEigval,*]
  ENDFOR
  P = (newFilteredEigvec # DIAG_MATRIX(NewFilteredEigval))^(-0.5)
  
  ;第二步
  ;covarNoiseImage是白噪声的协方差矩阵
  ;用P处理协方差矩阵n2
  newcovarNoiseImage=TRANSPOSE(P) # covarNoiseImage # P
  
  ;求取滤波后噪声协方差矩阵的特征值和特征向量
  NoiseEigval = IMSL_EIG(newcovarNoiseImage, Vectors = NoiseEigvec)
  HELP,NoiseEigvec,/structure
  
  ;升序 返回 NoiseEigval（噪声协方差阵的特征值）
  sortNoiseEigval = SORT(NoiseEigval)
  ;降序 返回相应的索引值
  sortIndexNoiseEigval=REVERSE(sortNoiseEigval)
  ;得到降序特征值排列数组
  NewNoiseEigval = NoiseEigval[sortIndexNoiseEigval]
  
  newNoiseEigvec=MAKE_ARRAY(DIMENSION=SIZE(NoiseEigvec,/DIMENSION),/DCOMPLEX)
  ;得到降序特征向量排列矩阵
  FOR i=0,N_ELEMENTS(GoodBandsIndex)-1 DO BEGIN
    newNoiseEigvec[i,*] = NoiseEigvec[sortIndexNoiseEigval,*]
  ENDFOR
  A = newNoiseEigvec
  
  ;综合得到 MNF 变换矩阵
  T = P # A
  ;对图像进行MNF变换
  imageMNF=bandfilteredImage # T
  
  
  ; 测试变换是否正确
  tmp=REFORM(DOUBLE(imageMNF[*,0]),[samples,lines])
  HELP,tmp,/structure
  WINDOW,0,xsize=samples,ysize=lines
  TVSCL,tmp,/order
  
END