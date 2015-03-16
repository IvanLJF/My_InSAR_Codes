function [dv, ddh, coh]=incsolut(num_intf, DIntf, thi, R, Bperp, dT, dv_inc, ddh_inc, Xdv, Xddh)
% 通过获取最大的一致性值预测两个相邻PS点的形变率增量和DEM误差
%  function [dv, ddh]=incsolut(num_intf, DIntf, thi, R, Bperp, dT, dv_inc, ddh_inc, Xdv, Xddh);
%
% Estimating increment of deformation rate and DEM error between 
% two neighbouring permanent scatterers (PS) by means of maximizing 
% model coherence value (see Ferretti et al., 2000, IEEE) 
% 
% Input:
%       num_intf-------total number of all interferograms
%       DIntf------------a num_intf-by-2 matrix, i.e., time series differential phase values 
%                              at the first [Dintf(:,1)] and the second [Dintf(:,2)] PS (in radian)
%       thi---------------a num_intf-by-1 matrix, i.e., radar look angle averaged from two PS points (in radian) 
%       R----------------a num_intf-by-1 matrix, i.e., slant ranges averaged from two PS points (in meter)
%       Bperp----------a num_intf-by-1 matrix, i.e., perpendicular baselines averaged from two PS points (in meter)
%       dT---------------a num_intf-by-1 vector, time intervals of interefreograms (in days) 
%       dv_inc----------grid size of velocity-increment dimension (mm/day)
%       ddh_inc--------grid size of height-error-increment dimension (m)
%       Xdv-------------coarse-grid solution space of velocity increments
%       Xddh-----------coarse-grid solution space of height-error increments
%
% Output:
%       dv----------------increment of range-displacement velocities between two neighbouring PS points
%       ddh--------------increment of height corrections between two neighbouring PS points
%       coh--------------maximum model coherence
%
%  e.g.,  [dv, ddh, coh]=incsolut(num_intf, DIntf, thi, R, Bperp, dT, dv_inc, ddh_inc, Xdv, Xddh);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Apr. 12, 2006: Created, Guoxiang LIU

Lamda=56;   % ERS C-band radar wavelength in mm

% Forming the objective function to be optimised
% let unknowns be x(1) and x(2),
% x(1) == increment of range-displacement velocity
% x(2) == increment of height errors
L1=4*pi/Lamda;                % Constant 1

% options=optimset('Display','off');   % set up optimization without any display
% options = optimset(options, 'TolFun',1e-12);
% options = optimset(options,'TolX', 1e-8);
% options = optimset(options, 'DiffMaxChange', 0.0001);
% warning  off      %('OFF', 'MSGID');           % disable and enable the display of any warning tagged with message identifier MSGID

% The following part has been moved into "dvddharcs.m"  (June 30, 2006)
% dv_low=-0.03;     % -0.1;          % mm/day; for velocity increment
% dv_up=0.03;         % 0.1;
% 
% ddh_low=-15;        % in meters, for height-error increment
% ddh_up=15;
% 
% dv_size=21;   %50;         % grid size for searching solution
% ddh_size=21; %50;
% 
% dv_inc=(dv_up-dv_low)/(dv_size-1);              % get tiny velocity increment corresponding to each grid size
% ddh_inc=(ddh_up-ddh_low)/(ddh_size-1);     % get tiny height-error increment corresponding to each grid size
% 
% dv_try=[dv_low:dv_inc:dv_up];                       % all possible veclocity increments at all grid points
% ddh_try=[ddh_low:ddh_inc:ddh_up];              % all possible height-error increments at all grid points
% 
% [DV, DDH]=meshgrid(dv_try, ddh_try);            
% Xdv=reshape(DV, prod(size(DV)), 1);
% Xddh=reshape(DDH, prod(size(DDH)), 1);

str=[];                     % for objective function
% str1=[];
dph=DIntf(:, 2)-DIntf(:, 1);        % difference (in radian) of differential phase values between to PS points
coef_dv=L1*dT;                      % Coefficient for range-displacement increment between two PS points
coef_ddh=L1*1000*Bperp./(R.*sin(thi));    % Coefficient for height-error increment between two PS points

for i=1:num_intf          % loop on all differential interferograms
    str=[str '+exp(j*(' num2str(dph(i), 6) '-(' num2str(coef_dv(i), 8) '*x' '+' num2str(coef_ddh(i), 8) '*y)))'];
    %str1=[str1 '+exp(j*(' num2str(dph(i), 6) '-(' num2str(coef_dv(i), 8) '*x(1)' '+' num2str(coef_ddh(i), 8) '*x(2))))'];    
end

str=['abs(', str, ')/', num2str(num_intf)];
fun=inline(str);    % fomring a objective function
y=feval(fun, Xdv, Xddh);
[coh_max, II]=max(y);
tt(1)=Xdv(II);
tt(2)=Xddh(II);                    % intial solution obtained from coarse-grid solution space

dvinc=2*dv_inc/20;
ddhinc=2*ddh_inc/20;
dv_try=[tt(1)-dv_inc:dvinc:tt(1)+dv_inc];                       % all possible veclocity increments at all grid points
ddh_try=[tt(2)-ddh_inc:ddhinc:tt(2)+ddh_inc];              % all possible height-error increments at all grid points
[DV, DDH]=meshgrid(dv_try, ddh_try);            
Xdv=reshape(DV, prod(size(DV)), 1);
Xddh=reshape(DDH, prod(size(DDH)), 1);
y=feval(fun, Xdv, Xddh);
[coh, II]=max(y);
x(1)=Xdv(II);
x(2)=Xddh(II);                    % final solution obtained from fine-grid solution space

% str1=['-abs(', str1, ')/', num2str(num_intf)];
% fun=inline(str1);
% [x, coh]=fmincon(fun, [0; 0], [], [], [], [], [-0.03; -15], [0.03; 15], [], options);
%[x, coh]=fmincon(fun, [tt(1); tt(2)], [], [], [], [], [-dv_inc+tt(1); -ddh_inc+tt(2)], [dv_inc+tt(1); ddh_inc+tt(2)], [], options);
                      % It results in a very good refinement to the initial solution.

% output for deformation velocity and height error
dv=x(1);     % unit: mm/day, increment of deformation velocity
ddh=x(2);   % unit: m, increment of height error
coh=abs(coh);
warning on