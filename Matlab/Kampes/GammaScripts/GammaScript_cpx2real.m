% Generating Gamma script for converting complex into real data

fid1=fopen('F:\Phoniex\intf\119ints.dat', 'rt');
fid2=fopen('F:\Phoniex\intf\cpx2phase', 'wt');

fprintf(fid2,'%s\n', '#! /bin/csh -fe');
fprintf(fid2,'%s\n', '');
fprintf(fid2,'%s\n', '#######################################################');
fprintf(fid2,'%s\n', '##### Converting complex interferogram into phase matrix #######');
fprintf(fid2,'%s\n', '#######################################################');
fprintf(fid2,'%s\n', '');

num_intf=fscanf(fid1, '%d ', 1);
rows=fscanf(fid1, '%d ', 1);
cols=fscanf(fid1, '%d', 1);
num_PS=fscanf(fid1, '%d', 1);
Dirt=fscanf(fid1, '%s', 1);

for i=1:num_intf
    intfile=fscanf(fid1, '%s', 1);
    comd=['cpx_to_real ', intfile, '  phase/', intfile, '.ph ', num2str(cols), ' ', num2str(4)]; 
    fprintf(fid2, '%s\n', comd);
end
    
fclose(fid1);
fclose(fid2);
    