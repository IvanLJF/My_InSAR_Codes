; Chapter08Track.pro
pro Chapter08Track_EVENT, sEvent
  WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
  if TAG_NAMES(sEvent, /STRUCTURE_NAME) eq  $
             'WIDGET_KILL_REQUEST' then begin
     WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState
     OBJ_DESTROY, sState.oView
     OBJ_DESTROY, sState.oTrack
     WIDGET_CONTROL, sEvent.top, /DESTROY
     return
  endif
  case uval of
    'DRAW': begin
      WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY
      if (sEvent.type eq 4) then begin
          sState.oWindow->Draw, sState.oView
          WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
          return
      endif
      bHaveTransform = sState.oTrack->Update( sEvent, TRANSFORM=qmat )
      if (bHaveTransform ne 0) then begin
         sState.oTopModel->GetProperty, TRANSFORM=t
         sState.oTopModel->SetProperty, TRANSFORM=t#qmat
         sState.oWindow->Draw, sState.oView
      endif
      if (sEvent.type eq 0) then begin
          WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
      endif
      if (sEvent.type eq 1) then begin
          WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
      endif
      WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    end
  endcase
end
pro Chapter08Track
  z = BYTARR(64,64, /NOZERO)
  OPENR, lun, FILEPATH('elevbin.dat', $
              SUBDIR=['examples','data']), /GET_LUN
  READU, lun, z  &  FREE_LUN, lun
  z = REVERSE(TEMPORARY(z), 2)
  data = SMOOTH(TEMPORARY(z), 3, /EDGE_TRUNCATE) + 1
  nmaps = 1
  oTexMap = MAKE_ARRAY(nmaps,/OBJ)
  READ_JPEG, FILEPATH('elev_t.jpg', SUBDIR= $
               ['examples','data']), idata, TRUE=3
  oTexMap[0] = OBJ_NEW('IDLgrImage', REVERSE(TEMPORARY(idata), 2), $
             INTERLEAVE = 2)
  n=64L  &  auxin = FLTARR(2,n,n)
  coords = (FINDGEN(n)/FLOAT(n-1)) # REPLICATE(1, n)
  auxin[0,*,*] = coords  &  auxin[1,*,*] = TRANSPOSE(coords)
  nlevels=5
  ISOCONTOUR, data, outverts, outconn, AUXDATA_IN=auxin, /FILL, $
    AUXDATA_OUT=auxout, OUTCONN_INDICES=outinds, N_LEVELS=nlevels
  oModel = OBJ_NEW('IDLgrModel')
  levmax = nlevels -1
  oContour = MAKE_ARRAY(nlevels,/OBJ)
  for l=0,levmax-1 do begin
    shade = l*(255./(levmax-1))
    oContour[l]=OBJ_NEW('IDLgrPolygon',outverts,STYLE=2,SHADING=1,$
        POLYGONS=outconn[outinds[l*2]:outinds[l*2+1]], $
        COLOR=[shade, (255-shade)>0, (255-shade)>0], $
        TEXTURE_MAP=oTexmap[l mod nmaps], TEXTURE_COORD=auxout)
    oModel->Add, oContour[l]
  end
  xdim = 600  &  ydim = 400
  oView = OBJ_NEW('IDLgrView')  &  oView->Add, oModel
  GET_BOUNDS, oModel, xr, yr, zr
  xs = NORM_COORD(xr)  &  ys = NORM_COORD(yr)  &  zs = NORM_COORD(zr)
  oModel->Scale, xs[1], ys[1], zs[1]
  oModel->Translate, xs[0]-0.5, ys[0]-0.5, zs[0]-0.5
  oModel->Rotate, [1,0,0], -70
  oModel->Rotate, [0,1,0], 30  &  oModel->Rotate, [1,0,0], 30
  wBase = WIDGET_BASE(TITLE='ISOCONTOUR', /COLUMN, $
            /TLB_KILL_REQUEST_EVENTS )
  wDraw = WIDGET_DRAW(wBase,XSIZE=xdim,YSIZE=ydim,GRAPHICS_LEVEL=2,$
      RETAIN=1, /BUTTON_EVENTS, /EXPOSE_EVENTS, UVALUE='DRAW')
  WIDGET_CONTROL, wBase, /REALIZE
  WIDGET_CONTROL, wDraw, GET_VALUE=oWindow
  oWindow->Draw, oView
  oTrack = OBJ_NEW('Trackball', [xdim/2., ydim/2.], xdim/2.)
  sState = {wDraw: wDraw, oWindow: oWindow, $
        oView: oView, oTopModel: oModel, oTrack: oTrack }
  WIDGET_CONTROL, wBase, SET_UVALUE=sState, /NO_COPY
  XMANAGER, 'Chapter08Track', wBase, /NO_BLOCK
end
