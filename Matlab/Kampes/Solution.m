function [V_PS, H_PS, XY, TRI, Arcs, dv_ddh]=Solution(V, H, DifInt, dT, B, M, N, num_PS, XY)
% 解决形变速率和高程误差
% Solution of deformation rates and height errors
% Input
% V=Gridded velocity values (matrix)
% H=Gridded elevation values (matrix)
% DifInt=Gridded differential phase values (matrix)
% dT=Time separations for all interferograms (vector)
% B=Perpendicular-baseline values for all interferograms (vector)
% M=The total number of interferograms
% N=Square-image size
% num_PS=Total number of PS points
% XY=Coordinates of PS Points
%
% Output
% V_PS=Deformation velocity at all PS points
% H_PS=Height error at all PS points
% XY=Coordinates of all PS points
% TRI=Vertex information of all triangles
% Arcs=All final arcs without arc duplication
% dv_ddh=Increments of velocity and height error along arcs

% Simulating discrete points to be estimated
%infile='F:\Phoniex\PS_Points\test\simulation\PSCoor.dat';
%[pathstr, name] = fileparts(infile);
%fwritebk(XY, infile, 'uint16');          % saving PS coordinates
%disp(['% Saving coordinates of all PS points into ', infile, ', OK!']);

% Simulating discrete points to be estimated
%N=64;         % Matrix dimension of interferogram=N by N
%num_PS=50;    % Total number of discrete points
%XY=[1+round(rand(num_PS, 1)*(N-1)), 1+round(rand(num_PS,1)*(N-1))];  % Image coordinate, column and row
%XY=unique(XY, 'rows');   % remove duplication
%num_PS=length(XY(:,1));    % Final total number of PS points without duplication
%disp(' ');
%disp(['% Total number of all PS points == ', num2str(num_PS)]);

% Extracting deformation velocity and and height error at all PS points
IJ=(XY(:,1)-1)*N+XY(:,2);       % calculate the index (in matrix) of PS point
V_PS=V(IJ);          
H_PS=H(IJ);

