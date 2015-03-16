; Chapter04TestArray.pro
PRO Chapter04TestArray
¡¡¡¡MyArray = FLTARR(10)
¡¡¡¡CATCH, ErrorStatus
¡¡¡¡IF ErrorStatus NE 0 THEN BEGIN
¡¡¡¡¡¡¡¡PRINT, '´íÎó´úÂë£º', ErrorStatus
¡¡¡¡¡¡¡¡PRINT, '´íÎóÐÅÏ¢£º', !ERROR_STATE.MSG
¡¡¡¡¡¡¡¡MyArray = FLTARR(19)
¡¡¡¡¡¡¡¡CATCH, /CANCEL
¡¡¡¡ENDIF
¡¡¡¡MyArray[16]=60
¡¡¡¡HELP, MyArray
END