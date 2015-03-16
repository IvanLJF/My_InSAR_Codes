function [count]=data_for_surfer(data, outfile, corner_lat, corner_lon, post_lat, post_lon)


[m,n]=size(data);

data(data==0)=1.70141e38;
% for i=1:m
%     for j=1:n
%         %         if  data(i,j)==0
%         if    isnan(data(i,j))==1
%             data(i,j)=1.70141e38;
%         elseif data(i,j)==0
%             data(i,j)=1.70141e38;
%         end
%     end
% end


% LU corner
maxlat=corner_lat;
minlon=corner_lon;

% RL corner
minlat=corner_lat+post_lat*(m-1);
maxlon=corner_lon+post_lon*(n-1);

fid2=fopen(outfile,'w','b');
fprintf(fid2,'DSAA\n');
fprintf(fid2,'%g\t',n);fprintf(fid2,'%g',m);fprintf(fid2,'\n');

fprintf(fid2,'%10.6f\t',minlon);fprintf(fid2,'%10.6f',maxlon);fprintf(fid2,'\n');%E
fprintf(fid2,'%10.6f\t', minlat);fprintf(fid2,'%10.6f', maxlat);fprintf(fid2,'\n');%N

fprintf(fid2,'%8.5f\t',min(data(:)));
fprintf(fid2,'%8.5f',max(data(:)));
fprintf(fid2,'\n');

for i=m:-1:1
    fprintf(fid2,'%8.5f\t',data(i,:));
    fprintf(fid2,'\n');
    fprintf(fid2,'\n');
end

count=fclose(fid2);


