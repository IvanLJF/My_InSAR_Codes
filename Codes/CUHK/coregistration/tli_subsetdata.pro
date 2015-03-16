FUNCTION TLI_SUBSETDATA, infile, ss, ls,  soff, ns, loff,nl, $
                      float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian
; ss: samples
; ls: lines
; sc: single complex
; fc: float complex
; int: int
  COMPILE_OPT idl2
  ON_ERROR, 2
  
  samples= LONG64(ss)
  lines= LONG64(ls)
  roff= LONG64(FLOOR(soff))       ;- Rows off
  nr= LONG64(FLOOR(ns))        ;- No. of rows to read
  loff= LONG64(FLOOR(loff))
  nl= LONG64(FLOOR(nl))
  
  IF roff GE samples THEN BEGIN
    Message, 'Begin at wrong point.'
    RETURN,-1
  ENDIF
  IF loff GE lines THEN BEGIN
    Message, 'Begin at wrong point.'
    RETURN, -1
  ENDIF
  IF (roff+nr) GT samples THEN nr= samples-roff
  IF (loff+nl) GT lines THEN nl= lines-loff
  IF roff LT 0 THEN BEGIN
    nr= nr+roff
    roff=0
  ENDIF
  IF loff LT 0 THEN BEGIN
    nl= nl+loff
    loff=0
  ENDIF
  IF nr LE 0 THEN MESSAGE, 'Number of samples to be read is wrong.'
  IF nl LE 0 THEN MESSAGE, 'Number of lines to be read is wrong.'
  ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Open data file ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
  IF KEYWORD_SET(float) THEN BEGIN
    length=4
    data= FLTARR(nr,nl)
    temparr=FLTARR(nr)
    pointer=DOUBLE((samples*loff+roff)*length);--------------------------------maybe wrong
    OPENR, lun, infile,/GET_LUN,swap_endian=swap_endian
    ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Read data file ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
    FOR i= 0, nl-1 DO BEGIN  ;assoc
      POINT_LUN, lun, pointer
      READU, lun, temparr
      data[*,i]=temparr
      pointer=pointer+samples*length
    ENDFOR
    ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Free lun ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
    FREE_LUN, lun
    RETURN, data
  ENDIF ELSE BEGIN  
    IF KEYWORD_SET(int) THEN BEGIN
      length=2
      data= INTARR(nr,nl)
      temparr=INTARR(nr)
      pointer=DOUBLE((samples*1D*loff+roff*1D)*length);--------------------------------maybe wrong
      OPENR, lun, infile,/GET_LUN,swap_endian= swap_endian
;      OPENR, lun, infile,/GET_LUN,/SWAP_ENDIAN
      ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Read data file ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
      FOR i= 0, nl-1 DO BEGIN  ;assoc
        POINT_LUN, lun, pointer
        READU, lun, temparr
        data[*,i]=temparr
        pointer=pointer+samples*length
      ENDFOR
      ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Free lun ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
      FREE_LUN, lun
      RETURN, data
    ENDIF ELSE BEGIN
      IF KEYWORD_SET(sc) THEN BEGIN
        length=2
        data=INTARR(nr*2, nl)
        temparr=INTARR(nr*2)  
;        type= READ_PARAMS(infile_par, 'image_format')
;        IF type EQ 'FCOMPLEX' THEN BEGIN
;          length=4
;          data= FLTARR(nr*2, nl)
;          temparr=FLTARR(nr*2)
;        ENDIF
        pointer=DOUBLE((samples*2D*loff+roff*2D)*length);--------------------------------maybe wrong
        IF KEYWORD_SET(swap_endian) THEN BEGIN
          OPENR, lun, infile,/GET_LUN,swap_endian= swap_endian
        ENDIF ELSE BEGIN
          OPENR, lun, infile,/GET_LUN
        ENDELSE
;          OPENR, lun, infile, /GET_LUN,/SWAP_ENDIAN
        ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Read data file ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        FOR i= 0, nl-1 DO BEGIN  ;assoc
          POINT_LUN, lun, pointer
          READU, lun, temparr
          data[*,i]=temparr
          pointer=pointer+samples*2*length
        ENDFOR
        ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Free lun ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
        FREE_LUN, lun
        data= COMPLEX(data[0:*:2, *], data[1:*:2, *])  
        RETURN, data
      ENDIF ELSE BEGIN
        IF KEYWORD_SET(fc) THEN BEGIN
          length=4
          data= FLTARR(nr*2, nl)
          temparr=FLTARR(nr*2)
          pointer=DOUBLE((samples*2D*loff+roff*2D)*length);--------------------------------maybe wrong
          IF KEYWORD_SET(swap_endian) THEN BEGIN
            OPENR, lun, infile,/GET_LUN,swap_endian= swap_endian
          ENDIF ELSE BEGIN
            OPENR, lun, infile,/GET_LUN
          ENDELSE
          ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Read data file ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
          FOR i= 0, nl-1 DO BEGIN  ;assoc
            POINT_LUN, lun, pointer
            READU, lun, temparr
            data[*,i]=temparr
            pointer=pointer+samples*2*length
          ENDFOR
          ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Free lun ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
          FREE_LUN, lun
          data= COMPLEX(data[0:*:2, *], data[1:*:2, *])  
          RETURN, data
        ENDIF ELSE BEGIN
          IF KEYWORD_SET(long) THEN BEGIN
            length=4
            data= LONARR(nr,nl)
            temparr=LONARR(nr)
            pointer=DOUBLE((samples*1D*loff+roff*1D)*length);--------------------------------maybe wrong
            OPENR, lun, infile,/GET_LUN,swap_endian= swap_endian
      ;      OPENR, lun, infile,/GET_LUN,/SWAP_ENDIAN
            ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Read data file ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
            FOR i= 0, nl-1 DO BEGIN  ;assoc
              POINT_LUN, lun, pointer
              READU, lun, temparr
              data[*,i]=temparr
              pointer=pointer+samples*length
            ENDFOR
            ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Free lun ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
            FREE_LUN, lun
            RETURN, data
          ENDIF ELSE BEGIN
            PRINT, 'Data type not supported!'
            RETURN, -1
          ENDELSE
        ENDELSE
      ENDELSE
    ENDELSE
  ENDELSE
END