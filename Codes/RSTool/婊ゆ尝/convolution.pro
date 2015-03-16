pro convolution_event, event

COMMON SHARE1,out

    widget_control, event.top, get_uvalue=ptr_param

    uname = widget_info(event.id,/uname)

    case uname of
    
       'droplist' : begin
       
        (*ptr_param).method = event.index
        
        ;img = (*ptr_param).img
        
        ;res = conv_display(ptr_param=ptr_param)
        
        conv_display, ptr_param
        
        widget_control, event.top, set_uvalue=param
        
        end
        
        'button_outfile' : begin
        
        outfile = dialog_pickfile(title='选择输出文件的路径', dialog_parent=event.top, filter=['*.img'])
        
        if outfile eq '' then return;,event
        
        filename=filter_filename(outfile)

;        is=strpos(filename,'.',/reverse_search)
;        if is eq -1 then filename=filename+'.img'
;        if is eq strlen(filename)-1 then  filename=strmid(filename,0,is)+'.img'
;        outfile=getpathname(outfile)+sep()+filename
;        if file_test(outfile) then begin
;        yn=dialog_message('文件已存在，是否覆盖？',/question,/default_no,title='卷积滤波')
;        if yn eq 'no' then return;,event
;        endif
  
        widget_control, widget_info(event.top, find_by_uname='text3'), set_value=filename
        
        (*ptr_param).outfile=filename
                        
        end
;        
        'confirm_button' : begin
        
        res = conv_ok(event)
        
        end
        
        'cancel_button' : begin
        
        res = conv_cancel(event)
        
        end
;        
        'text1' : begin
        
        ;print,'text1'

        if tag_names(event,/structure_name) eq 'WIDGET_TEXT_CH' then text1_ch, event
        
        end
        
        'kernel_table' : begin
        
        if tag_names(event,/structure_name) eq 'WIDGET_TABLE_CELL_SEL' then table_ch, event
        
        end
        
    endcase

end


pro convolution , infile;, outf
forward_function envi_get_data
;COMMON SHARE1,out
 defsysv ,'!out',''

  envi, /restore_base_save_files
  ;
  ; Initialize ENVI and send all errors
  ; and warnings to the file batch.txt
  ;
  envi_batch_init, log_file='batch.txt'

   screen_size = get_screen_size()
   
   base_size = [450,550]
   
   offset = (screen_size-base_size)/2
   
;   print,screen_size

   base = widget_base(title='卷积滤波', uname='convolution', scr_xsize=base_size(0), scr_ysize=base_size(1),$
          xoffset=offset(0), yoffset=offset(1), space=3, xpad=3, ypad=3, tlb_frame_attr=1, /colum)
          
   ;显示区的BASE
   disp_base = widget_base(base, uname='disp_base')
   
   drawer = widget_draw(disp_base, uname='drawer', xsize=440, ysize=300)
   
   ;按钮区的BASE          
   func_base = widget_base(base, uname='func_base',  /frame)
   
   func_base1 = widget_base(func_base, /row)
   
   ;用以选择增强方法的droplist
   droplist = widget_droplist(func_base1, uname='droplist', title='     卷积方法：',$
     value=['Sobel','Roberts','Median','Low pass','High pass','Laplacian','Directional','Gaussian low pass','Gaussian high pass','User-defined'])
   
   ;图像显示最小值
   label1 = widget_label(func_base1, uname='label1', value='          ADD-BACK：')
   
   text1 = widget_text(func_base1, uname='text1', value='2', scr_xsize=40, /editable, /all_events)
   
   label2 = widget_label(func_base1, uname='label2', value='%   ')
   
;   ;图像显示最大值
;   label3 = widget_label(func_base1, uname='label3', value='图像最大值：')
;   
;   text2 = widget_text(func_base1, uname='text2', value='98', scr_xsize=25, /editable,  /all_events)
;   
;   label4 = widget_label(func_base1, uname='label4', value='%').

    ;func_base2 = widget_table(func_base)
    
    kernel_table = widget_table(func_base, uname='kernel_table', /scroll, value=dblarr(3,3),$
                   scr_xsize=1, scr_ysize=1, xoffset=50 , yoffset=35, sensitive=0, ALIGNMENT=1,/all_events )
   
   ;输出文件
   func_base3 = widget_base(func_base, /row, yoffset=140)
   
   label5 = widget_label(func_base3, uname='label5', value=' 输出文件 ')
   
   text3 = widget_text(func_base3, uname='text3', scr_xsize=300, /editable)
   
   button_outfile = widget_button(func_base3, uname='button_outfile', value='选择')
   
   ;确定/取消按钮
   confirm_base = widget_base(base)
   
   confirm_button = widget_button(confirm_base, uname='confirm_button', value='确定', /frame, xoffset=250, yoffset=5, xsize=60, ysize=25)
   
   cancel_button = widget_button(confirm_base, uname='cancel_button', value='取消', /frame, xoffset=350, yoffset=5, xsize=60, ysize=25)
          
   widget_control, base, /realize
  
   
    envi_open_file, infile, r_fid=fid
   
   
   if fid eq -1 then begin
   
   return
   endif

   envi_file_query, fid, dims=dims, nb=nb
   
    dims1 = [-1, 0 , 449, 0, 299]
    
    if nb ge 3 then begin
    
    img = lindgen(3,450,300)
    
    img(0,*,*)= envi_get_data(dims=dims1, fid=fid, pos=0)
    
    img(1,*,*)= envi_get_data(dims=dims1, fid=fid, pos=1)
    
    img(2,*,*)= envi_get_data(dims=dims1, fid=fid, pos=2)
    
    widget_control, drawer, GET_VALUE=win
    
    WSET, win
    
    tvscl, img, true=1
    
    endif else begin
    
    img = lindgen(450,300)
    
    img = envi_get_data(dims=dims1, fid=fid, pos=0)
    
    widget_control, drawer, GET_VALUE=win
    
    WSET, win
    
    tvscl, img
    
    endelse
    
    kernel=[[0,0,0],[0,1,0],[0,0,0]]
    
    add_back=0.2
    
    ksize=3
    
     param_info = {infile:infile,$       ;输入文件
                   method:0,$            ;方法
                   drawer:drawer,$       ;drawer
                   win:win,$             ;drawer的窗口
                   outfile:'c:\out',$    ;输出文件
                   img:img ,$            ;img
                   fid:fid ,$            ;图像的id
                   dims1:dims1, $        ;显示窗口的范围
                   base:base,$           ;顶BASE
                   text:text3,$          ;输出文件文本widget
                   kernel:kernel,$       ;kernel
                   add_back:add_back,$   ;add_back 
                   ksize:ksize,$         ;ksize
                   ktable:kernel_table } ;table_id       
    
    ptr_param = ptr_new(param_info, /no_copy)
    
    widget_control, base, set_uvalue=ptr_param
   
   xmanager, 'convolution', base,/no_block
   
   ;outf=!out

end