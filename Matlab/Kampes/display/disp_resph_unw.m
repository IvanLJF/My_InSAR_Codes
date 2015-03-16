function disp_resph_unw(infile);
%  function disp_resph_unw(infile);
%
% Plotting all the residual differential interferograms and their unwrapped versions 
% 
% Input:
%        infile----------------a input text file including filenames of num_intf differential interferograms, e.g.,
%                                    num_intf rows cols num_PS       // num_intf differential interferograms with dimension of rows by cols, 
%                                                                                         // total number of all PS -- num_PS  
%                                    E:\PhoenixSAR\Dif_Int_MLI\        // directory of interferograms  
%                                   19920710_19930521.diff.int2.ph
%                                   19920710_19931008.diff.int2.ph
%                                   ...............
%                                   19991220_20001030.diff.int2.ph   
%
%              
%  e.g., disp_resph_unw('E:\PhoenixSAR\Dif_Int_MLI\117ints.all');
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   May. 10, 2006: Created, Guoxiang LIU

t0=cputime;

% open text file including filenames of num_intf differential interferograms   
fid= fopen(infile, 'rt');
if (fid<0) error(ferror(fid1)); end;
% read some basic information about image dimension and PS
num_intf=fscanf(fid, '%i', 1);    % num_tinf=total number of differential interferograms
rows=fscanf(fid, '%i', 1);          % rows=total number of rows of the entire interferogram
cols=fscanf(fid, '%i', 1);           % cols=total number of columns of the entire interferogram                                   
num_PS=fscanf(fid, '%i', 1);    % num_PS=total number of all PS points               
Dirt=fscanf(fid, '\n%s', 1);        % file directory of interferograms

disp(' ');
disp('% Please wait ...... Plotting data ......');
Dirt='E:\PhoenixSAR\Dif_Int_MLI_LPF\';

for m=1:20 %num_intf         % loop on all residual differential interferograms
    disp(' ');
    disp(['% Working on No.', num2str(m), ' residual differential interferogram and its unwrapped version......']);
    filenm=fscanf(fid, '\n%s', 1);
    master=filenm(1:8);              % get master name
    slave=filenm(10:17);             % get slave name
    
    cd(Dirt);      % change file directory
    %FTRfile=[num2str(master), '_', num2str(slave), '.diff.int2.lpf'];             % filename of residual differential interferogram
    UNWfile=[num2str(master), '_', num2str(slave), '.diff.int2.unw1'];        % filename of unwrapped version
   
    % reading in datasets
    %FltRes=freadbk(FTRfile, 750, 'cpxfloat32');
    unw=freadbk(UNWfile, 750, 'float32');
    
    % plotting them
%     figure; 
%     %subplot(2,1,1);
%     FltRes=fliplr(angle(FltRes));
%     imagesc(FltRes); axis image; %colormap(jet); colorbar;
%     set(gcf, 'Position', [113 133 839 460]);
%     title( [num2str(master), '\_', num2str(slave), '\_RES']);
%     colorbar('horiz', 'Position', [0.25 0.135 0.55 0.035], 'FontSize', 11);
%     %set(gca, 'Position', [0.1 0.12 0.90 0.88]);
%     %h=colorbar('horiz', 'Position',  [0.35 0.2 0.35 0.040], 'FontSize', 11);
%     %set(h, 'XColor',  [1 1 1], 'YColor', [1 1 1]);
%     %set(h, 'XColor',  [1 1 1], 'YColor', [1 1 1]);
%     str=[Dirt, 'FLR_Figs\'];
%     cd(str)
%     saveas(gcf, [num2str(master), '_', num2str(slave), '_RES'], 'emf');
%     close all;
    
    %subplot(2,1,2);
    figure;
    imagesc(fliplr(unw)); axis image; %colormap(jet); colorbar;
    set(gcf, 'Position', [113 133 839 460]);
    title([num2str(master), '\_', num2str(slave), '\_UNW']);
    colorbar('horiz', 'Position', [0.25 0.135 0.55 0.035], 'FontSize', 11);
    %set(gca, 'Position', [0.1 0.12 0.90 0.88]);
    %h=colorbar('horiz', 'Position', [0.35 0.2 0.35 0.040], 'FontSize', 11);
    %set(h, 'XColor',  [1 1 1], 'YColor', [1 1 1]);
    %set(h, 'XColor',  [1 1 1], 'YColor', [1 1 1]);
    str=[Dirt, 'UNW_Figs\'];
    cd(str);
    saveas(gcf, [num2str(master), '_', num2str(slave), '_UNW1'], 'emf');
    close all;
    
end
fclose(fid);

disp(' ');
disp(['% CPU time used for the whole processing == ', num2str(cputime-t0)]);
disp(' ');

% Use Empirical Model Decomposition (EMD) to separate atmospheric effects
% from non-linear deformation rate

