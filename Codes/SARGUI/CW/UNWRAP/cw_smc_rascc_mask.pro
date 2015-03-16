 PRO CW_SMC_RASCC_MASK_EVENT, EVENT
 
   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
   
   widget_control,event.top,get_uvalue=pstate
   
   workpath=config.workpath
   
   uname=widget_info(event.id,/uname)
   
   Case uname OF
   
     'pwr_file_button': begin
     
       infile=dialog_pickfile(title='Open Intensity File',/read,/must_exist,filter='*.pwr', path=config.workpath)
       
       IF NOT FILE_TEST(infile) THEN return
       
       widget_control,(*pstate).pwr_file_text,set_value=infile
       widget_control,(*pstate).pwr_file_text,set_uvalue=infile
       
       
     END
     
     'cc_file_button': begin
       infile=dialog_pickfile(title='open coherence file',filter='*.cc',/read,/must_exist, path=config.workpath)
       
       IF NOT FILE_TEST(infile) THEN return
       
       ; Update definitions
       TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
       
       IF FILE_TEST(config.m_rslc) THEN begin
       
         m_rslc=config.m_rslc
         pwr_file=config.workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
         
         parfile=pwr_file+'.par'
         parlab='Par file:'+parfile
         finfo=TLI_LOAD_SLC_PAR(parfile)
         width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
         nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
       endif
       
       outputfile=workpath+TLI_FNAME(infile, /remove_all_suffix)+'.mask.ras'
       
       config.workpath=workpath
       widget_control,(*pstate).cc_file_text,set_value=infile
       widget_control,(*pstate).cc_file_text,set_uvalue=infile
       widget_control, (*pstate).parlabel, set_value='SLC par:'+parfile, set_uvalue=parfile
       widget_control, (*pstate).width_text, set_value=width, set_uvalue=width
       widget_control, (*pstate).nlines_text, set_value=nlines, set_uvalue=nlines
       widget_control, (*pstate).rasf_out_text, set_value=outputfile, set_uvalue=outputfile
     end
     
     
     'rasf_out_button': begin
     
       infile=dialog_pickfile(title='output mask image',filter='*.mask.ras',file=file,/write,/overwrite_prompt, path=config.workpath)
       IF NOT FILE_TEST(infile) THEN return
       
       widget_control,(*pstate).pwr_file_text,get_value=pwr_file
       IF NOT FILE_TEST(pwr_file) THEN begin
         TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the  Intensity Image ']
         return
       endif
       
       widget_control,(*pstate).cc_file_text,get_value=cc_file
       IF NOT FILE_TEST(cc_file) THEN begin
         TLI_SMC_DUMMY, inputstr=['Error!', 'please Input the  Coherence Image ']
         return
       endif
       
       
       temp=file_basename(cc_file)
       temp=strsplit(temp, '.' ,/extract)
       rasf_out=temp(0)
       
       file=rasf_out+'.mask.ras'
       
       widget_control,(*pstate).rasf_out_text,set_value=infile
       widget_control,(*pstate).rasf_out_text,set_uvalue=infile
       
     end
     
     'ok':begin
     
     widget_control,(*pstate).cc_file_text,get_uvalue=cc_file
     IF NOT FILE_TEST(cc_file) THEN begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please select the coherence file ']
       return
     endif
     
     widget_control,(*pstate).pwr_file_text,get_uvalue=pwr_file
     IF NOT FILE_TEST(pwr_file) THEN begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please select the .pwr file ']
       return
     endif
     
     widget_control, (*pstate).rasf_out_text,  get_value=outputfile
     IF outputfile EQ '' THEN begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please select the output image']
       return
     endif
     
     widget_control,(*pstate).width_text,get_value=width
     width=long(width)
     if width le 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please assign image width']
       return
     endif
     
     widget_control,(*pstate).start_cc_text,get_value=start_cc
     start_cc=long(start_cc)
     if start_cc lt 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please assign the starting line of coherence image']
       return
     endif
     
     widget_control,(*pstate).start_pwr_text,get_value=start_pwr
     start_pwr=long(start_pwr)
     if start_pwr lt 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input the  Correct Starting Line Of Intensity Image']
       return
     endif
     
     widget_control,(*pstate).nlines_text,get_value=nlines
     nlines=long(nlines)
     if nlines lt 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input the  Correct Number Of Lines To Display']
       return
     endif
     
     widget_control,(*pstate).pixavr_text,get_value=pixavr
     pixavr=long(pixavr)
     if pixavr le 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input the  Correct Number Of Pixel To Average In Range']
       return
     endif
     
     widget_control,(*pstate).pixavaz_text,get_value=pixavaz
     pixavaz=long(pixavaz)
     if pixavaz lt 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input the  Correct Number Of Pixel To Average In Azimuth']
       return
     endif
     
     widget_control,(*pstate).cc_thres_text,get_value=cc_thres
     cc_thres=float(cc_thres)
     if cc_thres lt 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Cohrence Threshold For Masking ']
       return
     endif
     
     widget_control,(*pstate).pwr_thres_text,get_value=pwr_thres
     pwr_thres=float(pwr_thres)
     if pwr_thres lt 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Cohrence Intensity Threshold ']
       return
     endif
     
     widget_control,(*pstate).cc_min_text,get_value=cc_min
     cc_min=float(cc_min)
     if cc_min lt 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Minimum Coherence Value Used For Color Display Error ']
       return
     endif
     
     widget_control,(*pstate).cc_max_text,get_value=cc_max
     cc_max=float(cc_max)
     if cc_max lt 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Maximum Coherence Value Used For Color Display Error ']
       return
     endif
     
     widget_control,(*pstate).scale_text,get_value=scale
     scale=float(scale)
     if scale le 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please select The Correct Intensity Display Scale Factor']
       return
     endif
     
     widget_control,(*pstate).pwr_exp_text,get_value=pwr_exp
     pwr_exp=float(pwr_exp)
     if pwr_exp le 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please select The Correct Intensity Display Exponent']
       return
     endif
     
     mirror_text=WIDGET_INFO((*pstate).mirror_text,/droplist_select)
     if mirror_text eq 0 then begin
       mirror='1'
     endif else begin
       mirror='-1'
     endelse
     
     width=strcompress(width,/remove_all)
     start_cc=strcompress(start_cc,/remove_all)
     start_pwr=strcompress(start_pwr,/remove_all)
     nlines=strcompress(nlines,/remove_all)
     pixavr=strcompress(pixavr,/remove_all)
     pixavaz=strcompress(pixavaz,/remove_all)
     cc_thres=strcompress(cc_thres,/remove_all)
     pwr_thres=strcompress(pwr_thres,/remove_all)
     cc_min=strcompress(cc_min,/remove_all)
     cc_max=strcompress(cc_max,/remove_all)
     scale=strcompress(scale,/remove_all)
     pwr_exp=strcompress(pwr_exp,/remove_all)
     mirror=strcompress(mirror,/remove_all)
     
     scr="rascc_mask "+cc_file+" "+pwr_file+" "+width+" "+start_cc+" "+start_pwr+" "+nlines+" "+pixavr+" "+pixavaz+" "+cc_thres+" "+$
       pwr_thres+" "+cc_min+" "+cc_max+" "+scale+" "+pwr_exp+" "+mirror+" "+outputfile
     tli_smc_spawn, scr ,info='  Generate Phase Unwrapping Validity Mask, Please wait...'
     
   end
   
   
   'cl':begin
   
   widget_control,event.top,/destroy
   
 end
 
 else:return
 ENDCASE
 
 END
 
 PRO CW_SMC_RASCC_MASK,EVENT
 
   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
   
   ; --------------------------------------------------------------------
   ; Assignment
   
   device,get_screen_size=screen_size
   xoffset=screen_size(0)/3
   yoffset=screen_size(1)/3
   xsize=560
   ysize=640
   
   ; Get config info
   workpath=config.workpath
   inputfile=''
   parfile=''
   parlab='Par file not found'
   width='0'
   nlines='0'
   pwr_file=''
   cc_file=''
   flag_file=''
   outputfile=''
   
   IF FILE_TEST(config.m_rslc) THEN begin
     m_rslc=config.m_rslc
     pwr_file=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
     parfile=pwr_file+'.par'
     parlab='Par file:'+STRING(10b)+parfile
     info=TLI_LOAD_SLC_PAR(parfile)
     width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
     nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
   endif
   
   IF FILE_TEST(config.inputfile) THEN begin
     inputfile=config.inputfile
     cc_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
     outputfile=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.mask.ras'
   endif
   
   config.workpath=workpath
   ;-------------------------------------------------------------------------
   ; Create widgets
   tlb=widget_base(title='RASSCC_MASK',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
   
   pwr_file_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
   pwr_file_text=widget_text(pwr_file_tlb,value=pwr_file,uvalue=pwr_file,uname='pwr_file_text',/editable,xsize=66)
   pwr_file_button=widget_button(pwr_file_tlb,value='Input pwr_file',xsize=130,uname='pwr_file_button')
   
   cc_file_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
   cc_file_text=widget_text(cc_file_tlb,/editable,xsize=66,value=cc_file,uvalue=cc_file,uname='cc_file_text')
   cc_file_button=widget_button(cc_file_tlb,value='Input cc_file',xsize=130,uname='cc_file_button')
   
   temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
   
   labID=widget_base(tlb,/column,xsize=xsize)
   
   parID=widget_base(labID,/row, xsize=xsize)
   parlabel=widget_label(parID, xsize=xsize-10, value=parlab,/align_left,/dynamic_resize)
   
   infoID=widget_base(labID,/row, xsize=xsize)
   tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
   widthID=widget_base(tempID, /column, xsize=xsize/2-10)
   width_label=widget_label(widthID, value='Width:',/ALIGN_LEFT)
   width_text=widget_text(widthID,value=width, uvalue=width, uname='width',/editable,xsize=10)
   
   tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
   nlines_ID=widget_base(tempID, /column, xsize=xsize/2-10)
   nlines_label=widget_label(nlines_ID,value='Lines:',xsize=60,/ALIGN_LEFT)
   nlines_text=widget_text(nlines_ID,value=nlines,uvalue=nlines,uname='nlines_text',/editable,xsize=5)
   
   infoID=widget_base(labID,/row, xsize=xsize)
   tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
   star_pwrID=widget_base(tempID, /column, xsize=xsize/4-10)
   start_pwr_lable=widget_label(star_pwrID,value='Start_pwr:',xsize=60,/align_left)
   start_pwr_text=widget_text(star_pwrID,value='1',uvalue=' ',uname='start_pwr_text',/editable,xsize=5)
   
   tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
   star_ccID=widget_base(tempID, /column, xsize=xsize/4-10)
   start_label=widget_label(star_ccID,value='Start_cc:',xsize=60,/align_left)
   start_cc_text=widget_text(star_ccID,value='1',uvalue='1',uname='xtart_text',/editable,xsize=5)
   
   tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
   pixavrID=widget_base(tempID, /column, xsize=xsize/4)
   pixavr_label=widget_label(pixavrID,value='Pixavr:',xsize=60,/align_left)
   pixavr_text=widget_text(pixavrID,value='1',uvalue='1 ',uname='pixavr_text',/editable,xsize=5)
   
   
   tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
   pixavazID=widget_base(tempID, /column, xsize=xsize/4)
   pixavaz_label=widget_label(pixavazID,value='Pixavaz:',xsize=60,/align_left)
   pixavaz_text=widget_text(pixavazID,value='1',uvalue='1 ',uname='pixavaz_text',/editable,xsize=5)
   
   infoID=widget_base(labID,/row, xsize=xsize)
   tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
   cc_thresID=widget_base(tempID, /column, xsize=xsize/4)
   cc_thres_label=widget_label(cc_thresID,value='CC_Threshold:',xsize=120,/align_left)
   cc_thres_text=widget_text(cc_thresID,value='0',uvalue='0 ',uname='cc_thres_text',/editable,xsize=5)
   
   tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
   pwr_thresID=widget_base(tempID, /column, xsize=xsize/4)
   pwr_thres_label=widget_label(pwr_thresID,value='Pwr_Thresold:',xsize=60,/align_left)
   pwr_thres_text=widget_text(pwr_thresID,value='0',uvalue='0 ',uname='pwr_thres_text',/editable,xsize=5)
   
   tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
   cc_minID=widget_base(tempID, /column, xsize=xsize/4)
   cc_min_label=widget_label(cc_minID,value='CC_Min:',xsize=60,/align_left)
   cc_min_text=widget_text(cc_minID,value='0.1',uvalue='0.1',uname='cc_min_text',/editable,xsize=5)
   
   
   tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
   cc_maxID=widget_base(tempID,/column, xsize=xsize/4)
   cc_max_label=widget_label(cc_maxID,value='CC_Max:',xsize=60,/align_left)
   cc_max_text=widget_text(cc_maxID,value='0.9',uvalue='0.9',uname='cc_max_text',/editable,xsize=5)
   
   infoID=widget_base(labID,/row, xsize=xsize)
   tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
   scale_ID=widget_base(tempID, /column, xsize=xsize/2-10)
   scale_label=widget_label(scale_ID,value='Intensity Dispaly Scale:',xsize=200,/align_left)
   scale_text=widget_text(scale_ID,value='1',uvalue='1',uname='scale_text',/editable,xsize=5)
   
   
   tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
   pwr_exp_ID=widget_base(tempID, /column, xsize=xsize/2-10)
   pwr_exp_label=widget_label(pwr_exp_ID,value='Intensity Display Exponent:',xsize=200,/align_left)
   pwr_exp_text=widget_text(pwr_exp_ID,value='1',uvalue='1',uname='pwr_exp_text',/editable,xsize=5)
   
   temp=widget_base(tlb,/row,xsize=xsize,/frame)
   mirror_label=widget_label(temp,value='Left/Right Mirror Image Flag:',xsize=200,/align_center)
   mirror_text=widget_droplist(temp, value=['0: Normal Image',$
     '1: Mirror Image'])
     
     
   temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
   
   
   rasf_out_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
   rasf_out_text=widget_text(rasf_out_tlb,/editable,xsize=66,value=outputfile,uvalue=outputfile,uname='rasf_out_text')
   rasf_out_button=widget_button(rasf_out_tlb,value='Output rascc_mask',xsize=120,uname='rasf_out_button')
   
   
;   temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
;   show=widget_button(temp, value='show', uvalue='show')
   
   funID=widget_base(tlb,row=1,/align_center)
   ok=widget_button(funID,value='OK',xsize=90,uname='ok')
   cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
   
   state={cc_file_text:cc_file_text,cc_file_button:cc_file_button,pwr_file_text:pwr_file_text,pwr_file_button:pwr_file_button,$
     rasf_out_text:rasf_out_text,rasf_out_button:rasf_out_button,$
     width_text:width_text,$
     start_cc_text:start_cc_text,start_pwr_text:start_pwr_text,$
     nlines_text:nlines_text,$
     pixavr_text:pixavr_text,$
     pixavaz_text:pixavaz_text,$
     cc_thres_text:cc_thres_text,$
     pwr_thres_text:pwr_thres_text,$
     cc_min_text:cc_min_text,$
     parlabel:parlabel,$
     cc_max_text:cc_max_text,$
     scale_text:scale_text,$
     pwr_exp_text:pwr_exp_text,$
     mirror_text:mirror_text}
     
     
   pstate=ptr_new(state)
   widget_control,tlb,set_uvalue=pstate
   widget_control,tlb,/realize
   xmanager,'cw_smc_rascc_mask',tlb,/no_block
 END