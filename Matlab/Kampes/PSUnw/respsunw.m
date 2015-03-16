function [unwall]=respsunw(infile);
%  function unwall=respsunw(infile);
% Doing phase unwrapping on the residual phases by the weighted least sqaures 
% method presented by Ghiglia and Pritt (1998)
% Input:
%        infile----------------a input text file including filenames of num_intf differential interferograms, e.g.,
%                                    num_intf rows cols num_PS       // num_intf differential interferograms with dimension of rows by cols, 
%                                                                                         // total number of all PS -- num_PS  
%                                    E:\PhoenixSAR\Dif_Int_MLI\        // directory of interferograms  
%                                   19920710_19930521.diff.int2.ph
%                                   19920710_19931008.diff.int2.ph
%                                   ...............
%                                   19991220_20001030.diff.int2.ph   
% Output:
%        unwall--------------unwrapped-phase data at PS points for all the residual interferograms
%                                   (num_PS-by-num_intf)
%  e.g., unwall=respsunw('E:\PhoenixSAR\Dif_Int_MLI\86ints.all');
%          unwall=respsunw('E:\PhoenixSAR\Dif_Int_MLI\117ints.all');
% Original Author:  Guoxiang LIU
% Revision History:
%                   May. 20, 2006: Created, Guoxiang LIU, UTA
%
% See also PSLSUNW CONGRUENCE LSUNW_TEST RESFLTUNW BCUNW

cput0=cputime;     % the starting time of the computation

% Define the study area for Phoenix
r0=751;
rN=1500;
c0=2051;
cN=3400;

% Read in data of arcs and coordinates of all the PS points
num_PS=13920;   % total number of all PS points
num_Arcs=40122; % total number of all arcs
XY=freadbk('F:\Phoniex\PS_Points\27by15KM\updated\PSCoor_new.dat', num_PS, 'uint16');      % PS coordinates
Arcs=freadbk('F:\Phoniex\PS_Points\27by15KM\updated\PSArcs_new.dat', num_Arcs, 'uint32');   % PS arcs
X=XY(:,1)-c0+1;                % vector of PS coordinates in range dimension (i.e., columns)
Y=XY(:,2)-r0+1;                 % vector of PS coordinates in azimuth dimension (i.e., rows)
                                          % and convert coordinates into local frame [1:1350, 1:750]
III=(X-1)*(rN-r0+1)+Y;        % get the matrix index for all PS points
clear X Y;

% Read in weights along all arcs (weights were computed by function "dvddharcs")
dvddh=freadbk('F:\Phoniex\PS_Points\27by15KM\updated\dvddh_new.dat', num_Arcs, 'float32');   % dv, ddh, weight
wei=dvddh(:,3);   % get weights for all arcs
clear dvddh;

% read in velocity field and DEM errors at all PS points 
temp=load('F:\Phoniex\PS_Points\27by15KM\updated\XYV.dat');
V=temp(:,3);  % get Velocity at all PS points
temp=load('F:\Phoniex\PS_Points\27by15KM\updated\XY_dH.dat');
dH=temp(:,3); % get dH at all PS points
clear temp;

% % Check by plotting the network after removing both some arcs and PS points 
% figure; set(gcf, 'Position', [1 33 1024 657]);
% hold on; axis image;
% for i=1:num_Arcs
%         plot(XY(Arcs(i, :), 1), XY(Arcs(i, :), 2), 'k-');
% end
% set(gca, 'XLim', [c0, cN], 'YLim', [r0, rN]);
% box on; hold off

% open text file including filenames of num_intf differential interferograms   
fid= fopen(infile, 'rt');
if (fid<0) error(ferror(fid1)); end;
% read some basic information about image dimension and PS
num_intf=fscanf(fid, '%i', 1);    % num_tinf=total number of differential interferograms
rows=fscanf(fid, '%i', 1);          % rows=total number of rows of the entire interferogram
cols=fscanf(fid, '%i', 1);           % cols=total number of columns of the entire interferogram                                   
temp=fscanf(fid, '%i', 1);          % skipping
Dirt=fscanf(fid, '\n%s', 1);        % file directory of interferograms
clear temp;
disp(' ');
disp(['% Total number of all differential interferograms to be processed == ', num2str(num_intf)]);
disp(['    The file directory of storing all differential interferograms == ', Dirt]);

disp(' ');
disp('% Please wait ...... Computing residual phases and unwrapping with weighted LS ......');

% Prepare the information of nodes (PS points) related to any PS point
maxN=18;     % Initialize the maximum number of PS points related to any PS point
% for i=1:num_PS      % look for the maximum number of PS points connected to a PS 
%     II=find(Arcs(:,1)==i);                        % look for arcs connected with No.i PS
%     JJ=find(Arcs(:,2)==i);
%     pq=[Arcs(II,2); Arcs(JJ,1)];              % get the involded PS points related to No.i PS
%     n=length(pq);                                   % get the total number of PS points related No.i PS
%     if n>maxN
%         maxN=n;
%     end
% end
% clear II JJ pq n;

