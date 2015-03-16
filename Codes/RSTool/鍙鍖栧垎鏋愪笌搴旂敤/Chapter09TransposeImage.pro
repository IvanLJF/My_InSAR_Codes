; Chapter09TransposeImage.pro
PRO Chapter09TransposeImage
  READ_JPEG, FILEPATH('muscle.jpg', $
  SUBDIRECTORY=['examples', 'data']), image
  DEVICE, DECOMPOSED = 0
  LOADCT, 0
  WINDOW, 0, XSIZE = 652, YSIZE = 444, TITLE = 'Original Image'
  TV, image
  smallImg = CONGRID(image, 183, 111)
  transposeImg1 = TRANSPOSE(smallImg); 该命令与下命令作用相同
  transposeImg2 = TRANSPOSE(smallImg, [1,0])
  transposeImg3 = TRANSPOSE(smallImg, [0,1])
  WINDOW, 1, XSIZE= 600, YSIZE=183, TITLE='Transposed Images'
  TV, transposeImg1, 0
  TV, transposeImg2, 2
  TV, transposeImg3, 2
END