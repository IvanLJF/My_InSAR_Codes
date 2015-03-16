; Chapter04Exe62.pro
PRO  Chapter04Exe62
　　A = 'A'
　　B = 'B'
　　C = 'C'
　　D = 'D'
　　HELP, A, B, C, D
　　PRINT, A, B, C, D
　　E = Chapter04Exe62Sub(A, B, C)
　　HELP, A, B, C, D
　　PRINT, A, B, C, D
　　E = Chapter04Exe62Sub(A, B, D)
　　HELP, A, B, C, D
　　PRINT, A, B, C, D
END