PQD=zeros(num_PS, 2*maxN+1);          % initialize the matrix storing the numbers of PS points and arcs related to any PS point 
B=spalloc(num_PS, num_PS-1, (maxN+1)*num_PS);    % initialize the design matrix for LS phase unwrapping
% Look for PS points related to any PS point,
% And form the design matrix B for LS phase unwrapping 
for i=1:num_PS     
    II=find(Arcs(:,1)==i);                         % look for arcs connected with No.i PS
    JJ=find(Arcs(:,2)==i);
    D=[II', JJ'];                                         % get indexes of arcs related to No.i PS
    pq=[Arcs(II,2)', Arcs(JJ,1)'];              % get the involded PS points related to No.i PS
    n=length(pq);                                    % get the total number of PS points related No.i PS
    PQD(i,1)=n;
    PQD(i,2:n+1)=pq;                             % get PS points related No.i PS
    PQD(i,n+2:2*n+1)=D;                      % get arcs related No.i PS
    if i~=1
        B(i,i-1)=-sum(wei(D));
    end
    for j=1:n
        m=pq(j);
        if m>1
            B(i, m-1)=wei(D(j));
        end
    end
end
clear II JJ pq D n m i j;

% Do phase unwrapping by LS method for each residual interferogram
Lamda=56;   % ERS C-band radar wavelength in mm
K1=4*pi/Lamda;                % Constant 1
unwall=zeros(num_PS, num_intf);     % initialize matrix for storing unwrapped-phase data
for m=1:num_intf         % loop on all interferograms
    disp(' ');
    disp(['% Working on No.', num2str(m), ' differential interferogram ......']);
    filenm=fscanf(fid, '\n%s', 1);
    str=[Dirt, filenm];
    disp(['           Reading differential interferogram: ', str]);
    ph=freadbk(str, rows, 'float32', r0, rN, c0, cN);         % read a part of differential interferogram phase data
    intph=ph(III);                          % extract the original differential phase data of all PS points
    clear ph;
    master=filenm(1:8);              % get master name
    slave=filenm(10:17);             % get slave name
    dT=(datenum(slave, 'yyyymmdd')-datenum(master, 'yyyymmdd'))/365;    % time interval in years between master and slave image
      
    disp('           Computing interferometric parameters and subtracting phase trend');
    [thi, Rg, Bperp]=basecomp(XY(:,2), XY(:,1), str2num(master), str2num(slave));   
    coef_v=K1*dT;                                             % Coefficient for range displacement, which is same for all pixels
    coef_dh=K1*1000*Bperp./(Rg.*sin(thi));     % Coefficient for height error, which is varying pixel by pixel
    phi=coef_v*V+coef_dh.*dH;                         % Calculate the absolute phase due to linear velocity and DEM error
    j=sqrt(-1);
    Res=angle(exp(j*intph).*conj(exp(j*phi)));   % removing the deterministic parts related to linear deformation rates and DEM errors
    clear thi Rg Bperp coef_v coef_dh phi intph; 
    
    % Do phase unwrapping in TIN by a weighted LS method
    disp('           Unwrapping the residual phases at all PS points by a weighted LS method');
    L=zeros(num_PS, 1);                            % initialize the constant vector
    for i=1:num_PS       % form constant vector L
        L(i)=0;
        n=PQD(i,1);                                % get the total number of PS points related No.i PS
        pq=PQD(i,2:n+1);                       % get PS points related No.i PS
        D=PQD(i,n+2:2*n+1);                % get arcs related No.i PS
        if i==1
            L(i)=L(i)+sum(wei(D)*Res(1));
        end
        for j=1:n
            mm=pq(j);
            if mm==1
                L(i)=L(i)+wei(D(j))*wrap(Res(mm)-Res(i))-wei(D(j))*Res(1);
            else
                L(i)=L(i)+wei(D(j))*wrap(Res(mm)-Res(i));
            end
        end
    end
    clear pq D n mm i j;
    % Forming normal equation ...
    N=B'*B;
    w=B'*L;
    % Solving unknowns with sparse normal equations ...
    unw_x=N\w;                              % don't use function "inv", because it will be extremely slow or out of memory.
    unw_x=[Res(1); unw_x];   % include the strat point
    % Post-processing of LS unwrapping: congruence process
    [minD, unw_xc]=congruencePS(PQD, unw_x, Res);
    unwall(:,m)=unw_xc;
    clear N w unw_x unw_xc
end

fclose(fid);

disp(' ');
disp(['% CPU time used for the whole processing == ', num2str(cputime-cput0)]);
disp(' ');
   








