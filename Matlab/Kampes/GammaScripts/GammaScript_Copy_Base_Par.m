% Generating Gamma scripts for copying baseline- and ISP-parameter files for Phoenix

Int_Pairs=load('F:\Phoniex\SB\Pair_Dates_SB_120m.dat');    % loading interferometric pairs with 
                                                                                                   % acquistion dates, temporal and spatial baselines
[R, C]=size(Int_Pairs);
fid=fopen('F:\Phoniex\Scripts\cp_bae_par', 'wt');    % output file of Gamma commonds for copying baseline- and ISP-parameter files 

fprintf(fid,'%s\n', '#! /bin/csh -fe');
fprintf(fid,'%s\n', '');
fprintf(fid,'%s\n', '#######################################################');
fprintf(fid,'%s\n', '# Copy Baseline- and ISP-Parameter Files');
fprintf(fid,'%s\n', '#######################################################');
fprintf(fid,'%s\n', '');

fprintf(fid, '%s\n', 'cd /d1/users/liu/PhoenixDIF');
for i=1:R
    str=['set B = `basename_smb ', num2str(Int_Pairs(i,1)), ' ', num2str(Int_Pairs(i,2))];
    fprintf(fid,'%s\n', str);
    fprintf(fid,'%s\n', 'cd $B');
    str=['cp ',  num2str(Int_Pairs(i,1)), '_', num2str(Int_Pairs(i,2)), '.base', 
    fprintf(fid, '%s\n', 'cp
    fprintf(fid,'%s\n', 'cd ..');
    
set B = `basename_smb $MSP1 $MSP2`
mkdir $B
cd $B
    
    fid1=fopen('F:\Phoniex\Scripts\DIF_PRO_Templet', 'r');
    str=strcat('F:\Phoniex\Scripts\All_Diff\Dif_', num2str(Int_Pairs(i,1)), '_', num2str(Int_Pairs(i,2)));
    fid2=fopen(str, 'w');
    clear str;
    
    str=strcat('Dif_', num2str(Int_Pairs(i,1)), '_', num2str(Int_Pairs(i,2)));
    fprintf(fid, '%s\n', str); 
    clear str;
    
    while 1
       tline = fgetl(fid1);
       if tline==-1
          break;
       end
       if strcmp(tline, 'set MSP1=????????')==1
           str=strcat('set MSP1=', num2str(Int_Pairs(i,1)));
           fprintf(fid2, '%s\n', str); 
           clear str tline;
       elseif  strcmp(tline, 'set MSP2=????????')==1
           str=strcat('set MSP2=', num2str(Int_Pairs(i,2)));
           fprintf(fid2, '%s\n', str);
           clear str tline;
       else
           fprintf(fid2, '%s\n', tline);
           clear tline;
       end
    end
    
    fclose(fid1);
    fclose(fid2);
end

fclose(fid);

clear R C i fid1 fid2 tline