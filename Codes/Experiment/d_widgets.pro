;$Id: //depot/idl/IDL_70/idldir/examples/demo/demosrc/d_widgets.pro#1 $
;
;  Copyright (c) 1997-2007, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;
;+
;  FILE:
;       d_widgets.pro
;
;  CALLING SEQUENCE: d_widgets
;
;  PURPOSE:
;       This demo shows the various types of widgets in IDL's Graphical
;       User Interface (GUI) Toolkit.
;
;  MAJOR TOPICS: Widgets
;
;  CATEGORY:
;       IDL Demo System
;
;  INTERNAL FUNCTIONS and PROCEDURES:
;       pro d_widgetsEvent            -  Event handler
;       pro d_widgetsCleanup          -  Cleanup
;       pro d_widgets                 -  Main procedure
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       widgets.tip
;       pro demo_gettips            - Read the tip file and create widgets
;
;  REFERENCE: IDL Reference Guide, IDL User's Guide
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;   96,   DAT        - Written.
;   98,   ACY        - Major rewrite.
;-

; -----------------------------------------------------------------------------
;
;  Purpose:  Function returns the 3 angles of a space three 1-2-3
;            given a 3 x 3 cosine direction matrix
;            else -1 on failure.
;
;  Definition :  Given 2 sets of dextral orthogonal unit vectors
;                (a1, a2, a3) and (b1, b2, b3), the cosine direction matrix
;                C (3 x 3) is defined as the dot product of:
;
;                C(i,j) = ai . bi  where i = 1,2,3
;
;                A column vector X (3 x 1) becomes X' (3 x 1)
;                after the rotation as defined as :
;
;                X' = C X
;
;                The space three 1-2-3 means that the x rotation is first,
;                followed by the y rotation, then the z.
;
function angle3123, $
    cosMat           ; IN: cosine direction matrix (3 x 3)

    ;  Verify the input parameters
    ;
    if (N_PARAMS() ne 1) then begin
        PRINT,'Error in angle3123: 1 parameters must be passed.'
        RETURN, -1
    endif
    sizec = size(cosMat)
    if (sizec[0] ne 2) then begin
        PRINT,'Error, the input matrix must be of dimension 2'
        RETURN, -1
    endif
    if ((sizec[1] ne 3) or (sizec[2] ne 3)) then begin
        PRINT,'Error, the input matrix must be 3 by 3'
        RETURN, -1
    endif

    ;  Compute the 3 angles (in degrees)
    ;
    cosMat = TRANSPOSE(cosMat)
    angle = FLTARR(3)
    angle[1] = -cosMat[2,0]
    angle[1] = ASIN(angle[1])
    c2 = COS(angle[1])
    if (ABS(c2) lt 1.0e-6) then begin
        angle[0] = ATAN(-cosMat[1,2], cosMat[1,1])
        angle[2] = 0.0
    endif else begin
        angle[0] = ATAN( cosMat[2,1], cosMat[2,2])
        angle[2] = ATAN( cosMat[1,0], cosMat[0,0])
    endelse
    angle = angle * (180.0/!DPI)

    RETURN, angle

end    ;   of angle3123

; -----------------------------------------------------------------------------
;
;  Purpose:  Function returns the cosine direction matrix (3 x 3)
;            given the space three 1-2-3 rotation angles(i.e. rotation around
;            x axis, followed by Y axis, then z axis),
;            else -1 on failure.
;
;  Definition :  Given 2 sets of dextral orthogonal unit vectors
;                (a1, a2, a3) and (b1, b2, b3), the cosine direction matrix
;                C (3 x 3) is defined as the dot product of:
;
;                C(i,j) = ai . bi  where i = 1,2,3
;
;                A column vector X (3 x 1) becomes X' (3 x 1)
;                after the rotation as defined as :
;
;                X' = C X
;
function space3123, $
    theta, $        ; IN: angle of rotation around the x axis(in degrees)
    phi, $          ; IN: angle of rotation around the y axis(in degrees)
    gamma           ; IN: angle of rotation around the z axis(in degrees)

    ;  Verify the input parameters.
    ;
    if (N_PARAMS() ne 3) then begin
        PRINT,'Error in space3123: 3 parameters must be passed.'
        RETURN, -1
    endif

    cosMat = FLTARR(3, 3)

    ;  Transform the angle in radians.
    ;
    rTheta = theta * !DPI / 180.0
    rPhi = Phi * !DPI / 180.0
    rGamma = Gamma * !DPI / 180.0

    cos1 = COS(rTheta)
    cos2 = COS(rPhi)
    cos3 = COS(rGamma)
    sin1 = SIN(rTheta)
    sin2 = SIN(rPhi)
    sin3 = SIN(rGamma)

    ;  Compute the cosine direction matrix.
    ;
    cosMat[0,0] = cos2*cos3
    cosMat[1,0] = cos2*sin3
    cosMat[2,0] = -sin2
    cosMat[0,1] = (sin1*sin2*cos3) - (cos1*sin3)
    cosMat[1,1] = (sin1*sin2*sin3) + (cos1*cos3)
    cosMat[2,1] = sin1*cos2
    cosMat[0,2] = (cos1*sin2*cos3) + (sin1*sin3)
    cosMat[1,2] = (cos1*sin2*sin3) - (sin1*cos3)
    cosMat[2,2] = cos1*cos2

    RETURN, cosMat

