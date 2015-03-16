; 程序名称:
; VAR_TYPE
;
; 程序目的:
; 返回数值的类型
; 
; 示例:
;	定义一个浮点数
;	  x = 1.2
;	找出其数值类型
;	  result = var_type( x, /help )
;
;***********************************************************************

FUNCTION VAR_TYPE, Invar             $
                 , HELP=helpopt      $
                 , TEXT=text
 
;***********************************************************************
; 检查变量类型

  siz = size(invar)
  type = siz[ siz[0]+1 ]

  names = ['Undefined','Byte','Integer','Longword integer' $
          ,'Floating point','Double-precision floating'    $
          ,'Complex floating','String','Structure'         $
          ,'Double-precision complex floating'             $
          ,'Pointer','Object reference']

; 如果设置了帮助选项则输出类型名称
  if (Keyword_Set(helpopt)) then begin
    Print, names[type]
  endif
  
  if (Keyword_Set(text)) then type=names[type]

;***********************************************************************
;返回数据类型

  return, type
END
