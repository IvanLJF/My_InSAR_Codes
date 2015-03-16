%D-TomoSAR
tic
PI=3.1415926;
path='/home/mapeifeng/mount/E/former_Ubantu/Shanghai_diff/';
baseline_file=load(strcat(path,'base.list'));
master=baseline_file(1,2);
file_name_date_HK=baseline_file(:,3);
file_name_date_HK=sort(file_name_date_HK);
baseline_number_HK=length(file_name_date_HK);
master_par=strcat(path,'piece/',num2str(master),'.rslc.par');
header=fopen(master_par);
line_number=0;
C=299792458;

% Read par file.
while 1
    line_number=line_number+1;
    line_content=fgetl(header);
    if line_number==11
        line_content(find(isspace(line_content)))=[];
        image_width_HK=str2num(cell2mat(regexp(line_content,'\d','match')));
    end
    if line_number==12
        line_content(find(isspace(line_content)))=[];
        image_height_HK=str2num(cell2mat(regexp(line_content,'\d','match')));
    end
    if line_number==22
        line_content(find(isspace(line_content)))=[];
        range_spacing=str2num(line_content(length('range_pixel_spacing:')+1:length(line_content)-1));
    end
    if line_number==23
        line_content(find(isspace(line_content)))=[];
        azimuth_spacing=str2num(line_content(length('azimuth_pixel_spacing:')+1:length(line_content)-1));
    end
    if line_number==24
        line_content(find(isspace(line_content)))=[];
        near_slant_range=str2num(line_content(length('near_range_slc:')+1:length(line_content)-1));
    end
    if line_number==30
        line_content(find(isspace(line_content)))=[];
        incidence_angle=str2num(line_content(length('incidence_angle:')+1:length(line_content)-7));
    end
    if line_number==33
        line_content(find(isspace(line_content)))=[];
        wave_length=C/str2num(line_content(length('radar_frequency:')+1:length(line_content)-2));
        break;
    end
end


% Read spatio-temporal baselines.
time=baseline_file(:,5);
sort_time=sort(time);
total_mean_baseline_HK=zeros(baseline_number_HK,1);
for row=1:baseline_number_HK
    total_mean_baseline_HK(row,1)=baseline_file(find(time==sort_time(row)),4);%read baseline file
end
total_mean_baseline_HK=total_mean_baseline_HK';
mean_baseline_HK=zeros(baseline_number_HK,1);
for row=1:baseline_number_HK
    mean_baseline_HK(row,1)=total_mean_baseline_HK(find(file_name_date_HK==file_name_date_HK(row)));
end
time_baseline_HK=zeros(baseline_number_HK,1);
for row=1:baseline_number_HK
    time_baseline_HK(row,1)=(datenum(num2str(file_name_date_HK(row)),'yyyymmdd')-datenum(num2str(master),'yyyymmdd'))/365;
end

% Initialization
Smax=1200;            % Solution space.
Velocity=0.5;         % Solution space
L=401;                % Solution blocks.
P=101;                % Solution blocks.
deltaS=Smax/(L-1);      % Step length
deltaV=Velocity/(P-1);  % Step length

deltaS2=2*deltaS/(L-1); % For iteration.
deltaV2=2*deltaV/(P-1); % For iteration.

flag=2;
if flag==1
    row_start=1;
    row_end=image_height_HK;
    column_start=1;
    column_end=image_width_HK;
elseif flag==2
    row_start=822;
    row_end=2488;
    column_start=1421;
    column_end=2929;
end
 

% Read images.
site_image_width=column_end-column_start+1;
site_image_height=row_end-row_start+1;

datasets_HK=int16(zeros(baseline_number_HK,site_image_height,site_image_width));
for index_HK=1:baseline_number_HK
            data_file_name_HK=strcat(path,'piece/',num2str(file_name_date_HK(index_HK)),'.rslc');
            datasets_HK(index_HK,:,:)=int16(freadbkb(data_file_name_HK,image_height_HK,'cpxint16',row_start,row_end,column_start,column_end));
