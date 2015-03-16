;*****************************************************************************************************
;
;
;
;
; NAME:
;       Cw_progressbar  PROGRAM
;
; PURPOSE:
;
;       This is the PROGRESSBAR  program
; KEYWORDS:  :
;	   bmppath =bmppath ,            ; 进度条的图片路径，必要的，图标的格式只支持bmp。用户可以选择自己喜欢的进度条图片
;
;   optional :
;      parent                       ; 父组件id，用于在界面内集成进度条
; 	   GROUP_LEADER=group_leader, $ ; The identifier of the group leader widget
;      TEXT=text, $                 ; The message text to be written over the progress bar.
;      TITLE=title, $               ; The title of the top-level base widget.
;      num =num   ,$                ; 进度分割数，默认是100
;	   TLB_FRAME_ATTR=TLB_FRAME_ATTR; base 风格
;      XSIZE=xsize, $               ; The X size of the progress bar.
;      YSIZE=ysize                  ; The Y size of the progress bar
;                                   ; 在bitmap模式不推荐使用xsize，ysize，最好根据图片默认大小
;	   xoffset     =xoffset      ,$ ;
;      yoffset     =yoffset      ,$ ;
;      frame       =frame        ,$ ;
;      bitmap      =bitmap       ,$ ; 选择用图片还是程序自画进度条
;      color       =color        ,$ ; 选择程序自己绘制的进度条颜色
;      backgroud   =backgroud    ,$ ; 背景颜色
;
;MODIFICATION HISTORY:
;	2007-04-16 china beijing	WriteBy :Quxy(QQz)
;
;*****************************************************************************************************

Pro Cw_progressbar::cleanup
	self->destroy
End
;-------------------
;
;-------------------
Pro Cw_progressbar::getproperty  ,$
					time =time   ,$
					tlb  =tlb
	IF Arg_Present(time) THEN time = self.time
	IF Arg_Present(tlb) THEN tlb = self.tlb
End
;-------------------
;  设置属性
;-------------------
Pro Cw_progressbar::setproperty  ,$
						time = time ,$
						text=text
	if N_Elements(time) gt 0 THEN self.time = time
	if N_Elements(text) gt 0 THEN Begin
	   self.text = text
       IF Widget_Info(self.labelID, /Valid_ID) THEN Widget_Control, self.labelID, Set_Value=text
    Endif

End
;-------------------
;  销毁进度条类
;-------------------
Pro Cw_progressbar::destroy
	compile_opt idl2
	;

   if widget_info(self.tlb,/valid_id) then $
       widget_control,self.tlb,/destroy
	ptr_free,self.pos
	Obj_Destroy,self.draw_win
	Obj_Destroy,self.mask_image
	Obj_Destroy,self.draw_view
	Obj_Destroy, self

End
;-------------------
; 绘制需要的进度
;-------------------
Pro Cw_progressbar::update,count
	 compile_opt idl2
	 ;
	 if self.auto ge 1 then begin
	   	 xoffset = self.xsize/100.
	   	 *(self.pos) = shift((*(self.pos)),1)
	   	 n = where((*(self.pos)) eq 1)
	   	 loc = [xoffset*(n+1),0]
	   	 self.mask_image->setproperty,loc=loc
	   	 self.draw_win->draw
	 endif else begin
	 	xoffset = self.xsize/100.
	 	loc = [xoffset*(count),0]
	 	self.mask_image->setproperty,loc=loc
	   	self.draw_win->draw
	 endelse
