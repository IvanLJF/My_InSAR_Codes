function PS_Detect(Filename)
% 这个函数用来从一系列SLC SAR图像中探测PS点
% PS_Detect(Filename);
% 
% This function is used to detect permannent scatters (PS) from a number 
% of SLC SAR images
% 
% Input:
%        Filename------for a text file including filenames of P SAR intensity (=amplitude^2) images that have
%                              been co-registered together, e.g., (F:\PhoenixPWRL\sar_amp_imgs.txt)
%                              P M N        // P SAR intensity images with dimension of M by N  
%                              F:\PhoenixPWRL\                              
%                              P100.slc  
%                              ............  
%                              P200.slc
%
% Output:         Three files as output (directory: F:\Phoniex\PS_Points)
%        Mean_Amp.dat----Mean amplitude values for all pixels in
%                                   SAR scene (M-by-N matrix)
%        Std_Amp.dat------Standard deviation of amplitude values for all pixels in
%                                   SAR scene  (M-by-N matrix)
%        ADIs.dat------------Amplitude dispersion indcies (ADI) for all pixels in
%                                   SAR scene (M-by-N matrix)
%
%  e.g.,  PS_Detection('F:\PhoenixPWRL\sar_amp_imgs.txt');
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Mar. 6, 2006: Created, Guoxiang LIU
%
% See also PS_TIN  

t0=cputime;

%  Reading SLC SAR images co-registered        
fid = fopen(Filename, 'rt');
if (fid<0) error(ferror(fid)); end;

P=fscanf(fid, '%i', 1);    % P=total number of SLC SAR images
M=fscanf(fid, '%i', 1);    % M=total number of image rows
N=fscanf(fid, '%i', 1);     % N=total number of image columns                                   
Dirt=fscanf(fid, '%s', 1);   % get directory storing SAR datasets
disp(' ');
disp('% Computes mean, standard deviation and amplitude dispersion index from multiple SAR intensity images');
disp(['% Total number of SLC SAR images == ', num2str(P)]);
disp(['% Total number of image rows == ', num2str(M)]);
disp(['% Total number of image columns == ', num2str(N)]);
disp(['% Directory storing SAR images == ', Dirt]);
disp(' ');

%FP=num2str(zeros(P, 127));            % initialize the string array for storing filenames of all SAR intensity images 

for k=1:P
    str=fscanf(fid, '%s', 1);
    str=strcat(Dirt, str);
    FP(k,:)=str;     % get filename of SAR image
    % if (FP(k)<0) error(ferror(FP(k))); end;
end
fclose(fid);

% compute calibration factors for all SAR image
disp('% Please wait ...... calibrating of SAR data is ongoing ......');
cf=zeros(1,P);                             % cf == calibration factor of each SAR amplitude image
j=M*N;
mean_amp=0;                                      % the counter of the mean amplitude value of P SAR images
for k=1:P
	  disp(['% Doing No.', num2str(k), ' SAR image ......']);
      A=freadbk(FP(k,:), M, 'float32');
      % fseek(FP(k), 0, 'bof');               % enforce file pointer to return to the file begining
      cf(k)=mean2(sqrt(A));              % caculate the mean amplitude for the k-th SAR image
      mean_amp=mean_amp+cf(k)/P;              % calculate the mean amplitude for P SAR images
end
disp(' ');
disp('% The calibration factors derived are:');
for k=1:P
        disp(['% The mean of No.', num2str(k), ' SAR image == ', num2str(cf(k))]);
        cf(k)=cf(k)/mean_amp;                    % calculate the calibration factor for the k-th SAR image
        disp(['% The calibration factor of No.', num2str(k), ' SAR image == ', num2str(cf(k))]);
end
clear A;

% open file to write mean amplitude, std amplitude and ADI image
outfile1='F:\Phoniex\PS_Points\Mean_Amp.dat';
outfile2='F:\Phoniex\PS_Points\Std_Amp.dat';
outfile3='F:\Phoniex\PS_Points\ADIs.dat';
fid1=fopen(outfile1, 'wb');    
if (fid1<0) error(ferror(fid1)); end;
fid2=fopen(outfile2, 'wb');
if (fid2<0) error(ferror(fid2)); end;
fid3=fopen(outfile3, 'wb'); 
if (fid3<0) error(ferror(fid3)); end;

% read SAR intensity images and compute mean, std, and ADI
disp(' ');
disp(' ');
disp('% Please wait ...... statistical computation is ongoing ......');
K=100;                                 % set the row-along block size
intsy=zeros(K, N, P);           % initialize the data array with dimension of 100 by N by P
RN=ceil(M/K);                      % total number of along-row blocks (partition of the entire SAR image)

disp(['Total block size == ', num2str(RN)]);
disp(['A block size == ', num2str(K), ' by ', num2str(N)]);
disp(' ');

for i=1:RN
    disp(['% Doing No.', num2str(i), ' block ......']);
    if i<RN 
          r0=K*(i-1)+1;
          rN=K*i;
    else
           r0=K*(i-1)+1;
           rN=M;
    end
    for k=1:P
           intsy(:,:,k)=freadbk(FP(k,:), M, 'float32', r0, rN, 1, N);       % reading a block of intensity values
           intsy(:,:,k)=sqrt(intsy(:,:,k))/cf(k);                                    % converting into amplitude values and doing calibration
    end     
    Mean_Amp=mean(intsy, 3);         % takes the mean along the dimension 3 of Amp
    Std_Amp=std(intsy, 0, 3);             % pass in FLAG==0 to use the default normalization by N-1
    ADIs=Std_Amp./(Mean_Amp+0.01);
    fwrite(fid1, Mean_Amp', 'float32');
    fwrite(fid2, Std_Amp', 'float32');
    fwrite(fid3, ADIs', 'float32');
end

fclose(fid1);
fclose(fid2);
fclose(fid3);
disp(' ');        
disp('% Computing finished successfully!');
disp('% Results saved as F:\Phoniex\PS_Points\Mean_Amp.dat, Std_Amp.dat, and ADIs!');
disp(' ');
disp(['% Total CPU time used for the processing: ', num2str(cputime-t0)]);