end
% mean_intensity_image=zeros(site_image_height,site_image_width);
% for index_HK=1:baseline_number_HK
%     for index_row_HK=1:site_image_height
%         for index_colume_HK=1:site_image_width
%             mean_intensity_image(index_row_HK,index_colume_HK)=mean_intensity_image(index_row_HK,index_colume_HK)+abs(double(datasets_HK(index_HK,index_row_HK,index_colume_HK)));
%         end
%     end
% end
% mean_file = fopen(strcat(path,'result/mean_file'), 'wb');
% fwrite(mean_file,mean_intensity_image,'float32');

% equalization_intensity=zeros(baseline_number_HK,1);
% equalization_intensity2=zeros(baseline_number_HK,1);
% for index_HK=1:baseline_number_HK
%     for index_row_HK=1:site_image_height
%         for index_colume_HK=1:site_image_width
%             datasets_HK(index_HK,index_row_HK,index_colume_HK)=datasets_HK(index_HK,index_row_HK,index_colume_HK)/equalization_intensity(index_HK,1)*equalization_intensity(1,1);
%         end
%     end
% end

Da_point_count=800000;
TriX=zeros(Da_point_count,1);
TriY=zeros(Da_point_count,1);

amplitude=zeros(baseline_number_HK,Da_point_count);
ps_location=zeros(site_image_height,site_image_width);
ps_count=0;
%dinsar
for index_row_HK=1:site_image_height
    for index_colume_HK=1:site_image_width
        abs_amplitude=abs(double(datasets_HK(:,index_row_HK,index_colume_HK)));
        mean_amplitude=mean(abs_amplitude);
        std_amplitude=std(abs_amplitude);
        if std_amplitude/mean_amplitude<0.25   % Amplitude Dispersion Index
            ps_count=ps_count+1;
            TriX(ps_count)=index_row_HK;
            TriY(ps_count)=index_colume_HK;
            amplitude(:,ps_count)=abs_amplitude;  % Important. Using amplitude to calculate height values.
            ps_location(index_row_HK,index_colume_HK)=1;
        end
    end
end
%ipta
% plist=fopen('/home/peifeng/data/airportIPTA/plist','rb','b');
% [plist_data,plist_count]=fread(plist,'int32');
% point_count=plist_count/2;
% for index_HK=1:point_count
%     ps_count=ps_count+1;
%     TriX(ps_count)=plist_data(index_HK*2)+1;
%     TriY(ps_count)=plist_data(index_HK*2-1)+1;
% end
TriX=TriX(1:ps_count);
TriY=TriY(1:ps_count);
amplitude=amplitude(1:ps_count);

dt = delaunay(TriX,TriY);
triplot(dt,TriX,TriY);%�������������������?TRI(i,1)) y(TRI(i,1))x(TRI(i,2)) y(TRI(i,2))x(TRI(i,3)) y(TRI(i,3))�ֱ����i��delaunay����ε������ĺ�����꣬Ȼ�����Ĳ�������
tri_count=size(dt,1);
arc=zeros(tri_count*3,2);
for index_HK=1:tri_count
    arc(3*index_HK-2:3*index_HK,:)=[dt(index_HK,1),dt(index_HK,2);dt(index_HK,2),dt(index_HK,3);dt(index_HK,3),dt(index_HK,1)];
end
arc = unique(sort(arc,2),'rows');
% tree=kdtree_build([TriX,TriY]);
% for index_HK=1:ps_count
%     IDX=kdtree_ball_query(tree,[TriX(index_HK),TriY(index_HK)],20);
%     IDX=IDX(IDX~=index_HK);
%     if size(IDX)>20
%         IDX=IDX(1:20);
%     end
%     arc=[arc;[IDX,index_HK*ones(size(IDX))]];
% end
% arc = unique(sort(arc,2),'rows');
arc_count=size(arc,1);

datasets_PS_HK=single(zeros(baseline_number_HK,ps_count));
%dinsar
for index_HK=1:baseline_number_HK
            data_file_name_HK=strcat(path,num2str(file_name_date_HK(index_HK)),'/',num2str(master),'-',num2str(file_name_date_HK(index_HK)),'.diff.int');
            dataset_HK=single(conj(freadbkfloat32(data_file_name_HK,image_height_HK,'cpxfloat32',row_start,row_end,column_start,column_end)));
            for index_HK_data=1:ps_count
                datasets_PS_HK(index_HK,index_HK_data)=dataset_HK(TriX(index_HK_data),TriY(index_HK_data));
            end
%             datasets_PS_HK(index_HK,:)=diag(dataset_HK(TriX(:),TriY(:)));
end

