; Chapter08CRectangle__DEFINE.PRO
; --------------------------------------------------------------------
FUNCTION Chapter08CRectangle::Init, length, width
    IF N_PARAMS() NE 2 THEN BEGIN
       void=DIALOG_MESSAGE('Init requires length and width arguments!')
       RETURN, 0
    ENDIF ELSE BEGIN
       self.length = length
       self.width = width
       RETURN, 1
    ENDELSE
END
; --------------------------------------------------------------------
PRO Chapter08CRectangle::GetProperty, length=length, width=width
    length = self.length
    width = self.width
END
; --------------------------------------------------------------------
PRO Chapter08CRectangle::SetProperty, length=length, width=width
    self.length = length
    self.width = width
END
; --------------------------------------------------------------------
FUNCTION Chapter08CRectangle::CalculateArea
    SELF->GetProperty, length = length, width = width
    RETURN, length * width
END
; --------------------------------------------------------------------
PRO Chapter08CRectangle::PrintArea
    SELF->GetProperty, length = length, width = width
    Area = length * width
    void = DIALOG_MESSAGE('Area: ' + STRING(Area),/INFORMATION)
END
; --------------------------------------------------------------------
PRO Chapter08CRectangle__DEFINE
    void = { Chapter08CRectangle, length:0L, width:0L }
END
; --------------------------------------------------------------------