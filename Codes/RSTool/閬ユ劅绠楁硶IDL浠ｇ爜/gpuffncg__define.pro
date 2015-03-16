; docformat = 'rst'
; gpuffncg__define.pro
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
;     Object class for implementation of a
;     two-layer, feed-forward neural network classifier.
;       Implements scaled conjugate gradient training::
;           Bishop, C. M. (1995). Neural Networks for 
;           Pattern Recognition. Oxford ;University Press.       
; :Params:
;        Gs: in, required 
;           array of observation column vectors     
;        Ls: in, required
;            array of class label column vectors
;            of form (0,0,1,0,0,...0)^T          
;        L: in, required
;           number of hidden neurons
; :Examples:   
;     ffn = Obj_New("GPUFFNCG",Gs,Ls,L)
; :Uses:
;       COYOTE::   
;       GPULIB 
; :Author:      
;       Mort Canty (2009)           
;-
Function GPUFFNCG::Init, Gs, Ls, L, iterations=iterations
   catch, theError
   if theError ne 0 then begin
      catch, /cancel
      ok = dialog_message(!Error_State.Msg + ' Returning...', /error)
      return, 0
   endif
   if n_elements(iterations) eq 0 then self.iterations = 1000L $
      else self.iterations = iterations
   self.cost_array = ptr_new(fltarr(self.iterations))     
; network architecture
   self.LL = L
   self.np = n_elements(Gs[*,0])
   self.NN = n_elements(Gs[0,*])
   self.KK = n_elements(Ls[0,*]) 
   if n_elements(iterations) eq 0 then self.iterations = 1000L $
      else self.iterations = iterations
; ------------ GPU ---------------------------   
; biased training examples (column vectors)
   self.Gs_gpu = ptr_new(gpuPutArr([[fltarr(self.np)+1],[Gs]]))
   self.Ls_gpu = ptr_new(gpuPutArr(float(Ls)))
; synaptic weight matrices   
   self.Wh_gpu = ptr_new(gpuPutArr(randomu(seed,L,self.NN+1)-0.5))
   self.Wo_gpu = ptr_new(gpuPutArr(randomu(seed,self.KK,L+1)-0.5)) 
; biased output hidden layer   
   self.N_gpu = ptr_new(gpuPutArr(fltarr(self.np,self.LL+1)+1.0))   
; output network
   self.M_gpu = ptr_new(gpuPutArr(fltarr(self.np,self.KK)+1.0))
; work array for Rop    
   self.RIh_gpu = ptr_new(gpuPutArr(fltarr(self.np,self.LL+1)))
; work array for forwardPass
   self.onesL_gpu = ptr_new(gpuPutArr(fltarr(self.np,self.LL)+1.0))   
; current gradient of the cost function
   self.g_gpu = ptr_new(gpuPutArr(fltarr(L*(self.NN+1)+self.KK*(L+1)))) 
; current search direction in weight space      
   self.d_gpu = ptr_new(gpuPutArr(fltarr(L*(self.NN+1)+self.KK*(L+1)))) 
   return, 1
End

Pro GPUFFNCG::Cleanup
   ptr_free, self.cost_array
   gpuFree,[*self.Gs_gpu,*self.Ls_gpu,*self.Wh_gpu,*self.Wo_gpu,$
            *self.N_gpu,*self.M_gpu,*self.RIh_gpu,*self.onesL_gpu,$
            *self.g_gpu,*self.d_gpu] 
   ptr_free, self.Gs_gpu
   ptr_free, self.Ls_gpu
   ptr_free, self.Wh_gpu
   ptr_free, self.Wo_gpu 
   ptr_free, self.N_gpu
   ptr_free, self.M_gpu  
   ptr_free, self.RIh_gpu
   ptr_free, self.onesL_gpu
End

Pro GPUFFNCG::forwardPass
; vectorized forward pass 
   gpuView,*self.N_gpu,self.np,self.LL*self.np,Nv_gpu
   gpuReform,Nv_gpu,self.np,self.LL
