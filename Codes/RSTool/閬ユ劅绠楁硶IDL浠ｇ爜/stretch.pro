pro STRETCH
   envi_select, title='Choose MS image band', $
        fid=fid, dims=dims, pos=pos, /band_only
   if (fid eq -1) then return
   img = bytscl(envi_get_data(fid=fid,dims=dims,pos=pos))
   h = histogram(img,min=0,max=255,nbins=256)    
; make a histogram equalization lookup table      
   LUT = byte(255*(total(h, /cumulative)/total(h)))
; call the CUDA DLM once to get it loaded
   imgout = cuda_stretch(LUT, img) 
; now time it   
   start = systime(2)
   imgout = cuda_stretch(LUT, img)   
   print, 'CUDA: ',systime(2)-start   
; return result to ENVI   
   envi_enter_data, imgout
; now time the IDL version   
   start = systime(2)   
   imgout = LUT[img]
   print, 'IDL: ',systime(2)-start  
end

