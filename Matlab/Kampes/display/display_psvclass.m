% display_psvclass
% plot a map of groups of velocities (at PS points) estimated by "dvddgarcs"

% read in coordinates and velocities at PS points (x--y--v)
% XYV=load('F:\Phoniex\PS_Points\27by15KM\updated\XYV.dat');
XYV=load('F:\Phoniex\PS_Points\27by15KM\updated\ints86\XYV_86.dat');
% Given the study area
c0=2051;   cN=3400;    % range dimension
r0=751;      rN=1500;    % azimuth dimension
width=cN-c0+1;            % range width
height=rN-r0+1;             % azimuth height

X=XYV(:,1);                %width-(XYV(:,1)-c0+1)+1;     %  get x-coordinate
Y=XYV(:,2);                %height-(XYV(:,2)-r0+1)+1;     %  get y-coordinate
V=XYV(:,3);                                                                  % get velocities
num_PS=length(X);

figure; 
set(gcf, 'Position', [1  33 1024 657]);
hold on;
for i=1:num_PS
    if V(i)>=20
        h1=plot(X(i), Y(i), '.', 'MarkerSize', 5, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'k');
    elseif V(i)>=16 & V(i)<20
        h2=plot(X(i), Y(i), '.', 'MarkerSize', 5, 'MarkerEdgeColor', 'y', 'MarkerFaceColor', 'k');
    elseif V(i)>=12 & V(i)<16
        h3=plot(X(i), Y(i),'.', 'MarkerSize', 5, 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'k');
    elseif V(i)>=8 & V(i)<12
        h4=plot(X(i), Y(i), '.', 'MarkerSize', 5, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'k');
    else
        h5=plot(X(i), Y(i), '.', 'MarkerSize', 5, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    end
end
legend([h1 h2 h3 h4 h5], '20--54 mm/yr', '16--20 mm/yr', '12--16 mm/yr', '00--12 mm/yr', '00--08 mm/yr', 'Location', 'SouthWest'); 
set(gca, 'XLim', [0 1360], 'YLim', [-10, 760], 'FontSize', 11);
xlabel('27 KM', 'FontSize', 12);
ylabel('15 KM', 'FontSize', 12);
title('Deformation Velocities at PS Points', 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 13.5);
box on;
hold off;



