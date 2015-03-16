function [Rec_Phi] = TSD_SVD
% 这个函数用来计算小基线子集图像中单个PS点时间序列上的形变演化，并利用SVD来预测影像获取时间上的形变相位
% 
% This function is used to simulate a time series of deformation evolution
% at a PS in the configuration of SBAS (Short Baseline Subsets), and to estimate
% by SVD approach the deformation phase at each epoch when a image acquistion was made.
%
% Rec_Phi=Vector of deformation phases corresponding to the image-taking days
%
%  e.g., Rec_Phi = TSD_SVD;
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                  Jan 21 2005: Created, Guoxiang LIU
%                  Jun 10 2006: Revised 

% Imaging dates assumed
% 5/19/92  7/28/92  9/3/92    12/25/92
% 3/8/93    6/18/93  9/22/93  11/28/93
% 2/26/94  5/26/94  8/18/94  12/6/94
% 3/16/95  6/26/95  9/9/95    12/8/95
% 2/25/96  5/25/96  8/26/96  11/27/96
% 3/8/97    5/5/97    8/16/97  11/6/97

% Converting 24 imaging dates into 24 sequential days (the first imaging date as
% the 0th day)
T=[datenum('5/19/92')  datenum('7/28/92')  datenum('9/3/92')    datenum('12/25/92')  datenum('3/8/93')    datenum('6/18/93')  datenum('9/22/93')   datenum('11/28/93')...
     datenum('2/26/94')  datenum('5/26/94')  datenum('8/18/94')  datenum('12/6/94')    datenum('3/16/95')  datenum('6/26/95')  datenum('9/9/95')    datenum('12/8/95')...
     datenum('2/25/96')  datenum('5/25/96')  datenum('8/26/96')  datenum('11/27/96')  datenum('3/8/97')    datenum('5/5/97')    datenum('8/16/97')  datenum('11/6/97')];
T=T-datenum('5/19/92');    % Time separations w.r.t. the first imaging day

NN=24-1;   % Totoal number of SAR acquisitions

% Numbering for master and slave images
% IM=[2 3 4 6 7 8   11 12 13 13 14 15 15 15 16 16    20 20 21 22 23 23 24 24];   % Numbers for master images
% IS=[1 2 1 4 5 7     9  10  9  11 13 10 12 14 11 15    17 18 20 21 18 20 19 23];   % Numbers for slave images
% "The simulations you have done are correct but there is a problem due to the non-overlapping of 
% the different subsets. The subset composed by the acquisitions labeled to as 1,2,3,4,5,6,7,8] is not 
% overlapped with the subset composed by the acquisitions labeled to as [9,10,11,12,13,14,15,16] and, 
% finally, the third subset is completely separated with respect to the
% other ones." -- Antonio Pepe, Jun 12, 2006, personal communication
% So the following interferometric combinations are re-given accordingly. 
% Two subsets are given
IM=[2 3 4 7 8 9 11 12 13 13 14 15 15 15 16 18    19 20 21 22 23 23 24 24];   % Numbers for master images, 
                                                                                                                             %  changed according to Pepe Antonio, Jun 12, 2006
IS=[1 2 1 4 5 7  6  10  8  11 13 10 12 14 11 15    17 19 20 20 19 20 19 23];   % Numbers for slave images
                                                                                                                             % changed according to Pepe Antonio, Jun 12, 2006
% Three subsets given as follows                                                                                                                            
IM=[2 3 4 6 7 9   11 12 13 13 14 16 16 16 17 17    18 19 20 21 22 23 24 24];   % Numbers for master images
IS=[1 2 1 4 5 7     8  10  8  11 13 10 12 14 11 16    15 15 18 20 21 20 19 23];   % Numbers for slave images

M=length(IM);      % Interferometric combinations: total interferograms are 24

% Given a deformation-accumulated (phase) model for a specific permanent scatter
v=0.01;        % --mm/day
a=0.00001;      % --mm/(day^2)
da=0.000001;  % --mm/(day^3)
Def_Phi=zeros(1,NN+1); 
Def_Phi=v*T+0.5*a*(T.^2)+da*(T.^3)/6;
Def_Phi=Def_Phi/50; % in cm
Def_Phi=Def_Phi+randn(size(T))*0.6;     % add Gaussian noise to Def_Phi

% Generating 24 range changes (corresponding to differential interferometric phases) 
% for 24 interferograms
InPh=zeros(1, M);
for i=1:M
    InPh(i)=Def_Phi(IM(i))-Def_Phi(IS(i));    % range changes
end

% The time series can be reconstructed by solving for the incremental range
% change between SAR data acquisitions. (see pp.4 & 9, Schmidt and Burgmam, 2003, JGR)
A=zeros(M, NN);
for i=1:M
    k0=IS(i);                  % get the starting point of time sequence for the current interferogram
    ke=IM(i);                  % get the ending point of time sequence for the current interferogram
    for j=k0:ke-1
        A(i, j)=1;
    end
end

% The time series can be also reconstructed by solving for the deformation velocity
% between SAR data acquisitions. (see pp.2377, Berardino et al., 2002, IEEE)
% I have tested with both Berardino's and Schmidt's method, and the same
% results were obtained!!! (June 10, 2006, Austin, TX, USA)
% A=zeros(M, NN);
% for i=1:M
%     k0=IS(i);                  % get the starting point of time sequence for the current interferogram
%     ke=IM(i);                  % get the ending point of time sequence for the current interferogram
%     for j=k0:ke-1
%         A(i, j)=T(j+1)-T(j);
%     end
% end

% A can be decomposed by singular value decomposition (SVD) as
[U,S,V] = svd(A);
for i=1:M
    for j=1:NN
        if (i==j & S(i,j)>0.001)
            S(i,j)=1/S(i,j);
        end
    end
end

% The time seris of deformation evolution can be estimated as follows in the LS sense
% with minimum norm
dphi=V*S'*U'*InPh';      % the vector dphi correspond to the incremental
                                     % range changes between SAR acquisitions
Rec_Phi=cumsum([0; dphi]);    %  cumulative sum of the incremental range change
% Vel=V*S'*U'*InPh';
% dT=diff(T);     % calculate derivative
% Rec_Phi=cumsum([0; Vel.*dT']);    %  cumulative sum of phases

% plotting the result
TT=T+datenum('5/19/92');
figure; 
subplot(2,1,1)
plot(TT, Def_Phi, 'b+-');
hold on; plot(TT, Rec_Phi, 'ro-'); hold off
datetick('x', 'yyyy');
xlabel('Time (year)', 'FontSize', 11);
ylabel('Deformation (cm)', 'FontSize', 11);
title('Simulated and solved time series of deformations', 'FontSize', 12);
subplot(2,1,2)
plot(TT, Rec_Phi'-Def_Phi, 'bx-');
datetick('x', 'yyyy');
xlabel('Time (year)', 'FontSize', 11);
ylabel('Deformation difference (cm)', 'FontSize', 11);
title('Difference between solved and simulated range change', 'FontSize', 12);
