; Chapter05ObjectGrapgicsErase.pro
PRO Chapter05ObjectGrapgicsErase
DEVICE, GET_SCREEN_SIZE=ScreenSize
XPosition =(ScreenSize[0]- 460)/2
YPosition =(ScreenSize[1]- 460)/2
MyWindow=OBJ_NEW('IDLgrWindow', TITLE='MyWindow', COLOR_MODEL=0  $
            , LOCATION=[XPosition,YPosition], DIMENSIONS=[300, 300])
MyView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[0,-1,100,2])
MyModel = OBJ_NEW('IDLgrModel')
MyPlot = OBJ_NEW('IDLgrPlot', SIN(FINDGEN(100)/10))
MyModel -> ADD, MyPlot
MyView -> ADD, MyModel
MyWindow -> IDLgrWindow::DRAW, MyView
WAIT, 5
MyWindow -> IDLgrWindow::Erase, COLOR=[0, 255, 0]
WAIT, 10
OBJ_DESTROY, MyView
OBJ_DESTROY, MyWindow
END