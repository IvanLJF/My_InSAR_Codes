; Chapter08SurfacePickTrack.pro
;------------------------------------------------------------------------

FUNCTION Toggle_State, sEventID, ParentID
  WIDGET_CONTROL, sEventID, GET_VALUE=sEventName
  WIDGET_CONTROL, ParentID, GET_VALUE=ParentName
  MyPosition = STRPOS(ParentName, sEventName)
  IF MyPosition EQ -1 THEN BEGIN
     s = STRPOS(ParentName, '(Off)')
     IF (s NE -1) THEN BEGIN
         STRPUT, ParentName, '(On) ', s
         ret = 1
     ENDIF ELSE BEGIN
         s = STRPOS(ParentName, '(On) ')
         STRPUT, ParentName, '(Off)', s
         ret = 0
     ENDELSE
     WIDGET_CONTROL, ParentID, SET_VALUE=ParentName
  ENDIF ELSE BEGIN
     ret = -1
  ENDELSE
  RETURN, ret
END
;------------------------------------------------------------------------
PRO Chapter08SurfacePickTrack_EVENT, sEvent
  WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
 IF TAG_NAMES(sEvent,/STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST' THEN BEGIN
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
    OBJ_DESTROY, sState.oHolder
    WIDGET_CONTROL, sEvent.top, /DESTROY
    RETURN
  ENDIF
  CASE uval OF
    'STYLE': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, STYLE=sEvent.index
      CASE sEvent.index OF
        0: BEGIN
             WIDGET_CONTROL, sState.wHide, SENSITIVE=1
             WIDGET_CONTROL, sState.wShading, SENSITIVE=0
           END
        1: BEGIN
             WIDGET_CONTROL, sState.wHide, SENSITIVE=1
             WIDGET_CONTROL, sState.wShading, SENSITIVE=0
           END
        2: BEGIN
             WIDGET_CONTROL, sState.wHide, SENSITIVE=0
             WIDGET_CONTROL, sState.wShading, SENSITIVE=1
           END
        3: BEGIN
             WIDGET_CONTROL, sState.wHide, SENSITIVE=1
             WIDGET_CONTROL, sState.wShading, SENSITIVE=0
           END
        4: BEGIN
             WIDGET_CONTROL, sState.wHide, SENSITIVE=1
             WIDGET_CONTROL, sState.wShading, SENSITIVE=0
           END
        5: BEGIN
             WIDGET_CONTROL, sState.wHide, SENSITIVE=1
             WIDGET_CONTROL, sState.wShading, SENSITIVE=0
           END
        6: BEGIN
             WIDGET_CONTROL, sState.wHide, SENSITIVE=0
             WIDGET_CONTROL, sState.wShading, SENSITIVE=1
           END
      ENDCASE
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'MM_MIN0': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, MIN_VALUE=sState.zMinVals[0]
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'MM_MIN1': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, MIN_VALUE=sState.zMinVals[1]
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'MM_MIN2': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, MIN_VALUE=sState.zMinVals[2]
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'MM_MAX0': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, MAX_VALUE=sState.zMaxVals[0]
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'MM_MAX1': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, MAX_VALUE=sState.zMaxVals[1]
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'MM_MAX2': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, MAX_VALUE=sState.zMaxVals[2]
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'SHADE_FLAT': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, SHADING=0
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'SHADE_GOURAUD': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, SHADING=1
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'VC_OFF': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      wParent = WIDGET_INFO(sEvent.id, /PARENT)
      j = Toggle_State(sEvent.id, wParent)
      sState.oSurface->SetProperty, VERT_COLORS=0
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'VC_ON': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      wParent = WIDGET_INFO(sEvent.id, /PARENT)
      j = Toggle_State(sEvent.id, wParent)
      sState.oSurface->SetProperty, VERT_COLORS=sState.vc
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'HIDE_OFF': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      wParent = WIDGET_INFO(sEvent.id, /PARENT)
      j = Toggle_State(sEvent.id, wParent)
      sState.oSurface->SetProperty, HIDDEN_LINES=0
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'HIDE_ON': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      wParent = WIDGET_INFO(sEvent.id, /PARENT)
      j = Toggle_State(sEvent.id, wParent)
      sState.oSurface->SetProperty, HIDDEN_LINES=1
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'SKIRT0': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, SHOW_SKIRT=0
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'SKIRT1': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, SKIRT=sState.zSkirts[0],/SHOW_SKIRT
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'SKIRT2': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, SKIRT=sState.zSkirts[1],/SHOW_SKIRT
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'SKIRT3': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.oSurface->SetProperty, SKIRT=sState.zSkirts[2],/SHOW_SKIRT
      sState.oWindow->Draw, sState.oView
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'DRAGQ0' : BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.dragq = 0
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'DRAGQ1' : BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      sState.dragq = 1
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
      END
    'DRAW': BEGIN
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      IF (sEvent.type EQ 4) THEN BEGIN
        sState.oWindow->Draw, sState.oView
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
        RETURN
      ENDIF
      bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat )
      IF (bHaveTransform NE 0) THEN BEGIN
        sState.oGroup->GetProperty, TRANSFORM=t
        sState.oGroup->SetProperty, TRANSFORM=t#qmat
        sState.oWindow->Draw, sState.oView
      ENDIF
      IF (sEvent.type EQ 0) THEN BEGIN
        IF (sEvent.press EQ 4) THEN BEGIN ; Right mouse.
          pick = sState.oWindow->PickData(sState.oView,$
                 sState.oSurface, [sEvent.x,sEvent.y],dataxyz)
          IF (pick EQ 1) THEN BEGIN
            str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
              FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
            WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
          ENDIF ELSE BEGIN
            WIDGET_CONTROL, sState.wLabel, $
              SET_VALUE="Data point: In background."
          ENDELSE
          sState.btndown = 4b
          WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
        ENDIF ELSE BEGIN ; other mouse button.
          sState.btndown = 1b
          sState.oWindow->SetProperty, QUALITY=sState.dragq
          WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
          sState.oWindow->Draw, sState.oView
        ENDELSE
      ENDIF
      IF (sEvent.type EQ 2) THEN BEGIN
        IF (sState.btndown EQ 4b) THEN BEGIN ; Right mouse button.
          pick = sState.oWindow->PickData(sState.oView, $
                 sState.oSurface, [sEvent.x,sEvent.y], dataxyz)
          IF (pick EQ 1) THEN BEGIN
            str = STRING(dataxyz[0],dataxyz[1],dataxyz[2], $
              FORMAT='("Data point: X=",F7.3,",Y=",F7.3,",Z=",F7.3)')
            WIDGET_CONTROL, sState.wLabel, SET_VALUE=str
          ENDIF ELSE BEGIN
            WIDGET_CONTROL, sState.wLabel, $
              SET_VALUE="Data point: In background."
          ENDELSE
        ENDIF
      ENDIF
      IF (sEvent.type EQ 1) THEN BEGIN
        IF (sState.btndown EQ 1b) THEN BEGIN
          sState.oWindow->SetProperty, QUALITY=2
          sState.oWindow->Draw, sState.oView
        ENDIF
        sState.btndown = 0b
        WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
      ENDIF
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    END
  ENDCASE
