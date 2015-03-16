pro NDVI

; initialize GPULib
gpuinit

envi_select, title='Choose MS image', $
             fid=fid, dims=dims,pos=pos, /no_spec
if (fid eq -1) then begin
   print, 'cancelled'
   return
endif

num_cols = dims[2]-dims[1]+1
num_rows = dims[4]-dims[3]+1
num_bands = n_elements(pos)
num_pixels = num_cols*num_rows

; data matrix
D = fltarr(num_bands,num_pixels)

; read in the image 
for i=0,num_bands-1 do $
   D[i,*] = envi_get_data(fid=fid,dims=dims,pos=pos[i])

; put it onto the GPU device
gpuPutArr, transpose(D), D_gpu 

; views onto the red and nir bands (assumed to be 3 and 4)
gpuView, D_gpu, 2*num_pixels, num_pixels, gpu_RED
gpuView, D_gpu, 3*num_pixels, num_pixels, gpu_NIR

; calculate NDVI on the device
num_gpu = gpuSub(gpu_NIR,gpu_RED)
den_gpu = gpuAdd(gpu_NIR,gpu_RED)
NDVI_gpu = gpuDiv(num_gpu,den_gpu)

; get it back to the host
gpuGetArr, NDVI_gpu, NDVI

; clean up (note: NOT the views!!!)
gpuFree, [D_gpu,num_gpu,den_gpu,NDVI_gpu]

; map tie point
map_info = envi_get_map_info(fid=fid)
envi_convert_file_coordinates, fid, $
   dims[1], dims[3], e, n, /to_map
map_info.mc = [0D,0D,e,n]

; return result to ENVI
envi_enter_data, reform(NDVI,num_cols,num_rows),$
    map_info = map_info
   
; now do it with the external CUDA dll  
img3 = byte(reform(D[2,*],num_cols,num_rows))
img4 = byte(reform(D[3,*],num_cols,num_rows)) 
imgOut = fltarr(num_cols, num_rows)        
_ = call_external('NDVI.dll', 'GetNdvi', $
      img4, img3, imgout, num_cols, num_rows, value=[0,0,0,1,1], /CDECL, /B_VALUE)
      
; return result to ENVI      
envi_enter_data, imgout, map_info=map_info 

; now do it with the DLM
cuda_ndvi, img4, img3, ndvi   

; return result to ENVI      
envi_enter_data, ndvi, map_info=map_info  

end

