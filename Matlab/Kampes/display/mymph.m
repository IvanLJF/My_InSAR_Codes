function mph=mymph
%MYMPH -- Shades of color map
%   MYPH returns an 17-by-3 matrix containing a hsv-like colormap.
%   It is simialr to the Gamma 'mph' map,
%   and very suited for displaying interferometric phase superimposed on magnitude image.
%
%   For example, to reset the colormap of the current figure:
%     colormap(mymph)
%
%   See also HSV, GRAY, COOL, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT, BRIGHTEN.

% Guoxiang Liu, 18/5/2006

mph=[
136   83  81
136 102  61
136 123  41
128 136  36
108 136  56
  88 136  76
  67 136  97
  48 136 116
  29 136 136
  49 115 136
  69  95  136
  89  75  136
 109 55  136
 129 35  136
 136 42  122
 136 62  101
 136 83   81];

mph=mph/255;