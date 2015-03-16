; Chapter08CCylinder__DEFINE.PRO
; --------------------------------------------------------------------
FUNCTION Chapter08CCylinder::Init, radius, high
   IF N_PARAMS() NE 2 THEN BEGIN
       void=DIALOG_MESSAGE('Init requires Radius and High arguments!')
       RETURN, 0
    ENDIF ELSE BEGIN
       self.radius = radius
       self.high = high
       RETURN, 1
    ENDELSE
END
; --------------------------------------------------------------------
PRO Chapter08CCylinder::GetProperty, radius=radius, high=high
    radius = self.radius
    high = self.high
END
; --------------------------------------------------------------------
PRO Chapter08CCylinder::SetProperty, radius=radius, high=high
    IF KEYWORD_SET(radius) THEN BEGIN
        self.radius = radius
    ENDIF ELSE BEGIN
        self.radius = 10
    ENDELSE
    IF KEYWORD_SET(high) THEN BEGIN
        self.high = high
    ENDIF ELSE BEGIN
        self.high = 20
    ENDELSE
END
; --------------------------------------------------------------------
FUNCTION Chapter08CCylinder::CalculateVolume
    SELF->GetProperty, radius = radius, high=high
    RETURN, !PI * radius^2 * high
END
; --------------------------------------------------------------------
PRO Chapter08CCylinder::PrintVolume
    SELF->GetProperty, radius = radius, high=high
    Volume = !PI * radius^2 * high
    void = DIALOG_MESSAGE('Volume: '+ STRING(Volume),/INFORMATION)
END
; --------------------------------------------------------------------
PRO Chapter08CCylinder__DEFINE
    void = { Chapter08CCylinder, radius:0L, high:0L }
END
; --------------------------------------------------------------------