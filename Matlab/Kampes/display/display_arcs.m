% plotting arcs
%num_PS=20169;
%num_Arcs=60440;
%num_PS=14799;
%num_Arcs=44333;
num_PS=14618;
num_Arcs=43561;
r0=751;
c0=2051;
Width=1350;
Height=750;

% first, read in the coordinates of all PS points
%infile='F:\Phoniex\PS_Points\test\PSCoor.dat';
infile='F:\Phoniex\PS_Points\27by15KM\updated\PSCoor.dat';
PSCoor=freadbk(infile, num_PS, 'uint16');          
% second, read in PSArcs.dat
%infile='F:\Phoniex\PS_Points\test\PSArcs.dat';
infile='F:\Phoniex\PS_Points\27by15KM\updated\PSArcs.dat';
ARC_PS=freadbk(infile, num_Arcs, 'uint32');
% third, read in dv, ddh and coherence of each arc
infile='F:\Phoniex\PS_Points\27by15KM\updated\dvddh_all.dat';
dvddh=freadbk(infile, num_Arcs, 'float32');
thsld=0.6;       % coherence threshold
%dvddh=ones(num_Arcs,3);

X=PSCoor(:, 1)-c0+1;
Y=PSCoor(:, 2)-r0+1;
X=Width-X+1;       % flip horizontally
Y=Height-Y+1;       % flip vertically

% % delete the arcs with geometric length larger than 1 km
% PN=ARC_PS;
% XYPS1=[X(PN(:, 1)), Y(PN(:, 1))];                        % coordinate of starting point at arc
% XYPS2=[X(PN(:, 2)), Y(PN(:, 2))];                        % coordinate of ending point at arc
% ArcDist=(sum((XYPS1-XYPS2).^2, 2).^0.5)*20;      % caculate Euclidean distance, 1-pixel unit == 20 m
% II=find(ArcDist<=1000);                                      % look for short arcs with distance less than 1000 m
% Arcs=PN(II,:);                                                        % update the arc list by cleaning up long-distance arcs     
% % delete the PS points due to arc removal
% PNTS=[Arcs(:,1); Arcs(:,2)];
% PNTS=unique(sort(PNTS));                                 % sort point number and remove repeated ones
Arcs=ARC_PS;
clear ARC_PS PSCoor;
II=find(dvddh(:,3)>=thsld);

figure; hold on;
set(gcf, 'Position', [1 33 1024 657]);
for i=1:length(Arcs(:,1))
    %if dvddh(i,3)<thsld
    if dvddh(i,3)>=thsld
%         plot(X(Arcs(i, :)), Y(Arcs(i, :)), 'k-');
%     else
        plot(X(Arcs(i, :)), Y(Arcs(i, :)), 'b-');
    end
end
%if num_PS<=35
%    for i=1:num_PS
plot(X(1), Y(1), 'r+');
text(X(1), Y(1)-20, num2str(1), 'FontSize', 11, 'Color', 'r',  'FontName', 'Times New Roman');
  %  end
%end
%title('Blue arcs with coh >=0.45; but red arcs with coh <0.45');
title('PS-Based Arcs with Length less than 1 km', 'FontName', 'Arial', 'FontSize', 13.5);
set(gca, 'XLim', [0 Width+10]);
set(gca, 'YLim', [-10 Height+10]);
%set(gca, 'XLim', [0 1350]);
set(gca, 'XTick', [0:50:Width-10]);
%set(gca, 'YLim', [0 750]);
set(gca, 'YTick', [0:50:Height-10]);

xlabel('27 km','FontSize', 11, 'FontName', 'Times New Roman'); 
ylabel('15 km','FontSize', 11, 'FontName', 'Times New Roman');

str=['Total PS points == ', num2str(num_PS)];
text(60, 180, str, 'FontSize', 12, 'Color', 'k',  'FontName', 'Times New Roman');
str=['Total arcs < 1km == ', num2str(num_Arcs)];
text(60, 130, str, 'FontSize', 12, 'Color', 'k',  'FontName', 'Times New Roman');
str=['Total arcs in blue with coh>=', num2str(thsld), ' == ', num2str(length(II))];
text(60, 100, str, 'FontSize', 12, 'Color', 'b',  'FontName', 'Times New Roman');
% str=['Total arcs in black with coh<', num2str(thsld), ' == ', num2str(num_Arcs-length(II))];
% text(60, 70, str, 'FontSize', 12, 'Color', 'k',  'FontName', 'Times New Roman');

box on;
hold off;

clear X Y i r0 c0 infile PN II
    