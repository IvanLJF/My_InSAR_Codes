; Chapter04TestRunTime2.pro
PRO Chapter04TestRunTime2
　　MyVariable = DIST(1000, 1000)
　　Sum = 0.0
　　StartTime = SYSTIME(/SECONDS)
　　Sum = TOTAL(MyVariable)
　　EndTime = SYSTIME(/SECONDS)
　　PRINT, '数组的和：', Sum
　　PRINT, '使用时间：' , EndTime - StartTime
END