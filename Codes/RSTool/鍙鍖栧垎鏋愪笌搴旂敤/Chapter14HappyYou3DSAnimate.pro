; Chapter14HappyYou3DSAnimate.pro
PRO Chapter14HappyYou3DSAnimate
  device, get_screen_size = screensize
  xdim = (screensize[0] - 640) / 2   &   ydim = (screensize[1] - 480) / 2
  mywindow = OBJ_NEW('IDLgrWindow',LOCATION=[xdim, ydim], $
      TITLE='Chapter14HappyYou3D', DIMENSIONS=[640,480])
  myfont = OBJ_NEW('IDLgrFont', 'times*100*bold', SIZE=86)
  myview = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0,0,640,480], COLOR=[0,255,255])
  mymodel = OBJ_NEW('IDLgrModel')
  mytext = OBJ_NEW('IDLgrText','PSI-SWJTU', LOCATION=[190,100], $
         COLOR=[255,0,255], font=myfont)
;  file = FILEPATH('D:\myfiles\My_InSAR_Tools\IDL_BOOK\test.jpg')
  file='D:\myfiles\My_InSAR_Tools\IDL_BOOK\test.jpg'
  READ_JPEG, file, image, true=1
  myimage = OBJ_NEW('IDLgrImage', image, INTERLEAVE=0)
  myview -> Add, mymodel
  mymodel -> Add, myimage
  mymodel -> Add, mytext
  myview -> SetProperty, PROJECTION=2, EYE=60, ZCLIP=[50,-25]
  FOR i=-2.0, 0.0, 0.25 DO BEGIN
    mytext->SetProperty, BASELINE=[1,-i,i]
    mywindow->Draw, myview
    WAIT, 0.1
  ENDFOR
  FOR i=255, 0, -1 DO BEGIN
    mytext -> SetProperty, FONT=myfont1, BASELINE=[1,0,0], $
          UPDIR=[0,1,0], COLOR=[i, 255-i, i],LOCATION=[190,100]
    mywindow->Draw, myview
    WAIT, 0.0001
  ENDFOR
  FOR i=0, 255 DO BEGIN
    mytext -> SetProperty, FONT=myfont1, COLOR=[i, 255-i, 0], LOCATION=[190,100]
    mywindow->Draw, myview
    wait, 0.0001
  ENDFOR
  FOR i=100,500 DO BEGIN
    mytext->SetProperty, LOCATION=[190,i]
    mywindow->Draw, myview
    WAIT, 0.001
  ENDFOR
  OBJ_DESTROY, mywindow
  OBJ_DESTROY, myview
  OBJ_DESTROY, myfont
END
