; Chapter09CropWorld.pro
PRO Chapter09CropWorld
world = READ_PNG(FILEPATH('avhrr.png', $
SUBDIRECTORY = ['examples', 'data']), R,G,B)
DEVICE, DECOMPOSED = 0, RETAIN = 2
TVLCT, R, G, B
worldSize = SIZE(world, /DIMENSIONS)
WINDOW, 0, XSIZE = worldSize[0], YSIZE = worldSize[1]
TV, world
; 可以使用光标函数CURSOR选取裁剪区域，替代下面的数据
africa = world [312:475, 103:264]
WINDOW, 2, XSIZE =(475-312 + 1), YSIZE =(264-103 + 1)
TV, africa
END