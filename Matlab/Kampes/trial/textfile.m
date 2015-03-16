function textfile(Filename);

fid = fopen(Filename);
if (fid<0) error(ferror(fid)); end;

P=fscanf(fid, '%i', 1);    % P=total number of SLC SAR images
M=fscanf(fid, '%i', 1);    % M=total number of image rows
N=fscanf(fid, '%i', 1);     % N=total number of image columns                                   

Amp=zeros(M, N, P);        % define the matrix size for storage of all SAR datasets

for i=1:P
    str=fscanf(fid, '\n%s', 1);
    %temp=freadbk(str, M, 'cpxshort'); 
    %Amp(:,:,i)=abs(temp);
end
fclose(fid);