;  logistic output of hidden layer      
   expnt_gpu = gpuMatrix_Multiply(*self.Gs_gpu,*self.Wh_gpu,/btranspose)
   tmp_gpu = gpuExp(1.0,-1.0,expnt_gpu,0.0,1.0)  
   gpuDiv,*self.onesL_gpu,tmp_gpu,Nv_gpu    
;  softmax network output
   Io_gpu = gpuMatrix_Multiply(*self.N_gpu,*self.Wo_gpu,/btranspose)
   maxIo_gpu = gpuMax(Io_gpu,dimension=2)   
   for k=0,self.KK-1 do begin
      gpuView,Io_gpu,k*self.np,self.np,Iov_gpu
      gpuSub,Iov_gpu,maxIo_gpu,Iov_gpu
   endfor
   A_gpu = gpuExp(Io_gpu)    
   sum_gpu = gpuTotal(A_gpu,2,LHS=sum_gpu)
   for k=0,self.KK-1 do begin
      gpuView,*self.M_gpu,k*self.np,self.np,Mv_gpu
      gpuView,A_gpu,k*self.np,self.np,Av_gpu
      gpuDiv,Av_gpu,sum_gpu,Mv_gpu
   endfor
   gpuFree, [tmp_gpu,expnt_gpu,Io_gpu,maxIo_gpu, $
             A_gpu,sum_gpu]
End

Function GPUFFNCG::classify, Gs, Probs
; vectorized class membership probabilities
   nx = n_elements(Gs[*,0])
   Ones = dblarr(nx) + 1.0
   gpuGetArr,*self.Wh_gpu,Wh
   gpuGetArr,*self.Wo_gpu,Wo
   expnt = transpose(Wh)##[[Ones],[Gs]]
   N = [[Ones],[1/(1+exp(-expnt))]]
   Io = transpose(Wo)##N
   maxIo = max(Io,dimension=2)
   for k=0,self.KK-1 do Io[*,k]=Io[*,k]-maxIo
   A = exp(Io)
   sum = total(A,2)
   Probs = fltarr(nx,self.KK)
   for k=0,self.KK-1 do Probs[*,k] = A[*,k]/sum
   void = max(probs,labels,dimension=2)
   return, byte(labels/nx+1)
End

Function GPUFFNCG::cost
   self->forwardpass
   gpuLog,*self.M_gpu,log_gpu
   gpuMult,*self.Ls_gpu,log_gpu,res_gpu
   res = -gpuTotal(res_gpu)
   gpuFree,[log_gpu,res_gpu]
   return,res   
End

Pro GPUFFNCG::Gradient
   self->forwardpass
   gpuView,*self.g_gpu,0,self.LL*(self.NN+1),dEh_gpu
   gpuReform,dEh_gpu,self.LL,self.NN+1
   gpuView,*self.g_gpu,self.LL*(self.NN+1),self.KK*(self.LL+1),dEo_gpu 
   gpuReform,dEo_gpu,self.KK,self.LL+1
   gpuSub,*self.Ls_gpu,*self.M_gpu,D_o_gpu 
   gpuMatrix_Multiply, D_o_gpu, *self.Wo_gpu, tmp1_gpu
   gpuMult,*self.N_gpu,*self.N_gpu,tmp2_gpu
   gpuSub,*self.N_gpu,tmp2_gpu,tmp2_gpu
   gpuMult,tmp1_gpu,tmp2_gpu,tmp1_gpu
   gpuView,tmp1_gpu,self.np,self.LL*self.np,D_h_gpu
   gpuReform,D_h_gpu,self.np,self.LL 
   gpuMatrix_Multiply,D_h_gpu,*self.Gs_gpu,dEh_gpu,/ATRANSPOSE
   gpuMatrix_Multiply,D_o_gpu,*self.N_gpu,dEo_gpu,/ATRANSPOSE
   gpuAdd,-1.0,*self.g_gpu,0.0,*self.g_gpu,0.0,*self.g_gpu
   gpuFree,[D_o_gpu,tmp1_gpu,tmp2_gpu]
