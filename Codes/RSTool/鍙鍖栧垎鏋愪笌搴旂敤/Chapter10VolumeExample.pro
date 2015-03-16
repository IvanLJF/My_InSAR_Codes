; Chapter10VolumeExample.pro
PRO Chapter10VolumeExample_event, sEvent
  if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST') then begin
    WIDGET_CONTROL, sEvent.top, /DESTROY
    RETALL
    WIDGET_CONTROL, /RESET
    CLOSE, /ALL
    HEAP_GC, /VERBOSE
    RETURN
  endif
  WIDGET_CONTROL, sEvent.id, GET_UVALUE = myvalue
  case myvalue of
      'volbutton1': begin
         Widget_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
         sState.Myvolume -> SetPROperty, COMPOSITE_FUNCTION=0, LIGHTING_MODEL=0
         for i=0,255 do sState.opac[i] = i
         sState.Myvolume -> SetPROperty, OPACITY_TABLE0=sState.opac
         for i=0,255 do sState.rgb[i,0] = i
         for i=0,255 do sState.rgb[i,1] = i
         for i=0,255 do sState.rgb[i,2] = i
         sState.Myvolume -> SetPROperty, RGB_TABLE0=sState.rgb
         sState.myvol_Window -> Draw, sState.Myview
         Widget_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      end
      'volbutton2': begin
         Widget_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
         sState.Myvolume -> SetPROperty, COMPOSITE_FUNCTION=0, LIGHTING_MODEL=0
         for i=0,255 do sState.rgb[i,0] = i
         for i=0,255 do sState.rgb[i,1] = i
         for i=0,255 do sState.rgb[i,2] = i
         sState.Myvolume -> SetPROperty, RGB_TABLE0=sState.rgb
         sState.opac[0:127] = BINDGEN(128)/8
         sState.opac[255] = 255 ;Voxel value of one cube.
         sState.opac[128] = 255 ;Voxel value of the other cube.
         sState.Myvolume -> SetPROperty, OPACITY_TABLE0=sState.opac
         sState.myvol_window -> Draw, sState.Myview
         Widget_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      end
      'volbutton3': begin
         Widget_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
         sState.Myvolume -> SetPROperty, COMPOSITE_FUNCTION=0, LIGHTING_MODEL=0
         sState.opac[0:127] = BINDGEN(128)/8
         sState.opac[255] = 255 ;Voxel value of one cube.
         sState.opac[128] = 255 ;Voxel value of the other cube.
         sState.Myvolume -> SetPROperty, OPACITY_TABLE0=sState.opac
         sState.rgb[0:127,0] = bindgen(128) ;Grayscale ramp for the prism.
         sState.rgb[0:127,1] = bindgen(128)
         sState.rgb[0:127,2] = bindgen(128)
         sState.rgb[128,*] = [255,0,0] ;One cube is red.
         sState.rgb[255,*] = [0,0,255] ;One cube is blue.
         sState.Myvolume -> SetPROperty, RGB_TABLE0=sState.rgb
         sState.myvol_window -> Draw, sState.Myview
         Widget_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      end
      'volbutton4': begin
         Widget_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
         sState.Myvolume -> SetPROperty, COMPOSITE_FUNCTION=0, LIGHTING_MODEL=0
         sState.opac[0:127] = BINDGEN(128)/8
         sState.opac[255] = 255 ;Voxel value of one cube.
         sState.opac[128] = 255 ;Voxel value of the other cube.
         sState.Myvolume -> SetPROperty, OPACITY_TABLE0=sState.opac
         sState.rgb[0:127,0] = bindgen(128) ;Grayscale ramp for the prism.
         sState.rgb[0:127,1] = bindgen(128)
         sState.rgb[0:127,2] = bindgen(128)
         sState.rgb[128,*] = [255,0,0] ;One cube is red.
         sState.rgb[255,*] = [0,0,255] ;One cube is blue.
         sState.Myvolume -> SetPROperty, RGB_TABLE0=sState.rgb
         sState.Myvolume->SetPROperty, AMBIENT=[150,150,150], $
                                       LIGHTING_MODEL=1, TWO_SIDED=1
         sState.Myview -> Add, sState.Mylmodel
         sState.Mylmodel -> Add, sState.Mylight
         sState.myvol_window -> Draw, sState.Myview
         sState.Myview -> Remove, sState.Mylmodel
         sState.Mylmodel -> Remove, sState.Mylight
         Widget_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      end
      'volbutton5': begin
         Widget_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
         sState.Myvolume -> SetPROperty, COMPOSITE_FUNCTION=1, LIGHTING_MODEL=0
         sState.myvol_window -> Draw, sState.Myview
         Widget_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      end
      else:
  endcase
