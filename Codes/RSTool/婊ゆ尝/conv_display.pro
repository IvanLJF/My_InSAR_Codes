pro conv_display, ptr_param

;COMMON SHARE1,out

   fid=(*ptr_param).fid

   envi_file_query, fid, dims=dims, nb=nb, ns=ns, nl=nl, bname=bname
   
;   print,method

   ksize=(*ptr_param).ksize
   
   add_back=(*ptr_param).add_back
   
   kernel=(*ptr_param).kernel
   
   dims1=(*ptr_param).dims1
   
   method=(*ptr_param).method
   
   ktable=(*ptr_param).ktable
   
   pos=lindgen(nb)
   
     if method le 8 then begin

       if method le 3 then begin
       
       widget_control,ktable,scr_xsize=1
          
       widget_control,ktable,scr_ysize=1
       
       envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims1,$  
                 out_bname=bname(pos), method=method, kx=ksize, ky=ksize,$
                  add_back=add_back, in_memory=1, r_fid=r_fid  
        
       endif else begin
       
          widget_control,ktable,scr_xsize=300
          
          widget_control,ktable,scr_ysize=100
       
       case method of
       
          '4' : begin
          
          kernel=[[-1,-1,-1],[-1,8,-1],[-1,-1,-1]]
          
          (*ptr_param).kernel=kernel
          
          widget_control,ktable,set_value=kernel
          
                 envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims1, KERNEL=kernel,$  
                 out_bname=bname(pos), method=4, kx=ksize, ky=ksize,$
                  add_back=add_back, in_memory=1, r_fid=r_fid  
          
          end
          
          '5' : begin
          
          kernel=[[0,-1,0],[-1,4,-1],[0,-1,0]]
          
          (*ptr_param).kernel=kernel
          
          widget_control,ktable,set_value=kernel
          
          envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims1, KERNEL=kernel,$  
                 out_bname=bname(pos), method=5, kx=ksize, ky=ksize,$
                  add_back=add_back, in_memory=1, r_fid=r_fid 
          
          end
          
          '6' : begin
          
          direction,out=angle
          
          radians=(angle/180.)*!PI
          
          s=sin(radians) & c=cos(radians) & he=s+c & cha=c-s
          
          kernel=[[0-he,0-s,cha],[0-c,0,c],[0-cha,s,he]]
         
          (*ptr_param).kernel=kernel
          
          widget_control,ktable,set_value=kernel
          
          envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims1, KERNEL=kernel,$  
                 out_bname=bname(pos), method=6, kx=ksize, ky=ksize,$
                  add_back=add_back, in_memory=1, r_fid=r_fid 
          
          end
          
          '7' : begin
          
          kernel=[[0.0007,0.0256,0.0007],[0.0256,0.8948,0.0256],[0.0007,0.0256,0.0007]]
          
          (*ptr_param).kernel=kernel
          
          widget_control,ktable,set_value=kernel
          
          envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims1, KERNEL=kernel,$  
                 out_bname=bname(pos), method=7, kx=ksize, ky=ksize,$
                  add_back=add_back, in_memory=1, r_fid=r_fid 
          
          end
          
          '8' : begin
          
          kernel=[[-0.0007,-0.0256,-0.0007],[-0.0256,0.1052,-0.0256],[-0.0007,-0.0256,-0.0007]]
          
          (*ptr_param).kernel=kernel
          
          widget_control,ktable,set_value=kernel
          
          envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims1, KERNEL=kernel,$  
                 out_bname=bname(pos), method=7, kx=ksize, ky=ksize,$
                  add_back=add_back, in_memory=1, r_fid=r_fid 
          
          end
        endcase
      endelse
      
       if nb ge 3 then begin
    
       img = lindgen(3,450,300)
    
       img(0,*,*)= envi_get_data(dims=dims1, fid=r_fid, pos=0)
    
       img(1,*,*)= envi_get_data(dims=dims1, fid=r_fid, pos=1)
    
       img(2,*,*)= envi_get_data(dims=dims1, fid=r_fid, pos=2)
    
       WSET, (*ptr_param).win
    
       tvscl, img, true=1
    
       endif else begin
    
       img = lindgen(450,300)
    
       img = envi_get_data(dims=dims1, fid=r_fid, pos=0)
    
       WSET, (*ptr_param).win
    
       tvscl, img
    
       endelse
    endif    
          
          if method eq 9 then begin
          
          widget_control,ktable,scr_xsize=300
          
          widget_control,ktable,scr_ysize=100

          kernel=[[1,1,1],[1,1,1],[1,1,1]]
          
          widget_control,ktable,set_value=kernel
          
          widget_control,ktable,sensitive=1
          
          widget_control,ktable,editable=1
          
          endif
       
;       envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims1, KERNEL=kernel,$  
;                 out_bname=bname(pos), method=method, kx=ksize, ky=ksize,$
;                  add_back=add_back, in_memory=1, r_fid=r_fid  
          
