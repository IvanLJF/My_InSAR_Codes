; Chapter04CubeVolumeMain.pro
PRO  Chapter04CubeVolumeMain
　　　TempVolume = 0
　　　READ,  PROMPT = "请输入长方体的长 x = ?", x
　　　READ,  PROMPT = "请输入长方体的宽 y = ?", y
　　　READ,  PROMPT = "请输入长方体的高 z = ?", z
　　　Chapter04CubeVolume, x, y, z, TempVolume
　　　PRINT, 'Cube Volume = ', TempVolume
END