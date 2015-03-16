;+
; :Description:
;    Output a global map in 'TIFF' format.
;
; :Params:
;    infilename     - Data file that will be ouput in map.
;    outfilename    - Output map filename.
;    title          - Title displayed in map.
;    scale          - Scale to resize the map.
;
;
;
; :Examples:
;    infilename = 'F:\TMPA\2A12.20030501.03Z.Calib'
;    outfilename = 'F:TMPA\2A12.20030501.03Z.Calib.tif'
;    title = '2A12.20030501.03Z.Calib Rainrate'
;    scale = 0.5
;    make_map_global, infilename, outfilename, title, scale
; :History:
;   Modified from Liu Qiang's version.
;   
; :Author: Dabin Ji
; :Email: dabinj@gmail.com
; :Date: 2010-11-24
;-
;---------------------------------------------------
; rainbow
;---------------------------------------------------
;+
; :Description:
;    Return rainbow color table.
;
;
;
;
;
; :Examples:
;   color_table = rainbow_palette()
; :History:
;
; :Author: Dabin Ji
; :Email: dabinj@gmail.com
; :Date: 2010-11-24
;-
FUNCTION rainbow_palette
    COMPILE_OPT IDL2
    
    ;Rainbow color table.
    pal = [ [255,  255,   255],$    
            [  0,    0,     0 ],$    
            [120,    0,   255],$    
            [115,    0,   255],$    
            [111,    0,   255],$    
            [106,    0,   255],$    
            [102,    0,   255],$    
            [ 97,    0,   255],$    
            [ 93,    0,   255],$    
            [ 88,    0,   255],$    
            [ 84,    0,   255],$    
            [ 79,    0,   255],$    
            [ 75,    0,   255],$    
            [ 70,    0,   255],$    
            [ 66,    0,   255],$    
            [ 61,    0,   255],$    
            [ 57,    0,   255],$    
            [ 52,    0,   255],$    
            [ 48,    0,   255],$    
            [ 43,    0,   255],$    
            [ 39,    0,   255],$    
            [ 34,    0,   255],$    
            [ 30,    0,   255],$    
            [ 25,    0,   255],$    
            [ 21,    0,   255],$    
            [ 16,    0,   255],$    
            [ 12,    0,   255],$    
            [  7,    0,   255],$    
            [  3,    0,   255],$    
            [  0,    2,   255],$    
            [  0,    6,   255],$    
            [  0,   11,   255],$    
            [  0,   15,   255],$    
            [  0,   20,   255],$    
            [  0,   24,   255],$    
            [  0,   29,   255],$    
            [  0,   33,   255],$    
            [  0,   38,   255],$    
            [  0,   42,   255],$    
            [  0,   47,   255],$    
            [  0,   51,   255],$    
            [  0,   56,   255],$    
            [  0,   60,   255],$    
            [  0,   65,   255],$    
            [  0,   69,   255],$    
            [  0,   74,   255],$    
            [  0,   78,   255],$    
            [  0,   83,   255],$    
            [  0,   87,   255],$    
            [  0,   92,   255],$    
            [  0,   96,   255],$    
            [  0,  101,   255],$    
            [  0,  105,   255],$    
            [  0,  110,   255],$    
            [  0,  114,   255],$    
            [  0,  119,   255],$    
            [  0,  123,   255],$    
            [  0,  128,   255],$    
            [  0,  132,   255],$    
            [  0,  137,   255],$    
            [  0,  141,   255],$    
            [  0,  146,   255],$    
            [  0,  150,   255],$    
            [  0,  155,   255],$    
            [  0,  159,   255],$    
            [  0,  164,   255],$    
            [  0,  168,   255],$    
            [  0,  173,   255],$    
            [  0,  177,   255],$    
            [  0,  182,   255],$    
            [  0,  186,   255],$    
            [  0,  191,   255],$    
            [  0,  195,   255],$    
            [  0,  200,   255],$    
            [  0,  204,   255],$    
            [  0,  209,   255],$    
            [  0,  213,   255],$    
            [  0,  218,   255],$    
            [  0,  222,   255],$    
            [  0,  227,   255],$    
            [  0,  231,   255],$    
            [  0,  236,   255],$    
            [  0,  241,   255],$    
            [  0,  245,   255],$    
            [  0,  250,   255],$    
            [  0,  254,   255],$    
            [  0,  255,   251],$    
            [  0,  255,   247],$    
            [  0,  255,   242],$    
            [  0,  255,   238],$    
            [  0,  255,   233],$    
            [  0,  255,   229],$    
            [  0,  255,   224],$    
            [  0,  255,   220],$    
            [  0,  255,   215],$    
            [  0,  255,   211],$    
            [  0,  255,   206],$    
            [  0,  255,   202],$    
            [  0,  255,   197],$    
            [  0,  255,   193],$    
            [  0,  255,   188],$    
            [  0,  255,   184],$    
            [  0,  255,   179],$    
            [  0,  255,   175],$    
            [  0,  255,   170],$    
            [  0,  255,   166],$    
            [  0,  255,   161],$    
            [  0,  255,   157],$    
            [  0,  255,   152],$    
            [  0,  255,   148],$    
            [  0,  255,   143],$    
            [  0,  255,   139],$    
            [  0,  255,   134],$    
            [  0,  255,   130],$    
            [  0,  255,   125],$    
            [  0,  255,   121],$    
            [  0,  255,   116],$    
            [  0,  255,   112],$    
            [  0,  255,   107],$    
            [  0,  255,   103],$    
            [  0,  255,    98],$    
            [  0,  255,    94],$    
            [  0,  255,    89],$    
            [  0,  255,    85],$    
            [  0,  255,    80],$    
            [  0,  255,    76],$    
            [  0,  255,    71],$    
            [  0,  255,    67],$    
            [  0,  255,    62],$    
            [  0,  255,    58],$    
            [  0,  255,    53],$    
            [  0,  255,    49],$    
            [  0,  255,    44],$    
            [  0,  255,    40],$    
            [  0,  255,    35],$    
            [  0,  255,    31],$    
            [  0,  255,    26],$    
            [  0,  255,    22],$    
            [  0,  255,    17],$    
            [  0,  255,    13],$    
            [  0,  255,     8],$    
            [  0,  255,     4],$    
            [  1,  255,     0],$    
            [  5,  255,     0],$    
            [ 13,  255,     0],$    
            [ 14,  255,     0],$    
            [ 19,  255,     0],$    
            [ 23,  255,     0],$    
            [ 28,  255,     0],$    
            [ 32,  255,     0],$    
            [ 37,  255,     0],$    
            [ 41,  255,     0],$    
            [ 46,  255,     0],$    
            [ 50,  255,     0],$    
            [ 55,  255,     0],$    
            [ 59,  255,     0],$    
            [ 64,  255,     0],$    
            [ 68,  255,     0],$    
            [ 73,  255,     0],$    
            [ 77,  255,     0],$    
            [ 82,  255,     0],$    
            [ 86,  255,     0],$    
            [ 91,  255,     0],$    
            [ 95,  255,     0],$    
            [100,  255,     0],$    
            [104,  255,     0],$    
            [109,  255,     0],$    
            [113,  255,     0],$    
            [118,  255,     0],$    
            [123,  255,     0],$    
            [127,  255,     0],$    
            [132,  255,     0],$    
            [136,  255,     0],$    
            [141,  255,     0],$    
            [145,  255,     0],$    
            [150,  255,     0],$    
            [154,  255,     0],$    
            [159,  255,     0],$    
            [163,  255,     0],$    
            [168,  255,     0],$    
            [172,  255,     0],$    
            [177,  255,     0],$    
            [181,  255,     0],$    
            [186,  255,     0],$    
            [190,  255,     0],$    
            [195,  255,     0],$    
            [199,  255,     0],$    
            [204,  255,     0],$    
            [208,  255,     0],$    
            [213,  255,     0],$    
            [217,  255,     0],$    
            [222,  255,     0],$    
            [226,  255,     0],$    
            [231,  255,     0],$    
            [235,  255,     0],$    
            [240,  255,     0],$    
            [244,  255,     0],$    
            [249,  255,     0],$    
            [253,  255,     0],$    
            [255,  252,     0],$    
            [255,  248,     0],$    
            [255,  243,     0],$    
            [255,  239,     0],$    
            [255,  234,     0],$    
            [255,  230,     0],$    
            [255,  225,     0],$    
            [255,  221,     0],$    
            [255,  216,     0],$    
            [255,  212,     0],$    
            [255,  207,     0],$    
            [255,  203,     0],$    
            [255,  198,     0],$    
            [255,  194,     0],$    
            [255,  189,     0],$    
            [255,  185,     0],$    
            [255,  180,     0],$    
            [255,  176,     0],$    
            [255,  171,     0],$    
            [255,  167,     0],$    
            [255,  162,     0],$    
            [255,  158,     0],$    
            [255,  153,     0],$    
            [255,  149,     0],$    
            [255,  144,     0],$    
            [255,  140,     0],$    
            [255,  135,     0],$    
            [255,  131,     0],$    
            [255,  126,     0],$    
            [255,  122,     0],$    
            [255,  117,     0],$    
            [255,  113,     0],$    
            [255,  108,     0],$    
            [255,  104,     0],$    
            [255,   99,     0],$    
            [255,   95,     0],$    
            [255,   90,     0],$    
            [255,   86,     0],$    
            [255,   81,     0],$    
            [255,   77,     0],$    
            [255,   72,     0],$    
            [255,   68,     0],$    
            [255,   63,     0],$    
            [255,   59,     0],$    
            [255,   54,     0],$    
            [255,   50,     0],$    
            [255,   45,     0],$    
            [255,   41,     0],$    
            [255,   36,     0],$    
            [255,   32,     0],$    
            [255,   27,     0],$    
            [255,   23,     0],$    
            [255,   18,     0],$    
            [255,   14,     0],$    
            [255,    9,     0],$    
            [255,    5,     0],$    
            [255,    5,     0]]


    RETURN, pal
