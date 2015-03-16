; Chapter12DataMapImage.Pro
PRO Chapter12DataMapImage
    image = BYTSCL(SIN(DIST(400)/10))
    latmin = -65
    latmax = 65
    lonmin = 160
    lonmax = -70 + 360
    MAP_SET, 0, -140, /ORTHOGRAPHIC, /ISOTROPIC, LIMIT=[latmin,lonmin,latmax,lonmax]
    result = MAP_IMAGE(image,Startx,Starty, COMPRESS=1, $
                       LATMIN=latmin, LONMIN=lonmin, LATMAX=latmax, LONMAX=lonmax)
    TV, result, Startx, Starty
    MAP_GRID, latdel=10, londel=10, /LABEL, /HORIZON
    MAP_CONTINENTS, /coasts
END