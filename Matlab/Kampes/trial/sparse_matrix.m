 t0=cputime;
 A=sprandsym(8000, 0.005);
 x=rand(8000,1);
 w=A*x;
 x1=A\w;
 
 disp(['% Total CPU time used for the whole processing:  ', num2str(cputime-t0), ' seconds.']);