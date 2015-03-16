function ph=myph
%MYPH -- Shades of color map
%   MYPH returns an 17-by-3 matrix containing a hsv-like colormap.
%   It is simialr to the Gamma 'mph' map,
%   and very suited for solely displaying interferometric phase.
%
%   For example, to reset the colormap of the current figure:
%     colormap(myph)
%
%   See also HSV, GRAY, COOL, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT, BRIGHTEN.

% Guoxiang Liu, 18/5/2006

ph=[
55 255 255
92 217 255
130 179 255
167 142 255
205 104 255
243 66   255
255 80   229
255 118 191
255 156 153
255 156 153
255 193 116
255 231 78
240 255 69
203 255 106
165 255 144
127 255 182
90 255 219];

ph=ph/255;





