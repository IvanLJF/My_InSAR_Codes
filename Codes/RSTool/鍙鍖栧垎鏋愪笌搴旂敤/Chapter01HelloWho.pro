;
; Chapter01HelloWho
;
PRO Chapter01HelloWho

    name=''
    read, name, prompt='请输入姓名:'  ;按提示信息输入姓名，并保存到变量name中
    print,'Hello, ', name, '!'        ;依次输出字符串Hello、变量name的值和字符串！

end

