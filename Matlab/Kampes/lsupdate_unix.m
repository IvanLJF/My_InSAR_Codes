function [x, VV, delta]=lsupdate_unix(num_PS, num_Arcs, starting, ending, PSCoor, Arcs, dvhc)
% 通过二次最小二乘预测每个点的绝对位移矢量和高程误差，并剔除矢量中的粗差以及高程误差增量
%   [x, VV, delta]=lsupdate_unix(num_PS, num_Arcs, start, PSCoor, Arcs, dvhc);
%
% Estimating the absolute displacement velocity or height error at each PS points by twice least solutions,  
% and removing the gross errors in the velocity and height-error increments
% 
% Input:
%        num_PS-------total number of all PS points
%        num_Arcs-----total number of all arcs in the triangular irregular network (TIN)
%        starting---------use the velocity (or height error) at the first PS point as a benckmark
%        ending----------use the velocity (or height error) at the last PS point as a benckmark
%        PSCoor--------Coordinates of all PS points
%        Arcs------------all arcs  less than 1 km without arc duplication, num_Arcs-by-2 matrix
%        dvhc------------measurements, i.e., differential values (velocity and height error) and coherence along arcs, num_Arcs-by-3 matrix
%                              (dv in mm/day, ddh in m)
% Output:
%        x----------------estimated parameters (e.g., velocity and height error) in absolute sense
%        VV--------------residuals
%        delta-----------standard deviation in unit weight
%
%  e.g.,   num_PS=50;
%            num_Arcs=133;
%            [x, VV, delta]=lsupdate_unix(num_PS, num_Arcs, starting, ending, PSCoor, Arcs, dvhc);
% 
% for Phoenix study area: velocity starting=0, ending=0.05 (mm/day)
%                                       height error starting=8.2, ending=-2 (m) 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Apr. 20, 2006: Created, Guoxiang LIU

t0=cputime;     % the starting time of the operation

% Estimate initial parameters with least sqaures method  
disp(' ');
disp('% Computing initial solutions with least sqaures method'); 
disp('    Deleting noisy (unsolved) arcs and PS points......');
[x, VV, delta]=grserrls_ne(num_PS, num_Arcs, starting, ending, 0.38, Arcs, dvhc(:,1), dvhc(:,3));   % for velocity
%[x, VV, delta]=grserrls_ne(num_PS, num_Arcs, starting, ending, 0.38, Arcs, dvhc(:,2), dvhc(:,3)); % for height errors

VNaN=isnan(VV);            % check unuseful arcs
JJ=find(VNaN==0);         % find out valid arcs
num_Arcs1=length(JJ);  % update total number of arcs
Arcs_new=Arcs(JJ,:);     % get the useful arcs which will be used for the next LS solution
dvhc_new=dvhc(JJ,:);    % get the incremets and weights of the useful arcs
clear VNaN JJ;

% Remove non-useful PS points and update PS-point number at arcs
XNaN=isnan(x);                                 % check unuseful PS points
JJ=find(XNaN==0)+1;                        % find out valid PS points
num_PS1=length(JJ)+2;    % update total number of PS points
PSCoor_new=PSCoor([1; JJ; num_PS], :);       % extract useful PS points
JJ=find(XNaN==1)+1;                        % find out invalid PS points
detrend1=zeros(size(Arcs_new(:,1)));
detrend2=zeros(size(Arcs_new(:,2)));
for i=1:length(JJ)
    II=find(Arcs_new(:,1)>=JJ(i));
    detrend1(II)=detrend1(II)-1;
    II=find(Arcs_new(:,2)>=JJ(i));
    detrend2(II)=detrend2(II)-1; 
end
Arcs_new(:,1)= Arcs_new(:,1)+detrend1;
Arcs_new(:,2)= Arcs_new(:,2)+detrend2;
clear II detrend1 detrend2 XNaN JJ
     %% The following parts have same function as above but perform slowly
% PSNO=[Arcs_new(:,1); Arcs_new(:,2)];    % extract point numbers with duplication
% PSNO=sort(PSNO);                                  % sort point numbers
% PSNO=unique(PSNO);                              % remove duplication
% PSCoor_new=PSCoor(PSNO, :);              % extract useful PS points
% num_PS1=length(PSNO);                          % update total number of PS points
% for i=1:num_Arcs1       % update point number in Arcs_new                                 
%     start_Indx=find(PSNO==Arcs_new(i,1));
%     end_Indx=find(PSNO==Arcs_new(i,2));
%     Arcs_new(i,1)=start_Indx;
%     Arcs_new(i,2)=end_Indx;
% end

% check the updated networks by plotting
% r0=751;
% c0=2051;
% Width=1350;
% Height=750;
% X=PSCoor_new(:, 1)-c0+1;
% Y=PSCoor_new(:, 2)-r0+1;
% X=Width-X+1;       % flip horizontally
% Y=Height-Y+1;       % flip vertically
% figure; hold on;
% set(gcf, 'Position', [1 33 1024 657]);
% for i=1:num_Arcs1
%         plot(X(Arcs_new(i, :)), Y(Arcs_new(i, :)), 'b-');
% end
% box on;

% Show information 
disp(['   Total number of non-useful arcs == ', num2str(num_Arcs-num_Arcs1)]);
disp(['   Total number of remaining arcs after deleting noisy ones == ', num2str(num_Arcs1)]);
% pathstr='F:\Phoniex\PS_Points\27by15KM\updated';
% pathstr='F:\Phoniex\PS_Points\27by15KM\updated\ints86';
pathstr='/d1/users/liu/matlabprg/output';
% str='PSArcs_new.dat';
%str='PSArcs_86_new.dat';
str='PSArcs_full_new.dat';
fwritebk(Arcs_new, [pathstr, '/', str], 'uint32');
disp(['   Saving all the final remaining arcs into', pathstr, '/', str, ', OK!']);
% str='dvddh_new.dat';
% str='dvddh_86_new.dat';
str='dvddh_full_new.dat';
fwritebk(dvhc_new, [pathstr, '/', str], 'float32');
disp(['   Saving all the updated dv, ddh, and weight into', pathstr, '/', str, ', OK!']);
disp(' ');
disp(['   Total number of non-useful PS points == ', num2str(num_PS-num_PS1)]);
disp(['   Total number of remaining PS points after deleting noisy ones == ', num2str(num_PS1)]);
% str='PSCoor_new.dat';
%str='PSCoor_86_new.dat';
str='PSCoor_full_new.dat';
fwritebk(PSCoor_new, [pathstr, '/', str], 'uint16');
disp(['   Saving all the final remaining PS points into', pathstr, '/', str, ', OK!']);

% Estimate once again with the updated network
[x, VV, delta]=grserrls_ne(num_PS1, num_Arcs1, starting, ending, 0.0, Arcs_new, dvhc_new(:,1), dvhc_new(:,3));   % for velocity
%[x, VV, delta]=grserrls_ne(num_PS1, num_Arcs1, starting, ending, 0.0, Arcs_new, dvhc_new(:,2), dvhc_new(:,3)); % for height errors

disp(' ');
disp(['% CPU time used for the whole processing == ', num2str(cputime-t0)]);
disp(' ');


