% SARCoord2ECR_SBAS.m   
% 
% Calling as [Sat_Pos, XYZ, LLH, thi, dep, inc, b] = SARCoord2ECR_SBAS(M, r, t, f, h)
%           Conversion from SAR image coords
%           to ECR coords and getting unit vector in radar LOS
%
% Purpose: Given SAR image coords defined by radar slant range, time, 
%          Doppler frequency constraint, and the ellipsoidal height,
%          determining the Cartesian/geodetic coords (in ECR)  
%          of the point on the Earth surface
%
% Description: This function is essentially the inverse of
%          algorithm [sat_pos, b, range, time]=ECR2SARCoord_SBAS(LLH, dopp_cen_coefs).
%
% Input Parameters: 
%       M: Master satellite orbit model whose each component is represented 
%          by 4-order polynomial (Dim: 7 by 5)
%       r: slant range in meters from satellite to surface point
%       t: imaging time in seconds (azimuth position) of surface point
%             Note that the image coordinate system strongly depends on  
%             the processing Doppler frequency
%       f: Doppler frequency (=0 for zero Doppller coordinate system) 
%                            (<>0 for beam centred coordinate system) 
%       h: ellipsoidal height of the imaged point
%
% Output Parameters:
%       Sate_Pos: Satellite position  (Dim: 1 by 3)
%       XYZ: Cartesian coords in ECR  (Dim: 1 by 3)
%       LLH: Geodetic coords in ECR   (Dim: 1 by 3)
%       thi: radar looking angle      (complement of depression angle, in radian)
%       dep: radar depression angle   (in deg)
%       inc: local radar incidence angle  (in deg)
%         b: unit vector of radar LOS from sensor to ground (Dim: 3 by 1)
%
% Original Author:  Guoxiang LIU
% Revision History:
%                   August 28 2001 : Created, Guoxiang LIU
%

function [Sat_Pos, XYZ, LLH, thi, dep, inc, b] = SARCoord2ECR_SBAS(M, r, t, f, h)

max_iters=10000;
r_err_min=0.001;

% Getting the master orbit model parameters
% s='h:\thesis\orbits\mmdl_4order.txt';
% M=load(s);    % Loading master orbit model
%Tc=10503.692; % Original Time of orbit (central point)

% Computing instantaneous position and velocity of the platform
%tt=t-Tc;
[pm, vm]=Position_Velocity_SBAS(t, M);  % Velocity, Dim: 1X3
                                    % Position, Dim: 1X3

% Calculating unit vectors of coordinate axes  
% of local platform coordinate system

x=vm/sqrt(vm*vm');   % Unit vector for X axis
y=cross(x,pm);
y=y/sqrt(y*y');      % Unit vector for Y axis
z=cross(x,y);        % Unit vector for Z axis

% Evaluate Doppler angle (omega)
namdai=0.05656;      % Wavelength in meters of radar sensor
speed=sqrt(vm*vm');
omega=acos((f*namdai)/(2.0*speed));  % f=2*Vm*cos(omega)/namdai

% Given nominal values for the depression angle and antenna cone beamwidth 
dep=1.16937;       % in radians
width=0.0942478;   % in radians

% Evaluate unit vector (b) in direction from satellite to target on
% Earth surface. It is a unit vector in the Doppler cone,
% with the depression angle dep

% Take two initial depression angles & evaluate slant range to Earth.
dep_n=dep+width/2.0;
dep_n1=dep-width/2.0;

temp1=f*namdai/(2*speed);
temp2=sqrt(1-temp1^2);

b=x*temp1+y*cos(dep_n)*temp2+z*sin(dep_n)*temp2; % unit vector of radar LOS
[Range_n, XYZ]=EcrCoord_SBAS(pm',b',h);  % Invoke function to evaluate 
                                    % sensor-to-scatter range, ECR coords,
del_range_n=Range_n-r;              % range difference             
                                    
b=x*temp1+y*cos(dep_n1)*temp2+z*sin(dep_n1)*temp2;
[Range_n1, XYZ1]=EcrCoord_SBAS(pm',b',h);
del_range_n1=Range_n1-r;

dep_n2=dep_n1-del_range_n1*(dep_n1-dep_n)/(del_range_n1-del_range_n);
b=x*temp1+y*cos(dep_n2)*temp2+z*sin(dep_n2)*temp2;
[Range_n2, XYZ2]=EcrCoord_SBAS(pm',b',h);
del_range_n2=Range_n2-r;

count=0;
while count<max_iters
   dep_n=dep_n1;
   del_range_n=del_range_n1;
   dep_n1=dep_n2;
   del_range_n1=del_range_n2;
   dep_n2=dep_n1-del_range_n1*(dep_n1-dep_n)/(del_range_n1-del_range_n);
            
   b=x*temp1+y*cos(dep_n2)*temp2+z*sin(dep_n2)*temp2;
   [Range_n2, XYZ2]=EcrCoord_SBAS(pm',b',h);
   del_range_n2=Range_n2-r;
   
   count=count+1;
   if abs(del_range_n2)<r_err_min
      break;
   end
end


Sat_Pos=pm;             % Get satellite position      

XYZ=XYZ2;               % Get ECR coordinates
LLH=XYZ2LLH(XYZ2);      % Get geodetic coordinates
%thi=90-dep_n2*180/pi;   % Get radar looking angle
thi=pi/2-dep_n2;
dep=asin(b*z')*180/pi;

a=6378137.0+h;
c=6356752.0+h;

t(1)=XYZ(1)/a^2;
t(2)=XYZ(2)/a^2;
t(3)=XYZ(3)/c^2;
n=t/sqrt(t*t');         % Local outward normal

inc=acos(-b*n')*180/pi; % Local incidence angle

