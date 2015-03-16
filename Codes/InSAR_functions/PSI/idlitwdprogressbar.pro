; $Id: //depot/idl/IDL_70/idldir/lib/itools/ui_widgets/idlitwdprogressbar.pro#1 $
; Copyright (c) 2002-2007, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;+
; NAME:
;   IDLitwdProgressBar
;
; PURPOSE:
;   This function implements the Progress Bar.
;
; CALLING SEQUENCE:
;   IDLitwdProgressBar
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;
;
; MODIFICATION HISTORY:
;   Written by:  CT, RSI, August 2002
;   Modified:
;
;-


;-------------------------------------------------------------------------
pro IDLitwdProgressBar_setvalue, id, percentIn

    compile_opt idl2, hidden


    ; Retrieve cache info.
    child = WIDGET_INFO(id, /CHILD)
    WIDGET_CONTROL, child, GET_UVALUE=state


    ; Check if user hit the "Cancel" button.
    ; We cannot use SAVE_HOURGLASS because on Windows it never
    ; processes the events if the hourglass is present.
    ; Presumably if we are using a progress bar, we really don't
    ; need to see the hourglass anyway since we've got our own.
    event = WIDGET_EVENT(state.wCancel, BAD_ID=wBad, /NOWAIT)


    ; In case user closed the window by hitting the "X" or Cancel.
    if ((wBad ne 0) or (event.id eq state.wCancel)) then begin
        if (WIDGET_INFO(state.wBase, /VALID)) then $
            WIDGET_CONTROL, state.wBase, /DESTROY
        return
    endif


    ; Watch out for those 104% space shuttle engines...
    percent = 0 > percentIn[0] < 100

    ; New block every 1%
    nblock = 100
    iblock = LONG((percent/100d)*nblock)

    ; Fill in last block if we are at 98%. Technically this isn't
    ; correct but it looks nicer if the last square actually fills in.
    if (percent ge 99) then $
        iblock = nblock

    doUpdate = (iblock ne state.iblock)
    previoustime = state.time

    ; If this is the first call, reinitialize the time and percent.
    if (state.iblock lt 0) then begin
        state.time = SYSTIME(1)
        state.percent = percent
    endif

    ; Cache the new block number.
    state.iblock = iblock
    WIDGET_CONTROL, child, SET_UVALUE=state


    ; Only update the progress bar if we need to.
    if (doUpdate) then begin

        ; Size of one block within the progress bar.
        ; Leave room for the 1 pixel border.
        blocksize = (state.xsize - 4d)/nblock

        ; New ProgressBar size.
        x = iblock*blocksize
        y = state.ysize

        ; Fire everything to the pixmap first.
        WSET, state.pixmap

        TVLCT, red, green, blue, /GET
        rsave = red
        gsave = green
        bsave = blue
        ; Fill in our progress bar color.
        red[252:254] = [0b, state.background[0], 255b]
        green[252:254] = [255b, state.background[1], 255b]
        blue[252:254] = [0b, state.background[2], 255b]
        ; Our new color table.
        TVLCT, red, green, blue

        DEVICE, GET_DECOMPOSED=decomposed
        DEVICE, DECOMPOSED=0
        ERASE, 254

        ; Leave a one-pixel gap around the edges. This assumes that POLYFILL
        ; will not draw the bottom row.
        POLYFILL, [2, x+2, x+2, 2], [0, 0, y-2, y-2], $
            COLOR=252, /DEVICE

        ; Cut off the corners.
        PLOTS, [2,2,x+1,x+1], [1,y-2,1,y-2], COLOR=254, PSYM=3, /DEVICE
        PLOTS, [0,0,state.xsize-1,state.xsize-1], [0,y-1,0,y-1], $
            COLOR=253, PSYM=3, /DEVICE

        ; Copy pixmap to the draw widget.
        WSET, state.win
        DEVICE, COPY=[0, 0, state.xsize, state.ysize, 0, 0, state.pixmap]

        DEVICE, DECOMPOSED=decomposed
        TVLCT, rsave, gsave, bsave

    endif


    ; Do not update the label if the block hasn't changed,
    ; unless we are on the last block, in which case we should show the
    ; final time/percent counting off.
    if (~doUpdate && iblock lt (nblock-1)) then $
        return


    ; If TIME keyword hasn't been set, just display the percentage.
    if (~state.usetime) then begin
        WIDGET_CONTROL, state.wLabel, $
            SET_VALUE=' '+STRTRIM(LONG(percent), 2)+'%'
        return
    endif


    ; Display the TIME.

    ; Determine approximate time remaining until complete.
    elapsedtime = SYSTIME(1) - previoustime
    fractiondone = (percent - state.percent)/(100d - state.percent) > 0.01
    totalexpectedtime = elapsedtime/fractiondone
    timeleft = LONG(totalexpectedtime - elapsedtime) + 1

    ; Assume all hours, minutes, seconds are off.
    hh = -1
    mm = -1
    ss = -1

    ; Different formatting depending upon magnitude.
    case (1) of
        (timeleft ge 3600) : begin  ; 1 hour
            hh = timeleft/3600
            timeleft = timeleft - hh*3600
            mm = timeleft/60
            end
        (timeleft ge 60) : begin   ; 1 minute
            mm = timeleft/60
            ss = timeleft - mm*60
            end
        else: ss = timeleft
    endcase

    ; Build up label from time pieces.
    time = ''
    ff = '(I2)'

    ; Hours
    if (hh ge 0) then time = time + $
        STRING(hh,FORMAT=ff) + ' ' + ((hh ne 1) ? $
                                      IDLitLangCatQuery('UI:wdProgBar:Hours')+' ' : $
                                      IDLitLangCatQuery('UI:wdProgBar:Hour')+'  ')

    ; Minutes
    if (mm ge 0) then time = time + $
        STRING(mm,FORMAT=ff) + ' ' + ((mm ne 1) ? $
                                      IDLitLangCatQuery('UI:wdProgBar:Minutes')+' ' : $
                                      IDLitLangCatQuery('UI:wdProgBar:Minute')+'  ')

    ; Seconds
    if (ss ge 0) then time = time + $
        STRING(ss,FORMAT=ff) + ' ' + ((ss ne 1) ? $
                                      IDLitLangCatQuery('UI:wdProgBar:Seconds') : $
                                      IDLitLangCatQuery('UI:wdProgBar:Second'))

    WIDGET_CONTROL, state.wLabel, SET_VALUE=STRTRIM(time, 2)

