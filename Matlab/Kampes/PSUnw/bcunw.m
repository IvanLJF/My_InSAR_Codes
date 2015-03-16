function bcunw(infile);
%  function bcunw(infile);
% Doing phase unwrapping on the residual phases by the path-following 
% method (branch-cut method) presented by Ghiglia and Pritt (1998)
% Input:
%        infile----------------a input text file including filenames of num_intf differential interferograms, e.g.,
%                                    num_intf rows cols num_PS       // num_intf differential interferograms with dimension of rows by cols, 
%                                                                                         // total number of all PS -- num_PS  
%                                    E:\PhoenixSAR\Dif_Int_MLI\        // directory of interferograms  
%                                   19920710_19930521.diff.int2.ph
%                                   19920710_19931008.diff.int2.ph
%                                   ...............
%                                   19991220_20001030.diff.int2.ph   
% Output files
%        Unwrapped-phase data
%       19920710_19930521.diff.int2.unw  19920710_19931008.diff.int2.unw
%       .....................................................   19991220_20001030.diff.int2.unw 
%  e.g., bcunw('E:\PhoenixSAR\Dif_Int_MLI\117ints.all');
% Original Author:  Guoxiang LIU
% Revision History:
%                   May. 10, 2006: Created, Guoxiang LIU
%
% See also RESFLTUNW RESPSUNW  PSLSUNW CONGRUENCE LSUNW_TEST

t0=cputime;

% read in velocity field and DEM errors estimated by functions --- "dvddharcs" and "grserrls" 
% To consider mask area, the following trick is used.
V_mask=ReadSurferFile('F:\Phoniex\PS_Points\27by15KM\updated\XYV.grd', 'n');          
                     % Velocity matrix in mm/year (derived by Kriging
                     % interpoltation). This deformation velocity field had been already blanked with Surfer.
V_mask=fliplr(V_mask);   % flip horizontally

% generate a mask file needed by phase unwrapping
mask=ones(size(V_mask));
II=isnan(V_mask);
JJ=find(II==1);         % JJ will be used later on
mask(JJ)=0;            % set to 0 when it is a NaN
maskfile='E:\PhoenixSAR\Dif_Int_MLI_LPF\mask.dat';
disp(['    Writing the mask flags for phase unwrapping into ', maskfile]);
fwritebk(mask, maskfile, 'uint8');
clear II V_mask mask 

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
disp('% Please wait ...... Phase Unwrapping ......');
Dirt='E:\PhoenixSAR\Dif_Int_MLI_LPF\';

for m=1:num_intf         % loop on all residual differential interferograms
    cd(Dirt);      % change file directory
    disp(' ');
    disp(['% Working on No.', num2str(m), ' residual differential interferogram ......']);
    filenm=fscanf(fid, '\n%s', 1);
    master=filenm(1:8);              % get master name
    slave=filenm(10:17);             % get slave name

    iofile=[num2str(master), '_', num2str(slave), '.diff.int2.lpf'];
    copyfile(iofile, 'FltRes.lpf');
       
    % Do phase unwrapping by Goldstein's branch-cut method: gold  
    % Note: unwrapping executables are in "D:\SBAS\PhaseUnw\"
    outfile=[num2str(master), '_', num2str(slave), '.diff.int2.unw'];     %##############
    delete(outfile);
    disp(['           Conducting unwrapping by Goldstein method and writing into ', outfile]);
    %! D:\SBAS\PhaseUnw\mwd -input FltRes.lpf -format complex8 -output unw.dat -bmask mask.dat -xsize 1350 -ysize  750 -mode min_var -tsize 1 -thresh yes -debug yes -fat 1
    !D:\SBAS\PhaseUnw\gold -input FltRes.lpf -format complex8 -output unw.dat -xsize 1350 -ysize 750 -mask mask.dat
    %!D:\SBAS\PhaseUnw\mcut -input FltRes.lpf -format complex8 -output unw.dat -bmask mask.dat -xsize 1350 -ysize 750 -mode min_var -tsize 3
                                 % note: the unwrapped phases are written into the outfile as floating values
   unw=freadbk('unw.dat', 750, 'float32');   % reading unwrapped phases
   unw(JJ)=NaN;
   fwritebk(unw, outfile, 'float32');               % saving unwrapped phases with NaNs
   display_unw(master, slave, unw, Dirt);         % plotting unwrapped data
   delete('FltRes.lpf');
   delete('unw.dat');
   %delete('unw.dat.qual');
end
fclose(fid);

disp(' ');
disp(['% CPU time used for the whole processing == ', num2str(cputime-t0)]);
disp(' ');

function display_unw(master, slave, unw, Dirt)
    figure;
    imagesc(fliplr(unw)); axis image; %colormap(jet); colorbar;
    set(gcf, 'Position', [113 133 839 460]);
    title([num2str(master), '\_', num2str(slave), '\_UNW']);
    colorbar('horiz', 'Position', [0.25 0.135 0.55 0.035], 'FontSize', 11);
    %set(gca, 'Position', [0.1 0.12 0.90 0.88]);
    %h=colorbar('horiz', 'Position', [0.35 0.2 0.35 0.040], 'FontSize', 11);
    %set(h, 'XColor',  [1 1 1], 'YColor', [1 1 1]);
    %set(h, 'XColor',  [1 1 1], 'YColor', [1 1 1]);
    str=[Dirt, 'UNW1_Figs\'];
    cd(str);
    saveas(gcf, [num2str(master), '_', num2str(slave), '_UNW1'], 'emf');
    close all;
    
% Use Empirical Model Decomposition (EMD) to separate atmospheric effects
% from non-linear deformation rate

