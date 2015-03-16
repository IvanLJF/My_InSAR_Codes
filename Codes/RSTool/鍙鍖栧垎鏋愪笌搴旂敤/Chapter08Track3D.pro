; Chapter08Track3D.pro
PRO Chapter08Track3D_EVENT, sEvent
  WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
  IF TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
             'WIDGET_KILL_REQUEST' THEN BEGIN
     WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
     OBJ_DESTROY, sState.oView
     OBJ_DESTROY, sState.oTrack
     WIDGET_CONTROL, sEvent.top, /DESTROY
     RETURN
  ENDIF
  CASE uval OF
    'DRAW': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      IF (sEvent.type EQ 4) THEN BEGIN
        sState.oWindow->Draw, sState.oView
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
        RETURN
      ENDIF
      bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat )
      IF (bHaveTransform NE 0) THEN BEGIN
          sState.oTopModel->GetProperty, TRANSFORM=t
          sState.oTopModel->SetProperty, TRANSFORM=t#qmat
          sState.oWindow->Draw, sState.oView
      ENDIF
      IF (sEvent.type EQ 0) THEN BEGIN
          WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
      ENDIF
      IF (sEvent.type EQ 1) THEN BEGIN
          WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
      ENDIF
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
  ENDCASE
END
PRO Chapter08Track3D, data
  xdim = 600  &  ydim = 400
  IF N_ELEMENTS(data) EQ 0 THEN data=BESELJ(SHIFT(DIST(40),20,20)/2,0)
  wBase = WIDGET_BASE(/COLUMN, XPAD=0, YPAD=0, $
          TITLE="Trackball Example", /TLB_KILL_REQUEST_EVENTS)
  wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
            RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, GRAPHICS_LEVEL=2)
  WIDGET_CONTROL, wBase, /REALIZE
  WIDGET_CONTROL, wDraw, GET_VALUE=oWindow
  aspect = FLOAT(xdim) / FLOAT(ydim)
  sqrt3 = SQRT(3.0)
  myview = [ -sqrt3*0.5, -sqrt3*0.5, sqrt3, sqrt3 ]
  IF (aspect GT 1) THEN BEGIN
    myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
    myview[2] = myview[2] * aspect
  ENDIF ELSE BEGIN
    myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
    myview[3] = myview[3] / aspect
  ENDELSE
  oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=myview)
  oTopModel = OBJ_NEW('IDLgrModel')
  oView->Add, oTopModel
  oShow3 = OBJ_NEW('IDLexShow3', data)
  oTopModel->Add, oShow3
  GET_BOUNDS, oShow3, xr, yr, zr
  xs = NORM_COORD(xr)  &  ys = NORM_COORD(yr)  &  zs = NORM_COORD(zr)
  oShow3->Scale, xs[1], ys[1], zs[1]
  oShow3->Translate, xs[0]-0.5, ys[0]-0.5, zs[0]-0.5
  oTopModel->Rotate, [1,0,0], -90
  oTopModel->Rotate, [0,1,0], 30
  oTopModel->Rotate, [1,0,0], 30
  oTrack = OBJ_NEW('Trackball', [xdim/2, ydim/2.], xdim/2.)
  sState = { wDraw: wDraw, oWindow: oWindow, $
        oView: oView, oTopModel: oTopModel, oTrack: oTrack }
  WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY
  XMANAGER, 'Chapter08Track3D', wBase, /NO_BLOCK
END
