% Count the PCC hist.
% Written by:
%  T.LI @ ISEIS, 20130703

clear;
clc;

workpath='D:\myfiles\Software\experiment\HPA\sim\';
file=[workpath,'phi_std_0.5'];
fid=fopen(file);
if fid ~= -1
    phistd_pcc=fread(fid, [5000,2],'double');
end;
phistd=phistd_pcc(:, 1);
minx=min(phistd);
maxx=max(phistd);
pcc=phistd_pcc(:, 2);
x=minx:0.1:maxx;

% set the figure.
hist(pcc, x);
set(gca,'FontSize', 12, 'XLim', [0, 1.1],'Color','w');