%ipta
% datasets_PS_HK=single(conj(freadbkfloat32('/home/peifeng/data/airportIPTA/pint',31,'cpxfloat32',1,31,1,point_count)));


g=zeros(baseline_number_HK,1);
DR=zeros(baseline_number_HK,L*P);

picture_HK=zeros(site_image_height,site_image_width);
picture_HK(:)=NaN;
picture_velocity_HK=zeros(site_image_height,site_image_width);
picture_velocity_HK(:)=NaN;


%//////////////
height_diff=zeros(arc_count,1);
velocity_diff=zeros(arc_count,1);

final_ps_sparse=zeros(2*arc_count,1);
weights=zeros(1*arc_count,1);
eff_arc_count=0;
eff_arc=zeros(arc_count,2);
residual2=zeros(baseline_number_HK,arc_count);

slant_range=near_slant_range+(column_start+site_image_width/2-2)*range_spacing;
for column=1:L
    for velocity_index=1:P               
        DR(:,(column-1)*P+velocity_index)=exp(4*PI*mean_baseline_HK(:,1).*(column-(L-1)/2-1)*deltaS/wave_length/slant_range*i+4*PI*time_baseline_HK(:,1).*(velocity_index-(P-1)/2-1)*deltaV/wave_length*1i);  % Key equation.
    end
%       DR(:,column)=exp(4*PI*mean_baseline_HK(:,1).*(column-(L-1)/2-1)*deltaS/wave_length/slant_range*i);

end
% L2=101;
% deltaS=Smax/(L2-1);
% deltaV=Velocity/(P-1);
% deltaT=Temp_coef/(T-1);
% DR2=zeros(baseline_number_HK,L2*P);
% for column=1:L2
%     for velocity_index=1:P               
%         DR2(:,(column-1)*P+velocity_index)=exp(4*PI*mean_baseline_HK(:,1).*(column-(L2-1)/2-1)*deltaS/wave_length/slant_range*i+4*PI*time_baseline_HK(:,1).*(velocity_index-(P-1)/2-1)*deltaV/wave_length*i);
%     end
% %       DR(:,column)=exp(4*PI*mean_baseline_HK(:,1).*(column-(L-1)/2-1)*deltaS/wave_length/slant_range*i);
% 
% end

residual2=zeros(baseline_number_HK,arc_count);

