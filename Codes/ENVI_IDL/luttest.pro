pro luttest_draw, ev

;最终编辑 gchen1在遥感图像处理中，我们看到的图像是某些物理量经过线性拉伸到0-255的灰度级后所表现的形式，而其真正的物理意义并不能通过所显示的图像表达出来，这时就需要一个常用的工具——色标来进行处理，色标是将显示图像的数值对应到其真实物理量的一个有效手段。
;但是，在通过色标建立了显示图像到真实物理量的对应关系后，遇到了一个问题——就是当我们对显示图像作了处理（亮度、对比度、线性拉伸，直方图均衡化等）以后，如何对色标进行处理的问题。由于当我们对显示图像做了处理以后，显示图像的灰度发生了变化，因此色标也必须改变，以确保显示图像对应到的物理量不发生变化。
;如何使色标也跟随显示图像的变化而变化呢？
;１．如果用比较笨的办法，可以使用循环，遍历每一个处理后图像的像素和处理前图像像素的关系，但还是会有些问题，因为图像中在某个灰度级的像素个数可能为零，总之这时一个废时费事的办法。
;２．如果用比较聪明的办法，那就是本次的重点，请看下面的例子。
compile_opt strictarr

widget_control,ev.top,get_uvalue=pstate
uname = widget_info(ev.id,/uname)

     ;屏幕坐标转换到图像坐标
x = ev.x
y = ev.y-30
if y lt 0 then return

     ;**注意：对原始图像使用探针,即只对显示图像作处理
value = (*pstate).image[x,y]

;状态栏更新
widget_control,(*pstate).wstatus[0],set_value='X:'+strtrim(string(x),2)
widget_control,(*pstate).wstatus[1],set_value='Y:'+strtrim(string(y),2)
widget_control,(*pstate).wstatus[2],set_value='VALUE:'+strtrim(string(value),2)
end
;
;==========================================================================
pro luttest_setcolorbar, pstate, displayimage
compile_opt strictarr

     ;获取显示图像中的色标矢量，此时色标矢量已经跟随显示图像做了处理。
lut = displayimage[0:255,0]
(*pstate).opalette->getproperty, red=r, green=g, blue=b
nr = r[lut]
ng = g[lut]
nb = b[lut]
(*pstate).ocbPalette->setproperty, red=nr, green=ng, blue=nb
end
;
;==========================================================================
pro luttest_tools, ev
compile_opt strictarr

widget_control,ev.top,get_uvalue=pstate
uname = widget_info(ev.id,/uname)

(*pstate).oimage->getproperty, data=displayimage
case uname of
   'hist':displayimage = bytscl(hist_equal(displayimage))
   'reverse':displayimage = 255-displayimage
   'revert':begin
    displayimage = bytscl((*pstate).image)
    displayimage[0:255,0] = bindgen(256)
   end
   else:
endcase
luttest_setcolorbar, pstate, displayimage
(*pstate).oimage->setproperty, data=displayimage
(*pstate).owin->draw
end
;
;==========================================================================
pro luttest_cleanup, tlb
compile_opt strictarr
widget_control, tlb, get_uvalue=pstate
heap_free,pstate
end
;
;==========================================================================
pro luttest
compile_opt strictarr

;读取数据,到原始图像image
file = FILEPATH('surface.dat', SUBDIR=['examples', 'data'])
image = intarr(350,450)
openr, lun, file, /get_lun
readu, lun, image
free_lun, lun

;复制一份，拉伸到0-255作为显示图像
displayimage = bytscl(image)

;把0-255的线性矢量写到显示图像的第一行，让其跟随显示图像作处理
displayimage[0:255,0] = bindgen(256)

     ;创建界面
tlb = widget_base(/column)
wtoolsbase = widget_base(tlb,/row,event_pro='luttest_tools')
   whist = widget_button(wtoolsbase,value='直方图均衡化',uname='hist')
   wreverse = widget_button(wtoolsbase,value='反相',uname='reverse')
   wrevert = widget_button(wtoolsbase,value='还原',uname='revert')

wdraw = widget_draw(tlb,xsize=350,ysize=480,event_pro='luttest_draw',$
    /motion_events,graphics_level=2,retain=2)
wstatus = widget_base(tlb,/row)
   wX = widget_label(wstatus,value='X:        ')
   wY = widget_label(wstatus,value='Y:        ')
   wValue = widget_label(wstatus,value='VALUE:        ')

widget_control, tlb, /realize

widget_control, wdraw, get_value=owin
oview = obj_new('IDLgrView',viewplane_rect=[0,-30,350,480])
owin->setproperty, graphics_tree=oview

     ;图像的层次
omodel = obj_new('IDLgrModel')
loadct,3,/silent
tvlct,r,g,b,/get
opalette = obj_new('IDLgrPalette',red=r,green=g,blue=b)
oimage = obj_new('IDLgrImage',displayimage,palette=opalette)
omodel->add,oimage
oview->add,omodel

     ;色标的层次
ocolorbarModel = obj_new('IDLgrModel')
oview->add, ocolorbarModel
dd = max(image)-min(image)
rgb = bytarr(256,16)
rgb[*,*] = indgen(256*16) MOD 256
ocbpalette = obj_new('IDLgrPalette',red=r,green=g,blue=b)
ocbimage = obj_new('IDLgrImage',rgb,dimensions=[dd,16], $
       location=[min(image),0],palette=ocbpalette)
     oAxis = obj_new('IDLgrAxis',range=[min(image),max(image)], $
       /exact,color=[0,0,0],textpos=1,ticklen=16,major=5)
ocolorbarModel->add, ocbimage
     ocolorbarModel->add, oAxis
ocolorbarModel->translate, -min(image), 0, 0
     ocolorbarModel->scale, 350*0.90/dd, 450/40./16., 1
     ocolorbarModel->translate, 15,-30, 0

owin->draw

pstate = ptr_new({opalette:opalette, $
      ocbpalette:ocbpalette, $
      owin:owin, $
      oimage:oimage,$
      image:image, $
      wstatus:[wX,wY,wValue]})

widget_control, tlb, set_uvalue=pstate

xmanager, 'luttest', tlb, cleanup='luttest_cleanup', /no_block
end