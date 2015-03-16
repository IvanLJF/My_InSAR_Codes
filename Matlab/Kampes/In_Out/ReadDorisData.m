% Created by Guoxiang LIU, 2004-10-10

% Functionality: Read and display the DORIS output

% Read and display the complex matrix of SAR image chip
cpxms=freadbk('E:\Doris\doristest.linux\Your_work\1393.raw.linux', 800, 'cpxint16');
figure; imagesc(abs(cpxms));
colormap(gray);

% Read and display the complex matrix of interferogram chip
cint = freadbk('E:\Doris\doristest.linux\Your_work\cint.raw',111,'cpxfloat32');
figure; imagesc(angle(cint)); colormap(jet);

% Read and display the complex matrix of coherence chip
coh = freadbk('E:\Doris\doristest.linux\Your_work\coh.raw',112,'single');
figure; imagesc(coh); colormap(gray);