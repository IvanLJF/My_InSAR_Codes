; docformat = 'rst'
; gpukernel_matrix.pro
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details. 
;+
; :Description:
;       Returns array of kernel functions 
;       for data matrices G1 and G2. 
;       G1 is an N x m array,
;       G2 is an N x n array.
;       Returned array is n x m. 
;       If G2 not present then returns a symmetric, 
;       positive definite kernel matrix       
; :Params:
;       G1_gpu:  in, required, type={GPUHANDLE} 
;          data matrix
;       G2_gpu:  in, optional, type={GPUHANDLE}
;          data matrix     
; :Keywords:
;       gma: in,out,optional,type=float            
;            if not given and KERNEL=1, calculated from the data:
;            GMA=1/(2*(nscale*scale)^2) where scale = average 
;            distance between observations in the input space,
;            otherwise defaults to 1/N 
;       nscale: in, optional,type=float
;            multiple of scale for GMA when KERNEL=1 (default 1.0)    
;       kernel: in, optional, type=integer
;            the kernel used
;            0: linear
;            1: Gaussian (default)
;            2: polynomial
;            3: sigmoid
;       degree: in, optional, type=integer
;            degree of pylynomial kernel (default 2)
;       bias: in, optional, type=float 
;            bias of polynomial or sigmoid kernel (default 1.0)      
; :Requires: 
;       GPULIB                                                      
; :Author:
;       Mort Canty (2009)      
;-
function gpukernel_matrix,G1_gpu,G2_gpu,K_gpu,KERNEL=kernel,GMA=gma,NSCALE=nscale,DEGREE=degree,BIAS=bias
COMPILE_OPT STRICTARR
   if n_params() eq 1 then G2_gpu = G1_gpu
   if n_elements(nscale) eq 0 then nscale = 1.0
   if n_elements(kernel) eq 0 then kernel = 1
   if n_elements(degree) eq 0 then degree = 2
   if n_elements(bias) eq 0 then bias = 1.0
   case kernel of
      0: K_gpu = gpumatrix_multiply(G2_gpu,G1_gpu,/atranspose)
      1: begin   
            m = G1_gpu.dimension[0]
            n = G2_gpu.dimension[1]             
            n1_gpu = gpumake_array(n,value=1.0)                     
            G12_gpu = gpumult(G1_gpu,G1_gpu)
            t1_gpu = gputotal(G12_gpu,1)
            gpuFree, G12_gpu
            K_gpu = gpumatrix_multiply(n1_gpu,t1_gpu,/btranspose)
            gpuFree, [t1_gpu,n1_gpu]
            G22_gpu = gpumult(G2_gpu,G2_gpu)
            t2_gpu = gputotal(G22_gpu,1)
            gpuFree, G22_gpu           
            m1_gpu = gpumake_array(m,value=1.0)                       
            t3_gpu = gpumatrix_multiply(t2_gpu,m1_gpu,/btranspose)
            gpuFree, [t2_gpu,m1_gpu]
            K_gpu = gpuadd(K_gpu,t3_gpu,lhs=K_gpu)
            gpuFree, t3_gpu
            t4_gpu = gpumatrix_multiply(G2_gpu,G1_gpu,/atranspose)
            K_gpu = gpuadd(1.0,K_gpu,-2.0,t4_gpu,0.0,lhs=K_gpu)
            gpufree, t4_gpu
            if n_elements(gma) eq 0 then begin
               gpuAbs, K_gpu, Ka_gpu
               gpusqrt, Ka_gpu, Ka_gpu
               scale = gputotal(Ka_gpu)/(m^2-m)
               gpuFree,Ka_gpu
               gma = 1/(2*(nscale*scale)^2)
            endif   
            K_gpu = gpuexp(1.0,-gma,K_gpu,0.0,0.0,lhs=K_gpu)  
         end
      2: begin
            if n_elements(gma) eq 0 then gma=1.0/n_elements(G1[*,0])
            K1_gpu = gpumatrix_multiply(G2_gpu,G1_gpu,/atranspose) 
            K1_gpu = gpuadd(gma,K1_gpu,0.0,K1_gpu,bias,lhs=K1_gpu)
            K_gpu = gpuCopy(K1_gpu)
            for i=1,degree-1 do K_gpu = gpuMult(K_gpu,K1_gpu,lhs=K_gpu)
            gpuFree, K1_gpu
         end
      3: begin
            if n_elements(gma) eq 0 then gma=1.0/n_elements(G1[*,0])
            K_gpu = gpumatrix_multiply(G2_gpu,G1_gpu,/atranspose) 
            K_gpu = gpuadd(gma,K_gpu,0.0,K_gpu,bias,lhs=K_gpu)
            K_gpu = gpuDiv(gpusinh(K_gpu,lhs=sinh_gpu),gpucosh(K_gpu,lhs=cosh_gpu),lhs=K_gpu)
            gpuFree, [sinh_gpu,cosh_gpu]
         end
   endcase    
   return, K_gpu          
end   