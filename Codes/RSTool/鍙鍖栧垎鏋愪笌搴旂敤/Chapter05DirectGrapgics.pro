; Chapter05DirectGrapgics.pro
PRO Chapter05DirectGrapgics
mydevice = !D.NAME    ;获取当前设备，并存入变量mydevice
SET_PLOT, 'WIN'         ;设置当前设备为微软Windows
DEVICE, DECOMPOSED = 0    ;使用为伪彩显示模式
; 获取原始颜色表
TVLCT, OriginalR, OriginalG, OriginalB, /GET
WINDOW, TITLE = 'My Window', XPOS=100, YPOS=100, XSIZE=500, YSIZE=500
DEVICE, DECOMPOSED = 0
FOR i = 1,100 DO BEGIN
    LOADCT, i MOD 41
    TVSCL, DIST(500)
    WAIT, 0.1
    ;ERASE
ENDFOR
WDELETE
; 恢复原始颜色表
TVLCT, OriginalR, OriginalG, OriginalB
DEVICE, DECOMPOSED = 1    ;恢复为真彩显示模式
SET_PLOT, mydevice            ;恢复原始设备mydevice
END