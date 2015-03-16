; Chapter07MyPaint.pro
PRO Chapter07MyPaintExit, Event
    WIDGET_CONTROL, Event.TOP, /DESTROY
END
PRO Chapter07MyPaintCleanUp, ID
    WIDGET_CONTROL, ID, GET_UVALUE=InfoPointer
    PTR_FREE, InfoPointer
END
PRO Chapter07MyPaint_EVENT, Event
    WIDGET_CONTROL, Event.TOP, GET_UVALUE=InfoPointer
    Info = *InfoPointer
    WIDGET_CONTROL, Event.ID, GET_UVALUE=Widget
    CASE Widget of
      'Draw' : begin
         if (event.press gt 0) then begin
            WIDGET_CONTROL, event.ID, DRAW_MOTION_EVENTS=1
            Info.PEN = 1
            Info.X = event.X
            Info.Y = event.Y
         endif
         if (event.release gt 0) then begin
            WIDGET_CONTROL, event.id, draw_motion_events=0
            Info.pen = 0
         endif
         if (Info.pen eq 1) then begin
            wset, Info.WinID
            plots,[Info.X,event.X],[Info.Y,event.Y],/device,thick=2
            Info.X = event.X
            Info.Y = event.Y
         endif
         label_text = string(Info.x, Info.y, Info.pen, $
                 format='("X:", i3, 1x, "Y:", i3, 1x, "Pen:", i1)')
         WIDGET_CONTROL, Info.label, set_value=label_text
      end
      'Erase' : begin
         wset, Info.WinID
         erase
      end
      else :
    ENDCASE
    *InfoPointer = Info
END
PRO Chapter07MyPaint
  device, get_screen_size=screen_size
  xoffset = (screen_size[0]-600) / 2
  yoffset = (screen_size[1]-360) / 2
  MyBase = Widget_BASE(column=1, title='My Paint Window', $
    xoffset=xoffset, yoffset=yoffset, TLB_FRAME_ATTR=1)
  draw = widget_draw(MyBase, xsize=600, ysize=260, $
    uvalue='Draw', /button_events)
  label = widget_label(MyBase, value='X: Y: Pen:', $
    /align_center, /dynamic_resize)
  base = widget_base(MyBase, row=1, /align_center)
  butt = widget_button(base, value='Erase', uvalue='Erase', xsize=100)
  butt = widget_button(base, value='Exit', $
    uvalue='Exit', xsize=100, event_pro='Chapter07MyPaintExit')
  WIDGET_CONTROL, MyBase, /realize
  WIDGET_CONTROL, draw, get_value=WinID
  wset, WinID
  erase
  Info = {WinID:WinID, label:label, pen:0, x:-1L, y:-1L}
  InfoPointer = ptr_new(Info)
  WIDGET_CONTROL, MyBase, SET_UVALUE=InfoPointer
  xmanager, 'Chapter07MyPaint', MyBase, $
    CLEANUP='Chapter07MyPaintCleanUp', /no_block
END
