% read SRTM DEM data and convert into data points (x, y, h)
DEM=freadbk('F:\Phoniex\DEM\Phoenix_90m_DEM\76516494.flt', 2400, 'float32');
DEM=flipud(DEM);
xLL=-113.50000001043;
yLL=32.433333336975;
xSize=0.00083333333329992;
ySize=0.00083333333329992;

fid=fopen('F:\Phoniex\DEM\Phoenix_90m_DEM\PhXYH.dat', 'wt');
rN=2400;
cN=3000;
for i=1:rN
    y=yLL+(i-1)*ySize;
    for j=1:cN
        x=xLL+(j-1)*xSize;
        if DEM(i,j)~=-9999
              fprintf(fid, '%15.8f %15.8f %15.8f\n', x, y, DEM(i,j));
        end
    end
end
fclose(fid);