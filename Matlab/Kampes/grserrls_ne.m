function [A, L, x, VV, delta]=grserrls_ne(num_PS, num_Arcs, starting, ending, thrsld, Arcs, Inc, Wei)
% 预测每个PS点的绝对形变速率和高程误差，去除速率中的粗差和高程误差增量。
%   [A, L, x, VV, delta]=grserrls_ne(num_PS, num_Arcs, starting, thrsld, Arcs, Inc, Wei);
%
% Estimating the absolute displacement velocity or height error at each PS points,  
% and removing the gross errors in the velocity and height-error increments
% 
% Input:
%        num_PS-------total number of all PS points
%        num_Arcs-----total number of all arcs in the triangular irregular network (TIN)
%        starting---------use the velocity (or height error) at the first PS point as a benckmark
%        ending----------use the velocity (or height error) at the last PS point as a benckmark
%        thrsld------------Weight thresholding
%        Arcs------------all arcs without arc duplication, num_Arcs-by-2 matrix
%        Inc--------------measurements (dv in mm/day, ddh in m), i.e., differential values along arcs, num_Arcs-by-1 matrix
%        Wei-------------observation weight matrix, num_Arcs-by-1 matrix
%
% Output:
%        A----------------design matix
%        L----------------constant vector
%        x----------------estimated parameters (e.g., velocity in mm/yr and height error in m) in absolute sense
%        VV--------------residuals
%        delta-----------standard deviation in unit weight
%
%  e.g.,   num_PS=50;
%            num_Arcs=133;
%             [A, L, x, VV, delta]=grserrls_ne(num_PS, num_Arcs, starting, ending, thrsld, Arcs, Inc, Wei);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Apr. 20, 2006: Created, Guoxiang LIU

% Dealing with velocity (or height-error) increments along arcs in the TIN
% outliers will be detected out and removed by means of M etimator 
% (i.e., iterative least squares approach), as well as the abosolute
% linear velocities or height errors at PS points will be computed.

% ################### Least Squares Solution ##############################
% Initialize and form observation and constant matrix
% Note: There is one observation equation for each arc, like v(i)-v(j)=dv.
%           Suppose that the absolute velocity at the first PS point is
%           known as zero. The total number of observation eaquations 
%           will be num_Arcs, while total number of unknowns will be num_PS-1.
%           Therefore each equation might contain 1 or 2  non-zero entries.
%           It means that there are num_PS-2 or num_PS-3 zero entries in each 
%           observation equation. That is why the observation matrix is a sparse one.
warning on;
% A=spalloc(num_Arcs, num_PS-2, 2*num_Arcs); % for velocity
                                   %  creates a num_Arcs-by-num_PS-2 all zero sparse observation matrix
                                   %  with room to eventually hold NZMAX nonzeros.
P=speye(num_Arcs, num_Arcs);         % weight matrix
L=zeros(num_Arcs, 1);                         % for constant vector

% Weight processing  
II=find(Wei<thrsld);
if length(II)>0
    Wei(II)=0;
end
II=find(Wei<0.4);
Wei(II)=Wei(II).^5;
P=spdiags(Wei,0,P);
clear II Wei;

% Design matrix
% for arcs without starting and ending points
II=find(Arcs(:,1)~=1 &  Arcs(:,2)~=1 & Arcs(:,1)~=num_PS &  Arcs(:,2)~=num_PS);
N1=Arcs(II,1)-1;
N2=Arcs(II,2)-1;
L(II)=Inc(II);                             % constant terms
II=[II; II]; 
N12=[N1; N2];
SS=[-1*ones(size(N1)); 1*ones(size(N1))];
clear N1 N2; 
A=sparse(II, N12, SS, num_Arcs, num_PS-2, 2*num_Arcs);      % Generated the design matrix (sparse)
clear II N12 SS;
% for arcs with starting point
II=find(Arcs(:,1)==1);
if length(II)~=0
    for i=1:length(II)
        n2=Arcs(II(i), 2);
        dd=Inc(II(i));
        A(II(i), n2-1)=1;
        L(II(i))=dd+starting;
    end
end
II=find(Arcs(:,2)==1);
if length(II)~=0
    for i=1:length(II)
        n1=Arcs(II(i), 1);
        dd=Inc(II(i));
        A(II(i), n1-1)=-1;
        L(II(i))=dd-starting;
    end
end
% for arcs with ending point
II=find(Arcs(:,1)==num_PS);
if length(II)~=0
    for i=1:length(II)
        n2=Arcs(II(i), 2);
        dd=Inc(II(i));
        A(II(i), n2-1)=1;
        L(II(i))=dd+ending;
    end
end
II=find(Arcs(:,2)==num_PS);
if length(II)~=0
    for i=1:length(II)
        n1=Arcs(II(i), 1);
        dd=Inc(II(i));
        A(II(i), n1-1)=-1;
        L(II(i))=dd-ending;
    end
end
clear II;

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
delta=sqrt(VTPV/(num_Arcs-num_PS));     % standard deviation