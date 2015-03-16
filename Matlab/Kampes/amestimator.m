function [x, VV1, delta]=amestimator(A, L, VV, gamma,  num_PS, num_Arcs, Wei);
% 预测每个PS点的绝对形变速率和高程误差。通过AM估计去除速率中的粗差和高程误差增量
%   [x, VV1, delta]=amestimator(A, L, VV, gamma,  num_PS, num_Arcs);
%
% Estimating the absolute displacement velocity or height error at each PS points,  
% and removing the gross errors in the velocity and height-error increments
% by annealing M-estimator (AM) (see, STAN Z. LI et al., Robust Estimation of Rotation Angles from Image Sequences
% Using the Annealing M-Estimator, Journal of Mathematical Imaging and Vision 8, 181–192 (1998))
% 
% Input:
%        A----------------design matix
%        L----------------constant vector
%        VV--------------residuals obtained by last iteration
%        gamma--------annealing factor for AM
%        num_PS-------total number of all PS points
%        num_Arcs-----total number of all arcs in the triangular irregular network (TIN)
%        Wei-------------weighting vector

% Output:
%        x----------------newly estimated parameters (e.g., velocity in mm/yr and height error in m) in absolute sense
%        VV1-------------updated residuals
%        delta-----------standard deviation in unit weight
%
% e.g., [x, VV1, delta]=amestimator(A, L, VV, gamma,  num_PS, num_Arcs);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   July. 15, 2006: Created, Guoxiang LIU

% Dealing with velocity (or height-error) increments along arcs in the TIN
% outliers will be detected out and removed by means of AM etimator 
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

% Re-weight processing  
weight=zeros(num_Arcs,1);
II=find(abs(VV)<gamma);
% g2=gamma^2;
% weight(II)=(1-VV(II).^2/g2).^2;
weight(II)=Wei(II);
P=spdiags(weight,0,P);
clear Wei;

% Forming normal equation ...
N=A'*P*A; 
w=A'*P*L;
% Solving unknowns with sparse normal equations ...
% This is actually done by means of a built-in Matlab function 
%  "\" -- backslash or left matrix divide, i.e., UMFPACK library
% see http://www.cise.ufl.edu/research/sparse/umfpack
x=N\w;                    % don't use function "inv", because it will be extremely slow or out of memory.
% Error analysis based on LS solution
VV1=A*x-L;               % corrections to observations along all arcs 
VTPV=VV1'*P*VV1;
delta=sqrt(VTPV/(num_Arcs-num_PS));     % standard deviation