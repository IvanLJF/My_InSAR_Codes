function [TRI_PS, ARC_PS] = PS_TIN(infile, numlines);
%  [TRI_PS, ARC_PS] = PS_TIN(infile, numlines);
% 
% This function is used to form a  triangular irregular network with all
% permannent scatters (PS). The coding matrix for each triangular arc is 
% also generated.
% 
% Input:
%        infile------------file name storing the matrix of amplitude dispersion index (ADI) 
%        numlines------total number of rows of the ADI matrix
%
% Output:
%        TRI_PS--------a L-by-3 matrix describing triple vertexes of each triangle in TIN   
%                               L is the total number of triangles.
%        Arc_PS--------a NN-by-2 matrix, each row is for codes of two neighboring PS points that form an arc.  
%                               NN is the total number of arcs in TIN.
%
%  e.g.,  [TRI_PS, ARC_PS] = PS_TIN(RowCols, plotyn);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Mar. 8, 2006: Created, Guoxiang LIU
% 
% See also PS_DETECT

t0=cputime;     % the starting time of the operation

% finding out PS candidates
disp(' ');
ADIs=freadbk(infile, numlines, 'float32');
disp('% Finding out all PS candidates ......');
[Row, Col]=find(ADIs<=0.25);   
RowCols=[Row, Col];                 % get coodinates of all PS pixels, a K-by-2 matrix
clear ADIs Row Col; 

% forming TIN will all PS points
disp('% Generating triangular irregular network with PS points ......');
TRI_PS=delaunay(RowCols(:, 1)', RowCols(:, 2)');  
[L, C]=size(TRI_PS);
clear RowCols;
NN=L*3;                       % total number of all possible arcs
arc=zeros(NN, 2);   

cwd = pwd;
cd(tempdir);
pack
cd(cwd)

disp('% Generating all possible arcs with TIN ......');
% forming initial arcs with duplication
arc=[TRI_PS(:,1), TRI_PS(:,2); TRI_PS(:,1), TRI_PS(:,3); TRI_PS(:,2), TRI_PS(:,3)];
arc=sortrows(arc, 2);      % sorting along the second-column ascending order
arc=sortrows(arc, 1);      % sorting along the first-column ascending order

   % removing the duplicated arcs
   temp1=[0, 0; arc];
   temp=diff(temp1,1,1);        % the 1st order difference along the row dimension,
   clear temp1;
   II=temp(:,1)-temp(:,2);
   clear temp;
   JJ=find(II~=0);
   ARC_PS=arc(JJ, :);         % get the all independent arcs
   t=length(JJ);                     % total number of all arcs in TIN

disp(' ');
disp('% Success in generating TIN and arc information!');

%if plotyn=='y'
%      figure;
 %     subplot(1,2,1);      % plot TIN
  %    triplot(TRI_PS, RowCols(:, 1)', RowCols(:, 2)');
      %hold on;
      %for i=1:length(RowCols(:, 1))
      %   text(RowCols(i, 1), RowCols(i, 2), num2str(i));
      %end
      %hold off
      
   %   subplot(1,2,2);      % plot arcs
    %  hold on;
     % X=RowCols(:, 1)';
      %Y=RowCols(:, 2)';
      %for i=1:t
       %   plot(X(ARC_PS(i, :)), Y(ARC_PS(i, :)), 'r-');
      %end
      %hold off;
%end

disp(['% CPU time used for the whole processing == ', cputime-t0]);
                           % the total CPU time used for all computation and plotting

      
      
      
    
 