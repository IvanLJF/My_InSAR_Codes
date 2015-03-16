; docformat = 'rst'
; gpukmaf_run.pro
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.


PRO gpukmaf_run_define_buttons, buttonInfo
   ENVI_DEFINE_MENU_BUTTON, buttonInfo, $
      VALUE = 'Kernel MAF (CUDA)', $
      REF_VALUE = 'Band Ratios', $
      EVENT_PRO = 'gpukmaf_run', $
      UVALUE = 'KMAF',$
      POSITION = 'after'  
END

function eps, X, double=double
    if n_elements(double) eq 0 then double = 0 
    ma = machar(double=double)
    return, X*float((ma.ibeta))^(ma.machep)
end

;+
; :Description:
;       Performs kernel maximum autocorrelation factor
;       analysis using a Gaussian kernel
;       
;       Ref: A. A. Nielsen (2010) Kernel maximum autocorrelation
;       factor and minimum noise fraction transformations
;       (submitted)
;       
; :Params:
;       event:  in, optional 
;          required if called from ENVI             
; :Author:
;       Mort Canty (2009)
;       Juelich Research Center
;       m.canty@fz-juelich.de       
; :Uses:
;       ENVI::
;       CENTER::
;       KERNEL_MATRIX::
;       GPUKERNEL_MATRIX::       
;       COYOTE::
;       GPUKERNELPROJECT
;       GPULIB
;-
pro gpukMAF_run, event 

COMPILE_OPT STRICTARR

seed = 12345L
  
print, '-------------------'
print, 'Kernel MAF'
print, systime(0)
print, '-------------------'

catch, theError
if theError ne 0 then begin
   void = Dialog_Message(!Error_State.Msg, /error)
   return
endif

envi_select, title='Choose multispectral image', $
             fid=fid, dims=dims,pos=pos
if (fid eq -1) then begin
   print, 'cancelled'
   return
endif
envi_file_query, fid, fname=fname,xstart=xstart,ystart=ystart
num_cols = dims[2]-dims[1]+1
num_rows = dims[4]-dims[3]+1
num_bands = n_elements(pos)
num_pixels = num_cols*num_rows
print, 'input file '+fname

; sample size
base = widget_auto_base(title='Sample size')
wg = widget_sslider(base, title='Samples', min=500, max=2000, $
  value=1000, dt=1, uvalue='slide', /auto)
result = auto_wid_mng(base)
if (result.accept eq 0) then begin
   print, 'cancelled'
   return
endif 
m = long(result.slide)

; nscale parameter for Gaussian kernel
base = widget_auto_base(title='NSCALE')  
we = widget_param(base, dt=4, field=3, floor=0.,xsize= 50,$  
  default=1.0, uvalue='param', /auto)  
result = auto_wid_mng(base)  
if (result.accept ne 0) then nscale = float(result.param) $
   else nscale = 1.0

; number of MAFs
base = widget_auto_base(title='Numer of MAFs')
wg = widget_sslider(base, title='MAFs', min=5, max=50, $
  value=10, dt=1, uvalue='slide', /auto)
result = auto_wid_mng(base)
if (result.accept eq 0) then begin
   print, 'cancelled'
   return
endif 
num_mafs = long(result.slide)
   
query=dialog_message('Center on training means',/question,/default_no)
if query eq 'Yes' then ct=1 else ct=0   

cula = 0
;query=dialog_message('Use CUDA_SVD',/question,/default_no)
;if query eq 'Yes' then cula=1 else cula=0   

; output destination
base = widget_auto_base(title='KMAF Output')
sb = widget_base(base, /row, /frame)
wp = widget_outfm(sb, uvalue='outf', /auto)
result1 = auto_wid_mng(base)
if (result1.accept eq 0) then begin
  print, 'Output cancelled'
  return
end

progressbar = Obj_New('progressbar', Color='blue', Text='Initializing...',$
              title='Kernel MAF ',xsize=300,ysize=20)
progressbar->start

start_time=systime(2)

; image data matrix
GG = fltarr(num_bands,num_pixels)
; difference matrix
GGup=fltarr(num_bands,num_pixels)
GGright=fltarr(num_bands,num_pixels)
for i=0,num_bands-1 do begin
  temp =  envi_get_data(fid=fid,dims=dims,pos=pos[i])
  GG[i,*] = temp
  GGup[i,*] = shift(temp,0,-1)
  GGright[i,*] = shift(temp,-1,0)
end

; training data matrices
indices = randomu(seed,m,/long) mod num_pixels
G = GG[*,indices]
Gup = GGup[*,indices]
Gright = GGright[*,indices]
; save to disk
;openw, unit, result1.outf.name+'_G', /get_lun
;writeu, unit, G
;free_lun, unit
;openw, unit, result1.outf.name+'_Gup', /get_lun
;writeu, unit, Gup
;free_lun, unit
;openw, unit, result1.outf.name+'_Gright', /get_lun
;writeu, unit, Gright
;free_lun, unit

