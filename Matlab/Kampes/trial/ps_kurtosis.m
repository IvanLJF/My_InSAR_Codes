function [ kur, coh]=ps_kurtosis(num_intf, DIntf, thi, R, Bperp, dT, dv_inc, ddh_inc, Xdv, Xddh);
%  function [dv, ddh]=ps_kurtosis(num_intf, DIntf, thi, R, Bperp, dT, dv_inc, ddh_inc, Xdv, Xddh);
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
%       kur----------------sample kurtosis of the model-coherence surface
%       coh---------------maximum model coherence
%
%  e.g.,  kur=ps_kurtosis(num_intf, DIntf, thi, R, Bperp, dT, dv_inc, ddh_inc, Xdv, Xddh);
% 
% Original Author:  Guoxiang LIU
% Revision History:
%                   Apr. 12, 2006: Created, Guoxiang LIU

Lamda=56;   % ERS C-band radar wavelength in mm

% Forming the objective function to be optimised
L1=4*pi/Lamda;                % Constant 1

str=[];                     % for objective function
dph=DIntf(:, 2)-DIntf(:, 1);        % difference (in radian) of differential phase values between to PS points
coef_dv=L1*dT;                      % Coefficient for range-displacement increment between two PS points
coef_ddh=L1*1000*Bperp./(R.*sin(thi));    % Coefficient for height-error increment between two PS points

for i=1:num_intf          % loop on all differential interferograms
    str=[str '+exp(j*(' num2str(dph(i), 6) '-(' num2str(coef_dv(i), 8) '*x' '+' num2str(coef_ddh(i), 8) '*y)))'];
end

str=['abs(', str, ')/', num2str(num_intf)];
fun=inline(str);    % fomring a objective function
y=feval(fun, Xdv, Xddh);
coh=max(y);
kur=(coh-mean(y));               % returns the sample kurtosis of the model-coherence surface in y

Xdv=reshape(Xdv, 281, 281);
Xddh=reshape(Xddh, 281, 281);
y=reshape(y, 281, 281);

disp(['Kurtosis=', num2str(kur), '          Max. coherence=', num2str(coh)]);

figure; 
set(gcf, 'Position', [309   168   404   368]);
surf(Xdv, Xddh, y);
%imagesc(y); axis image;
colormap(jet);
shading interp;
set(gca, 'FontSize', 10.5);
%xlabel('\bf\it\Deltav \rm(mm/day)','FontSize',18);
xlabel('\it\Deltav \rm(mm/day)','FontSize',11);
%ylabel('\bf\it\Delta\epsilon \rm(m)','FontSize',18);
ylabel('\it\Delta\epsilon  \rm(m)','FontSize',11);
%zlabel('\bf\gamma','FontSize',18);
zlabel('MC  \gamma','FontSize',11);
set(gca, 'YTick', -20:10:20);
set(gca, 'XTick', -0.2:0.1:0.2);

%axis([-0.2 0.2 -20 20 0 1]);

test=1;
pause;
