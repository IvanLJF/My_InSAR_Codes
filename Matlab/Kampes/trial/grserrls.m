function [x, VV, delta]=grserrls(num_PS, num_Arcs, start, Arcs, Inc, Wei);
%   [x, VV, delta]=grserrls(num_PS, num_Arcs, start, Arcs, Inc, Wei);
%
% Estimating the absolute displacement velocity or height error at each PS points,  
% and removing the gross errors in the velocity and height-error increments
% 
% Input:
%        num_PS-------total number of all PS points
%        num_Arcs-----total number of all arcs in the triangular irregular network (TIN)
%        start-------------use the velocity (or height error) at the first PS point as a benckmark
%        Arcs------------all arcs without arc duplication, num_Arcs-by-2 matrix
%        Inc--------------measurements, i.e., differential values along arcs, num_Arcs-by-1 matrix
%        Wei-------------observation weight matrix, num_Arcs-by-1 matrix
%
% Output:
%        x----------------estimated parameters (e.g., velocity and height error) in absolute sense
%        VV--------------residuals
%        delta-----------standard deviation in unit weight
%
%  e.g.,   num_PS=50;
%            num_Arcs=133;
%             [x, VV, delta]=grserrls_ne(num_PS, num_Arcs, start, Arcs, Inc, Wei);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Apr. 20, 2006: Created, Guoxiang LIU

% Dealing with velocity increments along arcs in the TIN
% outliers will be detected out and removed by means of M etimator 
% (i.e., iterative least squares approach), as well as the abosolute
% linear velocities at PS points will be computed.

% ################### Least Squares Solution ##############################
% Initialize and form observation and constant matrix
% Note: There is one observation equation for each arc, like v(i)-v(j)=dv.
%           Suppose that the absolute velocity at the first PS point is
%           known as zero. The total number of observation eaquations 
%           will be num_Arcs, while total number of unknowns will be num_PS-1.
%           Therefore each equation might contain 1 or 2  non-zero entries.
%           It means that there are num_PS-2 or num_PS-3 zero entries in each 
%           observation equation. That is why the observation matrix is a sparse one.
A=spalloc(num_Arcs, num_PS-1, 2*num_Arcs);
                                   %  creates a num_Arcs-by-num_PS-1 all zero sparse observation matrix
                                   %  with room to eventually hold NZMAX nonzeros.
P=speye(num_Arcs, num_Arcs);         % weight matrix
L=zeros(num_Arcs, 1);                         % for constant vector                             
for i=1:num_Arcs
    n1=Arcs(i, 1);                              % get the number of PS1 of the i-th arc
    n2=Arcs(i, 2);                              % get the number of PS2 of the i-th arc
    dd=Inc(i);                                     % velocity or height-error increments along the arc formed by the two PS points
    if Wei(i)<0.6                                 % recommended by Dr. Sean M. Buckley at CSR, UTA 
        Wei(i)=Wei(i)^2;
    end
    P(i,i)=Wei(i);
    if n1==1
        A(i, n2-1)=1;
        L(i)=dd+start;  
    elseif n2==1
        A(i, n1-1)=-1;
        L(i)=dd-start;
    else
         A(i, n1-1)=-1;
         A(i, n2-1)=1;
         L(i)=dd;
    end
end
% Forming normal equation ...
N=A'*P*A; 
w=A'*P*L;
% Solving unknowns with sparse normal equations ...
% This is actually done by means of a built-in Matlab function 
%  "\" -- backslash or left matrix divide, i.e., UMFPACK library
% see http://www.cise.ufl.edu/research/sparse/umfpack
x=N\w;                    % don't use function "inv", because it will be extremely slow or out of memory.
% Error analysis based on LS solution
VV=A*x-L;               % corrections to observations along all arcs 
VTPV=VV'*P*VV;
delta=sqrt(VTPV/(num_Arcs-num_PS+1));     % standard deviation
disp(' ');
disp('% Summary of The 1st Least Sqaures Solution:');
disp(['   Maximum residual == ', num2str(max(abs(VV))), '    Minimum residual == ', num2str(min(abs(VV)))]);
disp(['   Sum of residual sqaure (VTPV) == ', num2str(VTPV)]);
disp(['   Unit-weight standard deviation (delat) == ', num2str(delta)]);

% ################### M-Estimator Solution ##############################
% Detecting out outliers by iterative least sqaures solutions
disp(' ');
disp('% Robust estimation by iteratively setting up weights ......');
counter=0;
Huber_Par=2;           % Huber's method

while 1
   counter=counter+1;
   disp(['     % For the ', num2str(counter), '-time robust iteration ...']);
   med1=median(VV); med2=median(abs(VV-med1));
   delta1=1.483*med2;    % Robust standard deviation, Median Absolute Deviation (MAD)
   Std_V=VV/delta1;         % Reasonable standard residue
   
   % Determing weigt matrix according to M-estimator proposed by Huber
   %for i=1:num_Arcs
      %Flag=abs(Std_V(i));
      %if Flag<=Huber_Par
       %   P(i,i)=1;                   % set up weight 1
      %else
           %P(II,II)=0;          % set up weight 0
           %disp(['         No.', num2str(II), ' measurement is removed in the current iteration !']);
      %end
    %end
      [max_v, II]=max(abs(Std_V));    
      [rows, cols]=size(A);
      if max_v>=Huber_Par
           num_Arcs=num_Arcs-1;
           PP=speye(num_Arcs, num_Arcs);
           AA=spalloc(num_Arcs, num_PS-1, 2*num_Arcs);
           LL=zeros(num_Arcs, 1);                         % for constant vector
           Wei1=zeros(num_Arcs, 1);      
           if II==1
               AA=A(2:rows,:);
               LL=L(2:rows);
               for i=2:rows
                   Wei1(i-1)=Wei(i);
                   PP(i-1,i-1)=Wei1(i-1);
               end                   
           elseif II==rows
               AA=A(1:rows-1,:);
               LL=L(1:rows-1);
               for i=1:rows-1
                   Wei1(i)=Wei(i);
                   PP(i,i)=Wei1(i);
               end                                 
           else
               AA=[A(1:II-1,:); A(II+1:rows,:)];
               LL=[L(1:II-1); L(II+1:rows)];
               for i=1:II-1
                   Wei1(i)=Wei(i);
                   PP(i,i)=Wei1(i);
               end
               for i=II+1:rows
                   Wei1(i-1)=Wei(i);
                   PP(i-1,i-1)=Wei1(i-1);
               end               
           end
           disp(['         No.', num2str(II), ' measurement is removed in the current iteration !']);
      else
          break;
     end
   %end
   
  % Forming normal equation ...
  clear N w x VV A L P Wei
   N=AA'*PP*AA;
   w=AA'*PP*LL;
   x=N\w;                    % Solving the unknown parameter
   VV=AA*x-LL;               % corrections to observations along all arcs
   A=AA;
   L=LL;
   P=PP;
   Wei=Wei1;
end   

% Error analysis based on M-estimator solution
VTPV=VV'*P*VV;
PP=0;
for i=1:num_Arcs
   PP=PP+P(i,i);
end
delta=sqrt(VTPV/(PP-num_PS-1+1));    % Robust standard deviation
disp(' ');
disp('% Summary of The Final Robust Solution:');
disp(['   Maximum residual == ', num2str(max(abs(VV))), '    Minimum residual == ', num2str(min(abs(VV)))]);
disp(['   Sum of residual sqaure (VTPV) == ', num2str(VTPV)]);
disp(['   Unit-weight standard deviation (delat) == ', num2str(delta)]);