;       endcase
;       
;    endelse   
;                        
;       if nb ge 3 then begin
;    
;       img = lindgen(3,450,300)
;    
;       img(0,*,*)= envi_get_data(dims=dims1, fid=r_fid, pos=0)
;    
;       img(1,*,*)= envi_get_data(dims=dims1, fid=r_fid, pos=1)
;    
;       img(2,*,*)= envi_get_data(dims=dims1, fid=r_fid, pos=2)
;    
;       WSET, (*ptr_param).win
;    
;       tvscl, img, true=1
;    
;       endif else begin
;    
;       img = lindgen(450,300)
;    
;       img = envi_get_data(dims=dims1, fid=r_fid, pos=0)
;    
;       WSET, (*ptr_param).win
;    
;       tvscl, img
;    
;       endelse
    return

end


function conv_ok, event

COMMON SHARE1,out

    widget_control, event.top, get_uvalue=ptr_param

    widget_control, (*ptr_param).text, get_value=outfile
    
 ;   print,outfile
    
    (*ptr_param).outfile=outfile
    
    !out=outfile
    
   ksize=(*ptr_param).ksize
   
   add_back=(*ptr_param).add_back
   
   kernel=(*ptr_param).kernel
   
   dims1=(*ptr_param).dims1
   
   method=(*ptr_param).method
   
   ktable=(*ptr_param).ktable
   
   fid=(*ptr_param).fid
    
    envi_file_query, fid, dims=dims, nb=nb, ns=ns, nl=nl, bname=bname
   
    pos=lindgen(nb)

       if method le 3 then begin
       
       envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims,$  
                 out_bname=bname(pos), method=method, kx=ksize, ky=ksize,$
                  add_back=add_back, r_fid=r_fid, out_name=outfile
                  
       print,r_fid
        
       endif else begin

       case method of
       
          '4' : begin
          
          ;kernel=[[-1,-1,-1],[-1,8,-1],[-1,-1,-1]]
          
                 envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims, KERNEL=(*ptr_param).kernel,$  
                 out_bname=bname(pos), method=method, kx=ksize, ky=ksize,$
                  add_back=add_back, r_fid=r_fid, out_name=outfile
          
          end
          
          '5' : begin
          
          ;kernel=[[0,-1,0],[-1,4,-1],[0,-1,0]]
          
          ;widget_control,ktable,set_value=kernel
          
                 envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims, KERNEL=(*ptr_param).kernel,$  
                 out_bname=bname(pos), method=method, kx=ksize, ky=ksize,$
                  add_back=add_back, r_fid=r_fid, out_name=outfile
          
          end
          
          '6' : begin
          
          ;direction=direction()
          ;这里有问题需要解决，哈哈~~~
          
                 envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims, KERNEL=(*ptr_param).kernel,$  
                 out_bname=bname(pos), method=method, kx=ksize, ky=ksize,$
                  add_back=add_back, r_fid=r_fid, out_name=outfile
          
          end
          
          '7' : begin
          
                 envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims, KERNEL=(*ptr_param).kernel,$  
                 out_bname=bname(pos), method=method, kx=ksize, ky=ksize,$
                  add_back=add_back, r_fid=r_fid, out_name=outfile
          
          end
          
          '8' : begin
          
                 envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims, KERNEL=(*ptr_param).kernel,$  
                 out_bname=bname(pos), method=7, kx=ksize, ky=ksize,$
                  add_back=add_back, r_fid=r_fid, out_name=outfile
          
          end
          
          '9' : begin

          widget_control,ktable,get_value=kernel
          
          (*ptr_param).kernel=kernel
          
                 envi_doit,'conv_doit', fid=fid, pos=pos, dims=dims, KERNEL=(*ptr_param).kernel,$  
                 out_bname=bname(pos), method=8, kx=ksize, ky=ksize,$
                  add_back=add_back, r_fid=r_fid, out_name=outfile         
          
          end
          
      endcase
      
    endelse
    
print,'done'
  widget_control,event.top, get_uvalue=ptr_param
  
    ptr_free, ptr_param

  widget_control,event.top,/destroy

return,out


end


function conv_cancel,event

COMMON SHARE1,out

  widget_control,event.top, get_uvalue=ptr_param
  
    ptr_free, ptr_param

  widget_control,event.top,/destroy
     return, out ; by default, return the event.

end


pro text1_ch,event

;COMMON SHARE1,out

   widget_control, event.top, get_uvalue=ptr_param
   
   widget_control, event.id, get_value=val
   
   if val lt 0 then begin
   
      res=dialog_message('输入最小值不能小于0！',/info,title='卷积滤波')
      
    return
    
   endif
   
   if val gt 100 then begin
   
      res=dialog_message('输入最大值不能大于100！',/info,title='卷积滤波')
      
      return
      
   endif
   
   (*ptr_param).add_back=val/100

end


pro table_ch,event

  widget_control, event.top, get_uvalue=ptr_param
  
  widget_control, event.id, get_value=kernel
  
  (*ptr_param).kernel=kernel

end


