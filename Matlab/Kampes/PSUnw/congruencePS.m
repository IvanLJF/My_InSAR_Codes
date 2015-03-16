function [minD, unw_xc]=congruencePS(PQD, unw_x, wphi_PS)
% function [minD, unw_xc]=congruence(PQD, unw_x, wphi_PS);
% Post-processing (congruence) of least squares phase unwrapping, 
% i.e., correction made to the unwrapped surface by comparing the total number 
% of discontinuities in the network (see page 227, Ghiglia & Pritt, 1998)
% Input: 
%          PQD------------(um_PS)-by-(2*maxN+1) matrix storing the numbers of PS points and arcs
%                                 related to any PS point
%          unw_x----------num_PS-by-1 vector for the unwrapped phase data
%                                 at num_PS PS points 
%          wphi_PS-------wrapped phases at PS points
% Output: 
%          unw_xc---------num_PS-by-1 vector for unwrapped-phase values at all PS points
%                                 after adjustment
% Original Author:  Guoxiang LIU
% Revision History:
%                   May. 25, 2006: Created, Guoxiang LIU, UTA
%
% See also RESPSUNW PSLSUNW LSUNW_TEST RESFLTUNW BCUNW

num_PS=length(wphi_PS);           % get the total number of all the PS points
M=10;                                             % iterations
minD=1e28;                                  % give the minimum value of D
TWOPI=2*pi;
for k=1:M
    D=0;                                           % store discontinuities at different h (total h=10)
    h=2*pi*(k-1)/M;                           % constant
    unw_xt=unw_x+h+wrap(wphi_PS-unw_x-h);
    for i=1:num_PS
        n=PQD(i,1);                                % get the total number of PS points related No.i PS
        pq=PQD(i,2:n+1);                       % get PS points related No.i PS
        for j=1:n
            t=pq(j);
            v=round((unw_xt(t)-unw_xt(i))/TWOPI);     % see eqution (4.4) in page 154, Ghiglia & Pritt, 1998
            D=D+abs(v);
        end
    end
    if D<minD
        minD=D;
        unw_xc=unw_xt;
    end
end