progressbar->Update,0,text='Training on '+strtrim(m,2)+' observations ...'

if gpu_detect() then begin
   print,'running CUDA ...'
   G_gpu = gpuputarr(G)
   Gup_gpu = gpuputarr(Gup) 
   Gright_gpu = gpuputarr(Gright) 
   K_gpu = gpukernel_matrix(G_gpu,gma=gma,nscale=nscale)
; gma is output and saved for generalization and used to get KD
   K = gpuGetArr(K_gpu)
   Kup_gpu = gpukernel_matrix(G_gpu,Gup_gpu,gma=gma) 
   Kup = gpuGetArr(Kup_gpu)
   Kright_gpu = gpukernel_matrix(G_gpu,Gright_gpu,gma=gma)
   Kright = gpuGetArr(Kright_gpu)
   gpufree,[Gup_gpu,Gright_gpu,K_gpu,Kup_gpu,Kright_gpu]
end else begin
   print, 'CUDA not available ...'
   K = kernel_matrix(G,gma=gma,nscale=nscale)
; gma is output and saved for generalization and used to get KD  
   Kup = kernel_matrix(G,Gup,gma=gma)
   Kright = kernel_matrix(G,Gright,gma=gma)
endelse  
print,'GMA = '+strtrim(gma,2) 
K = center(K)
KD = K - (Kup + Kright)/2    
;KD = center(KD)

print, 'Training on '+strtrim(m,2)+' observations ...'
A = K##K
B = KD##transpose(KD)

start = systime(2)
if cula then begin
; experimental (single precision CUDA routine, should be double precision)
   cuda_svd, float(B), lambda, P, _
   tol = max((size(B))[1:2])*eps(max(lambda)) 
   _ = where(lambda gt tol, r)
end else begin   
   lambda = la_eigenql(B,/double,eigenvectors=P) ; P are row vectors
   P = transpose(P)
   idx = reverse(sort(lambda))
   lambda = lambda[idx]
   P = P[idx,*]
   tol = max((size(B))[1:2])*eps(max(lambda),/double) 
   _ = where(lambda gt tol, r) 
endelse   
print,'rank = ',strtrim(r,2)
print, 'diagonalize time: ',systime(2)-start

Bsi = P[0:r-1,*]##diag_matrix(1.0/(sqrt(lambda[0:r-1])))##transpose(P[0:r-1,*])
C = Bsi##A##Bsi

lambda = la_eigenql(C,/double,eigenvectors=U,range=[m-num_mafs,m-1])
idx = reverse(sort(lambda))
lambda = lambda[idx]
U = U[*,idx]

; eigenvectors of C are rows of U
B = U##Bsi  
; MAF projection directions are now rows of B

D = 1./sqrt(diag_matrix(B##A##transpose(B)))
B = B*(transpose(D)##(fltarr(m)+1))
; B is now renormalized such that B##A##transpose(B)=I

print,'Elapsed time for training: ',systime(2)-start_time
progressbar->Destroy

print,'First '+strtrim(num_mafs,2)+' eigenvalues'
print, lambda

; plot the eigenvalues
envi_plot_data,findgen(num_mafs)+1,lambda[0:num_mafs-1],$
   plot_title='Kernel MAF File: '+file_basename(fname),$
   title='Kernel MAF',$
   ytitle='Eigenvalue',$
   xoff=100, yoff=100
   
; dual variables (normalized eigenvectors)
alpha = float(B) 

start_time=systime(2)     
if not gpuKernelProject(alpha,  gma, G, GG, num_cols, num_rows, image, center_train=ct) then $
       message, 'projection aborted'
print,'Elapsed time for image projection: ',systime(2)-start_time
         
; map tie point
map_info = envi_get_map_info(fid=fid)
envi_convert_file_coordinates,fid,dims[1],dims[3],e,n,/to_map
map_info.mc[2:3]= [e,n]

; write to memory or file
bnames='kernel MAF '+strtrim(lindgen(num_mafs)+1,2)
if (result1.outf.in_memory eq 1) then begin
   envi_enter_data, image, $
      map_info=map_info, $
      bnames=bnames, $
      xstart=xstart+dims[1], ystart=ystart+dims[3], $
      descrip='kernel MAF: '+file_basename(fname)
   print, 'MAFs written to memory'
end else begin
   openw, unit, result1.outf.name, /get_lun
   writeu, unit, image
   envi_setup_head,fname=result1.outf.name, ns=num_cols, nl=num_rows, nb=num_mafs, $
                    data_type=4, $
                    interleave=0, $
                    file_type=0, $
                    map_info=map_info, $
                    xstart=xstart+dims[1], $
                    ystart=ystart+dims[3], $
                    bnames=bnames,$            
                    descrip='kernel MAF: '+file_basename(fname), $
                    /write,/open
   print, 'File created ', result1.outf.name
   free_lun, unit
endelse

end
