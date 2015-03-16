% EcrCoord.m  
% 
% Calling as [Len, XYZ]=EcrCoord(R,b,h)
%
% Given a location (S) in space, defined by ECR location vector R, 
% and a direction specified by unit vector b,
% we can evaluate the ECR coordinates of the (nearest) 
% intersection (P) of a vector along b with a general ellipsoid surface (h=0) 
% or a extended surface (h<>0),  
% and the length (or radar range) from S to P. See following diagram,
%
%             S |  .
%                |   .
%                |    .
%                |     \./ Unit vector b
%                ^       .
%                |        .
% Vector R |        + P (Intersetion point on the ellipsoid surface)
%                |       .
%                |      .
%                |     .
%                |    .
%                |   .
%             o |  . (Center of the Earth mass)
%
% Usually, the ellipsoid surface is an Earth model, such as WGS84 with parameters:
% Radius of the semi-major axis: a=6378137.0 m 
% Radius of the semi-minor axis: c=6356752.0 m
%
% Original Author:  Guoxiang LIU
% Revision History:
%                   August 16 2001 : Created, Guoxiang LIU
%

function [Len, XYZ] = EcrCoord_SBAS(R,b,h)

[R1,C1]=size(R);
if R1~=3 | C1~=1
   error('The input coordinates is not at 3X1 dimension!!!')
end

[R1,C1]=size(b);
if R1~=3 | C1~=1
   error('The input unit direcion vector is not at 3X1 dimension!!!')
end

% Components of the coordinate at start point (S) 
rx=R(1);
ry=R(2);
rz=R(3);

% Components of the unit vector along the direction  
bx=b(1);
by=b(2);
bz=b(3);

% Parameters of the WGS84 ellipsoid 
% Calculate the local earth model taking into account the height
% information.  The equations below are a simplification of the
% more rigorous equation where the ellipsoid is exactly the height
% at the ECR surface point location. Since this is not known, it
% is this routine's job to estimate it, the height is used to adjust
% the polar and equatorial radii equally.
a=6378137.0+h;
c=6356752.0+h;

t1=bx*rx/a^2+by*ry/a^2+bz*rz/c^2;
t2=bx^2/a^2+by^2/a^2+bz^2/c^2;
t3=rx^2/a^2+ry^2/a^2+rz^2/c^2-1;

if t1^2<=t2*t3
   error('Invalid Earth surface intersection!')
end

Len1=(-t1+sqrt(t1^2-t2*t3))/t2;
Len2=(-t1-sqrt(t1^2-t2*t3))/t2;

%  Closest intersection is the one we want.
if abs(Len1)<=abs(Len2)
   Len=Len1;
else
   Len=Len2;
end;

%  Compute intersection coordinates & return.
XYZ=zeros(size(R));

XYZ=R+Len*b;
