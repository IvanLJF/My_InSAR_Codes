function [unw_xc]=pslsunw(num_PS, Arcs, wphi_PS, wei)
% function [unw_xc]=pslsunw(num_PS, Arcs, wphi_PS, wei);
% Doing phase unwrapping for sparse data at PS points with least squares method
% (see page 227, Ghiglia and Pritt, 1998)
% Input: 
%          num_PS--------total number of PS points
%          Arcs-------------N-by-2 matrix for nodes of all arcs
%          wphi_PS--------wrapped phases at PS points
%          wei---------------N-by-1 vector for weights (model coherences) of all arcs
% Output: 
%          unw_xc---------num_PS-by-1 vector for unwrapped-phase values at all PS points
%                                 (the unwrapped phase at No.1 PS point is fixed to the wrapped phase)
% Original Author:  Guoxiang LIU
% Revision History:
%                   May. 25, 2006: Created, Guoxiang LIU, UTA
%
% See also RESPSUNW CONGRUENCE LSUNW_TEST RESFLTUNW BCUNW

B=spalloc(num_PS, num_PS-1, 20*num_PS); % initialize the observation matrix
%  creates a num_PS-by-num_PS-1 all zero sparse observation matrix
%  with room to eventually hold NZMAX nonzeros.
%P=speye(num_Arcs, num_Arcs);         % weight matrix
L=zeros(num_PS, 1);                            % initialize the constant vector
% creat the observation matrix B for LS phase unwrapping based on wrapped-phase gradients
for i=1:num_PS
    II=find(Arcs(:,1)==i);                 % look for arcs connected with No.i PS
    pq=Arcs(II,2);                            % get the involded PS numbers from the second column of Arcs
    JJ=find(Arcs(:,2)==i);
    D=[II; JJ];                                   % get indexes of arcs related to No.i PS
    pq=[pq; Arcs(JJ,1)];                  % get and update the involded PS numbers from the first column of Arcs
    n=length(pq);                            % get number of connections
    L(i)=0;
    if i~=1
        B(i,i-1)=-sum(wei(D));
    else
        L(i)=L(i)+sum(wei(D)*wphi_PS(1));
    end
    for j=1:n
        m=pq(j);
        if m==1
            L(i)=L(i)+wei(D(j))*wrap(wphi_PS(m)-wphi_PS(i))-wei(D(j))*wphi_PS(1);
        else
            B(i, m-1)=wei(D(j));
            L(i)=L(i)+wei(D(j))*wrap(wphi_PS(m)-wphi_PS(i));
        end
    end
end

% Forming normal equation ...
N=B'*B;
w=B'*L;
clear B L m pq i j II JJ
% Solving unknowns with sparse normal equations ...
% This is actually done by means of a built-in Matlab function
%  "\" -- backslash or left matrix divide, i.e., UMFPACK library
% see http://www.cise.ufl.edu/research/sparse/umfpack
unw_x=N\w;                    % don't use function "inv", because it will be extremely slow or out of memory.
unw_x=[wphi_PS(1); unw_x];   % include the strat point

% Post-processing of LS unwrapping: congruence process
% (see page 227, "Two-Dimensional Phase Unwrapping" by Ghiglia & Pritt, 1998)
% for simulated data without any noise, congruence can be done by the next commond line
%unw_x=unw_x+wrap(wphi_PS(2:num_PS)-unw_x);
% for noise phase data, congruence can be done by the following
[minD, unw_xc]=congruence(Arcs, unw_x, wphi_PS);
