FUNCTION SOURCEROOT 
COMPILE_OPT StrictArr 
HELP, Calls = Calls 
UpperRoutine = (StrTok(Calls[1], ' ', /Extract))[0] 
Skip = 0 
CATCH, ErrorNumber 
IF (ErrorNumber NE 0) THEN BEGIN 
CATCH, /Cancel 
ThisRoutine = ROUTINE_INFO(UpperRoutine, /Functions, /Source) 
Skip = 1 
ENDIF 
IF (Skip EQ 0) THEN BEGIN 
ThisRoutine = ROUTINE_INFO(UpperRoutine, /Source) 
IF (thisRoutine.Path EQ '') THEN BEGIN 
MESSAGE,'',/traceback 
ENDIF 
ENDIF 
CATCH,/cancel 
IF (STRPOS(thisroutine.path,PATH_SEP()) EQ -1 ) THEN BEGIN 
CD, current=current 
sourcePath = FILEPATH(thisrouitine.path, root=current) 
ENDIF ELSE BEGIN 
sourcePath = thisroutine.path 
ENDELSE 
Root = STRMID(sourcePath, 0, STRPOS(sourcePath, PATH_SEP(), /Reverse_Search) + 1) 
RETURN, Root 
END

PRO PSISWJTU_EVENT, EVENT
  widget_control, event.top, get_uvalue=pstate
  mywindow= (*pstate).mywindow
  myview= (*pstate).myview
  myfont= (*pstate).myfont
  uname=widget_info(event.id, /uname)
  case uname of
    'start_button': begin
       OBJ_DESTROY, mywindow
       OBJ_DESTROY, myview
       OBJ_DESTROY, myfont
       widget_control, event.top, /destroy
       sargui
    end
    else: 
  endcase
END

PRO PSISWJTU
  device, get_screen_size = screensize
  xdim = (screensize[0] - 640) / 2   &   ydim = (screensize[1] - 400) / 2
   ;- 创建界面
  tlb = widget_base(tlb_frame_attr=31,xsize=640,xoffset=xdim,yoffset=ydim )
  labelstr='   InSAR 工作组'+string(13b)+'西南交通大学遥感系'
  label= widget_label(tlb, xsize=110,ysize=30,xoffset=503,yoffset=324,value=labelstr, uname='start_button')
  start_button= widget_button(tlb, xsize=90,ysize=30,xoffset=513,yoffset=270,value='开始', uname='start_button')
  draw = widget_draw(tlb,xsize=640, ysize=400, graphics_level=2, uvalue='Draw') 
  widget_control, tlb, /realize  
  widget_control, draw, get_value=mywindow
;  mywindow = OBJ_NEW('IDLgrWindow',LOCATION=[xdim, ydim], TITLE='PSI-SWJTU', DIMENSIONS=[640,480])
  myfont = OBJ_NEW('IDLgrFont', 'times*100*bold', SIZE=86)
  myview = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0,0,640,400], COLOR=[0,255,255])
  mymodel = OBJ_NEW('IDLgrModel')
  mytext = OBJ_NEW('IDLgrText', 'PSI-SWJTU', LOCATION=[190,100], COLOR=[255,0,255], font=myfont)
;;  file = FILEPATH('D:\myfiles\My_InSAR_Tools\IDL_BOOK\test.jpg')
  sourcepath= sourceroot()
  file=sourcepath+'test.jpg'
  READ_JPEG, file, image, true=1
  myimage = OBJ_NEW('IDLgrImage', image, INTERLEAVE=0)
  myview -> Add, mymodel
  mymodel -> Add, myimage
  mymodel -> Add, mytext
  myview -> SetProperty, PROJECTION=2, EYE=60, ZCLIP=[50,-25]
;  FOR i=-2.0, 0.0, 0.25 DO BEGIN
;    mytext->SetProperty, BASELINE=[1,-i,i]
;    mywindow->Draw, myview
;    WAIT, 0.1
;  ENDFOR
  FOR i=255, 0, -1 DO BEGIN
    mytext -> SetProperty, FONT=myfont1, BASELINE=[1,0,0], $
          UPDIR=[0,1,0], COLOR=[i, 255-i, i],LOCATION=[100,100]
    mywindow->Draw, myview
    WAIT, 0.0001
  ENDFOR
  FOR i=0, 255 DO BEGIN
    mytext -> SetProperty, FONT=myfont1, COLOR=[i, 255-i, 0], LOCATION=[100,100]
    mywindow->Draw, myview
    wait, 0.0001
  ENDFOR
  FOR i=100, 500 DO BEGIN
    mytext->SetProperty, LOCATION=[100,i]
    mywindow->Draw, myview
    WAIT, 0.001
  ENDFOR

  state= {mywindow:mywindow, myview:myview, myfont:myfont}
  pstate= ptr_new(state)
  widget_control, tlb, set_uvalue=pstate
  xmanager, 'PSISWJTU', tlb, /no_block  
END