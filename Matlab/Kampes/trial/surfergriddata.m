function [Xi,Yi,Zi]=surfergriddata(X,Y,Z,Xi,Yi,method)
% Just like griddata but uses surfer instead. Default kringing
%
% Usage:
% [Xi,Yi,Zi]=surfergriddata(X,Y,Z,Xi,Yi,method) or 
% [Xi,Yi,Zi]=surfergriddata(X,Y,Z) or
% [Zi]=surfergriddata(X,Y,Z,Xi,Yi,method) or
%
% methods:
%   InverseDistance, Kriging(default), MinCurvature, NaturalNeighbor
%   NearestNeighbor, RadialBasis, Regression, Shepards, Triangulation
%
%
% Aslak Grinsted 2006


if nargin<5
    Xi=[];
    Yi=[];
end

if isempty(Xi)
    NumCols=[];
    NumRows=[];
    xMin=[];xMax=[];
    yMin=[];yMax=[];
else
    [msg,X,Y,Z,Xi,Yi] = xyzchk(X,Y,Z,Xi,Yi);
    if ~isempty(msg), error(msg); end
    
    Xi=Xi(1,:);
    Yi=Yi(:,1);
    NumCols=(size(Xi,2));
    NumRows=(size(Yi,1));
    xMin=min(Xi);xMax=max(Xi);
    yMin=min(Yi);yMax=max(Yi);
end


%methods:
srfInverseDistance = 1;
srfKriging = 2;
srfMinCurvature = 3;
srfNaturalNeighbor = 5;
srfNearestNeighbor = 6;
srfRadialBasis = 8;
srfRegression = 7;
srfShepards = 4;
srfTriangulation = 9;
 
 
if nargin>5
    switch lower(method),
        case {'invdist','v4','inversedistance'}, method=srfInverseDistance;
        case 'kriging', method=srfKriging;
        case {'mincurv','mincurvature'}, method=srfMinCurvature;
        case {'natural','naturalneighbor'}, method=srfNaturalNeighbor;
        case {'nearest','nearestneighbor'}, method=srfNearestNeighbor;
        case 'radialbasis', method=srfRadialBasis;
        case 'regression', method=srfRegression;
        case 'shepards', method=srfShepards;
        case {'linear','triangulation'}, method=srfTriangulation;
        otherwise
            error('surfergriddata:UnknownMethod', 'Unknown method.');
    end
else
    method=srfKriging;
end


%some enum values:
srfGridFmtAscii = 2;
srfDupAvg = 15;

 srf=actxserver('surfer.application');

try 
    %txtsave('~surferdata-temp.txt',[X,Y,Z]);
    save('surferdata_temp.txt', 'X','Y','Z', '-ASCII');
    srf.DefaultFilePath = cd;
    

   b= srf.GridData('surferdata_temp.txt', [], [], [], [], ...
       srfDupAvg, [], [], ... %DupMethod, xDupTol, yDupTol, 
       NumCols, NumRows, xMin, xMax, yMin, yMax,...%NumCols, NumRows, xMin, xMax, yMin, yMax,
       srfKriging, 0, [], [], ... % Algorithm, ShowReport, SearchEnable, SearchNumSectors, 
       [], [], [], [], [], [], ... %SearchRad1, SearchRad2, SearchAngle, SearchMinData, SearchDataPerSect, SearchMaxEmpty,
       [], [], [], [],... % FaultFileName, BreakFileName, AnisotropyRatio, AnisotropyAngle, 
       [], [], [], [], [], [], ... %IDPower, IDSmoothing, KrigType, KrigDriftType, KrigStdDevGrid, KrigVariogram, 
       [], [], [], [], [],... %MCMaxResidual, MCMaxIterations, MCInternalTension, MCBoundaryTension, MCRelaxationFactor,
       [], [], [], [], [], ... %ShepSmoothFactor, ShepQuadraticNeighbors, ShepWeightingNeighbors, ShepRange1, ShepRange2, 
       [], [], [], [], [], ... %RegrMaxXOrder, RegrMaxYOrder, RegrMaxTotalOrder, RBBasisType, RBRSquared, 
       'surfergrid_temp.txt', srfGridFmtAscii );    %OutGrid, OutFmt )
    if ~b
        warning('something went wrong in srf.griddata')
    end
    

    delete('surferdata_temp.txt');
catch
    err=lasterror;
    warning(err.message);
end

srf.Quit;
srf.delete;

[Zi,Xi,Yi]=loadsurfergrid('surfergrid_temp.txt');

if nargout==1
    Xi=Zi;
    clear Zi;
end


function [A,x,y]=loadsurfergrid(fname);

fid=fopen(fname,'r');

s=fgetl(fid);
gridsize=fscanf(fid,'%f',2);
mx=fscanf(fid,'%f',2);mx(3)=mx(2)-mx(1);
my=fscanf(fid,'%f',2);my(3)=my(2)-my(1);
hmmm=fscanf(fid,'%f',2);
x=mx(1)+mx(3)*(0:gridsize(1)-1)/(gridsize(1)-1);
y=my(1)+my(3)*(0:gridsize(2)-1)/(gridsize(2)-1);
A=fscanf(fid,'%f',inf);
A=reshape(A,gridsize')';

fclose(fid);