end


;-------------------------------------------------------------------------
function IDLitwdProgressBar, $
    CANCEL=cancelIn, $
    GROUP_LEADER=groupLeader, $
    TIME=time, $
    TITLE=titleIn, VALUE=value, $
    _REF_EXTRA=_extra


    compile_opt idl2, hidden

    myname = 'IDLitwdProgressBar'

    ; Check keywords.
    title = (N_ELEMENTS(titleIn) gt 0) ? titleIn[0] : ''
    if (title eq '') then $
        title = IDLitLangCatQuery('UI:wdProgBar:Title')

    if (not WIDGET_INFO(groupLeader, /VALID)) then $
        MESSAGE, IDLitLangCatQuery('UI:NeedGroupLeader')


    ; Create our floating base.
    wBase = WIDGET_BASE( $
        /ROW, $
        /FLOATING, $
        GROUP_LEADER=groupLeader, $
;        /MODAL, $   ; Cannot use because of blocking
        PRO_SET_VALUE=myname+'_setvalue', $
        SPACE=5, XPAD=5, YPAD=5, $
        TITLE=title, $
        TLB_FRAME_ATTR=1, $
        _EXTRA=_extra)

    ; Construct the actual property sheet.
    wCol = WIDGET_BASE(wBase, /COLUMN, SPACE=2)
    xsize = 204
    ysize = 12
    wDraw = WIDGET_DRAW(wCol, $
        XSIZE=xsize, YSIZE=ysize)
    wLabel = WIDGET_LABEL(wCol, $
        /DYNAMIC_RESIZE, $
        VALUE=' ')

    wButbase = WIDGET_BASE(wBase, /ROW)
    cancel = (SIZE(cancelIn, /TYPE) eq 7 && cancelIn ne '') ? $
        STRTRIM(cancelIn, 2) : IDLitLangCatQuery('UI:Cancel')
    wCancel = WIDGET_BUTTON(wButbase, $
        VALUE='  ' + cancel + '  ')


    ; Create an offscreen pixmap.
    WINDOW, /FREE, /PIXMAP, XSIZE=xsize, YSIZE=ysize
    pixmap = !D.WINDOW   ; retrieve window index.

    ; Retrieve the window index and erase.
    WIDGET_CONTROL, wBase, /REALIZE
    WIDGET_CONTROL, wDraw, GET_VALUE=win

    WSET, win

    TVLCT, red, green, blue, /GET
    rsave = red
    gsave = green
    bsave = blue
    ; Fill in our progress bar color.
    red[254] = 255b
    green[254] = 255b
    blue[254] = 255b
    ; Our new color table.
    TVLCT, red, green, blue

    DEVICE, GET_DECOMPOSED=decomposed
    DEVICE, DECOMPOSED=0

    ERASE, 254

    DEVICE, DECOMPOSED=decomposed
    TVLCT, rsave, gsave, bsave

    background = (WIDGET_INFO(wBase, /SYSTEM_COLORS)).face_3d

    ; Cache my state information within my child.
    state = { $
        wBase: wBase, $
        wDraw: wLabel, $
        wLabel: wLabel, $
        wCancel: wCancel, $
        xsize: xsize, $
        ysize: ysize, $
        pixmap: pixmap, $
        win: win, $
        iblock: -1L, $   ; initialize value
        background: background, $
        usetime: KEYWORD_SET(time), $
        time: SYSTIME(1), $
        percent: 0d}

    wChild = WIDGET_INFO(wBase, /CHILD)
    WIDGET_CONTROL, wChild, SET_UVALUE=state

    if (N_ELEMENTS(value) gt 0) then $
        IDLitwdProgressBar_setvalue, wBase, value

    return, wBase

end