end    ;   of space3123

; -----------------------------------------------------------------------------
;
;  Purpose:  Draw view.  Some platforms throw math errors that are
;            beyond our control.  Supress the printing of those errors.
;
pro d_widgetsDraw, sState

;  Flush and print any accumulated math errors
;
void = check_math(/print)

;  Silently accumulate any subsequent math errors, unless we are debuggung.
;
orig_except = !except
!except = ([0, 2])[keyword_set(sState.debug)]

;  Draw.
;
sState.drawWindowID->Draw, sState.oView

;  Silently (unless we are debuggung) flush any accumulated math errors.
;
void = check_math(PRINT=keyword_set(sState.debug))

;  Restore original math error behavior.
;
!except = orig_except
end
;
; -----------------------------------------------------------------------------
;
;  Purpose:  Event handler
;
pro d_widgetsEvent, $
    sEvent     ; IN: event structure

    ;  Quit the application using the close box.
    ;
    if (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ $
        'WIDGET_KILL_REQUEST') then begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
        RETURN
    endif

    ;  Get the info structure from top-level base.
    ;
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=sState, /NO_COPY

    ;  Determine which event.
    ;
    WIDGET_CONTROL, sEvent.id, GET_UVALUE=eventval

    ;  Take the following action based on the corresponding event.
    ;
    case eventval of


        'TABLE' : begin

            ;  Insertion of character.
            ;
            if (sEvent.type eq 0) then begin

                ;  Take action only when the carriage return character
                ;  is typed.
                ;
                if (sEvent.ch EQ 13) then begin
                    WIDGET_CONTROL, sState.wDataTable, GET_VALUE=data

                    sState.oTextureImage->SetProperty, DATA=bytscl(data)

                    ;  Draw the surface.
                    ;
                    if(sState.textureFlag eq 1) then begin
                        sState.oSimpleSurface->SetProperty, $
                            TEXTURE_MAP=sState.oTextureImage
                    endif
                    sState.oSimpleSurface->SetProperty, DATAZ=data
                    d_widgetsDraw, sState

                endif
            endif
        end        ;   of TABLE

       'POPINFO' : begin
           widget_control, sState.wTextField,  get_value=textVal
           void = DIALOG_MESSAGE(['This is a message displayed by the ', $
                                 'DIALOG_MESSAGE routine.  It can be used ', $
                                 'to display messages that a user must ',$
                                 'acknowledge before the program continues.', $
                                 '', $
                                 'For example, the text from the Editable', $
                                 'Text field is:', $
                                 textVal])

        end           ;  of POPINFO


        'STYLELIST' : begin

            WIDGET_CONTROL, /HOURGLASS

            listValue = WIDGET_INFO( sEvent.id, /DROPLIST_SELECT)

            case listValue of

                ;  Shaded style.
                ;
                0 : begin
                    sState.oSimpleSurface->SetProperty, STYLE=2
                    d_widgetsDraw, sState
                end    ;    of 0

                ;  Wire style.
                ;
                1 : begin
                    sState.oSimpleSurface->SetProperty, STYLE=1
                    d_widgetsDraw, sState
                end    ;    of 1

                ;  Lego solid style.
                ;
                2 : begin
                    sState.oSimpleSurface->SetProperty, STYLE=6
                    d_widgetsDraw, sState
                end    ;    of 2

            endcase     ;  of listValue

        end       ;   of DROPLIST

        ;  Handle the list event, Choose between 4 color scenarios.
        ;
        'COLORLIST' : begin

            WIDGET_CONTROL, /HOURGLASS

            listValue = WIDGET_INFO( sEvent.id, /LIST_SELECT)

            case listValue of

                ;  Texture Map
                ;
                0 : begin
                    sState.oSimpleSurface->SetProperty, $
                        TEXTURE_MAP=sState.oTextureImage
                    sState.oSimpleSurface->SetProperty, COLOR=[230,230,230], $
                       BOTTOM=[64, 192, 128]
                    d_widgetsDraw, sState
                    sState.textureFlag=1
                end    ;  of 0

                ;  White.
                ;
                1 : begin
                    sState.oSimpleSurface->SetProperty, $
                        TEXTURE_MAP=OBJ_NEW()
                    sState.oSimpleSurface->SetProperty, COLOR=[200,200,200]
                    d_widgetsDraw, sState
                    sState.textureFlag=0
                end    ;  of 1

                ;  Yellow.
                ;
                2 : begin
                    sState.oSimpleSurface->SetProperty, $
                        TEXTURE_MAP=OBJ_NEW()
                    sState.oSimpleSurface->SetProperty, COLOR=[200,200,0]
                    d_widgetsDraw, sState
                    sState.textureFlag=0
                end    ;  of 2

                ;  Red.
                ;
                3 : begin
                    sState.oSimpleSurface->SetProperty, $
                        TEXTURE_MAP=OBJ_NEW()
                    sState.oSimpleSurface->SetProperty, COLOR=[200,0,0]
                    d_widgetsDraw, sState
                    sState.textureFlag=0
                end    ;  of 3

            endcase

        end     ;   of LIST

        ;  Handle the rotation.
        ;
        'SLIDER' : begin

            WIDGET_CONTROL, sState.wXSlider, GET_VALUE=xDegree
            WIDGET_CONTROL, sState.wYSlider, GET_VALUE=yDegree
            WIDGET_CONTROL, sState.wZSlider, GET_VALUE=zDegree
            matFinal = FLTARR(3,3)
            matFinal = space3123(xDegree, yDegree, zDegree)

            sState.oRotationModel->GetProperty, TRANSFORM=t
            tempMat = FLTARR(3,3)
            tempMat[0:2, 0:2] = TRANSPOSE(t[0:2, 0:2])
            tempMat = TRANSPOSE(tempMat)
            rotMat = matFinal # tempMat

            ;  Find the Euler parameters 'e4' of rotMat
            ;  which is the rotation it takes to go from
            ;  the original (t) to the final (matFinal).
            ;
            e4 = 0.5 * SQRT(1.0 + rotMat[0,0] + $
                rotMat[1,1] + rotMat[2,2])

            ;  Find the unit vector of the single rotation axis
            ;  and the angle of rotation.
            ;
            if (e4 eq 0) then begin
                if (rotMat[0,0] eq 1) then begin
                    axisRot = [1, 0, 0]
                endif else if(rotMat[1,1] eq 1) then begin
                    axisRot = [0, 1, 0]
                endif else begin
                    axisRot = [0, 0, 1]
                endelse
                angleRot = 180.0
            endif else begin
                e1 = (rotMat[2,1] - rotMat[1,2])/(4.0*e4)
                e2 = (rotMat[0,2] - rotMat[2,0])/(4.0*e4)
                e3 = (rotMat[1,0] - rotMat[0,1])/(4.0*e4)
                modulusE = SQRT(e1*e1 + e2*e2 +e3*e3)
                if(modulusE eq 0.0) then begin
                    WIDGET_CONTROL, sEvent.top, $
                        SET_UVALUE=sState, /NO_COPY
                    RETURN
                endif
                axisRot = FLTARR(3)
                axisRot[0] = e1/modulusE
                axisRot[1] = e2/modulusE
                axisRot[2] = e3/modulusE
                angleRot = (2.0 * ACOS(e4)) * 180 / !DPI
            endelse

            for i = 0, 2 do begin
                if(ABS(axisRot[i]) lt 1.0e-6) then axisRot[i]=1.0e-6
            endfor
            sState.oRotationModel->Rotate, axisRot, angleRot
            d_widgetsDraw, sState

        end    ;  of SLIDER

        'DRAW': begin

            ;  Expose.
            ;
            if (sEvent.type eq 4) then begin
                d_widgetsDraw, sState
                WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
                RETURN
            endif


            ;  Handle trackball update
            ;
            bHaveTransform = sState.oTrack->Update(sEvent, TRANSFORM=qmat )
            if (bHaveTransform NE 0) then begin
                sState.oRotationModel->GetProperty, TRANSFORM=t
                mt = t # qmat
                sState.oRotationModel->SetProperty,TRANSFORM=mt
            endif

            ;  Button press.
            ;
            if (sEvent.type eq 0) then begin
                sState.btndown = 1B
                sState.drawWindowID->SetProperty, QUALITY=2
                WIDGET_CONTROL, sState.wDraw, /DRAW_MOTION
            endif    ;     of Button press

            ;  Button motion.
            ;
            if ((sEvent.type eq 2) and (sState.btndown eq 1B)) then begin

                if (bHaveTransform) then begin
                    ;  Reset the x, y, z axis angle values.
                    ;
                    sState.oRotationModel->GetProperty, TRANSFORM=transform
                    tempMat = FLTARR(3,3)
                    xyzAngles = FLTARR(3)
                    tempMat[0:2, 0:2] = transform[0:2, 0:2]
                    xyzAngles = Angle3123(tempMat)
                    WIDGET_CONTROL, sState.wXSlider, SET_VALUE=xyzAngles[0]
                    WIDGET_CONTROL, sState.wYSlider, SET_VALUE=xyzAngles[1]
                    WIDGET_CONTROL, sState.wZSlider, SET_VALUE=xyzAngles[2]
                    d_widgetsDraw, sState
                endif

            endif     ;   of Button motion

            ;  Button release.
            ;
            if (sEvent.type eq 1) then begin
                if (sState.btndown EQ 1b) then begin
                    sState.drawWindowID->SetProperty, QUALITY=2
                    d_widgetsDraw, sState
                endif
                sState.btndown = 0B
                WIDGET_CONTROL, sState.wDraw, DRAW_MOTION=0
            endif
        end                 ;     of DRAW
        'TEXT': begin
        end


        "ABOUT": begin

            ;  Display the information.
            ;
            ONLINE_HELP, 'd_widgets', $
               book=demo_filepath("idldemo.adp", $
                       SUBDIR=['examples','demo','demohelp']), $
                       /FULL_PATH

        end

        "QUIT": begin

            ;  Restore the info structure before destroying event.top
            ;
            WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY

            ;  Destroy widget hierarchy.
            ;
            WIDGET_CONTROL, sEvent.top, /DESTROY

            RETURN
        end

        ELSE :  begin
            PRINT, 'Case Statement found no matches'
        end

    endcase

    ; Restore the info structure
    ;
    WIDGET_CONTROL, sEvent.top, Set_UValue=sState, /No_Copy
