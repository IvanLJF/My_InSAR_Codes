; Chapter08FontText.pro
PRO Chapter08FontText
    Mywindow = OBJ_NEW('IDLgrWindow')
    Myfont1 = OBJ_NEW('IDLgrFont', 'times*BOLD', SIZE=50)
    Myfont2 = OBJ_NEW('IDLgrFont', 'courier*BOLD*ITALIC', SIZE=50)
    Myview = OBJ_NEW('IDLgrView',   $
               VIEWPLANE_RECT=[0,0,10,10], COLOR=[255,255,255])
    Mymodel = OBJ_NEW('IDLgrModel') 
    Mytext = OBJ_NEW('IDLgrText', STRINGS='Happy You!', $
               LOCATION=[2,2], COLOR=[0,0,0], FONT=Myfont2)
    Myview -> Add, Mymodel
    Mymodel -> Add, Mytext
    Myview -> SetProperty, PROJECTION=2, EYE=50, ZCLIP=[5,-5]
    FOR i=-5,0 DO BEGIN
      Mytext->SetProperty, BASELINE=[1,0,i]
      Mywindow->Draw, Myview
      WAIT, 0.1
    ENDFOR
    FOR i=0,5 DO BEGIN
      Mytext->SetProperty, BASELINE=[1,i,0]
      Mywindow->Draw, Myview
      WAIT, 0.1
    ENDFOR
    Mytext->SetProperty, BASELINE=[0,1,0], UPDIR=[-1,0,0]
    Mywindow->Draw, Myview
    WAIT, 1
    Mytext -> SetProperty, FONT=Myfont1, BASELINE=[1,0,0], $
          UPDIR=[0,1,0], COLOR=[200,100,0], LOCATION=[2,6]
    Mywindow->Draw, Myview
    WAIT, 1
    Mytext -> SetProperty, FONT=Myfont2, COLOR=[255,0,0], $
          LOCATION=[2,3]
    Mywindow->Draw, Myview
    var=''
    READ, var, PROMPT='press Return to destroy the window'
    OBJ_DESTROY, Mywindow
    OBJ_DESTROY, Myview
    OBJ_DESTROY, Myfont1
    OBJ_DESTROY, Myfont2
END
