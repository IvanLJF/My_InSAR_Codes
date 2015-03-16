;+--------------------------------------------------------------------------

;| 主事件

;+--------------------------------------------------------------------------

Pro TestInterrupt_Event, ev


       uname = widget_info(ev.id, /uname)


       case uname of

              ;

              ; 开始循环

              'startLoop': begin

                     wInterrupt = widget_info(ev.top, find_by_uname='interrupt')

                     wExit = widget_info(ev.top, find_by_uname='exit')

                     widget_control, wExit, sensitive=0

                     widget_control, ev.id, sensitive=0


                     for i=1, 100 do begin

                            if widget_info(wInterrupt, /valid_ID) then begin

                                event = widget_event(wInterrupt, /noWait)

                               name = tag_names(event, /structure_name)

                               if name eq 'WIDGET_BUTTON' then begin

                                      print, '循环被终止 ~_~ '

                                      break

                               endif

                         endif

                            print, '已执行到第 ' + strtrim(string(i), 2) + '  步'

                            wait, 1

                     endfor


                     print, '循环执行完毕 ^_^ '

                     widget_control, wExit, sensitive=1

                     widget_control, ev.id, sensitive=1

              end

              ;

              ; 退出

              'exit': begin

                     widget_control, ev.top, /destroy

              end

              ;

              ; 未知事件

              else:

       endcase

End

;+--------------------------------------------------------------------------

;| 目的: 测试如何在循环执行过程中，使外部操作进入循环内部

;| 作者: huxz, 2007-1-13

;| 类属: 程序控制

;+--------------------------------------------------------------------------

Pro TestInterrupt

       ;

       ; 创建界面

       wTlb = widget_base(/col, /toolbar, tlb_frame_attr=8, title='Inter')

       wBtn = widget_button(wTlb, value='开始循环', uname='startLoop')

       wBtn = widget_button(wTlb, value='终止循环', uname='interrupt')

       wBtn = widget_button(wTlb, value='退出', uname='exit')

       ;

       ; 界面居中

       screenSize = get_screen_size()

       geom = widget_info(wTlb, /geometry)

       widget_control, wTlb, $

           tlb_set_xoffset = (screenSize[0] - geom.scr_XSize)/2., $

           tlb_set_yoffset = (screenSize[1] - geom.scr_YSize)/2.


       widget_control, wTlb, /realize

       ;

       ; 注册事件

       xmanager, 'TestInterrupt', wTlb, /no_block

End
