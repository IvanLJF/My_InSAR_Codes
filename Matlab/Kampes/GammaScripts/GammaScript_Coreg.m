% Generating a Gamma script for co-registering all SAR images onto
% 1996-9-16 SAR image (ERS2)

% the dates when SAR scenes to be co-registered were acquired
dib=[
19920710
19920814
19920918
19921023
19930205
19930521
19930903
19931008
19931217
19950514
19950827
19951105
19951106
19951210
19951211
19960114
19960115
19960218
19960219
19960428
19960603
19960812
19961021
19961125
19961230
19970310
19970519
19971215
19980223
19980330
19980504
19980608
19980713
19981130
19990104
19990315
19990524
19990628
19990802
19991220
20000508
20000717
20000925
20001030]; 

% open a textfile for writing scripts
fid = fopen('F:\Phoniex\images\all_coreg', 'w');
fprintf(fid,'%s\n', '#! /bin/csh -fe');
fprintf(fid,'%s\n', '');
fprintf(fid,'%s\n', '#######################################################');
fprintf(fid,'%s\n', '# Co-Registering All SAR Scenes onto 19960916 ERS2 SAR Scene');
fprintf(fid,'%s\n', '#######################################################');
fprintf(fid,'%s\n', '');

str=strcat('set under=', char(39), '_', char(39));
fprintf(fid,'%s\n', str); clear str;
fprintf(fid,'%s\n', 'set MSP1=19960916'); 
fprintf(fid,'%s\n', 'set ref_slc=/d1/users/liu/slc_phoenix/slcdata/scomplex/19960916.slc');

for i=1:length(dib)
     fprintf(fid,'%s\n', '');
     str=strcat('##########################', num2str(dib(i)), '############################');
     fprintf(fid,'%s\n', str); clear str;
     str=strcat('set MSP2=', num2str(dib(i)));
     fprintf(fid,'%s\n', str); clear str;
     str=strcat('set sec_slc=/d1/users/liu/slc_phoenix/slcdata/scomplex/', num2str(dib(i)), '.slc');
     fprintf(fid,'%s\n', str); clear str;
     fprintf(fid,'%s\n', 'create_offset $MSP1.slc.par $MSP2.slc.par $MSP1$under$MSP2.off 1 1 < input_off_Phoenix');
     fprintf(fid,'%s\n', 'init_offset_orbit $MSP1.slc.par $MSP2.slc.par $MSP1$under$MSP2.off');
     fprintf(fid,'%s\n', 'init_offset $ref_slc $sec_slc $MSP1.slc.par $MSP2.slc.par $MSP1$under$MSP2.off 2 10');
     fprintf(fid,'%s\n', 'init_offset $ref_slc $sec_slc $MSP1.slc.par $MSP2.slc.par $MSP1$under$MSP2.off 1 1');
     fprintf(fid,'%s\n', 'offset_pwr $ref_slc $sec_slc $MSP1.slc.par $MSP2.slc.par $MSP1$under$MSP2.off $MSP1$under$MSP2.offs $MSP1$under$MSP2.snr - - $MSP1$under$MSP2.offsets');
     fprintf(fid,'%s\n', 'offset_fit $MSP1$under$MSP2.offs $MSP1$under$MSP2.snr $MSP1$under$MSP2.off $MSP1$under$MSP2.coffs $MSP1$under$MSP2.coffsets');
     fprintf(fid,'%s\n', 'SLC_interp $sec_slc $MSP1.slc.par $MSP2.slc.par $MSP1$under$MSP2.off $MSP2.rslc $MSP2.rslc.par');
end

fclose(fid);


