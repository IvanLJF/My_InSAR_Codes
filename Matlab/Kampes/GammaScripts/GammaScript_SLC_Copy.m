% Generating Gamma script for cropping SAR images
% Cropping a segment from each SAR image
% with SLC_copy 

% No. of SAR images
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
19960916
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

fid=fopen('F:\Phoniex\Gamma_Scripts\SLC_Crop', 'w');

fprintf(fid,'%s\n', '#! /bin/csh -fe');
fprintf(fid,'%s\n', '');
fprintf(fid,'%s\n', '#######################################################');
fprintf(fid,'%s\n', '# Cropping All SAR Scenes (r0=5000, rN=17000, c0=1, cN=3500)');
fprintf(fid,'%s\n', '#######################################################');
fprintf(fid,'%s\n', '');

for i=1:length(dib)
    str=['SLC_copy ', num2str(dib(i)), '.rslc ', 'ISP_Pars/', num2str(dib(i)), '.rslc.par ', 'cropped/', num2str(dib(i)), '.rcslc ', 'cropped/ISP_Pars/', num2str(dib(i)), '.rcslc.par '];
    str=[str, '4 ', '- ', '0 ', '3500 ', '3000 ', '16000 '];
    fprintf(fid,'%s\n', str);
end

fclose(fid);

clear str fid i dib
    