END




PRO make_map_global, infilename, outfilename, title, scale
    COMPILE_OPT IDL2


    ;Defind color table, Rainbow.
    color_tbl = rainbow_palette()
    color_tbl = REVERSE(color_tbl, 2)
    color_tbl_size = SIZE(color_tbl, /DIMENSIONS)
       
    ;Read data from input file.
    READ_ENVI_IMAGE, infilename, img, img_cols, img_rows, type, offset, map_info
    img = REVERSE(TEMPORARY(img), 2)
    
    cols = 1440
    rows = 720
    
    tmp_img = FLTARR(cols, rows)
    row_pos = (rows - img_rows) / 2 - 1
    tmp_img[0:1439, row_pos : row_pos + img_rows - 1] = img[*, *, 0]
    
    ;Set the output map size
    map_size = [FIX(cols / 0.8), FIX(rows / 0.8)]
    
    plot_x_pos = 0.06
    plot_y_pos = 0.08
    
    ;set the position of img in the map
    img_pos = [FIX(map_size[0] * plot_x_pos), FIX(map_size[1] * plot_y_pos)]
    
    ;Initialize R, G, B color table.
    red_tbl = color_tbl[0, *]
    green_tbl = color_tbl[1, *]
    blue_tbl = color_tbl[2, *]
    
    ;Create display image.
    dis_img = MAKE_ARRAY(map_size[0], map_size[1], TYPE = type)
    dis_img[img_pos[0] : (img_pos[0] + cols - 1), img_pos[1] : (img_pos[1] + rows - 1)] = tmp_img[*, *]
    
    ;Density slice
    idx0 = WHERE(dis_img EQ 0, idx0_count)
    idx1 = WHERE(dis_img GT 0 AND dis_img LE 0.2, idx1_count)
    idx2 = WHERE(dis_img GT 0.2 AND dis_img LE 0.4, idx2_count)
    idx3 = WHERE(dis_img GT 0.4 AND dis_img LE 0.6, idx3_count)
    idx4 = WHERE(dis_img GT 0.6 AND dis_img LE 0.8, idx4_count)
    idx5 = WHERE(dis_img GT 0.8 AND dis_img LE 1.0, idx5_count)
    idx6 = WHERE(dis_img GT 1.0 AND dis_img LE 1.5, idx6_count)
    idx7 = WHERE(dis_img GT 1.5 AND dis_img LE 2.5, idx7_count)
    idx8 = WHERE(dis_img GT 2.5 AND dis_img LE 5.0, idx8_count)
    idx9 = WHERE(dis_img GT 5.0 AND dis_img LE 10.0, idx9_count)
    idx10 = WHERE(dis_img GT 10.0 AND dis_img LE 20.0, idx10_count)
    idx11 = WHERE(dis_img GT 20.0 AND dis_img LE 30.0, idx11_count)
    idx12 = WHERE(dis_img GT 30.0, idx12_count)
    
    IF (idx0_count GT 0) THEN dis_img[idx0] = 255
    IF (idx1_count GT 0) THEN dis_img[idx1] = 253
    IF (idx2_count GT 0) THEN dis_img[idx2] = 230
    IF (idx3_count GT 0) THEN dis_img[idx3] = 207
    IF (idx4_count GT 0) THEN dis_img[idx4] = 184
    IF (idx5_count GT 0) THEN dis_img[idx5] = 161
    IF (idx6_count GT 0) THEN dis_img[idx6] = 138
    IF (idx7_count GT 0) THEN dis_img[idx7] = 115
    IF (idx8_count GT 0) THEN dis_img[idx8] = 92
    IF (idx9_count GT 0) THEN dis_img[idx9] = 69
    IF (idx10_count GT 0) THEN dis_img[idx10] = 46
    IF (idx11_count GT 0) THEN dis_img[idx11] = 23
    IF (idx12_count GT 0) THEN dis_img[idx12] = 0
     
    ;Create Legend.
    legend_cols = 25
    legend_rows = color_tbl_size[1] * 2
    legend = MAKE_ARRAY(legend_cols, legend_rows, TYPE = type)
    legend_step = 2
    FOR i = 0, color_tbl_size[1] - 2 DO BEGIN
        legend[*, i * legend_step : (i + 1) * legend_step - 1] = color_tbl_size[1] - i - 2
    ENDFOR
    legend[*, i * legend_step : legend_rows - 1] = color_tbl_size[1] - i - 2
    
    
    ;Draw ticks and borders in legend.
    legend[0, *] = 254
    legend[legend_cols - 1, *] = 254
    legend[*, 0] = 254
    legend[*, legend_rows - 1] = 254
    legend[*, legend_rows - 2] = 254
    FOR k = 1, 10 DO BEGIN
        legend[*, k * 23 * 2 : k * 23 * 2 + 1] = 254
    ENDFOR


    
    legend_xpos = ROUND(map_size[0] * (plot_x_pos + 0.8 + 0.05))
    legend_ypos = img_pos[1] + (rows - color_tbl_size[1] * 2) / 2
    dis_img[legend_xpos : (legend_xpos + legend_cols - 1), legend_ypos : (legend_ypos + legend_rows - 1)] = legend
    
    ;Resize the output imag by scale.
    re_map_size = map_size * scale
    dis_img = CONGRID(dis_img, re_map_size[0], re_map_size[1])
    
    DEVICE, DECOMPOSED = 0
    TVLCT, red_tbl, green_tbl, blue_tbl
    WINDOW, XSIZE = re_map_size[0], YSIZE = re_map_size[1]
    TV, dis_img
    
    ;Overlap continents map.
    map_limit = [-90, -180, 90, 180]
    map_pos = [plot_x_pos, plot_y_pos, plot_x_pos + 0.8, plot_y_pos + 0.8]
    color = 254
    MAP_SET, LIMIT = map_limit, POSITION = map_pos, /NOBORDER, /NOERASE, /CONTINENTS, COLOR = color
    
    ;Plot axies
    xrange = [-180, 180]
    yrange = [-90, 90]
    xticknames = ['180W', '150W', '120W', '90W', '60W', '30W', '0', '30E', '60E', '90E', '120E', '150E', '180E']
    yticknames = ['90S', '60S', '30S', '0', '30N', '60N', '90N']
    AXIS, XAXIS = 0, XRANGE = xrange, COLOR = color, /DEVICE, /NOERASE, XTICKINTERVAL = 30, $
          XMINOR = 1, XSTYLE = 1, XTICKNAME = xticknames, FONT = 0


    AXIS, XAXIS = 1, XRANGE = xrange, COLOR = color, /DEVICE, /NOERASE, XTICKINTERVAL = 30, $
          XMINOR = 1, XSTYLE = 1, XTICKNAME = xticknames, FONT = 0


    AXIS, YAXIS = 0, YRANGE = yrange, COLOR = color, /DEVICE, /NOERASE, YTICKINTERVAL = 30, $
          YMINOR = 1, YSTYLE = 1, TICKLEN = 0.01, YTICKNAME = yticknames, FONT = 0


    AXIS, YAXIS = 1, YRANGE = yrange, COLOR = color, /DEVICE, /NOERASE, YTICKINTERVAL = 30, $
          YMINOR = 1, YSTYLE = 1, TICKLEN = 0.01, YTICKNAME = yticknames, FONT = 0
          
    ;Draw legend text
    txt_legend = ['0.0', '0.2', '0.4', '0.6', '0.8', '1.0', '1.5', '2.5', '5.0', '10.0', '20.0', '30.0']
    txt_x_pos = (legend_xpos + legend_cols) * scale
    FOR j = 0, N_ELEMENTS(txt_legend) - 1 DO BEGIN
        txt_y_pos = (legend_ypos + j * 46 - 8) * scale
        XYOUTS, txt_x_pos, txt_y_pos, txt_legend[j], CHARSIZE = 2.5 * scale, CHARTHICK = 2 * scale, COLOR = color, /DEVICE, FONT = 0
    ENDFOR
    XYOUTS, txt_x_pos, txt_y_pos + 40 * scale, '[mm/h]', CHARSIZE = 2.5 * scale, CHARTHICK = 2 * scale, COLOR = color, /DEVICE, FONT = 0
    
    ;Draw Title
    title_pos = [img_pos[0], map_size[1] * 0.94] * scale
    XYOUTS, title_pos[0], title_pos[1], title, CHARSIZE = 5 * scale, CHARTHICK = 3.5 * scale, COLOR = color, /DEVICE, FONT = 0
    
    WRITE_IMAGE, outfilename, 'TIFF', REVERSE(TVRD(TRUE = 1), 3)
    DEVICE, DECOMPOSED = 1
END
