; Chapter04ScoreGrade.pro
PRO  Chapter04ScoreGrade
m = " "
READ, PROMPT="请输入等级（A , B, C, D, or E）：", m
m = STRUPCASE(m)
SWITCH  m  of
       'A' :
       'B' :
       'C' :
       'D' : BEGIN
                PRINT, "Score >= 60！ ", m + "级，" ,  "通过考试！"
                BREAK
              END
        'E' :  PRINT, " Score < 60！ ", m  + "级，" ,  "没有通过考试！"
ENDSWITCH
END