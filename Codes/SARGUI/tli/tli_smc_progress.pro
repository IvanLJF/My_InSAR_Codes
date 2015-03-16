;
; Progress bar
;
; Keywords:
;
; Written by:
;
function center_box,drawsize,drawysize=drawysize
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo

  geom = Widget_Info(wid.base, /geometry)
  posx = geom.xoffset + geom.xsize/2.0 - drawsize/2.0
  posy = geom.yoffset + geom.ysize/2.0 - 30
  IF KEYWORD_SET(drawysize) THEN posy = geom.yoffset + geom.ysize/2.0 - drawysize/2.0

  return,[posx,posy]
end
;-------------------------------------------------------------------------------
; CHECK_CANCEL: this function returns 1 if cancel button is pressed
;-------------------------------------------------------------------------------
function progressObj::check_cancel
	return, self.cancel
end

;-------------------------------------------------------------------------------
; NEW_LABEL: allow to rename the progress bar during the process
;-------------------------------------------------------------------------------
pro progressObj::new_label,NewLabel
	if n_elements(NewLabel) eq 0 then NewLabel=""
	widget_control,self.labelID,set_value=NewLabel
end

;-------------------------------------------------------------------------------
; NEW_LABEL2: allow to rename the second line of the progress bar during the process
;-------------------------------------------------------------------------------
pro progressObj::new_label2,NewLabel
	if n_elements(NewLabel) eq 0 then NewLabel=""
	widget_control,self.labelID2,set_value=NewLabel
end

;-------------------------------------------------------------------------------
; SET_CANCEL: set the cancel flag
;-------------------------------------------------------------------------------
pro progressObj::set_cancel,value
	if n_elements(value) eq 0 then value=1
	self.cancel = value
end

;-------------------------------------------------------------------------------
; DESTROY: destroy the progress bar widget
;-------------------------------------------------------------------------------
pro progressObj::destroy
	widget_control,self.base,/destroy
end

;-------------------------------------------------------------------------------
; hide: unsensitive the cancel button
;-------------------------------------------------------------------------------
pro progressObj::hide_cancel_button
	if self.cancelID ne -1 then widget_control,self.cancelID,sensitive=0
end

;-------------------------------------------------------------------------------
; UPDATE: update the progress bar function of percent
;-------------------------------------------------------------------------------
pro progressObj::update,percent
	
	;set the progress bar draw
	wset,self.wid
	
	;update the progress bar
	ybox_coords = [0, 10, 10, 0, 0]
	xextent = Fix(self.xsize*percent/100.0)
	xbox_coords1 = [0, 0, xextent, xextent, 0]
	xbox_coords2 = [xextent, xextent, self.xsize, self.xsize, 0]

	tvlct,r,g,b,/get
	loadct,13,/silent
	polyfill, xbox_coords1, ybox_coords, Color=255, /Device
	tvlct,r,g,b
	polyfill, xbox_coords2, ybox_coords, Color=100, /Device
	
	;--> Check for button cancel event
	if widget_info(self.cancelID,/valid_id) then begin
		event = widget_event(self.cancelID,/nowait)
   	name = tag_names(event, /structure_name)
     	if name eq 'WIDGET_BUTTON' then self.cancel = 1
		endif
	
end

;-------------------------------------------------------------------------------
; UPDATE2: update the second progress bar function of percent
;-------------------------------------------------------------------------------
pro progressObj::update2,percent
	
	;set the progress bar draw
	wset,self.wid2
	
	;update the progress bar
	ybox_coords = [0, 10, 10, 0, 0]
	xextent = Fix(self.xsize*percent/100.0)
	xbox_coords1 = [0, 0, xextent, xextent, 0]
	xbox_coords2 = [xextent, xextent, self.xsize, self.xsize, 0]

	tvlct,r,g,b,/get
	loadct,0,/silent
	polyfill, xbox_coords1, ybox_coords, Color=255, /Device
	tvlct,r,g,b
	polyfill, xbox_coords2, ybox_coords, Color=100, /Device
	
	;--> Check for button cancel event
	if widget_info(self.cancelID,/valid_id) then begin
		event = widget_event(self.cancelID,/nowait)
   	name = tag_names(event, /structure_name)
     	if name eq 'WIDGET_BUTTON' then self.cancel = 1
		endif
	
end


;-------------------------------------------------------------------------------
; START: start the progress bar object
;-------------------------------------------------------------------------------
pro progressObj::start
	
	;--> Realise the widget
	widget_control,self.base,/realize
	
	;--> Get the draw id
	widget_control,self.drawID,get_value=dummy
	self.wid=dummy
	
	if self.drawID2 ne 0 then begin
		WIDGET_CONTROL, self.drawID2, GET_VALUE=dummy
		self.wid2 = dummy
	endif
	
	;--> Start the update
	self->update,0
	
end

