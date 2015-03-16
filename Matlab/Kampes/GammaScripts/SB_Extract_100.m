% Extracting perpendicular baselines from a multiple baseline files
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
20000925];    % directories

B=ones(length(dib), length(dib));  % storage of perpendicular baselines
B=-10000*B;                                  % Initial values = -10000

for i=1:length(dib)
     str=strcat('F:\Phoniex\SB\', num2str(dib(i)));
     temp=SB(str);
     B(i, i:length(dib))=temp;
end
save F:\Phoniex\SB\SB_Extract.dat B -ASCII    % save the baseline file
 
% Getting the useful interferometric pairs with small baselines
B1=B;
I=find(abs(B1)>100);
B1(I)=-10000;
dib1=[dib(2:length(dib)); 20001030];
    
k=0;
pair_dates=zeros(1000, 3);    % initiate a matrix storing the dates taking SAR image pairs
SB=zeros(1000,1);                 % for baseline of useful pairs
for i=1:length(dib)
    for j=i:length(dib1)
        if B1(i,j)~=-10000
            k=k+1;
            pair_dates(k,1)=dib(i);
            pair_dates(k,2)=dib1(j);
            pair_dates(k,3)=datenum(num2str(pair_dates(k,2)), 'yyyymmdd')-datenum(num2str(pair_dates(k,1)), 'yyyymmdd');
            SB(k)=B1(i,j);
        end
    end
end
t=pair_dates(1:k,:); 
b=SB(1:k);
clear pair_dates SB;
pair_dates=t; 
SB=b;
%save F:\Phoniex\SB\Pair_Dates.dat pair_dates -ASCII    % save the baseline file
fid = fopen('F:\Phoniex\SB\Pair_Dates_SB.dat', 'w');
fprintf(fid,'%8.0f    %8.0f    %10.0f    %6.2f\n', [pair_dates SB]');
fclose(fid);
        
% plotting the temporal-baseline distribution
figure;
hold on;
for i=1:k
     plot([datenum(num2str(pair_dates(i,1)), 'yyyymmdd'), datenum(num2str(pair_dates(i,2)), 'yyyymmdd')], [i, i], 'LineWidth', 2.0, 'Color', [0 0 0]);
end;
hold off;
datetick('x', 'yyyy');
set(gca, 'FontSize', 10.5);
set(gca, 'TickLength', [0.008, 0.008]);
xlabel('Year');
ylabel('Interferogram ID number');
set(gca, 'Box', 'on');
set(gca, 'LineWidth', 0.75);
   
clear temp dib i I j k str date_nums t B1 dib1 b fid
    