end
PRO Chapter10VolumeExampleCleanup, wTopBase
    WIDGET_CONTROL, wTopBase, GET_UVALUE=sState, /NO_COPY
    for i=0,n_tags(sState)-1 do begin
        case size((sState).(i), /TNAME) of
            'POINTER': ptr_free, (sState).(i)
            'OBJREF':  obj_destroy, (sState).(i)
            else:
        endcase
    end
end
PRO Chapter10VolumeExample
  data = BYTARR(64,64,64)
  FOR i=0,63 DO data[*,i,0:i] = i*2
  data[5:15, 5:15, 5:55] = 128
  data[45:55, 45:55, 5:15] = 255
  Myvolume = OBJ_NEW('IDLgrVolume', data)
  cc = [-0.5, 1.0/64.0]
  Myvolume -> SetPROperty, XCOORD_CONV=cc, YCOORD_CONV=cc, ZCOORD_CONV=cc
  Myvolume -> SetPROperty, ZERO_OPACITY_SKIP=1
  Myvolume -> SetPROperty, ZBUFFER=1
  Myview = OBJ_NEW('IDLgrView',VIEWPLANE_RECT=[-1,-1,2,2], $
                               ZCLIP=[2.0,-2.0], COLOR=[255,255,255])
  Mymodel = OBJ_NEW('IDLgrModel')
  Myview -> Add, Mymodel
  Mymodel -> Add, Myvolume
  Mylmodel = OBJ_NEW('IDLgrModel')
  Mylight = OBJ_NEW('IDLgrLight', TYPE=2, LOCATION=[0,0,1], COLOR=[255,255,255])
  Mymodel -> rotate, [1,1,1], 45
  rVol_Base = Widget_Base(TITLE='Volume Example', /ROW, /TLB_KILL_REQUEST_EVENTS)
  rLeft_Base = Widget_Base(rVol_Base, XOFFSET=6 ,YOFFSET=6)
  rVol_DRAW = WIDGET_DRAW(rLeft_Base, XSIZE=600, YSIZE=500, UVALUE='DRAW',RENDERER=1,$
                          RETAIN=1, /EXPOSE_EVENTS, /BUTTON_EVENTS, GRAPHICS_LEVEL=2)
  rRight_Base = Widget_Base(rVol_Base,/COLUMN, XOFFSET=6 ,YOFFSET=6)
  rVol_BUTTON1 = Widget_Button(rRight_Base, uvalue='volbutton1',VALUE=' Render1 ')
  rVol_BUTTON2 = Widget_Button(rRight_Base, uvalue='volbutton2',VALUE=' Render2 ')
  rVol_BUTTON3 = Widget_Button(rRight_Base, uvalue='volbutton3',VALUE=' Render3 ')
  rVol_BUTTON4 = Widget_Button(rRight_Base, uvalue='volbutton4',VALUE=' Render4 ')
  rVol_BUTTON5 = Widget_Button(rRight_Base, uvalue='volbutton5',VALUE=' Render5 ')
  Widget_Control, /REALIZE, rVol_Base
  Widget_CONTROL, rVol_DRAW, GET_VALUE = myvol_Window
  sState ={rVol_DRAW: rVol_DRAW, myvol_Window: myvol_Window, Myview: Myview, $
           Mymodel: Mymodel, Myvolume: Myvolume, Mylmodel: Mylmodel, $
           Mylight: Mylight, rgb: bytarr(256,3), opac: BYTARR(256)   }
  myvol_Window -> Draw, Myview
  Widget_CONTROL, rVol_Base, SET_UVALUE=sState, /NO_COPY
  XManager, 'Chapter10VolumeExample', $
             CLEANUP='Chapter10VolumeExampleCleanup', rVol_Base, /NO_BLOCK
end