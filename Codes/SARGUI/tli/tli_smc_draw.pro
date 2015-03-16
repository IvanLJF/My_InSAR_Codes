pro TLI_SMC_DRAW_EVENT,ev
  COMMON TLI_SMC_GUI, types, file, wid, config
  
  widget_control, ev.id, get_uvalue = state, /no_copy
  if ev.press eq 8 then begin
    widget_control,ev.id,get_draw_view=tmp
    state.dv = tmp
    widget_control,ev.id,set_draw_view=state.dv + [0,10]
  endif
  if ev.press eq 16 then begin
    widget_control,ev.id,get_draw_view=tmp
    state.dv = tmp
    widget_control,ev.id,set_draw_view=state.dv - [0,10]
  endif
  if ev.press eq 1 and ev.clicks eq 1 then begin
    state.flag_press = 1
    state.flag_press_pos = [ev.x, ev.y]
  endif
  if ev.release eq 1 then begin
    state.flag_press = 0
    device,/cursor_original
  endif
  if state.flag_press eq 1 then begin
    device,cursor_standard=52
    widget_control,ev.id,get_draw_view=tmp
    state.dv = tmp
    geo = widget_info(ev.id,/geometry)
    scroll_test = (state.dv + (state.flag_press_pos - [ev.x,ev.y]))[1]
    if scroll_test ge 0 and scroll_test le (geo.draw_ysize-geo.ysize) then $
      state.dv = state.dv + (state.flag_press_pos - [ev.x,ev.y])
    widget_control,ev.id,set_draw_view=state.dv
  endif
  widget_control, ev.id, set_uvalue = state, /no_copy
  
  
  ; Update label info
  
  drawsz=widget_info(wid.draw,/geom)
  
  x=ev.x
  y=ev.y
  
  value='Coordinate:'+STRING(10b)+$
                           '('+STRCOMPRESS(x, /REMOVE_ALL)+','+STRCOMPRESS(y,/REMOVE_ALL)+')'+STRING(10b)+$
                           STRING(10b)+$
                           'Value: '+STRING(10b)+$
                           '0.0'
  
 
  
  widget_control,wid.label,set_value=value
end

function TLI_SMC_DRAW,parent,xsize,ysize,XSCROLL=xscroll,YSCROLL=yscroll, SCROLL=scroll, retain=retain,color_model=color_model
  COMMON TLI_SMC_GUI, types, file, wid, config
  state = { flag_press: 0,$
    flag_press_pos: [0,0],$
    dv: [0,0]$
    }
  main = widget_draw(parent,xsize=xsize,ysize=ysize,x_scroll_size=xscroll,y_scroll_size=yscroll, scroll=scroll, $
    retain=retain,color_model=color_model,event_pro='tli_smc_draw_event')
  widget_control, main, set_uvalue = state, /no_copy
  return,main
end