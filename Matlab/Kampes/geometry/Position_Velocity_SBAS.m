% Evaluating orbital state vector
% 
% Calling as [Pos, Vel]=Position_Velocity(Tm, Mm)
%
% Purpose:     Computing the orbital position and velocity at a given time, 
%              and definite orbit model of whose each component is represented
%              by a high-order polynomial (6 freedom: 3 position components plus
%                                                     3 velocity components)
%              
% Input data:  Tm: Specific time of the orbit;
%              Mm: Orbital models in dimension of 7 by 1: The first row is for time. 
%
% Output data: Pos: Orbital position at given time (Time)
%              Vel: Velocity at given time (Time)             
%
% Original Author:  Guoxiang LIU
% Revision History:
%                   August 19 2001 : Created, Guoxiang LIU
%
function [Pos, Vel]=Position_Velocity_SBAS(Tm, Mm)

% First, calculating every component of position and velocity at Tm along an obit

xs=polyval(Mm(1,:), Tm);
ys=polyval(Mm(2,:), Tm);
zs=polyval(Mm(3,:), Tm);   % 3 position components

vxs=polyval(Mm(4,:), Tm);
vys=polyval(Mm(5,:), Tm);
vzs=polyval(Mm(6,:), Tm);  % 3 velocity components

Vel=[vxs, vys, vzs];  % Velocity, Dim: 1X3
Pos=[xs, ys, zs];     % Position, Dim: 1X3

