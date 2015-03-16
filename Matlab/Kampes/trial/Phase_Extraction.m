function Phi = Phase_Extraction(infile1, infile2);
% Phi = Phase_Extraction(infile1, infile2);
% 
% This function is used to extract phase data at permannent scatters (PS).
% 
% Input:
%        Filename------for a text file including filenames of P differential interferograms, e.g.,
%                              T M N        // T differential interferograms with dimension of M by N  
%                              d:\sh\1000.int  
%                              ............  
%                              d:\sh\P000.int
%        RowCols--------------pixel coordinates of all PSs (a K-by-2 matrix)     
%
% Output:
%        Phi----------------differential phase values at all PSs (a K-by-T matrix)
%
%  e.g.,  Phi = Phase_Extraction(Filename, RowCols);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Mar. 8, 2006: Created, Guoxiang LIU
        
%  Reading SLC SAR images co-registered        
fid = fopen(Filename);
if (fid<0) error(ferror(fid)); end;

T=fscanf(fid, '%i', 1);    % T=total number of differential interferograms
M=fscanf(fid, '%i', 1);    % M=total number of rows in SAR image
N=fscanf(fid, '%i', 1);     % N=total number of columns in SAR image                                   


[rows, cols]=size(RowCols);   
K=rows;                         % get the total number of all PS points
clear rows, clos; 

Phi=zeros(K, T);        % define the matrix size for storage of all differential phase values at K PSs
                                   % from T interferograms
loc=zeros(K,1);
loc=(RowCols(:,2)-1)*K+RowCols(:,1);    % calculate the column-along order of PS locations

for i=1:T
    str=fscanf(fid, '\n%s', 1);               % read a filename for a differential interferogram
    temp=freadbk(str, M, 'cpxshort'); 
    Phi(:, i)=angle(temp(loc));
end
fclose(fid);
clear temp;

disp('Success in phase extraction!');
        
 