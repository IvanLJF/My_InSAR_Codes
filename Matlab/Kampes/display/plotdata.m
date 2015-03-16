% 1. plotting the residual unwrapped data an its SVD residue at a PS point, which is obtained from 117
%     differential interferograms
% 2. plotting the time series of atmospheric effects at a PS point
% 3. plotting the time series of non-linear deformation at a PS point

function plotdata(unw, absPhi, B, imf);
% unw: unwrapped phases (vector: 1 by 117 interferograms)
% absPhi: solution of SVD (vector: 1 by 40 SAR images)
% B: design matrix of SVD (matrix: 117 by 39)
% imf: EMD results (2 by 40)

% Imaging dates of fourty SAR images over Phoenix study area
% msDates=[19920710    19920814    19920918    19921023    19930205    19930521    19930903    19931008    19931217  ...
%                   19950514    19950827    19951105    19951106    19951210    19951211    19960218    19960219    19960428  ...
%                   19960603    19960812    19960916    19961021    19961230    19970310    19970519    19971215    19980223  ...
%                   19980330    19980504    19980608    19980713    19981130    19990315    19990524    19990628    19990802  ...
%                   19991220    20000508    20000925    20001030]; 
msDates=[19920710    19920814    19920918    19921023    19930205    19930521    19930903    19931008    19931217 ...
                  19950514    19950827    19951105    19951106    19951210    19951211    19960218    19960219    19960428 ...
                  19960603    19960812    19960916    19961021    19961230    19970310    19970519    19971215    19980223 ...
                  19980330    19980504    19980608    19980713    19981130    19990315    19990524    19990628    19990802 ...
                  19991220    20000508    20001030];
              
 % Calculate residue of SVD
 [R, C]=size(B);
 res=1.0*5.6*(B*diff(absPhi')-unw')/(4*pi);       % in cm
 %res=5.6*randn(1, R)/(4*pi);        % in cm
 
 % plot both unw and res
 x=1:1:R;
 unw=5.6*unw/(4*pi);
 figure; plot(x, unw, 'bo', 'MarkerSize', 3.0);
 set(gcf, 'Position', [101   178   824   390]);
 hold on; plot(x, res, 'r+-', 'MarkerSize', 3.0);
 xlabel('Interferogram ID number', 'FontSize', 11);
 ylabel('Slant range variation (cm)', 'FontSize', 11);

 % plot time series
 x_days=zeros(1, length(msDates));
 for i=1:length(msDates)
     x_days(i)=datenum(num2str(msDates(i)), 'yyyymmdd');
 end
 absPhi=5.6*absPhi/(4*pi);
 imf=5.6*imf/(4*pi);         % in cm
 atm=imf(1,:)+0.2*imf(2,:);            % get atmospheric evolution
 nlr_def=0.8*imf(2,:)+imf(3,:)+imf(4,:);       % get non-linear deformation evolution
 figure; 
 set(gcf, 'Position', [166    75   703   605]);
 subplot(3,1,1);
 plot(x_days, absPhi, 'k-^', 'MarkerSize', 5.0);
 datetick('x', 'yyyy');
 %xlabel('Time (year)', 'FontSize', 11);
 ylabel('SVD solution (cm)', 'FontSize', 10);
 subplot(3,1,2);
 plot(x_days, atm, 'k-+', 'MarkerSize', 5.0);
 datetick('x', 'yyyy');
 %xlabel('Time (year)', 'FontSize', 11);
 ylabel('Atmosperhic delay (cm)', 'FontSize', 10);
 subplot(3,1,3); 
 plot(x_days, nlr_def, 'k-o', 'MarkerSize', 5.0);
 datetick('x', 'yyyy');
 xlabel('Time (year)', 'FontSize', 11);0
 ylabel('Nonlinear deformation (cm)', 'FontSize', 10);

 
                  