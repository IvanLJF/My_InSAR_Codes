% Testing LS Phase Unwrapping

% Simulate phase data
N=256;
% beta=10.5;
% absphi=3200*fracsurf(N, beta);   % Generating a phase surface with a fractal tool
%                                                    % Unit of phase is radians
% wphi=wrap(absphi+randn(size(absphi))*0.5);                      % wrapping operation and converting in [-pi pi)

% read in the phase dataset simulated as above
wphi=freadbk('D:\SBAS\MatlabCode\PSUnw\wphi.dat', 256, 'float32');   % wrapped image
absphi=freadbk('D:\SBAS\MatlabCode\PSUnw\absphi.dat', 256, 'float32');   % wrapped image

% Extract the wrapped phase data at discrete PS points
num_PS=5000;                       % Total number of discrete points
XY=[1+round(rand(num_PS, 1)*(N-1)), 1+round(rand(num_PS,1)*(N-1))];  % Image coordinate, column and row
XY=unique(XY, 'rows');            % remove duplication
num_PS=length(XY(:,1));        % Final total number of PS points without duplication

% Generate triangular irregular network (TIN)
TRI=delaunay(XY(:,1), XY(:,2));           % Generating triangles with XY
[num_TRI, C]=size(TRI);
% % plot both the wrapped-phase data and TIN
% figure; set(gcf, 'Position', [1 33 1024 657]);
% imagesc(wphi); colormap(jet); colorbar('horiz'); axis image;
%  title('Wrapped phases and original TIN');
% hold on; triplot(TRI, XY(:,1), XY(:,2), 'k'); hold off

% Extract all the arcs in the TIN
arc=[TRI(:,1), TRI(:,2); TRI(:,1), TRI(:,3); TRI(:,2), TRI(:,3)];
% removing arc duplication
arc=sort(arc, 2);                    % sorting along row dimension
arc=sortrows(arc, 2);            % sorting along the second-column ascending order
arc=sortrows(arc, 1);            % sorting along the first-column ascending order
Arcs=unique(arc, 'rows');      % removing the row-along repetitions
[num_Arcs, C]=size(Arcs);    % total number of arcs
clear arc C;

% Delete the arcs with geometric length larger than 300 m 
% and update the total number of remaining arcs
X=XY(:, 1);
Y=XY(:, 2);
PN=Arcs;
clear Arcs;
XYPS1=[X(PN(:, 1)), Y(PN(:, 1))];                          % coordinate of starting point at arc
XYPS2=[X(PN(:, 2)), Y(PN(:, 2))];                          % coordinate of ending point at arc
ArcDist=(sum((XYPS1-XYPS2).^2, 2).^0.5)*20;    % caculate Euclidean distance, 1-pixel unit == 20 m
II=find(ArcDist<=300);                                            % look for short arcs with distance less than 300 m
Arcs=PN(II,:);                                                          % get the reamining valid arcs
num_Arcs=length(Arcs);                                        % update the total number of valid arcs
clear X Y PN XYPS1 XYPS2 ArcDist II;
wei=ones(num_Arcs, 1);                                        % set weights for all arcs as 1          

% Remove non-useful PS points and update the total number of remaining PS points
PSNO=[Arcs(:,1); Arcs(:,2)];                    % extract point numbers with duplication
PSNO=sort(PSNO);                                 % sort point numbers
PSNO=unique(PSNO);                             % remove duplication
PSCoor=XY(PSNO, :);                              % extract the coordiantes of the valid PS points
num_PS=length(PSNO);                          % update total number of PS points
for i=1:num_Arcs                                       % update point number in the valid Arcs                                 
    start_Indx=find(PSNO==Arcs(i,1));
    end_Indx=find(PSNO==Arcs(i,2));
    Arcs(i,1)=start_Indx;
    Arcs(i,2)=end_Indx;
end
clear XY PSNO start_Indx end_Indx;
XY=PSCoor;                                               % update the pixel coordinates at the valid PS points
clear PSCoor;

% Get unwrapped and wrapped phase data at all the valid PS points
absphi_PS=zeros(num_PS,1);    % initialize a vector to store unwrapped phases
wphi_PS=zeros(num_PS,1);       % initialize a vector to store wrapped phases
for i=1:num_PS
    absphi_PS(i)=absphi(XY(i,1), XY(i,2));
    wphi_PS(i)=wphi(XY(i,1), XY(i,2));
end

% % Check by plotting the network after removing both some arcs and PS points 
figure; set(gcf, 'Position', [1 33 1024 657]);
imagesc(wphi); colormap(jet); colorbar('horiz'); axis image;  
title('Wrapped phases and reduced TIN');
hold on;
for i=1:num_Arcs
        plot(XY(Arcs(i, :), 1), XY(Arcs(i, :), 2), 'k-');
end
box on; hold off

% Summary of input data for LS phase unwrapping
% absphi        --- unwrapped phase
% wphi           --- wrapped phases
% absphi_PS --- unwrapped phases at PS points
% wphi_PS    ---- wrapped phases at PS points
% num_PS    --- total number of PS points
% num_TRI   --- total number of all triangles in TIN
% num_Arcs --- total number of all the arcs in TIN
% XY             --- pixel coodinates of all PS points
% Arcs          --- all arcs in TIN

% unknowns: (num_PS-1)-by-1 unwrapped-phase values
%                   (the unwrapped phase at No.1 PS point is fixed to 0)

% Do phase unwrapping by LS method for all PS points
 unw_xc=pslsunw(num_PS, Arcs, wphi_PS, wei);
 
 % Calibrate the unwrapped phases by
 unw_xc=unw_xc-mean(unw_xc-absphi_PS);
 
 % Plotting difference between the known and computed phases in absolute
 % sense
 figure; set(gcf, 'Position', [1 33 1024 657]);
 subplot(3,1,1);
 plot(unw_xc);
 set(gca, 'YLim', [-15 11]);
 title('Unwrapped phases at PS: unw\_xc');
 subplot(3,1,2);
 plot(absphi_PS);
 set(gca, 'YLim', [-15 11]);
 title('Known absolute phases at PS: absphi\_PS');
 subplot(3,1,3)
 plot(unw_xc-absphi_PS);
 title('Difference between unw\_xc and absphi\_PS');


 