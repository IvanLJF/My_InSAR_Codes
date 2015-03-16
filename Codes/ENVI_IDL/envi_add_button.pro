PRO Envi_file_info_define_buttons, buttonInfo
; 创建主菜单-在Basic Tools菜单前后
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '自定义菜单after', $
    /MENU, REF_VALUE = 'Basic Tools', /SIBLING, POSITION = 'after'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '自定义菜单before', $
    /MENU, REF_VALUE = 'Basic Tools', /SIBLING, POSITION = 'before'
    
;创建子菜单
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '功能都有了，添加点儿啥呢？', $
    uValue = '', $
    event_pro ='Envi_file_info', $
    REF_VALUE = '自定义菜单before'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '确实不好加！', $
    uValue = '', $
    event_pro ='Envi_file_info', $
    REF_VALUE = '自定义菜单before'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '加分隔线咋样？', $
    uValue = '', $
    event_pro ='Envi_file_info',$
    REF_VALUE = '自定义菜单before' , $
    /SEPARATOR
ENVI_DEFINE_MENU_BUTTON, buttonInfo, VALUE = '后来的，加个塞', $
    uValue = '', $
    event_pro ='Envi_file_info', $
    REF_VALUE = '自定义菜单before', POSITION = 'first'    
    
;创建显示菜单
ENVI_DEFINE_MENU_BUTTON, buttonInfo, $
    VALUE = '自定义菜单', $
    /Display, $
    /MENU, REF_VALUE = 'File', $
    /SIBLING, POSITION = 'after'
ENVI_DEFINE_MENU_BUTTON, buttonInfo, $
    VALUE = '更不知道加啥了', $
    UValue =' ', $
    /Display, $
    event_pro ='Envi_file_info', $
    REF_VALUE = '自定义菜单'   
    
END
;+
;escription:
;    ENVI query image
; Author: DYQ 2009-5-15;
;
PRO Envi_file_info,event
; COMPILE_OPT STRICTARR

;选择文件
ENVI_OPEN_FILE, fname, r_fid=fid

;如无效则返回
IF fid[0] EQ -1 THEN BEGIN
    msg = DIALOG_MESSAGE('未打开文件或数据错误！',/Error)
    RETURN
ENDIF

;数据信息查询
ENVI_FILE_QUERY, fid, ns=ns, nl=nl, nb=nb, fname=fname
;提示
msg = DIALOG_MESSAGE('输入文件名：'+ fName + STRING(13B)+ $
    ';波段数：'+STRING(nb)+ STRING(13B)+ $
';大小：'+STRING(ns)+'*'+STRING(nl),$
/Information)

END