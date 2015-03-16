; Chapter04Exe62Sub.pro
FUNCTION Chapter04Exe62Sub, X, Y, D
　　HELP, X, Y, D
　　PRINT, X, Y, D
　　X = X + 'U'
　　Y = Y + 'V'
　　D = X + Y
　　A = 'W'
　　HELP,  X, Y, D, A
　　PRINT, X, Y, D, A
　　RETURN, A
END