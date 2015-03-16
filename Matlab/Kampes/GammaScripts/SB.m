function B=SB(str);
% Extracting perpendicular baselines from a multiple baseline files
% generated with GAMMA
%
% Input:    str=directory for baseline files like 'F:\Phoniex\SB\19920710'
% Usage:  B=SB('F:\Phoniex\SB\19920710');

cd(str);   % change into directory containing the baseline files 
wd=cd;
D=dir(wd);                                          % Get the structure of multiple filenames
N=length(D);                                       % Get the number of all files
B=zeros(N-2,1);

for i=3:N
   fid = fopen (D(i).name);
   for j=1:17
       tline = fgetl(fid);   
       % disp(tline);
   end
   [A, Count]=fscanf(fid, '%f', 8);
   B(i-2)=A(8);
   fclose(fid);
end

