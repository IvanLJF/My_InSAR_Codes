function test_svd, m, n, verbose=verbose

   COMPILE_OPT STRICTARR 

   if n_elements(verbose) eq 0 then verbose = 0

; IDL (n x m) array representing an (m x n) matrix
   A = randomu(seed,n,m)
   print,'m,n', m, n 
   if verbose then begin
      print, 'A'
      print, A
      print, ' '
   endif   
 
   start = systime(2) 
   LA_SVD, A, W, U, V
   t_host = systime(2)-start
   print, 'host', t_host
   if verbose then begin     
      print,W
      print,''
      print,U
      print,''
      print,V
   endif   
  
   start = systime(2)    
   CUDA_SVD, A, W, U, VT
   t_device =  systime(2)-start
   print, 'device', t_device   
   if verbose then begin
      print,W
      print,''
      print,U
      print,''
      print,VT
      print, ' '
      print, 'U.S.VT '
      print, U##diag_matrix(W)##VT 
   endif

   return, t_host/t_device
     
end
   
   