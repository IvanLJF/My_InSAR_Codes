function [V_PS, H_PS, XY, TRI, Arcs, dv_ddh]=Solution_ne(V, H, DifInt, dT, B, M);
% Solution of deformation rates and height errors
% Input
% V=Gridded velocity values (matrix)
% H=Gridded elevation values (matrix)
% DifInt=Gridded differential phase values (matrix)
% dT=Time separations for all interferograms (vector)
% B=Perpendicular-baseline values for all interferograms (vector)
% M=The total number of interferograms
%
% Output
% V_PS=Deformation velocity at all PS points
% H_PS=Height error at all PS points
% XY=Coordinates of all PS points
% TRI=Vertex information of all triangles
% ARCs=All final arcs without arc duplication
% dv_ddh=Increments of velocity and height error along arcs

% Simulating discrete points to be estimated
N=64;         % Matrix dimension of interferogram=N by N
num_PS=35;    % Total number of discrete points
XY=[1+round(rand(num_PS, 1)*(N-1)), 1+round(rand(num_PS,1)*(N-1))];  % Image coordinate, column and row
XY=unique(XY, 'rows');   % remove duplication
num_PS=length(XY(:,1));    % Final total number of PS points without duplication
disp(' ');
disp(['% Total number of all PS points == ', num2str(num_PS)]);
%infile='F:\Phoniex\PS_Points\test\simulation\PSCoor.dat';
%[pathstr, name] = fileparts(infile);
%fwritebk(XY, infile, 'uint16');          % saving PS coordinates
%disp(['% Saving coordinates of all PS points into ', infile, ', OK!']);

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
dv_ddh=zeros(num_Arcs, 3);   % initialize variable
GB_arc=ones(num_Arcs, 1);            % flag of goodness or badness for solution along each arc
for i=1:num_Arcs    % loop on all arcs
    PS1=Arcs(i, 1);
    PS2=Arcs(i, 2);
    x1=XY(PS1, 1);    % column coordinate
    y1=XY(PS1, 2);    % row coordinate
    x2=XY(PS2, 1);
    y2=XY(PS2, 2);
    disp(['% The No.', num2str(i), ' arc being processed ...']);
    disp(['Given dV=', num2str(V(x2,y2)-V(x1, y1)), '     Given dH=' num2str(H(x2,y2)-H(x1, y1))]);
    dv_ddh(i,1)=V(y2,x2)-V(y1, x1);              % for velocity increment
    dv_ddh(i,2)=H(y2,x2)-H(y1, x1);              % for height-error increment
    dv_ddh(i,3)=1;                                          % for model coherence along arc
    disp(' ');
end

%str='dvddh.dat';
%fwritebk(dv_ddh, [pathstr, '\', str], 'float32');        % saving velocity increment and height error increment of each arc
%disp(['% Saving increment solutions into ', pathstr, '\', str, ', OK!']);
disp(' ');
disp('% Non-Noise Processing Summary:');
disp(['   Total number of differential interferograms == ', num2str(M)]);
disp(['   Total number of all PS points == ', num2str(num_PS)]);
disp(['   Total number of all triangles in TIN generated == ', num2str(num_TRI)]);
disp(['   Total number of arcs without duplication == ', num2str(num_Arcs)]);
%disp(['   The total number of arcs with incorrect solution == ', num2str(KK)]);
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