;-------------------------------------------------------------------------------
; PROGRESS BAR OBJECT INITIALISATION
;-------------------------------------------------------------------------------
function progressObj::init,$
	parent, $          ; The widget ID of the group leader
	cancel_button = cancel_button, $ ; Allow to display the cancel button
	message=message, $ ; Define the message to display above the progress bar
	submessage=submessage,$ ; Define the second message to be displayed
	xsize=xsize, $     ; The xsize of the progress bar
	xoffset=xoffset,$
	yoffset=yoffset,$
	two_lines=two_lines
	
	;--> update self structure
	self.cancel_button = keyword_set(cancel_button)
	self.message = message
	self.submessage=submessage
	self.xsize = xsize
	self.xoffset = xoffset
	self.yoffset = yoffset
	self.parent = parent
	
	;--> Create the widget
	if self.cancel_button eq 1 then modal=0 else modal=1
	self.base = WIDGET_BASE(group_leader=self.parent,/column,title='Sasmac InSAR is busy...',modal=modal,$
	                        xoffset=self.xoffset,yoffset=self.yoffset,/floating,/tlb_kill_request_events,tlb_frame_attr=9)
	self.labelID = widget_label(self.base,value=self.message, xsize=self.xsize,/align_left)
	self.drawID = widget_draw(self.base,xsize=self.xsize,ysize=10)
	IF self.submessage ne '' THEN BEGIN
		self.labelID2 = WIDGET_LABEL(self.base,VALUE=submessage, XSIZE=self.xsize,/ALIGN_CENTER)
		self.drawID2  = WIDGET_DRAW(self.base,XSIZE=self.xsize,YSIZE=10)
	ENDIF
	if self.cancel_button eq 1 $
		then self.cancelID = widget_button(self.base,value=' Cancel operation ') $
		else self.cancelID = -1l
	
	return,1
end

pro progressObj__define

	; the progress obj structure
   struct = {progressObj, $    ; The SHOWPROGRESS object class.
             base:0L, $          ; The identifier of the top-level base.
             labelID:0L, $      ; The identifier of the label widget.
             drawID:0L, $       ; The identifier of the draw widget.
             labelID2:0L, $     ; The identifier of the second label widget
             drawID2:0L, $      ; The identifier of the second draw widget
             parent:0L, $       ; The identifier of the group leader widget.
             cancelID:0L, $     ; The identifier of the CANCEL button.
             wid:0L, $          ; The window index number of the draw widget.
             wid2:0L, $         ; The window index number of the second draw widget
             xsize:0L, $        ; The XSize of the progress bar.
             ysize:0L, $        ; The YSize of the progress bar.
				 		 xoffset:0l, $      ; The global Xoffset position to display the progress bar
				     yoffset:0l, $      ; The global Yoffset position to display the progress bar
             cancel:0L, $       ; A flag to indicate the CANCEL button was clicked.
             cancel_button:0L, $ ; A flag to indicate a CANCEL button should be added.
             message:'', $      ; The message to be written over the progress bar.
             submessage:'', $     ; The second message to be written over the second progress bar
             title:''$        ; The title of the top-level base widget.
             }
end


pro TLI_SMC_PROGRESS, message=message, drawsize=drawsize, percent=percent, destroy=destroy, $
              check_cancel=check_cancel, cancel_button=cancel_button, $
              submessage = submessage, subpercent = subpercent
   COMMON TLI_SMC_GUI, types, file, wid, config, finfo

   if config.batch then begin
      if n_elements(message) ne 0 then begin
         print,''
         print,format='(A,%"\r\t\t\t\t\t\t",$)','Progress of '+message+' : '
         print,format='(A,%"\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b",$)','       [                    ]'
      endif
               
      if n_elements(submessage) ne 0 then print,'    Subprogress of '+submessage+' : '
      if n_elements(percent) ne 0 then begin
         for k=1,percent/5.0 do print,format='(A,$)','.'
         for k=1,percent/5.0 do print,format='(%"\b",$)'
      endif
      if n_elements(subpercent) ne 0 then print,'      {'+string(percent,f='(f0.2)')+'%}+'
      return
   endif
	
	if not keyword_set(drawsize) then drawsize = 250
	pos = center_box(drawsize)
	
	;-> generat case: two_lines is set to 0
	if not keyword_set(submessage) then submessage=''		
	
	;if keyword_set(cancel_button) then file_delete,config.tempdir+'progressTimer.sav',/quiet

	; --> Initialisation of the progress bar:
	if keyword_set(message) then begin
		
		if ptr_valid(config.progress) then begin
			*config.progress->new_label,message
		endif else begin
			; need a cancel button?
			cb = (not keyword_set(cancel_button)) ? 0l : 1l
			; initialisation 
			wid.cancel = 0l
			ptr_free,config.progress
			; create the progressTimer object
			config.progress = ptr_new(obj_new("progressObj",wid.base, cancel_button=cb,message=message,$
			                          xsize=drawsize,xoffset=pos[0],yoffset=pos[1],$
			                          submessage=submessage))
			*config.progress->start
			return	
		endelse
	endif
	
	if keyword_set(percent) then *config.progress->update,percent
	if keyword_set(subpercent) then *config.progress->update2,subpercent
	if keyword_set(submessage) then *config.progress->new_label2,submessage
	
	if keyword_set(destroy) then begin
           if config.progress ne ptr_new() then begin
              *config.progress->destroy
              obj_destroy,*config.progress
              ptr_free,config.progress
              config.progress=ptr_new()
           endif
           widget_control,wid.draw,get_value=dummy
           wset,dummy
           return
        endif
	
	if keyword_set(check_cancel) then begin
		;cancelled = *config.progress->check_cancel()
		if *config.progress->check_cancel() eq 1 then begin
			ok = dialog_message('User Cancelled operation',dialog_parent=wid.base)
			progress,/destroy
			percent = 0
			wid.cancel = 1
		endif
	endif else begin	  
		*config.progress->hide_cancel_button
	endelse

end