END

;------------------------------------------------------------------------
PRO Chapter08SurfacePickTrack, zData
  xdim = 600  &  ydim = 360
  IF N_ELEMENTS(zData) EQ 0 THEN zData=BESELJ(SHIFT(DIST(40),20,20)/2,0)
  zMax = MAX(zData, MIN=zMin)
  zQuart = (zMax - zMin) * 0.25
  zSkirts = [zMin-zQuart, zMin, zMin+zQuart]
  wBase = WIDGET_BASE(/COLUMN,XPAD=0,YPAD=0,/TLB_KILL_REQUEST_EVENTS, $
          TITLE="Surface  Pick Data Trackball Example")
  wDraw = WIDGET_DRAW(wBase, XSIZE=xdim, YSIZE=ydim, UVALUE='DRAW', $
          RETAIN=0, /EXPOSE_EVENTS, /BUTTON_EVENTS, GRAPHICS_LEVEL=2)
  wGuiBase = WIDGET_BASE(wBase, /ROW)
  wStyleDrop = WIDGET_DROPLIST(wGuiBase,VALUE=['Point','Wire','Solid',$
         'Ruled XZ','Ruled YZ','Lego Wire','Lego Solid'], XSIZE=480 , $
          UVALUE='STYLE',/FRAME, TITLE='Style',/ALIGN_CENTER)
  wOptions=WIDGET_BUTTON(wGuiBase,MENU=2,VALUE="Additional Options...")
  wDrag = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Drag Quality")
  wButton = WIDGET_BUTTON(wDrag, VALUE='Low', UVALUE='DRAGQ0')
  wButton = WIDGET_BUTTON(wDrag, VALUE='Medium', UVALUE='DRAGQ1')
  wHide = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Hidden Lines (Off)")
  wButton = WIDGET_BUTTON(wHide, VALUE='Off', UVALUE='HIDE_OFF')
  wButton = WIDGET_BUTTON(wHide, VALUE='On', UVALUE='HIDE_ON')
  wMinMax = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Minimum")
  zMinVals = [zMin, zMin+zQuart, zMin+2*zQuart]
  zLabels = ['Reset', STRCOMPRESS(STRING(zMinVals[1:2]), /REMOVE_ALL)]
  wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[0], UVALUE='MM_MIN0')
  wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[1], UVALUE='MM_MIN1')
  wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[2], UVALUE='MM_MIN2')
  wMinMax = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Maximum")
  zMaxVals = [zMax, zMax-zQuart, zMax-2*zQuart]
  zLabels = ['Reset', STRCOMPRESS(STRING(zMaxVals[1:2]), /REMOVE_ALL)]
  wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[0], UVALUE='MM_MAX0')
  wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[1], UVALUE='MM_MAX1')
  wButton = WIDGET_BUTTON(wMinMax, VALUE=zLabels[2], UVALUE='MM_MAX2')
  wShading = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Shading")
  wButton = WIDGET_BUTTON(wShading, VALUE='Flat', UVALUE='SHADE_FLAT')
  wButton=WIDGET_BUTTON(wShading,VALUE='Gouraud',UVALUE='SHADE_GOURAUD')
  wVC = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Vertex Colors (Off)")
  wButton = WIDGET_BUTTON(wVC, VALUE='Off', UVALUE='VC_OFF')
  wButton = WIDGET_BUTTON(wVC, VALUE='On', UVALUE='VC_ON')
  zLabels = ['None', STRCOMPRESS(STRING(zSkirts[*]), /REMOVE_ALL)]
  wSkirt = WIDGET_BUTTON(wOptions, MENU=2, VALUE="Skirt")
  wButton = WIDGET_BUTTON(wSkirt, VALUE=zLabels[0], UVALUE='SKIRT0')
  wButton = WIDGET_BUTTON(wSkirt, VALUE=zLabels[1], UVALUE='SKIRT1')
  wButton = WIDGET_BUTTON(wSkirt, VALUE=zLabels[2], UVALUE='SKIRT2')
  wButton = WIDGET_BUTTON(wSkirt, VALUE=zLabels[3], UVALUE='SKIRT3')
  wGuiBase2 = WIDGET_BASE(wBase, /COLUMN)
  wLabel = WIDGET_LABEL(wGuiBase2, /FRAME, /ALIGN_CENTER,XSIZE=595,$
           VALUE="Left Mouse: Trackball  Right Mouse: Data Picking" )
  wLabel = WIDGET_LABEL(wGuiBase2, VALUE=" ",/ALIGN_CENTER,XSIZE=595)
  WIDGET_CONTROL, wBase, /REALIZE
  WIDGET_CONTROL, wDraw, GET_VALUE=oWindow
  WIDGET_CONTROL, wStyleDrop, SET_DROPLIST_SELECT=2
  WIDGET_CONTROL, wHide, SENSITIVE=0
  aspect = FLOAT(xdim) / FLOAT(ydim)
  sqrt2 = SQRT(2.0)
  myview = [ -sqrt2*0.5, -sqrt2*0.5, sqrt2, sqrt2 ]
  IF (aspect GT 1) THEN BEGIN
    myview[0] = myview[0] - ((aspect-1.0)*myview[2])/2.0
    myview[2] = myview[2] * aspect
  ENDIF ELSE BEGIN
    myview[1] = myview[1] - (((1.0/aspect)-1.0)*myview[3])/2.0
    myview[3] = myview[3] / aspect
  ENDELSE
  oView = OBJ_NEW('IDLgrView', PROJECTION=2, EYE=3, ZCLIP=[1.4,-1.4],$
          VIEWPLANE_RECT=myview, COLOR=[40,40,40])
  oTop = OBJ_NEW('IDLgrModel')
  oGroup = OBJ_NEW('IDLgrModel')
  oTop->Add, oGroup
  sz = SIZE(zData)
  xMax=sz[1]-1  &  yMax=sz[2]-1  &  zMin2=zMin-1 & zMax2 = zMax + 1
  xs = [-0.5,1.0/xMax] & ys = [-0.5,1.0/yMax]
  zs = [(-zMin2/(zMax2-zMin2))-0.5, 1.0/(zMax2-zMin2)]
  vc = BYTARR(3,sz[1]*sz[2], /NOZERO)
  cbins=[[255,  0,0],[255, 85,0],[255,170,0],[255,255,0], $
         [170,255,0],[ 85,255,0],[  0,255,0]]
  zi = ROUND((zData - zMin)/(zMax-zMin) * 6.0)
  vc[*,*] = cbins[*,zi]
  oSurface = OBJ_NEW('IDLgrSurface', zData, STYLE=2, SHADING=0, $
             COLOR=[60,60,255], BOTTOM=[64,192,128], $
             XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)
  oGroup->Add, oSurface
  oLight = OBJ_NEW('IDLgrLight', LOCATION=[2,2,2], TYPE=1)
  oTop->Add, oLight
  oLight = OBJ_NEW('IDLgrLight', TYPE=0, INTENSITY=0.5)
  oTop->Add, oLight
  oView->Add, oTop
  oGroup->Rotate, [1,0,0], -90
  oGroup->Rotate, [0,1,0], 30
  oGroup->Rotate, [1,0,0], 30
  oTrack = OBJ_NEW('Trackball', [xdim/2., ydim/2.], xdim/2.)
  oHolder = OBJ_NEW('IDL_Container')
  oHolder->Add, oView
  oHolder->Add, oTrack
  sState = {btndown: 0b, dragq: 0, oHolder: oHolder, oTrack:oTrack, $
        wDraw: wDraw, wLabel: wLabel, wHide: wHide,           $
        wShading: wShading, oWindow: oWindow, oView: oView,   $
        oGroup: oGroup, oSurface: oSurface, zSkirts: zSkirts, $
        zMinVals: zMinVals, zMaxVals: zMaxVals, vc: vc        }
  WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY
  XMANAGER, 'Chapter08SurfacePickTrack', wBase, /NO_BLOCK
END