% solution in arcs
for index_HK=1:arc_count
   distance=sqrt((TriX(arc(index_HK,1))-TriX(arc(index_HK,2)))^2+(TriY(arc(index_HK,1))-TriY(arc(index_HK,2)))^2);
          
   if distance<4000
       g=datasets_PS_HK(:,arc(index_HK,1)).*conj(datasets_PS_HK(:,arc(index_HK,2)));
       Dvector_bf=abs(DR'*g);
       [Dmax_vector_bf, first_peak_index]=max(Dvector_bf);
        
       cbf=Dmax_vector_bf/(norm(g)*baseline_number_HK^0.5);
       if cbf>0.82
%            hold on;
%            plot([TriX(arc(index_HK,1)),TriX(arc(index_HK,2))],[TriY(arc(index_HK,1)),TriY(arc(index_HK,2))],'Color',[cbf,0,0]);
%            Dvector_bf=abs(DR2'*g);
%            [Dmax_vector_bf, first_peak_index]=max(Dvector_bf);
           
%            [vel_index1 hei_index1]=ind2sub([P L2],first_peak_index);
%            reletive_height1=(hei_index1-(L+1)/2)*deltaS;
%            reletive_velocity1=(vel_index1-(P+1)/2)*deltaV;
%            hold on;
%             figure(1);
%            plot(time_baseline_HK,angle(g),'r');
%            axis([-2 2 -PI PI]);

           [vel_index1 hei_index1]=ind2sub([P L],first_peak_index);
           reletive_height1=(hei_index1-(L+1)/2)*deltaS;
           reletive_velocity1=(vel_index1-(P+1)/2)*deltaV;
%            plot(1:L*P,Dvector_bf,'r');
%            if reletive_height1>400
% %                 plot(1:L*P,Dvector_bf,'r');
%            end
%            for index_HK_baseline=1:baseline_number_HK
%                g(index_HK_baseline,1)= g(index_HK_baseline,1)/abs(g(index_HK_baseline,1))*exp(-4*PI*mean_baseline_HK(index_HK_baseline,1)*reletive_height1/wave_length/slant_range*i);
%            end
%            figure(2);
%            plot(time_baseline_HK,angle(g),'b');
%            axis([-2 2 -PI PI]);
           
%            complete_angle=4*PI*mean_baseline_HK(:,1).*reletive_height1/wave_length/slant_range+4*PI*time_baseline_HK(:,1).*reletive_velocity1/wave_length+4*PI*temperature(:,1).*reletive_temperature1/wave_length+angle(g.*conj(DDR(:,first_peak_index)));
%            solution=K\complete_angle;
%            reletive_height1=solution(1,1);
%            reletive_velocity1=solution(2,1);
%            reletive_temperature1=solution(3,1);
%            
%      
               eff_arc_count=eff_arc_count+1;
               height_diff(eff_arc_count)=reletive_height1;
               velocity_diff(eff_arc_count)=reletive_velocity1;
               final_ps_sparse(eff_arc_count*2-1)=arc(index_HK,1);
               final_ps_sparse(eff_arc_count*2)=arc(index_HK,2);
               weights(eff_arc_count)=cbf;
               eff_arc(eff_arc_count,:)=arc(index_HK,:);
               residual2(:,eff_arc_count)=angle(g.*exp(-4*PI*mean_baseline_HK(:,1).*reletive_height1/wave_length/slant_range*i-4*PI*time_baseline_HK(:,1).*reletive_velocity1/wave_length*i));

           temp=0;
       end
   end
end
eff_arc=eff_arc(1:eff_arc_count,:);


isolated_area_count=50;
arc_color=rand(isolated_area_count,3);
final_ps_sparse_temp=final_ps_sparse;
final_ps_sparse=final_ps_sparse_temp;
final_ps_sparse=unique(final_ps_sparse);
final_ps_sparse(final_ps_sparse==0)=[];
area1_ps1=[];
area1_ps2=[];
total_arc_count_index=0;
isolated_area_count_index=1;
max_eff_arc_track_count=0;

while total_arc_count_index<eff_arc_count && isolated_area_count_index<isolated_area_count
    eff_arc_track_count=0;
    eff_arc_track=zeros(eff_arc_count,1);
    area1_ps2=[];
    area1_ps2(1)=final_ps_sparse(1);
    colomn_sparse=[];
    while 1
        area1_ps2=unique(area1_ps2);
        diff_area1_ps=setdiff(area1_ps2,area1_ps1);
        area1_ps1=area1_ps2;%previous ps points
        if isempty(diff_area1_ps)
            final_ps_sparse=setdiff(final_ps_sparse,area1_ps2);
            isolated_area_count_index=isolated_area_count_index+1;
            break;
        else
            for index_HK=1:size(diff_area1_ps,1)
                connected_points=find(diff_area1_ps(index_HK)==eff_arc);
                for index_HK_connected_points=1:size(connected_points,1)
                    if connected_points(index_HK_connected_points)<=eff_arc_count%the first column 
                        eff_arc_track_count=eff_arc_track_count+1;%count of arcs in connected areas
                        eff_arc_track(eff_arc_track_count)=connected_points(index_HK_connected_points);%line of connected arc in eff_arc
                        area1_ps2=[area1_ps2;eff_arc(eff_arc_track(eff_arc_track_count),2)];
                        colomn_sparse(eff_arc_track_count*2-1)=eff_arc(eff_arc_track(eff_arc_track_count),1);
                        colomn_sparse(eff_arc_track_count*2)=eff_arc(eff_arc_track(eff_arc_track_count),2);
%                         hold on;
%                         plot([TriX(eff_arc(eff_arc_track(eff_arc_track_count),1)),TriX(eff_arc(eff_arc_track(eff_arc_track_count),2))],[TriY(eff_arc(eff_arc_track(eff_arc_track_count),1)),TriY(eff_arc(eff_arc_track(eff_arc_track_count),2))],'Color',arc_color(isolated_area_count_index,:));
                    else%the second column
                        eff_arc_track_count=eff_arc_track_count+1;
                        eff_arc_track(eff_arc_track_count)=connected_points(index_HK_connected_points)-eff_arc_count;
                        area1_ps2=[area1_ps2;eff_arc(eff_arc_track(eff_arc_track_count),1)];
                        colomn_sparse(eff_arc_track_count*2-1)=eff_arc(eff_arc_track(eff_arc_track_count),1);
                        colomn_sparse(eff_arc_track_count*2)=eff_arc(eff_arc_track(eff_arc_track_count),2);
%                         hold on;
%                         plot([TriX(eff_arc(eff_arc_track(eff_arc_track_count),1)),TriX(eff_arc(eff_arc_track(eff_arc_track_count),2))],[TriY(eff_arc(eff_arc_track(eff_arc_track_count),1)),TriY(eff_arc(eff_arc_track(eff_arc_track_count),2))],'Color',arc_color(isolated_area_count_index,:));
                    end
                    eff_arc(eff_arc_track(eff_arc_track_count),1)=0;
                    eff_arc(eff_arc_track(eff_arc_track_count),2)=0;
                    total_arc_count_index=total_arc_count_index+1;
                end
            end
        end
    end
    
    if eff_arc_track_count>max_eff_arc_track_count
        max_eff_arc_track_count=eff_arc_track_count;
        max_area1_ps2=area1_ps2;
        max_eff_arc_track=eff_arc_track;
        max_colomn_sparse=colomn_sparse;
    end
end
eff_arc_track_count=max_eff_arc_track_count;
area1_ps2=max_area1_ps2;
eff_arc_track=max_eff_arc_track;
colomn_sparse=max_colomn_sparse;

eff_arc_track=eff_arc_track(1:eff_arc_track_count);
height_diff=height_diff(eff_arc_track);
velocity_diff=velocity_diff(eff_arc_track);


row_sparse=zeros(eff_arc_track_count*2,1);
colomn_sparse=colomn_sparse(1:eff_arc_track_count*2);
value_sparse=zeros(eff_arc_track_count*2,1);
for index_HK=1:eff_arc_track_count
       row_sparse(index_HK*2-1)=index_HK;
       value_sparse(index_HK*2-1)=1;
       row_sparse(index_HK*2)=index_HK;
       value_sparse(index_HK*2)=-1;
end
A=sparse(row_sparse,colomn_sparse,value_sparse,eff_arc_track_count,ps_count);
% 
weights=weights(eff_arc_track);
weights_row=1:eff_arc_track_count;
weights_column=1:eff_arc_track_count;
weights_sparse=sparse(weights_row',weights_column',weights,eff_arc_track_count,eff_arc_track_count);


size_final_ps_sparse=size(area1_ps2,1);
index_delete=zeros(ps_count,1);
index_delete_count=0;
for index_HK=1:ps_count
    if ~ismember(index_HK,area1_ps2)
        index_delete_count=index_delete_count+1;
        index_delete(index_delete_count)=index_HK;      
    end
end
index_delete(index_delete==0)=[];
A(:,index_delete)=[];
reference_position=1;
reference_point=area1_ps2(reference_position);
A(:,reference_position)=[];
area1_ps2_temp=area1_ps2;
area1_ps2(reference_position)=[];

% network adjustment
adjust_height=(A'*weights_sparse*A)\(A'*weights_sparse*height_diff);%sparse(A)\height_diff;%inv(A'*A)*A'*height_diff;
for index_HK=1:size_final_ps_sparse-1
        picture_HK(TriX(area1_ps2(index_HK)),TriY(area1_ps2(index_HK)))=adjust_height(index_HK);
end
picture_HK(TriX(reference_point),TriY(reference_point))=0;

picture_image = fopen(strcat(path,'result/picture_sparse'), 'wb');
fwrite(picture_image,picture_HK,'float32');

adjust_velocity=(A'*weights_sparse*A)\(A'*weights_sparse*velocity_diff);%sparse(A)\velocity_diff;%inv(A'*A)*A'*height_diff;
for index_HK=1:size_final_ps_sparse-1
        picture_velocity_HK(TriX(area1_ps2(index_HK)),TriY(area1_ps2(index_HK)))=adjust_velocity(index_HK);
end
picture_velocity_HK(TriX(reference_point),TriY(reference_point))=0;

picture_image = fopen(strcat(path,'result/picture_velocity_sparse'), 'wb');
fwrite(picture_image,picture_velocity_HK,'float32');

toc
temp=0;