disp(' ');
disp('% Generating TIN with all PS points ......');
TRI=delaunay(XY(:,1), XY(:,2));           % Generating triangles with XY
[num_TRI, C]=size(TRI);
disp(['% Total number of all triangles in TIN generated == ', num2str(num_TRI)]);
%str='PSTIN.dat';
%fwritebk(TRI, [pathstr, '\', str], 'uint32');        % saving vertex information of all triangles
%disp(['% Saving all TINs into ', pathstr, '\', str, ', OK!']);

disp(' ');
disp('% Generating all possible arcs with TIN ......');
% forming initial arcs with duplication
arc=[TRI(:,1), TRI(:,2); TRI(:,1), TRI(:,3); TRI(:,2), TRI(:,3)];
% removing arc duplication
arc=sort(arc, 2);              % sorting along row dimension
arc=sortrows(arc, 2);      % sorting along the second-column ascending order
arc=sortrows(arc, 1);      % sorting along the first-column ascending order
Arcs=unique(arc, 'rows');     % removing the row-along repetitions
[num_Arcs, c]=size(Arcs);           % total number of arcs
clear arc c;
disp(['% Total number of arcs without duplication == ', num2str(num_Arcs)]);
%str='PSArcs.dat';
%fwritebk(ARCs, [pathstr, '\', str], 'uint32');
%disp(['% Saving all final arcs without arc duplication into ', pathstr, '\', str, ', OK!']);

disp(' ');
disp('% Computing velocity and height-error increments along arcs ......');
% Some interferometric parameters
Lamda=56;   % ERS C-band radar wavelength in mm
R0=850000;      % mid-range in meters
thita=23;            % ERS radar loook angle in degree
L1=4*pi/Lamda;                % Constant 1
L2=R0*sin(thita*pi/180);   % Constant 2
j=1i;                                   % for complex value 

dv_ddh=zeros(num_Arcs, 3);   % initialize variable
options=optimset('Display','off');   % set up optimization without any display
options = optimset(options, 'TolFun',1e-8);
%options = optimset(options,'Display','iter');
options = optimset(options,'TolX', 1e-5);
%options = optimset(options,'Diagnostics', 'on');
%options = optimset(options, 'GradConstr', 'on'); %, 'Jacobian', 'on');
options = optimset(options, 'DiffMaxChange', 0.0001);
%options = optimset(options, 'NodeSearchStrategy', 'df'); 

warning  off   %('OFF', 'MSGID');           % disable and enable the display of any warning tagged with message identifier MSGID
KK=0;            % counter of fail number 
GB_arc=ones(num_Arcs, 1);            % flag of goodness or badness for solution along each arc
dv_low=-0.2;          % mm/day; for velocity increment
dv_up=0.2;
ddh_low=-20;        % in meters, for height-error increment
ddh_up=20;
dv_size=100;        % grid size for searching solution
ddh_size=100;
dv_inc=(dv_up-dv_low)/(dv_size-1);            % get tiny velocity increment corresponding to each grid size
ddh_inc=(ddh_up-ddh_low)/(ddh_size-1);     % get tiny height-error increment corresponding to each grid size
dv_try=[dv_low:dv_inc:dv_up];                   % all possible veclocity increments at all grid points
ddh_try=[ddh_low:ddh_inc:ddh_up];          % all possible height-error increments at all grid points
y=zeros(dv_size*ddh_size,1);                         
[DV, DDH]=meshgrid(dv_try, ddh_try);            
Xdv=reshape(DV, prod(size(DV)), 1);
Xddh=reshape(DDH, prod(size(DDH)), 1);

for i=1:num_Arcs    % loop on all arcs
    t0=cputime;
    PS1=Arcs(i, 1);
    PS2=Arcs(i, 2);
    x1=XY(PS1, 1);    % column coordinate
    y1=XY(PS1, 2);    % row coordinate
    x2=XY(PS2, 1);
    y2=XY(PS2, 2);
    str=[];
    str1=[];
    disp(['% The No.', num2str(i), ' arc being processed ...']);
    for k=1:M    % for M interferograms
        dpm=DifInt(y2, x2, k)-DifInt(y1, x1, k);   % Phase increament from differential interferogram along arc (wrapped phase in radians)
        dpc=L1*dT(k);                                       % Coefficient for deformation
        dph=L1*1000*B(k)/L2;                          % Coefficient for height error
        str=[str '+exp(j*(' num2str(dpm, 6) '-(' num2str(dpc, 8) '*x' '+' num2str(dph, 8) '*y)))'];
        str1=[str1 '+exp(j*(' num2str(dpm, 6) '-(' num2str(dpc, 8) '*x(1)' '+' num2str(dph, 8) '*x(2))))'];
    end
    %str=[num2str(M) '/abs(' str ')'];
    str=['abs(', str, ')/', num2str(M)];
    fun=inline(str);    % fomring a objective function
    y=feval(fun, Xdv, Xddh);
    [coh_max, II]=max(y);
    tt(1)=Xdv(II);
    tt(2)=Xddh(II);
   %disp(['coh value == ', num2str(y)]);
    str1=['-abs(', str1, ')/', num2str(M)];
    fun=inline(str1); 
    %[x, coh]=fmincon(fun, [0; 0], [], [], [], [], [-0.2; -20], [0.2; 20]);
    [x, coh]=fmincon(fun, [tt(1); tt(2)], [], [], [], [], [-dv_inc+tt(1); -ddh_inc+tt(2)], [dv_inc+tt(1); ddh_inc+tt(2)], [], options);
    %fmincon(fun, [0; 0], [], [], [], [], [-0.1; -30], [0.1; 30], [], options);
     %disp(['Optimization exit flag == ', num2str(flag)]);
    %if abs(coh)<0.6
    %    coh=0;
    %end
    dv_ddh(i,1)=x(1);
    dv_ddh(i,2)=x(2);
    dv_ddh(i,3)=abs(coh_max);
    
    figure; surf(DV, DDH, reshape(y, dv_size, ddh_size)); shading interp
    title('Example: Surface of Model Coherence, Simulated Data');
    xlabel('Velocity increment (mm/day)');
    ylabel('Height-error increment (m)');
    zlabel('Model-coherence value');

    %%%% Important: the solution of difference of height erros along an arc is not very
    %%%% stable because InSAR is inherently insensitive to topographic relief.
    %%%% This means that estimating the exact height errors on PS becomes difficult.
    %%%% So, an accurate DEM is a prerquirement for perfect interferometric analysis.
    disp(['Solved dV=', num2str(x(1)), '    Solved dH=', num2str(x(2)), '    Model coherence=', num2str(abs(coh_max))]);
    disp(['Given dV=', num2str(V(y2,x2)-V(y1, x1)), '     Given dH=' num2str(H(y2,x2)-H(y1, x1))]);
    disp(['Total CPU time used for the processing:  ', num2str(cputime-t0), ' seconds.']);
    disp(' ');
    if abs(coh_max)<0.7
        KK=KK+1;
        GB_arc(i)=-1;
    end
end

%str='dvddh.dat';
%fwritebk(dv_ddh, [pathstr, '\', str], 'float32');        % saving velocity increment and height error increment of each arc
%disp(['% Saving increment solutions into ', pathstr, '\', str, ', OK!']);
disp('% Processing Summary:');
disp(['   Total number of differential interferograms == ', num2str(M)]);
disp(['   Total number of all PS points == ', num2str(num_PS)]);
disp(['   Total number of all triangles in TIN generated == ', num2str(num_TRI)]);
disp(['   Total number of arcs without duplication == ', num2str(num_Arcs)]);
disp(['   The total number of arcs with incorrect solution == ', num2str(KK)]);
x1=XY(Arcs(1, 1), 1);     % column coordinate
y1=XY(Arcs(1, 1), 2);     % row coordinate
disp(['   No.# of the first node of the first arc == ', num2str(Arcs(1, 1)), ';     V == ', num2str(V(y1, x1)), ';     H == ', num2str(H(y1, x1))]);
disp(' ');
warning on;

% plotting
displaycmp(TRI, XY, Arcs, GB_arc);

function displaycmp(TRI_PS, XY_PS, ARC_PS, GBArc);
    figure;
    set(gcf, 'Position', [5   145  1016    425]);
    subplot(1,2,1);      % plot TIN
    triplot(TRI_PS, XY_PS(:, 1)', XY_PS(:, 2)');
    hold on;
    if length(XY_PS(:, 1))<=35
        hold on;
        for i=1:length(XY_PS(:, 1))
             text(XY_PS(i, 1), XY_PS(i, 2), num2str(i));
        end
    end
    set(gca, 'XLim', [0 65]);
    set(gca, 'YLim', [0 65]);
    title('Plotted with TIN Information');
    box on;
    hold off

    subplot(1,2,2);      % plot arcs
    hold on;
    X=XY_PS(:, 1)';
    Y=XY_PS(:, 2)';
    [r, c]=size(ARC_PS);
    for i=1:r
        if GBArc(i)==-1
             plot(X(ARC_PS(i, :)), Y(ARC_PS(i, :)), 'r-');
        else 
            plot(X(ARC_PS(i, :)), Y(ARC_PS(i, :)), 'b-');
        end
    end
    if length(XY_PS(:, 1))<=35
        for i=1:length(XY_PS(:, 1))
            text(XY_PS(i, 1), XY_PS(i, 2), num2str(i));
        end
    end
    set(gca, 'XLim', [0 65]);
    set(gca, 'YLim', [0 65]);
    title('Plotted with Non-Repeated Arc Information');
    box on;
    hold off;

