; Chapter06DrawBar.pro
PRO Chapter06DrawBar
    DEVICE, DECOMPOSED=0
    LOADCT, 5
    !P.COLOR=0
    array = INDGEN(5,8)
    colors = INTARR(5,8)
    FOR I = 0, 7 DO colors[*,I]=(20*I)+20
    !Y.RANGE = [0, MAX(array)]
    nrows = N_ELEMENTS(array[0,*])
    base = INTARR(nrows)
    FOR I = 0, nrows-1 DO BEGIN
       BAR_PLOT, array[*,I], COLORS=colors[*,I], BACKGROUND=255, $
       BASELINES=base, BARWIDTH=0.75, BARSPACE=0.25, OVER=(I GT 0)
       base = array[*,I]
    ENDFOR
    ncols = N_ELEMENTS(array[*,0])
    FOR I = 0, nrows-1 DO BEGIN
       BAR_PLOT, array[*,I], COLORS=colors[*,I], BACKGROUND=255, $
       BARWIDTH=0.75, BARSPACE=0.25, BAROFFSET=I*(1.4*ncols), $
    OVER=(I GT 0), BASERANGE=0.12
    ENDFOR
END