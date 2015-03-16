% Purpose: display TIN, point number, and all arcs
%
% Description of variables:
%        TRI_PS--------a L-by-3 matrix describing triple vertexes of each triangle in TIN   
%                               L is the total number of triangles
%        ARC_PS--------a NN-by-2 matrix, each row corresponds to the numbers of two neighboring PS points that form an arc.  
%                               NN is the total number of arcs in TIN
%        XY_PS---------a K-by-2 matrix, coodinates of all PS pixels
%
% Original Author:  Guoxiang LIU
% Revision History:
%                   Apr. 2, 2006: Created, Guoxiang LIU
% 
% See also PS_DETECT, PS_TIN

figure;
subplot(1,2,1);      % plot TIN
triplot(TRI_PS, XY_PS(:, 1)', XY_PS(:, 2)');
hold on;
for i=1:length(XY_PS(:, 1))
    text(XY_PS(i, 1), XY_PS(i, 2), num2str(i));
end
hold off

subplot(1,2,2);      % plot arcs
hold on;
X=XY_PS(:, 1)';
Y=XY_PS(:, 2)';
[r, c]=size(ARC_PS);
for i=1:r
    plot(X(ARC_PS(i, :)), Y(ARC_PS(i, :)), 'r-');
end
for i=1:length(XY_PS(:, 1))
    text(XY_PS(i, 1), XY_PS(i, 2), num2str(i));
end
hold off;
clear r c X Y

