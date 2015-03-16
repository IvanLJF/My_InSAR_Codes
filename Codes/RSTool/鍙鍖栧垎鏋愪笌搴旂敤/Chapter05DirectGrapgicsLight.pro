; Chapter05DirectGrapgicsLight.pro
PRO Chapter05DirectGrapgicsLight
mydevice = !D.NAME    ;获取当前设备，并存入变量mydevice
SET_PLOT, 'WIN'         ;设置当前设备为微软Windows
DEVICE, DECOMPOSED = 0    ;使用为伪彩显示模式
; 获取原始颜色表
TVLCT, OriginalR, OriginalG, OriginalB, /GET
WINDOW, TITLE = 'My Window', XPOS=100, YPOS=100, XSIZE=400, YSIZE=400
DEVICE, DECOMPOSED = 0
MyR = INDGEN(256)
MyG = 150-INDGEN(256)
MyB = 250-INDGEN(256)
FOR i = 0, 255 DO BEGIN
    FOR j = 0, 255 DO BEGIN
        MyR = (MyR + j) Mod 256
        MyG = (MyG + j) Mod 256
        MyB = (MyB + j) Mod 256
        TVLCT, MyR, MyG, MyB
        TVSCL, DIST(400)
        WAIT, 0.005
    ENDFOR
ENDFOR
WDELETE
; 恢复原始颜色表
TVLCT, OriginalR, OriginalG, OriginalB
DEVICE, DECOMPOSED = 1    ;恢复为真彩显示模式
SET_PLOT, mydevice            ;恢复原始设备mydevice
END