;-
;- Generate Bperp and lookangle for each point in plist file.
;-
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ SWJTU, 20140302
;
PRO TLI_GAMMA_BP_LA_FUN, ptfile, itabfile, slctabfile, basepath, pbasefile, plafile,gamma=gamma,force=force

  COMPILE_OPT idl2
  
  npt=TLI_PNUMBER(ptfile)
  
  itab_stru=TLI_READMYFILES(itabfile,type='itab')
  nintf=itab_stru.nintf_valid
  
  IF NOT KEYWORD_SET(force) THEN BEGIN
    pbaseexist=0
    plaexist=0
    ; check the file existency.
    IF FILE_TEST(pbasefile) THEN BEGIN
      temp=FILE_INFO(pbasefile)
      temp=temp.size
      fsize=npt*nintf*8
      IF fsize EQ temp THEN pbaseexist=1
    ENDIF
    IF FILE_TEST(plafile) THEN BEGIN
      temp=FILE_INFO(plafile)
      temp=temp.size
      fsize=npt*8
      IF fsize EQ temp THEN plaexist=1
    ENDIF
    
    IF pbaseexist+plaexist EQ 2 THEN BEGIN
      Print, TLI_TIME(/str)
      Print, 'Baselines and look angles for each point were calculated before. Please check the files:'
      Print, pbasefile
      Print, plafile
      Print, 'If you want to re-calculate the files, please add the keyword "force".'
      RETURN
    ENDIF
    
  ENDIF
  
  OPENW, pbaselun, pbasefile,/GET_LUN
  OPENW, plalun, plafile,/GET_LUN
  
  intpair= TLI_GAMMA_INT(slctabfile, itabfile, /date)
  
  ;- Read plist
  IF KEYWORD_SET(gamma) THEN BEGIN
    pt= TLI_READDATA(ptfile, samples=2, FORMAT='LONG',/SWAP_ENDIAN)
  ENDIF ELSE BEGIN
    pt= TLI_READDATA(ptfile, samples=1, format='FCOMPLEX')
    pt= [LONG(REAL_PART(pt)), LONG(IMAGINARY(pt))]
  ENDELSE
  FOR i=0, (SIZE(intpair,/DIMENSIONS))[1]-1 DO BEGIN
    IF ~(i MOD 100) THEN $
      Print, 'Calculating baselines and look angles for each points'+$
      STRCOMPRESS(i)+'/'+STRCOMPRESS((SIZE(intpair,/DIMENSIONS))[1]-1)
    thisbase= basepath+PATH_SEP()+STRCOMPRESS(intpair[0, i])+'-'+STRCOMPRESS(intpair[1, i])+'.txt'
    thisbase= STRCOMPRESS(thisbase,/REMOVE_ALL)
    IF ~FILE_TEST(thisbase) THEN Message, 'TLI_GAMMA_BP_LA: File can not be found:'$
      +STRING(13b)+thisbase
    ; Extract information.
    nlines= FILE_LINES(thisbase)
    OPENR, lun, thisbase,/GET_LUN
    
    FOR j=0, 11 DO BEGIN
      temp=' '
      READF, lun, temp
    ENDFOR
    data= DBLARR(9, nlines-12-5)
    READF, lun, data
    FREE_LUN, lun
    x= data[0, *]
    y= data[1, *]
    la= data[5, *]
    bp= data[7, *]
    result=TLI_POLYFIT2D(x, y, bp, pt[0, *], pt[1, *], degree=1)
    WRITEU, pbaselun, result
    IF i EQ 0 THEN BEGIN ; Points in different interferograms have the same look angle
      result=TLI_POLYFIT2D(x, y, la, pt[0, *], pt[1, *], degree=1)
      result= result/360D*(2D*!PI)
      WRITEU, plalun, result
    ENDIF
  ENDFOR
  FREE_LUN, pbaselun
  FREE_LUN, plalun
  
END