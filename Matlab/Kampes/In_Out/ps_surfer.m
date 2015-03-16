% reading PSs coordinates and converting them into the text file that is
% readable by Surfer

PS_Num=14581;   % total number of PSs
r0=751; rN=1500;      % starting and ending rows in the original differential interferogram
rows=rN-r0+1;
c0=2051; cN=3400;  % starting and ending colums in the original differential interferogram
cols=cN-c0+1;

% read the coordiantes of all PSs
PSCoor=freadbk('D:\PhoenixSBAS\Results\PSCoorN.dat', PS_Num, 'uint16');

% prepare a post file for Surfer 8.0
PSCoor(:,1)=cols-(PSCoor(:,1)-c0);
PSCoor(:,2)=rows-(PSCoor(:,2)-r0);

save D:\PhoenixSBAS\Results\figures\PSCoorN_Surfer.dat PSCoor -ASCII 
clear r0 rN c0 cN rows cols

% extracting PSs within [860--1150, 50--340]
k=0; 
for i=1:PS_Num
   if PSCoor(i,1)>=860 & PSCoor(i,1)<=1150 & PSCoor(i,2)>=50 & PSCoor(i,2)<=340
       k=k+1;
       II(k)=PSC(i,1); JJ(k)=PSC(i,2);
  end
end
IIJJ=[II', JJ', zeros(k,1)];
save D:\PhoenixSBAS\Results\figures\PSCoorN_cropped_Surfer.dat IIJJ -ASCII 
clear PSCoor k i PS_Num II JJ IIJJ