end               ; of d_widgetsEvent

; -----------------------------------------------------------------------------
;
;  Purpose:  Cleanup procedure
;
pro d_widgetsCleanup, $
    wTopBase      ; IN: top level base associated with the cleanup

    ;  Get the color table saved in the window's user value.
    ;
    WIDGET_CONTROL, wTopBase, GET_UVALUE=sState,/No_Copy

    ;  Destroy the top objects
    ;
    OBJ_DESTROY, sState.oStaticModel
    OBJ_DESTROY, sState.oContainer
    OBJ_DESTROY, sState.oTextureImage
    OBJ_DESTROY, sState.oPalette

    ;  Restore the previous color table.
    ;
    TVLCT, sState.colorTable

    ;  Map the group leader base if it exists.
    ;
    if (WIDGET_INFO(sState.groupBase, /VALID_ID)) then $
        WIDGET_CONTROL, sState.groupBase, /MAP

end   ; of d_widgetsCleanup


; -----------------------------------------------------------------------------
;
;  Purpose:  Main procedure of the widgets demo
;
pro d_widgets, $
    GROUP=group, $     ; IN: (opt) group identifier
    RECORD_TO_FILENAME=record_to_filename, $
    DEBUG=debug, $     ; IN: (opt)
    APPTLB = appTLB    ; OUT: (opt) TLB of this application

    ; Check the validity of the group identifier
    ;
    ngroup = N_ELEMENTS(group)
    if (ngroup NE 0) then begin
        check = WIDGET_INFO(group, /VALID_ID)
        if (check NE 1) then begin
            print,'Error, the group identifier is not valid'
            print, 'Return to the main application'
            RETURN
        endif
        groupBase = group
    endif else groupBase = 0L


    ;  Get the screen size.
    ;
    Device, GET_SCREEN_SIZE = screenSize

    ;  Set up dimensions of the drawing (viewing) area.
    ;
    xdim = screenSize[0]*0.4
    ydim = xdim * 0.75

    ;  Make the system have a maximum of 256 colors
    ;
    numcolors = !d.N_COLORS
    if( (( !D.NAME EQ 'X') or (!D.NAME EQ 'MAC')) $
        and (!d.N_COLORS GE 256L)) then $
        DEVICE, PSEUDO_COLOR=8

    DEVICE, DECOMPOSED=0, BYPASS_TRANSLATION=0

    ;  Get the current color table
    ;
    TVLCT, savedR, savedG, savedB, /GET

    ;  Build color table from color vectors
    ;
    colorTable = [[savedR],[savedG],[savedB]]

    ;  Load an initial file .
    ;
    file = 'abnorm.dat'
    demo_getdata, NewImage, FILENAME=file, /TWO_DIM
    data=SMOOTH(NewImage[*,*,7], 3, /EDGE_TRUNCATE)

    ; Define a main widget base.
    ;
    if (N_ELEMENTS(group) EQ 0) then begin
        wTopBase = WIDGET_BASE(TITLE="Widgets", /COLUMN, $
            /TLB_KILL_REQUEST_EVENTS, $
            TLB_FRAME_ATTR=1, MBAR=barBase)
    endif else begin
        wTopBase = WIDGET_BASE(TITLE="Widgets", /COLUMN, $
            /TLB_KILL_REQUEST_EVENTS, $
            GROUP_LEADER=group, $
            TLB_FRAME_ATTR=1, MBAR=barBase)
    endelse

        ;  Create the quit button
        ;
        wFileButton = WIDGET_BUTTON(barBase, VALUE= 'File', /MENU)

            wQuitButton = WIDGET_BUTTON(wFileButton, $
                VALUE='Quit', UVALUE='QUIT')

        ; Create the help button
        ;
        wHelpButton = WIDGET_BUTTON(barBase, /HELP, $
            VALUE='About', /MENU)

            wAboutButton = WIDGET_BUTTON(wHelpButton, $
                VALUE='About IDL Widgets', UVALUE='ABOUT')



        ;  Create the first child of the graghic base.
        ;
        wSubBase = WIDGET_BASE(wTopBase, COLUMN=2)

            ;  Create a base for the left column.
            ;
            wLeftBase = WIDGET_BASE(wSubBase, /BASE_ALIGN_CENTER, $
               XPAD=5, YPAD=5, $
               /FRAME, /COLUMN)


                wStatusLabel = WIDGET_LABEL(wLeftBase, $
                   VALUE='Surface Style')

                wStyleDroplist = WIDGET_DROPLIST(wLeftBase, $
                     VALUE=['Shaded', 'Wire', 'Lego Solid'], $
                     UVALUE='STYLELIST')


                wColorLabel = WIDGET_LABEL(wLeftBase, $
                     VALUE='Surface color')

                wColorList = WIDGET_LIST(wLeftBase, VALUE=['Texture Map', $
                     'White', 'Yellow', 'Red'], YSIZE=3, UVALUE='COLORLIST')

                wSliderBase = WIDGET_BASE(wLeftBase, /COLUMN, $
                    /FRAME, YPAD=8, XPAD=8)

                    ; Initial rotation values, also used below when
                    ; initializing model
                    xRot = -60
                    yRot = 20
                    zRot = 0
                    wSliderLabel = WIDGET_LABEL(wSliderBase, $
                        VALUE='Rotation', /ALIGN_CENTER)

                    wXSlider = WIDGET_SLIDER(wSliderBase, $
                        UVALUE='SLIDER', $
                        VALUE=xRot, MINIMUM=-180, MAXIMUM=180)

                    wSliderXLabel = WIDGET_LABEL(wSliderBase, $
                        VALUE='X Axis')

                    wYSlider = WIDGET_SLIDER(wSliderBase, $
                        UVALUE='SLIDER', $
                        VALUE=yRot, MINIMUM=-180, MAXIMUM=180)

                    wSliderYLabel = WIDGET_LABEL(wSliderBase, $
                        VALUE='Y Axis')

                    wZSlider = WIDGET_SLIDER(wSliderBase, $
                        VALUE=zRot, MINIMUM=-180, MAXIMUM=180, $
                        UVALUE='SLIDER')

                    wSliderZLabel = WIDGET_LABEL(wSliderBase, $
                        VALUE='Z Axis')


            wStatusLabel = WIDGET_LABEL(wLeftBase, $
                VALUE='Editable Text')

                    wTextField = widget_text(wLeftBase, $
                        /EDITABLE, $
                        UVALUE='TEXT', $
                        VALUE='Example text')

                    wPopInfoButton = WIDGET_BUTTON(wLeftBase, $
                        VALUE='Message Popup', UVALUE='POPINFO')

            ;  Create a base for the right column.
            ;
            wRightBase = WIDGET_BASE(wSubBase, /COLUMN)

                wTableBase = WIDGET_BASE(wRightBase, /COLUMN, $
                    /FRAME, YPAD=0, XPAD=0)
                    sz = SIZE(data)
                    wLabel = WIDGET_LABEL(wTableBase, $
                        VALUE='View or modify surface data with the table widget')
                    wDataTable = WIDGET_TABLE(wTableBase, $
                        UVALUE='TABLE', $
                        VALUE=data, /EDITABLE, /ALL_EVENTS, $
                        XSIZE=sz[1], YSIZE=sz[2], $
                        X_SCROLL_SIZE=5, Y_SCROLL_SIZE=3 )


                wDrawBase = WIDGET_BASE(wRightBase, /COLUMN, $
                    /FRAME, UVALUE=-1)

                    wDraw = WIDGET_DRAW(wDrawBase, $
                        XSIZE=xdim, YSIZE=ydim, /BUTTON_EVENTS, $
                        /EXPOSE_EVENTS, UVALUE='DRAW', $
                        RETAIN=0, $
                        GRAPHICS_LEVEL=2)

        ;  Create tips texts.
        ;
        wStatusBase = WIDGET_BASE(wTopBase, MAP=0, /ROW)

    ;  Realize the widget hierarchy.
    ;
    WIDGET_CONTROL, wTopBase, /REALIZE

    ;  Returns the top level base in the appTLB keyword.
    ;
    appTLB = wTopBase

    ;  Get the tips
    ;
    sText = demo_getTips(demo_filepath('widgets.tip', $
                             SUBDIR=['examples','demo', 'demotext']), $
                         wTopBase, $
                         wStatusBase)

    WIDGET_CONTROL, wTopBase, SENSITIVE=0

    ; Determine the window value of plot window, wDraw1.
    ;
    WIDGET_CONTROL, wDraw, GET_VALUE=drawWindowID


    ;  Set the view such that the surface is
    ;  contained within a box defined by
    ;  by radx and rady ( view normal coordinates).
    ;
    sqr3 = SQRT(3)/1.5   ; length of a diagonal in a cube
    radx = SQRT(2.0)       ; viewport in normal coordinates
    rady = SQRT(2.0)

    ;  Select the normal corrdinates of the
    ;  orthogonal axes location within the volume.
    ;  example:
    ;  middle :  axesX, axesY, axesZ = -0.5
    ;  lowest data values : axesX, axesY, axesZ = 0.0
    ;  highest data values : axesX, axesY, axesZ = -1.0
    ;
    axesX = -0.5
    axesY = -0.5
    axesZ = -0.5

    xMargin = (1.0-sqr3)/2.0
    yMargin = (1.0-sqr3)/2.0
    xv = ((xMargin)*radx + axesX)
    yv = ((yMargin)*rady + axesY)
    width = 1.0 - 2.0 * xMargin* radx
    height = 1.0 - 2.0 * yMargin * radY

    myview = [xv, yv, width, height]

    ;  Create view.
    ;
    oView = OBJ_NEW('idlgrview', PROJECTION=2, EYE=3, $
        ZCLIP=[1.5, -1.5], VIEWPLANE_RECT=myview, COLOR=[0,0,0])

    ;  Create model.
    ;
    oStaticModel = OBJ_NEW('idlgrmodel')
    oMovableModel = OBJ_NEW('idlgrmodel')
    oRotationModel = OBJ_NEW('idlgrmodel')
    oScalingModel = OBJ_NEW('idlgrmodel')
    oTranslationModel = OBJ_NEW('idlgrmodel')

    oStaticModel->Add, oMovableModel
    oMovableModel->Add, oRotationModel
    oRotationModel->Add, oScalingModel
    oScalingModel->Add, oTranslationModel

    sc = 0.7
    oStaticModel->Scale, sc, sc, sc

    ;  Create light.
    ;
    oLight1 = OBJ_NEW('idlgrLight', TYPE=1, INTENSITY=0.5, $
        LOCATION=[1.5, 0, 1])
    oLight2 = OBJ_NEW('idlgrLight', TYPE=0, $
        INTENSITY=0.75)
    oStaticModel->Add, oLight1
    oStaticModel->Add, oLight2

    ;  Compute coordinate conversion to normalize.
    ;
    z = data
    sz = SIZE(z)
    maxx = sz[1] - 1
    maxy = sz[2] - 1
    maxz = MAX(z,min=minz)
    xs = [axesX,1.0/maxx]
    ys = [axesY,1.0/maxy]
    minz2 = minz - 1
    maxz2 = maxz + 1
    zs = [(-minz2/(maxz2-minz2))+axesZ, 1.0/(maxz2-minz2)]

    oPalette = OBJ_NEW('idlgrPalette')
    oPalette->LOADCT, 25
    oTextureImage = OBJ_NEW('idlgrImage', BYTSCL(z), PALETTE=oPalette)

    ;  Create the surface.
    ;
    oSimpleSurface = OBJ_NEW('IDLgrSurface', data, $
        TEXTURE_MAP=oTextureImage, $
        STYLE=2, SHADING=1, $
        /USE_TRIANGLES, $
        ;COLOR=[60,60,255], $
        ;BOTTOM=[64,192,128], $
        COLOR=[230, 230, 230], BOTTOM=[64, 192, 128], $
        XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD_CONV=zs)

    oTranslationModel->Add, oSimpleSurface

    ;  Rotate the original display.
    ;
    oRotationModel->Rotate, [1,0,0], xRot
    oRotationModel->Rotate, [0,1,0], yRot

    ;  Place the model in the view.
    ;
    oView->Add, oStaticModel

    ;  Add the trackball object for interactive change
    ;  of the scene orientation
    ;
    oTrack = OBJ_NEW('Trackball', [xdim/2.0, ydim/2.0], xdim/2.0)

    oContainer = OBJ_NEW('IDLgrContainer')
    oContainer->Add, oView
    oContainer->Add, oTrack

    ;  Create the info structure
    ;
    sState={ $

        BtnDown: 0, $                           ; mouse button down flag
        OTrack: oTrack, $                       ; Trackball object
        OContainer: oContainer, $               ; Container object
        OView: oView, $                         ; View object
        OStaticModel: oStaticModel, $           ; Models objects
        ORotationModel: oRotationModel, $
        OSimpleSurface: oSimpleSurface, $       ; Surface object
        WDataTable: wDataTable, $               ; Widget table ID
        WXSlider: wXSlider, $                   ; Widget sliders ID
        WYSlider: wYSlider, $
        WZSlider: wZSlider, $
        DrawWindowID: drawWindowID, $           ; Window ID
        WDraw: wDraw, $                         ; Widget draw ID
        wTextField: wTextField, $               ; C-Widget text ID
        OTextureImage: oTextureImage, $         ; Texture image object
        OPalette: oPalette, $                   ; Palette for image
        textureFlag: 1, $                       ; Texture mapping flag
        colorTable: colorTable, $               ; color table to restore
        debug: keyword_set(debug), $            ; debug flag
        groupBase: groupBase $                  ; Base of Group Leader
    }

    d_widgetsDraw, sState

    ;  Register the info structure in the user value of the top-level base
    ;
    WIDGET_CONTROL, wTopBase, SET_UVALUE=sState, /NO_COPY

    WIDGET_CONTROL, wTopBase, SENSITIVE=1

    ;  Map the top level base.
    ;
    WIDGET_CONTROL, wTopBase, MAP=1

    XMANAGER, "d_widgets", wTopBase, $
        /NO_BLOCK, $
        EVENT_HANDLER="d_widgetsEvent", CLEANUP="d_widgetsCleanup"

end   ;  main procedure


