 PRO cw_smc_rascc_mask_thinning_EVENT, EVENT
 
   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
   
   widget_control,event.top,get_uvalue=pstate
   
   uname=widget_info(event.id,/uname)
   
   Case uname OF
   
     'ras_in_button': begin
       infile=dialog_pickfile(title='open ras_in',filter='*.ras',/read,/must_exist, path=config.workpath)
       IF NOT FILE_TEST(infile) THEN return
       ; Update definitions
       TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
       workpath=config.workpath
       inputfile=config.inputfile
       
       
       IF FILE_TEST(config.m_rslc) THEN begin
       
         m_rslc=config.m_rslc
         pwr_file=workpath+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
         
         parfile=pwr_file+'.par'
         parlab='Par file:'+parfile
         finfo=TLI_LOAD_SLC_PAR(parfile)
         width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
         nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
       endif
       
       IF FILE_TEST(config.inputfile) THEN begin
         inputfile=config.inputfile
         cc_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
         ras_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.mask.ras'
         ras_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.mask_thinned.ras'
       endif
       
       
       widget_control,(*pstate).ras_in_text,set_value=infile
       widget_control,(*pstate).ras_in_text,set_uvalue=infile
       widget_control,(*pstate).width_text,set_value=width
       widget_control,(*pstate).width_text,set_uvalue=width
       widget_control,(*pstate).nlines_text,set_value=nlines
       widget_control,(*pstate).nlines_text,set_uvalue=nlines
       widget_control,(*pstate).cc_file_text,set_value=cc_file
       widget_control,(*pstate).cc_file_text,set_uvalue=cc_file
       widget_control,(*pstate).ras_out_text,set_value=ras_out
       widget_control,(*pstate).ras_out_text,set_uvalue=ras_out
       widget_control, (*pstate).parlabel, set_value='SLC par:'+parfile, set_uvalue=parfile
     end
     
     'cc_file_button': begin
       infile=dialog_pickfile(title='open coherence file',filter='*.cc',/read,/must_exist, path=config.workpath)
       IF NOT FILE_TEST(infile) THEN return
       widget_control,(*pstate).cc_file_text,set_value=infile
       widget_control,(*pstate).cc_file_text,set_uvalue=infile
     end
     
     'ras_out_button': begin
       widget_control,(*pstate).cc_file_text,get_value=cc_file
       IF NOT FILE_TEST(cc_file) THEN begin
         TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Coherence File ']
         return
       endif
       
       temp=file_basename(cc_file)
       temp=strsplit(temp, '.' ,/extract)
       cc_file=temp(0)
       
       file=cc_file+'.mask_thinned.ras'
       
       infile=dialog_pickfile(title='ras output',filter='*.mask_thinned.ras',file=file,/write,/overwrite_prompt)
       
       IF NOT FILE_TEST(infle) THEN return
       widget_control,(*pstate).ras_out_text,set_value=infile
       widget_control,(*pstate).ras_out_text,set_uvalue=infile
       
     end
     
     'ok':begin
     
     widget_control,(*pstate).cc_file_text,get_uvalue=cc_file
     IF NOT FILE_TEST(cc_file) THEN begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please select The Interferometric Correlation File ']
       return
     endif
     
     widget_control,(*pstate).ras_in_text,get_uvalue=ras_in
     IF NOT FILE_TEST(ras_in) THEN begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please select The Mask File ']
       return
     endif
     
     widget_control,(*pstate).ras_out_text,get_uvalue=ras_out
     IF ras_out EQ '' THEN begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please select The  Output Racc_Mask File ']
       return
     endif
     
     widget_control,(*pstate).width_text,get_value=width
     width=long(width)
     if width le 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Width ']
       return
     endif
     
     widget_control,(*pstate).nmax_text,get_value=nmax
     nmax=long(nmax)
     if nmax le 0 then begin
       TLI_SMC_DUMMY, inputstr=['Error!', 'Please Input The Correct Number Of Samping Reduction Runs ']
       return
     endif
     
     widget_control,(*pstate).thres_text,get_value=thres
     
     nmax=strcompress(nmax,/remove_all)
     width=strcompress(width,/remove_all)
     ; thres=strcompress(thres)
     
     scr="rascc_mask_thinning "+ras_in+" "+cc_file+" "+width+" "+ras_out+" "+nmax+" "+thres
     tli_smc_spawn, scr ,info=' Adaptive Sampling Reduction, Please wait...'
     
   end
   
   'cl':begin
   
   widget_control,event.top,/destroy
   
 end
 
 else: begin
   return
 end
 endcase
 
 END
 
 
 PRO cw_smc_rascc_mask_thinning,EVENT
 
   COMMON TLI_SMC_GUI, types, file, wid, config, finfo
   
   ; --------------------------------------------------------------------
   ; Assignment
   
   device,get_screen_size=screen_size
   xoffset=screen_size(0)/3
   yoffset=screen_size(1)/3
   xsize=560
   ysize=440
   
   ; Get config info
   workpath=config.workpath
   inputfile=''
   parfile=''
   parlab='Par file not found'
   width='0'
   lines='0'
   ras_in=''
   ras_out=''
   
   IF FILE_TEST(config.m_rslc) THEN begin
   
     m_rslc=config.m_rslc
     pwr_file=workpath+'/'+TLI_FNAME(m_rslc, /nosuffix)+'.pwr'
     
     parfile=pwr_file+'.par'
     parlab='Par file:'+parfile
     finfo=TLI_LOAD_SLC_PAR(parfile)
     width=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
     nlines=STRCOMPRESS(finfo.azimuth_lines-1,/REMOVE_ALL)
   endif
   
   IF FILE_TEST(config.inputfile) THEN begin
     inputfile=config.inputfile
     cc_file=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.filt.cc'
     ras_in=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.mask.ras'
     ras_out=workpath+TLI_FNAME(inputfile, /remove_all_suffix)+'.mask_thinned.ras'
   endif
   
   config.workpath=workpath
   ;-------------------------------------------------------------------------
   ; Create widgets
   tlb=widget_base(title='RASSCC_MASK_THINNING',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
   
   
   ras_in_tlb=widget_base(tlb,/row,xsize=xsize,frame=1)
   ras_in_text=widget_text(ras_in_tlb,value=ras_in,uvalue=ras_in,uname='ras_in_TEXT',/editable,xsize=66)
   ras_in_button=widget_button(ras_in_tlb,value='Input ras_in',xsize=130,uname='ras_in_button')
   
   
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
   nlines_label=widget_label(nlines_ID,value='Lines:',xsize=200,/ALIGN_LEFT)
   nlines_text=widget_text(nlines_ID,value=nlines,uvalue=nlines,uname='nlines_text',/editable,xsize=5)
   
   infoID=widget_base(labID,/row, xsize=xsize)
   tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
   nmaxID=widget_base(tempID, /column, xsize=xsize/2-10)
   nmax_lable=widget_label(nmaxID,value='Number Of Samping Reduction Runs:',xsize=200,/align_left)
   nmax_text=widget_text(nmaxID,value='3',uvalue=' ',uname='nmax_text',/editable,xsize=5)
   
   tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
   thresID=widget_base(tempID, /column, xsize=xsize/2-10)
   thres_label=widget_label(thresID,value='Threshold (Scale Samping Reduction):',xsize=260,/align_left)
   thres_text=widget_text(thresID,value='0.3 0.4 0.5',uvalue='0.3 0.4 0.5',uname='thres_text',/editable,xsize=5)
   
   temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
   
   infoID=widget_base(labID,/row, xsize=xsize)
   ras_outID=widget_base(infoID,/row,xsize=xsize, frame=1)
   ras_out_tlb=widget_base(ras_outID, /row, xsize=xsize)
   ras_out_text=widget_text(ras_out_tlb,/editable,xsize=66,value=ras_out,uvalue=ras_out,uname='ras_out_text')
   ras_out_button=widget_button(ras_out_tlb,value='Output rascc_mask',xsize=120,uname='ras_out_button')
   
   
   ;  temp=widget_base(tlb,tab_mode=1,/column,/nonexclusive)
   ;  show=widget_button(temp, value='show', uvalue='show')
   
   funID=widget_base(tlb,row=1,/align_center)
   ok=widget_button(funID,value='OK',xsize=90,uname='ok')
   cl=widget_button(funID,value='Cancle',xsize=90,uname='cl')
   
   state={cc_file_text:cc_file_text,cc_file_button:cc_file_button,ras_in_text:ras_in_text,ras_in_button:ras_in_button,$
     ras_out_text:ras_out_text,ras_out_button:ras_out_button,width_text:width_text,$
     thres_text:thres_text,nmax_text:nmax_text,nlines_text:nlines_text,$
     parlabel:parlabel}
     
     
   pstate=ptr_new(state)
   widget_control,tlb,set_uvalue=pstate
   widget_control,tlb,/realize
   xmanager,'cw_smc_rascc_mask_thinning',tlb,/no_block
 END