End
 
Function GPUFFNCG::Rop, V_gpu
; ----------- CPU Version ------------------------------
;; reform V to dimensions of Wh and Wo and transpose
;  VhT=transpose(reform(V[0:self.LL*(self.NN+1)-1], $
;                  self.LL,self.NN+1))
;  Vo=reform(V[self.LL*(self.NN+1):*],self.KK,self.LL+1)
;  VoT = transpose(Vo)
;; transpose the weights
;  Wo  = *self.Wo
;  WoT = transpose(Wo)
;; vectorized forward pass
;  self->forwardpass
;  gpuGetArr,*self.N_gpu,N
;  gpuGetArr,*self.M_gpu,M
;; evaluation of v^T.H
;  Zeroes = fltarr(self.np)
;  D_o=*self.Ls-M                            ;d^o
;  RIh=VhT##(*self.Gs)                       ;Rv{I^h}
;  RN=N*(1-N)*[[Zeroes],[RIh]]               ;Rv{n}
;  RIo=WoT##RN + VoT##N                      ;Rv{I^o}
;  Rd_o=-M*(1-M)*RIo                         ;Rv{d^o}
;  Rd_h=N*(1-N)*((1-2*N)*[[Zeroes],[RIh]]*(Wo##D_o) $
;         + Vo##D_o + Wo##Rd_o)
;  Rd_h=Rd_h[*,1:*]                          ;Rv{d^h}
;  REo=-N##transpose(Rd_o)-RN##transpose(D_o);Rv{dE/dWo}
;  REh=-*self.Gs##transpose(Rd_h)            ;Rv{dE/dWh}
;  return, [REh[*],REo[*]]                   ;v^T.H
; -----------------------------------------------------
; output structure
   res_gpu = gpuMake_Array(V_gpu.dimensions[0],/nozero)
   gpuView,res_gpu,0,self.LL*(self.NN+1),REh_gpu
   gpuReform,REh_gpu,self.LL,self.NN+1
   gpuView,res_gpu,self.LL*(self.NN+1),self.KK*(self.LL+1),REo_gpu 
   gpuReform,REo_gpu,self.KK,self.LL+1
; reform V to dimensions of Wh and Wo  
   gpuView,V_gpu,0,self.LL*(self.NN+1),Vh_gpu
   gpuView,V_gpu,self.LL*(self.NN+1),self.KK*(self.LL+1),Vo_gpu
   gpuReform, Vh_gpu, self.LL,self.NN+1
   gpuReform, Vo_gpu, self.KK,self.LL+1
; vectorized forward pass
   self->forwardpass   
; evaluation of v^T.H
   gpuSub, *self.Ls_gpu,*self.M_gpu,Do_gpu                     ;d^o   
   gpuView,*self.RIh_gpu,self.np,self.LL*self.np,RIh1_gpu
   gpuReform,RIh1_gpu,self.np,self.LL
   gpuMatrix_Multiply,*self.Gs_gpu,Vh_gpu,RIh1_gpu,/btranspose ;Rv{I^h}  
   gpuMult,*self.N_gpu,*self.N_gpu,N1_gpu
   gpuSub,*self.N_gpu,N1_gpu,N1_gpu                            ;N(1-N)
   gpuMult,N1_gpu,*self.RIh_gpu,RN_gpu                         ;Rv(n) 
   gpuMatrix_Multiply,RN_gpu,*self.Wo_gpu,RIo_gpu,/btranspose
   gpuMatrix_Multiply,*self.N_gpu,Vo_gpu,tmp_gpu,/btranspose
   gpuAdd,RIo_gpu,tmp_gpu,RIo_gpu                              ;Rv{I^o} 
   gpuMult,*self.M_gpu,*self.M_gpu,tmp_gpu
   gpuSub,tmp_gpu,*self.M_gpu,tmp_gpu
   gpuMult,tmp_gpu,RIo_gpu,Rdo_gpu                             ; Rv(d^o)
   gpuFree,tmp_gpu
   gpuSub,0.0,*self.N_gpu,2.0,*self.N_gpu,1.0,tmp_gpu
   gpuMult,tmp_gpu,*self.RIh_gpu,tmp_gpu
   gpuMatrix_Multiply,Do_gpu,*self.Wo_gpu,tmp1_gpu
   gpuMult,tmp_gpu,tmp1_gpu,tmp_gpu
   gpuMatrix_Multiply,Do_gpu,Vo_gpu,tmp1_gpu
   gpuAdd,tmp_gpu,tmp1_gpu,tmp_gpu
   gpuMatrix_Multiply,Rdo_gpu,*self.Wo_gpu,tmp1_gpu
   gpuAdd,tmp_gpu,tmp1_gpu,tmp_gpu
   gpuMult,N1_gpu,tmp_gpu,tmp_gpu         
   gpuView,tmp_gpu,self.np,self.LL*self.np,Rdh_gpu             ;Rv{d^h} 
   gpuReform,Rdh_gpu,self.np,self.LL
   gpuMatrix_Multiply,Rdo_gpu,*self.N_gpu,REo_gpu,/atranspose
   gpuMatrix_multiply,Do_gpu,RN_gpu,tmp2_gpu,/atranspose
   gpuAdd,REo_gpu,tmp2_gpu,REo_gpu                             ;-Rv{dE/dWo} 
   gpuMatrix_Multiply,Rdh_gpu,*self.Gs_gpu,REh_gpu,/atranspose ;-Rv{dE/dWh}  
   gpuAdd,-1.0,res_gpu,0.0,res_gpu,0.0,res_gpu                 
   gpuFree,[Do_gpu,N1_gpu,RN_gpu,RIo_gpu,tmp_gpu,Rdo_gpu,tmp1_gpu,tmp2_gpu]
   return, res_gpu                                             ;v^T.H                     
End

Function GPUFFNCG::Hessian
   nw = self.LL*(self.NN+1)+self.KK*(self.LL+1)
   v = diag_matrix(fltarr(nw)+1.0)
   H = fltarr(nw,nw)
   for i=0,nw-1 do begin  
      gpuPutArr,v[*,i],tmp_gpu
      tmp_gpu = self->Rop(tmp_gpu)
      gpuGetArr,tmp_gpu,tmp
      H[*,i] = tmp   
   endfor  
   gpuFree,tmp_gpu 
   return, H
End

Function GPUFFNCG::Eigenvalues
   H = self->Hessian()
   H = (H+transpose(H))/2
   return, eigenql(H,/double)
End

Pro GPUFFNCG::Train  
   w_gpu = gpuMake_Array(self.LL*(self.NN+1)+self.KK*(self.LL+1),/nozero)
   gpuView,w_gpu,0,self.LL*(self.NN+1),wh_gpu
   gpuView,w_gpu,self.LL*(self.NN+1),self.KK*(self.LL+1),wo_gpu
   gpuReform,wh_gpu,self.LL,self.NN+1
   gpuReform,wo_gpu,self.KK,self.LL+1
   gpuCopy,*self.Wh_gpu,wh_gpu
   gpuCopy,*self.Wo_gpu,wo_gpu
   nw = w_gpu.n_elements
   self->gradient
   gpuAdd,-1.0,*self.g_gpu,0.0,*self.g_gpu,0.0,*self.d_gpu ; search direction, row vector
   k = 0L
   lambda = 0.001
   window,12,xsize=600,ysize=400, $
      title='FFN(scaled conjugate gradient, CUDA)'
   wset,12
   progressbar = Obj_New('progressbar', $
     Color='blue', Text='0', $
     title='Training: epoch No...',xsize=250,ysize=20)
   progressbar->start
   eivminmax = '?'
   repeat begin
      if progressbar->CheckCancel() then begin
         print,'Training interrupted'
         progressbar->Destroy
         return
      endif
      gpuMult,*self.d_gpu,*self.d_gpu,tmp_gpu
      d2 = gpuTotal(tmp_gpu)                           ;d^2
      tmp_gpu = self->Rop(*self.d_gpu)
      gpuMult,tmp_gpu,*self.d_gpu,tmp_gpu
      dTHd = gpuTotal(tmp_gpu)                         ;d^T.H.d    
      delta = dTHd+lambda*d2
      if delta lt 0 then begin
         lambda = 2*(lambda-delta/d2)
         delta = -dTHd
      endif
      E1 = self->cost()                                ;E(w)
      (*self.cost_array)[k] = E1            
      gpuMult,*self.d_gpu,*self.g_gpu,tmp_gpu
      dTg = gpuTotal(tmp_gpu)                          ;d^T.g
      alpha = -dTg/delta
      gpuAdd, 1.0,w_gpu,alpha,*self.d_gpu,0.0,w_gpu    ;w = w+alpha*d     
;    update weights     
      gpuCopy,wh_gpu,*self.Wh_gpu
      gpuCopy,wo_gpu,*self.Wo_gpu      
      E2 = self->cost()                                ;E(w+dw)
      Ddelta = -2*(E1-E2)/(alpha*dTg)                  ;quadricity
      if Ddelta lt 0.25 then begin
;    undo weight change        
         gpuAdd, 1.0,w_gpu,-alpha,*self.d_gpu,0.0,w_gpu;w = w-alpha*d   
         gpuCopy,wh_gpu,*self.Wh_gpu
         gpuCopy,wo_gpu,*self.Wo_gpu      
         lambda = 4*lambda                             ;decrease step size
         if lambda gt 1e20 then $                      ;if step too small
           k=self.iterations   $                       ; then give up
         else gpuAdd,-1.0,*self.g_gpu,0.0, $           ; else restart (d = -g)
                    *self.g_gpu,0.0,*self.d_gpu 
      end else begin
         k++
         if Ddelta gt 0.75 then lambda = lambda/2
         self->gradient
         if k mod nw eq 0 then beta = 0 $
         else begin
            tmp_gpu = self->Rop(*self.g_gpu)
            gpuMult,tmp_gpu,*self.d_gpu,tmp_gpu
            beta = gpuTotal(tmp_gpu)/dTHd  
         endelse   
         gpuAdd,beta,*self.d_gpu,-1.0, $               ;d = beta*d-g
                  *self.g_gpu,0.0,*self.d_gpu     
         if k mod 10 eq 0 then plot,*self.cost_array,xrange=[0,k>100L], $
            color=0, background='FFFFFF'XL, $
            ytitle='cross entropy', $
            xtitle='Epoch'
      endelse
      progressbar->Update,k*100/self.iterations, $
         text=strtrim(k,2)
   endrep until k ge self.iterations
   progressbar->Destroy
   gpuFree,[w_gpu,tmp_gpu]
End

Pro GPUFFNCG__Define
   class  = { GPUFFNCG, $
           cost_array: ptr_new(),    $
           iterations: 0L,           $
           NN: 0L,                   $ ;input dimension
           LL: 0L,                   $ ;number of hidden units
           KK: 0L,                   $ ;output dimension
           np: 0L,                   $ ;number of training pairs
; ------------- GPU --------------------------------------------------  
           N_gpu: ptr_new(),         $ ;biased output hidden layer  
           M_gpu: ptr_new(),         $ ;output network                     
           Wh_gpu:ptr_new(),         $ ;hidden weights
           Wo_gpu:ptr_new(),         $ ;output weights
           Gs_gpu:ptr_new(),         $ ;training pairs
           Ls_gpu:ptr_new(),         $ 
           RIh_gpu:ptr_new(),        $ ;[[zeroes],[Rv(I^h)]](for Rop)
           OnesL_gpu:ptr_new(),      $ ;work array (for forwardpass) 
           g_gpu:ptr_new(),          $ ;current gradient
           d_gpu:ptr_new()           $ ;current search direction         
            }
End