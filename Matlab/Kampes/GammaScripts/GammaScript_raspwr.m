% Generating Gamma script for generating BMP images with interferograms and
% intensity images

fid1=fopen('E:\PhoenixSAR\Dif_Int_MLI\117ints.all', 'rt');
fid2=fopen('F:\PhoenixDif_MLI\GammaScript_raspwr', 'wt');

fprintf(fid2,'%s\n', '#! /bin/csh -fe');
fprintf(fid2,'%s\n', '');
fprintf(fid2,'%s\n', '#########################################################################');
fprintf(fid2,'%s\n', '##### Generate BMP images by superimposing interferogram onto intensity image ######');
fprintf(fid2,'%s\n', '#########################################################################');
fprintf(fid2,'%s\n', '');

num_intf=fscanf(fid1, '%d ', 1);
rows=fscanf(fid1, '%d ', 1);
cols=fscanf(fid1, '%d', 1);
num_PS=fscanf(fid1, '%d', 1);
Dirt=fscanf(fid1, '%s', 1);

for i=1:num_intf
    infile=fscanf(fid1, '%s', 1);
    int_file=[infile(1:28), 'sm'];
    comd=['rasmph_pwr ', int_file, ' SAR_mean ', '3500 1 1 0 1 1 1. .6 -1 ', int_file, '.bmp']; 
    fprintf(fid2, '%s\n', comd);
end
    
fclose(fid1);
fclose(fid2);
    