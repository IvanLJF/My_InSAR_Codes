function freenet;
% plotting a freely-connected network

% coordinates
X=rand(100,1)*1000;
Y=rand(100,1)*1000;
% X=[1, 3, 6, 4, 2, 5, 2, 4, 6, 1, 1, 6, 4]';
% Y=[6, 6, 6, 5, 5, 4, 3, 2, 1, 1, 3, 3, 1]'; 
num_PS=length(X);

figure; 
subplot(1,2,1);
hold on;
% forming a network
Arcs_free=[0 0];
for i=1:num_PS
    PN=[i+1:num_PS]';                                                   % get numbers of points
    XYPS1=[X(i)*ones(length(PN), 1), Y(i)*ones(length(PN), 1)];       % coordinate of starting point
    XYPS2=[X(i+1:num_PS), Y(i+1:num_PS)];            % coordinate of ending point
    ArcDist=sum((XYPS1-XYPS2).^2, 2).^0.5;            % caculate Euclidean distance, 
    II=find(ArcDist<=200000);                                               % look for short arcs with distance less than 1000 m
    PNI=PN(II);                                                               % get valid points that can be connected with the ith point  
    PN0=ones(size(PNI))*i;                                           % starting point for each arc
    PN0I=[PN0, PNI];                                                     % starting-ending points for all arcs 
    for j=1:length(II)
        plot(X(PN0I(j,:)), Y(PN0I(j,:)), 'k-', 'LineWidth', 1.5);
    end
    Arcs_free=[Arcs_free; PN0I];
end
plot(X, Y, 'ob', 'MarkerSize', 8, 'MarkerEdgeColor','k',  'MarkerFaceColor','g'); 
hold off; box on; %axis image;
set(gca, 'XLim', [0.5, 6.5], 'YLim', [0.5, 6.5]);
set(gca, 'XTick', 0.5:1:6.5, 'YTick', 0.5:1:6.5); 
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'LineWidth', 1.5);
grid on;
[R, C]=size(Arcs_free);
Arcs_free=Arcs_free(2:R,:);
num_Arcs_free=R-1;
B_free=coefmat(Arcs_free, num_Arcs_free, num_PS);
clear Arcs_free XYPS1 XYPS2 PN ArcDist II PNI PN0 PN0I;
R_free=speye(num_Arcs_free, num_Arcs_free);
test=B_free*inv(B_free'*B_free);
test=test*B_free';
R_free=R_free-test;   % compute redanduncy matrix
clear test;
r_free=diag(R_free);  
clear R_free;

% Design matrix
% for arcs without starting and ending points
tri=delaunay(X',Y');
Arcs=[tri(:,1), tri(:,2); tri(:,1), tri(:,3); tri(:,2), tri(:,3)];
Arcs=sort(Arcs, 2);                % sorting along row dimension
Arcs=sortrows(Arcs, 2);        % sorting along the second-column ascending order
Arcs=sortrows(Arcs, 1);        % sorting along the first-column ascending order
Arcs=unique(Arcs, 'rows');    % removing the row-along repetitions 
XYPS1=[X(Arcs(:, 1)), Y(Arcs(:, 1))];                        % coordinate of starting point at arc
XYPS2=[X(Arcs(:, 2)), Y(Arcs(:, 2))];                        % coordinate of ending point at arc
ArcDist=sum((XYPS1-XYPS2).^2, 2).^0.5;      % caculate Euclidean distance, 1-pixel unit == 20 m
II=find(ArcDist<=20000);                                      % look for short arcs with distance less than 1000 m
Arcs=Arcs(II,:);                                   
[R, C]=size(Arcs);
num_Arcs=R;
clear tri XYPS1 XYPS2 ArcDist
B_tri=coefmat(Arcs, num_Arcs, num_PS);    % compute coefficient matrix
R_tri=speye(R,R)-B_tri*inv(B_tri'*B_tri)*B_tri';   % compute redanduncy matrix
r_tri=diag(R_tri);  
clear B_tri R_tri;

subplot(1,2,2);
for j=1:length(II)
      plot(X(Arcs(j,:)), Y(Arcs(j,:)), 'k-', 'LineWidth', 1.5);
end
hold on; plot(X, Y, 'ob', 'MarkerSize', 8, 'MarkerEdgeColor','k',  'MarkerFaceColor','g');
box on; hold off; %axis image;
set(gca, 'XLim', [0.5, 6.5], 'YLim', [0.5, 6.5]);
set(gca, 'XTick', 0.5:1:6.5, 'YTick', 0.5:1:6.5); 
set(gca, 'XTickLabel', '', 'YTickLabel', '', 'LineWidth', 1.5);
grid on;


test=1;  

% Generating a coefficient matrix
function [A]=coefmat(Arcs, num_Arcs, num_PS);
     II=find(Arcs(:,1)~=1 &  Arcs(:,2)~=1);
     N1=Arcs(II,1)-1;
     N2=Arcs(II,2)-1;
     II=[II; II];
     N12=[N1; N2];
     SS=[-1*ones(size(N1)); 1*ones(size(N1))];
     clear N1 N2;
     A=sparse(II, N12, SS, num_Arcs, num_PS-1, 2*num_Arcs);      % Generated the design matrix (sparse)
     clear II N12 SS;
     % for arcs with starting point
     II=find(Arcs(:,1)==1);
     if length(II)~=0
         for i=1:length(II)
             n2=Arcs(II(i), 2);
             A(II(i), n2-1)=1;
         end
     end
     II=find(Arcs(:,2)==1);
     if length(II)~=0
         for i=1:length(II)
             n1=Arcs(II(i), 1);
             A(II(i), n1-1)=-1;
         end
     end
    
