%function tli_ls_dvddh
% Solve v and dh using a least square estimation.
clear;
clc;

if 1
    dvddhfile='/mnt/software/myfiles/Software/experiment/TSX_PS_SH_3/HPA/dvddh_update_sort';
    plistfile='/mnt/software/myfiles/Software/experiment/TSX_PS_SH_3/HPA/plistupdate';
    vdhfile='/mnt/software/myfiles/Software/experiment/TSX_PS_SH_3/HPA/vdh';
    weighted=0;
end

if 0
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/HPA/';
    dvddhfile=[workpath,'dvddh'];
    plistfile=[workpath,'plist'];
    vdhfile=[workpath, 'vdh_matlab'];
    weighted=1;
end

if 0
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/';
    dvddhfile=[workpath,'dvddh_update_sort'];
    plistfile=[workpath,'dvddh_update.plist'];
    vdhfile=[workpath, 'vdh_matlab_weighted'];
    weighted=1;
end

% read dvddh file
samples=6;
finfo=dir(dvddhfile);
fsize=finfo.bytes;
lines=fsize/samples/8;
fid=fopen(dvddhfile, 'r');
dvddh=fread(fid, [samples, lines], 'double'); % IDL -> Matlab. Data transpose.
fclose(fid);

% read plist file
samples=2;
finfo=dir(plistfile);
fsize=finfo.bytes;
lines=fsize/samples/4;
fid=fopen(plistfile, 'r');
plist=fread(fid, [samples, lines], 'float'); 
fclose(fid);

% Prepare for LS estimation.
[~, narcs]=size(dvddh);
finfo=dir(plistfile);
fsize=finfo.bytes;
npt=fsize/8;
% Define the line header info of dvddh.
start_ind=dvddh(1, :)+1;  % All the indices from IDL start at 0, not 1.
start_val=zeros(1,narcs)-1;
end_ind=dvddh(2, :)+1;% All the indices from IDL start at 0, not 1.
end_val=zeros(1,narcs)+1;
dv=transpose(dvddh(3, :));
ddh=transpose(dvddh(4, :));
coh=dvddh(5, :)';
sigma=dvddh(6, :)';

% Create the sparse matrix.
lines=1:1:narcs;
i=[lines, lines];
j=[start_ind, end_ind];
s=[start_val, end_val];
coefs=sparse(i,j,s,narcs, npt);

if weighted == 0
    v=coefs\dv;
    dh=coefs\ddh;
else
    
    % weighted LS estimation
    p=sparse(1:narcs, 1:narcs, coh);
    temp=(transpose(coefs)*p*coefs)\(transpose(coefs)*p);
    v=temp*dv;
    dh=temp*ddh;
    
    %     temp=(transpose(coefs)*p*coefs)\(transpose(coefs)*p);
    %     v=temp*dv;
    %     dh=temp*ddh;

end
% Write vdh file.
result=[0:1:npt-1; plist(1,:); plist(2,:); transpose(v);transpose(dh)];
result=double(result);

fid=fopen(vdhfile, 'w');
fwrite(fid, result);
fclose(fid);

tli_write(vdhfile, result,'double');

disp('Main pro finished.')
