function direc_ok, event

COMMON SHARE1, val

   base1=widget_info(event.top,/child)

   text=widget_info(base1,/all_children)

   widget_control,text(1),get_value=val

   widget_control,event.top,/destroy

   return,val

end




function direc_cancel, event

COMMON SHARE1, val

val=0

widget_control,event.top,/destroy

return,val

end




pro direction, out=out

;defsysv,'!val',0
COMMON SHARE1, val

   screen_size = get_screen_size()

   offset = screen_size*0.4

base_direction=widget_base(/colum,xoffset=offset(0),yoffset=offset(1))

base1=widget_base(base_direction,/row)

label1=widget_label(base1,value='输入方向：')

text=widget_text(base1,uname='text',/editable,xsize=10,value='0')

base2=widget_base(base_direction,/row)

button1=widget_button(base2,value='确定',uname='button1',event_func='direc_ok')

button2=widget_button(base2,value='取消',uname='button2',event_func='direc_cancel')

widget_control,base_direction,/realize

xmanager,'direction',base_direction,/no_block

out=val

end