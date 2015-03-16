; Chapter08Polyline.pro
PRO Chapter08Polyline_event, sEvent
  IF TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
                       'WIDGET_KILL_REQUEST' THEN BEGIN
     WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
     OBJ_DESTROY, sState.oView
     OBJ_DESTROY, sState.oWindow
     WIDGET_CONTROL, sEvent.top, /DESTROY
     RETURN
  ENDIF
  WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
  CASE uval OF
    'MOVE': BEGIN  ; Turn on/off automotion.
      WIDGET_CONTROl, sEvent.top, GET_UVALUE=sState
      sState.automotion = sEvent.select
      IF (sState.automotion EQ 1) THEN $
        WIDGET_CONTROL, sState.wBase, TIMER=sState.timer
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
     END
    'DRAW': BEGIN  ; Expose event.
      IF (sEvent.type EQ 4) THEN BEGIN
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
        sState.oWindow->Draw, sState.oView
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
      ENDIF
     END
    'Chapter08Polyline': BEGIN ; Rotate it about its axis.
       WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
       sState.oRot->Rotate, [0,0,1], -30
       sState.oWindow->Draw, sState.oView
       WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
     END
    'TIMER' : BEGIN ; Timer event for automotion.
       WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
       IF (sState.automotion EQ 1) THEN BEGIN
         sState.oRot->Rotate, [0,0,1], -1
         sState.oOrbit->Rotate, [0,1,0], -1
         sState.oCorr->Rotate, [0,1,0], 1
       ENDIF
       IF (sState.automotion EQ 1) THEN BEGIN
         sState.oWindow->Draw, sState.oView
         WIDGET_CONTROL, sEvent.id, TIMER=sState.timer
       ENDIF
       WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
     END
    'SUN': BEGIN  ; Orbit the Chapter08Polyline about the sun.
       WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
     sState.oOrbit->Rotate, [0,1,0], -6
     sState.oCorr->Rotate, [0,1,0], 6
       sState.oWindow->Draw, sState.oView
       WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState
     END
  ENDCASE
END
PRO Chapter08Polyline
  xdim = 600  &  ydim = 300
  wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0,TITLE='Planet Rotation',$
            /TLB_KILL_REQUEST_EVENTS)
  wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
            RETAIN=0, /EXPOSE_EVENTS, GRAPHICS_LEVEL=2)
  wGuiBase = WIDGET_BASE(wBase, /ROW, UVALUE='TIMER' )
  wButton = WIDGET_BUTTON(wGuiBase, VALUE="Spin Planet About Axis",$
              UVALUE='Chapter08Polyline')
  wButton = WIDGET_BUTTON(wGuiBase,VALUE="Orbit About Sun",UVALUE='SUN')
  wBBase = WIDGET_BASE(wGuiBase, /NONEXCLUSIVE)
  wButton = WIDGET_BUTTON(wBBase, VALUE="Automotion", UVALUE='MOVE')
  WIDGET_CONTROL, wBase, /REALIZE
  WIDGET_CONTROL, wDraw, GET_VALUE=oWindow
  oWindow->Setproperty, QUALITY=0
  aspect = FLOAT(xdim)/FLOAT(ydim)
  myview = [-2.0,-2.0,4.0,4.0]
  IF (aspect GT 1) THEN BEGIN
    myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
    myview[2] = myview[2] * aspect
  ENDIF ELSE BEGIN
    myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
    myview[3] = myview[3] / aspect
  ENDELSE
  oView = OBJ_NEW('IDLgrView', COLOR=[60,60,60], PROJECTION=2, EYE=4, $
          ZCLIP=[2.0,-2.0], VIEWPLANE_RECT=myview )
  oTop = OBJ_NEW('IDLgrModel')
  oLight1=OBJ_NEW('IDLgrLight',LOCATION=[2,2,5],TYPE=2,INTENSITY=0.25)
  oTop->Add, oLight1
  oLight2 = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
  oTop->Add,oLight2
  oGalaxy = OBJ_NEW('IDLgrModel')
  oTop->Add, oGalaxy
  oSun = OBJ_NEW('Orb', COLOR=[255,255,0], DENSITY=3.0)
  oGalaxy->Add, oSun
  oOrbit = obj_new('IDLgrModel')
  oGalaxy->add,oOrbit
  oOffset = OBJ_NEW('idlgrmodel')
  oOffset->Translate,1.5,0,0
  oOrbit->Add, oOffset
  oCorr = OBJ_NEW('IDLgrModel')
  oOffset->Add, oCorr
  oTilt = OBJ_NEW('IDLgrModel')
  oTilt->Rotate, [1,0,0], -60-180
  oTilt->Rotate, [0,0,1], -30
  oCorr->Add, oTilt
  oRot = OBJ_NEW('IDLgrModel')
  oTilt->Add, oRot
  oAxis=OBJ_NEW('IDLgrPolyline',[[0,0,-0.5],[0,0,0.5]],COLOR=[0,255,0])
  oRot->Add, oAxis
  oChapter08Polyline = OBJ_NEW('Orb', COLOR=[0,0,255],$
       RADIUS=0.25, DENSITY=1.0, /TEX_COORDS)
  oRot->Add, oChapter08Polyline
  oView->Add, oTop
  oWindow->Draw, oView
  sState = {wBase: wGuiBase, timer: 0.05, automotion: 0, oRot:oRot, $
            oOrbit:oOrbit, oCorr:oCorr, oWindow:oWindow, oView:oView}
  WIDGET_CONTROL, wBase, SET_UVALUE=sState
  XMANAGER, 'Chapter08Polyline', wBase, /NO_BLOCK
END
