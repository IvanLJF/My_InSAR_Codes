Pro progressbar_test_cleanup,wtlb
	widget_control,wtlb,get_uvalue = progressbar
	obj_destroy,progressbar
End
;
;
;
Pro progressbar_test_event,ev
	uname = widget_info(ev.id,/uname)
	case uname of
	 'outstart' : begin
	 	cd ,current = rootdir
	 	 bmppath = rootdir+'\bar2.jpg'
	 	 ;
		 ;创建弹出进度条
		 ;
     	 progressbar = obj_new('Cw_progressbar',$
		   		group=ev.top,$
		        /bitmap,$
				bmppath=bmppath,text='')
		for i=0 ,100 do begin
			  progressbar->setproperty,text='进度 :' + strtrim(string(i),2)+'%'
			 progressbar->update ,i
			 wait,0.1
		endfor
		 progressbar->destroy
	 end
	 'instart'  : begin
	 	widget_control,ev.top,get_uvalue = progressbar
	 	for i=0 ,100 do begin
			 progressbar->setproperty,text='进度 :' + strtrim(string(i),2)+'%'
			 progressbar->update ,i
			 wait,0.1
		endfor
		progressbar->setproperty,text='进度完成'
	 end
	 else :
	endcase
ENd
;
;
;
PRo progressbar_test
	wtlb = widget_base(title='progressbar_test',ysize=300,/column)
	;
	wbutton = widget_button(wtlb,value='悬浮进度条 start',uname='outstart')
	wbutton = widget_button(wtlb,value='嵌入进度条 start',uname='instart')
	;
	cd ,current = rootdir
	bmppath = rootdir+'\bar.bmp'
	;
	;创建嵌入式进度条
	;
	progressbar = obj_new('Cw_progressbar',$
		   		parent=wtlb,$
		        /bitmap,$
				bmppath=bmppath,text='')
	widget_control,wtlb,/realize,set_uvalue = progressbar
	xmanager,'progressbar_test',wtlb,/no_block,cleanup = 'progressbar_test_cleanup'
End