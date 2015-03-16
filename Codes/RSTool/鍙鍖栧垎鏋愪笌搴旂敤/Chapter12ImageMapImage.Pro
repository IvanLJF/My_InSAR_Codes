; Chapter12ImageMapImage.Pro
PRO Chapter12ImageMapImage
    OPENR, lun, 'D:\RSI\IDL60\examples\data\worldelv.dat', /GET_LUN
    elev = BYTARR(360, 360)
    READU, lun, elev
    FREE_LUN, lun
    elev = SHIFT(elev, 180, 0)
    MAP_SET, 20, 80, /ORTHOGRAPHIC, /ISOTROPIC, /NOBORDER
    image = MAP_IMAGE(elev, x0, y0,xsize,ysize,COMPRESS=1,SCALE=0.05, $
            MISSING = 255, LATMIN=-90, LONMIN=-180, LATMAX=90, LONMAX=180)
    TVSCL, image, x0, y0, XSIZE = xsize, YSIZE = ysize
    color = !D.TABLE_SIZE - 1
    MAP_CONTINENTS, COLOR = color
    MAP_GRID, COLOR = color
END