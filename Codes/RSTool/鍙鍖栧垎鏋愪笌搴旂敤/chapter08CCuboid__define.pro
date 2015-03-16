; Chapter08CCuboid__DEFINE.PRO
; --------------------------------------------------------------------
FUNCTION Chapter08CCuboid::Init, length, width, high
    IF N_PARAMS() NE 3 THEN BEGIN
       void=DIALOG_MESSAGE(   $
       'Init requires Length, width and High arguments!')
       RETURN, 0
    ENDIF ELSE BEGIN
       SELF->Chapter08CRectangle::SetProperty  $
                 , length = length, width = width
       SELF.high = high
       RETURN, 1
    ENDELSE
END
; --------------------------------------------------------------------
PRO Chapter08CCuboid::SetProperty  $
        ,length=length,width=width,high=high
    SELF->Chapter08CRectangle::SetProperty    $
        , length = length, width = width
    SELF.high = high
END
; --------------------------------------------------------------------
PRO Chapter08CCuboid::GetProperty  $
        ,length=length,width=width,high=high
    SELF->Chapter08CRectangle::GetProperty    $
        , length = length, width = width
    high = self.high
END
; --------------------------------------------------------------------
FUNCTION Chapter08CCuboid::CalculateVolume
    SELF->GetProperty, length=length, width=width, high=high
    RETURN, length * width * high
END
; --------------------------------------------------------------------
PRO Chapter08CCuboid::PrintVolume
    SELF->GetProperty, length=length, width=width, high=high
    Volume = length * width * high
    void = DIALOG_MESSAGE('Volume: ' + STRING(Volume),/INFORMATION)
END
; --------------------------------------------------------------------
PRO Chapter08CCuboid__DEFINE
    void = {Chapter08CCuboid, INHERITS Chapter08CRectangle, high:0L}
END
; --------------------------------------------------------------------

