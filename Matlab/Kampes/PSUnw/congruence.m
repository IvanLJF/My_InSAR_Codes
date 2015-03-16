function [minD, unw_xc]=congruence(Arcs, unw_x, wphi_PS)
% function [minD, unw_xc]=congruence(Arcs, unw_x, wphi_PS);
% Post-processing (congruence) of least squares phase unwrapping, 
% i.e., correction made to the unwrapped surface by comparing the total number 
% of discontinuities in the network (see page 227, Ghiglia & Pritt, 1998)
% Input: 
%          Arcs-------------N-by-2 matrix for nodes of all arcs
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
for k=1:M
    D=0;                                           % store discontinuities at different h (total h=10)
    h=2*pi*(k-1)/M;                           % constant
    unw_xt=unw_x+h+wrap(wphi_PS-unw_x-h);
    for i=1:num_PS
        II=find(Arcs(:,1)==i);                 % look for arcs connected with No.i PS
        pq=Arcs(II,2);                            % get the involded PS numbers from the second column of Arcs
        JJ=find(Arcs(:,2)==i);
        pq=[pq; Arcs(JJ,1)];                  % get and update the involded PS numbers from the first column of Arcs
        n=length(pq);                            % get number of connections
        for j=1:n
            t=pq(j);
            v=round((unw_xt(t)-unw_xt(i))/(2*pi));     % see eqution (4.4) in page 154, Ghiglia & Pritt, 1998
            D=D+abs(v);
        end
    end
    if D<minD
        minD=D;
        unw_xc=unw_xt;
    end
end