End
;-------------------
;初始化
;-------------------
Function Cw_progressbar::init           ,$
			  parent      = parent      ,$
			  group       =group        ,$ ; The identifier of the group leader widget
              TEXT        =text         ,$ ; The message text to be written over the progress bar.
              TITLE       =title        ,$ ; The title of the top-level base widget.
              bmppath     =bmppath      ,$ ;
              time        =time         ,$ ;
              xoffset     =xoffset      ,$ ;
              yoffset     =yoffset      ,$ ;
              frame       =frame        ,$ ;
              color       =color        ,$ ;
              backgroud   =backgroud    ,$ ;背景颜色
              bitmap      =bitmap       ,$
              MAP         =MAP          ,$
              SENSITIVE   =SENSITIVE    ,$
              TLB_FRAME_ATTR=TLB_FRAME_ATTR,$;
              num         =num          ,$ ;
              XSIZE       =xsize        ,$ ; The X size of the progress bar.
              YSIZE       =ysize           ; The Y size of the progress bar.
	compile_opt idl2
	IF N_Elements(text) EQ 0 THEN text = "Operation in progress..."
    IF N_Elements(title) EQ 0 THEN title = "Progress Bar"
    IF N_Elements(xoffset) EQ 0 THEN xoffset = 0
    IF N_Elements(yoffset) EQ 0 THEN yoffset = 0
    IF N_Elements(frame) EQ 0 THEN   frame = 0
    IF N_Elements(MAP) EQ 0 THEN   MAP = 1
    IF N_Elements(SENSITIVE) EQ 0 THEN   SENSITIVE = 1
    IF N_Elements(TLB_FRAME_ATTR) EQ 0 THEN TLB_FRAME_ATTR = 5
    IF N_Elements(backgroud) ne 3 THEN backgroud = [255,255,255]
    IF N_Elements(num) gt 0 THEN begin
    	self.num = num
    endif else begin
		self.num = 100
    endelse
   	self.pos = ptr_new(intarr(self.num))
    IF N_Elements(time) EQ 0 THEN begin
     	self.time = 0.1
    endif else begin
    	self.time =time
    endelse
    ;
    ;
	if (n_elements(xsize) gt 0) then begin
		self.xsize = xsize
	endif
	if (n_elements(ysize) gt 0) then begin
		self.ysize = ysize
	endif
	;
	;判断是否用进度图片
	;
	if N_Elements(bitmap) gt 0 then begin
	    r = query_image(bmppath, dimensions=sz,CHANNELS=CHANNELS)
	    if r eq 0 then return,0
	    if self.xsize eq 0 then begin
		    self.xsize =sz[0]
		    self.ysize =sz[1]
	    endif
		if r eq 0 then begin
			print,'value:'+bmppath
			print,'cw_progressbar :'+'未知的图标地址'
			return,0
		endif else begin
			if (CHANNELS lt 3) or (CHANNELS gt 3) then begin
				print,'cw_progressbar :'+'只支持3通道图标'
			return,0
			endif
		endelse
		;
   		bb = congrid(read_image(bmppath, /rgb),3,self.xsize,self.ysize)
	endif else begin
		if N_Elements(color) le 0 then color=[0,0,255]
			if self.xsize eq 0 then self.xsize = 100
			if self.ysize eq 0 then self.ysize = 30
			bb = bytarr(3,self.xsize,self.ysize)
			bb[0,*,*] = color[0]
			bb[1,*,*] = color[1]
			bb[2,*,*] = color[2]
	endelse
	;
	;建立顶base
	;
	if n_elements(parent) gt 0 then begin
		self.tlb = Widget_Base(           $
					 parent              ,$
					 Title=title         ,$
	   				 Column=1            ,$
	   				 Base_Align_Center=1 ,$
	     			 Map=0               ,$
	     			 frame = frame       ,$
	     			 SENSITIVE =SENSITIVE,$
	     			 xoffset = xoffset   ,$
	     			 yoffset = yoffset   ,$
	     			 event_pro='Cw_progressbar_Event')
	endif else begin
		self.tlb = Widget_Base(Title=title    ,$
	   				 Column=1                 ,$
	   				 Base_Align_Center=1      ,$
	     			 ;Map=0                    ,$
	     			 frame = frame            ,$
	     			 xoffset = xoffset        ,$
	     			 yoffset = yoffset        ,$
	     			 SENSITIVE =SENSITIVE     ,$
	     			 /FLOATING                ,$
	     			 /MODAL                   ,$
	     			 Group_Leader=group       ,$
	     			 TLB_FRAME_ATTR=TLB_FRAME_ATTR,$
	     			 event_pro='Cw_progressbar_Event')
	endelse
   self.labelID = Widget_Label(self.tlb,$
   				 Value=text,$
   				 /Dynamic_Resize)
   self.drawID = Widget_Draw(self.tlb ,$
   				 RETAIN =2            ,$
   				  /EXPOSE_EVENTS      ,$
   				 SENSITIVE =SENSITIVE ,$
   				 XSize=self.xsize     ,$
   				 YSize=self.ysize     ,$
   				 GRAPHICS_LEVEL =2    )
   Widget_Control, self.tlb, Set_UValue=self
   widget_control, self.drawID, /realize
   widget_control, self.drawID, get_value=draw_win
   self.draw_win=draw_win
   self.draw_win->setcurrentcursor, 'ARROW'
   draw_image = obj_new('IDLgrImage', bb,INTERLEAVE=0)
   mbmp = bytarr(3,self.xsize,self.ysize)
   mbmp[0,*,*] = backgroud[0]
   mbmp[1,*,*] = backgroud[1]
   mbmp[2,*,*] = backgroud[2]
   self.mask_image = obj_new('IDlgrimage',data=mbmp,INTERLEAVE=0)
   draw_model = obj_new('IDLgrModel')
   draw_model->add, draw_image
   draw_model->add, self.mask_image
   self.draw_view = obj_new('IDLgrView',$
   				 viewplane_rect=[0,0,self.xsize,self.ysize], $
				 dimensions=[self.xsize,self.ysize])
   self.draw_view->add, draw_model
   ;
   self.draw_win->setproperty,graphics_tree=self.draw_view
   self.draw_win->draw
   widget_control, self.drawID,map=1
   self.draw_win->draw

   return,1

End
;----------
; 定义
;----------
Pro Cw_progressbar__define
	compile_opt idl2
	state = { Cw_progressbar        ,$
			text: ""                ,$        ; The text message to be written over the progress bar.
            title: ""               ,$        ; The title of the top-level base widget.
            tlb: 0L                 ,$        ; The identifier of the top-level base.
            labelID :0l             ,$        ;
            drawID  :0l             ,$;
            pos     :ptr_new()      ,$;
            draw_win :obj_new()     ,$;
            mask_image : obj_new()  ,$;
            draw_view  : obj_new()  ,$;
            auto :0L                ,$
            time :0.                ,$
            num  :0l                ,$
            wid: 0L                 ,$         ; The window index number of the draw widget.
            xsize: 0L               ,$         ; The XSize of the progress bar.
            ysize: 0L                $         ; The YSize of the progress bar.

	}

End