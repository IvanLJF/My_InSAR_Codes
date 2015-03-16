;+ 
; Name:
;    TLI_PSSELECT
; Purpose:
;    Select PSs according to amplitude dispersion
; Calling Sequence:
;    result= TLI_PSSELECT(sarlist, samples, lines, $
;                 float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian, $
;                 outfile=outfile, thr_da=thr_da,thr_amp=thr_amp)
; Inputs:
;    sarlist   :  A .txt file containing all slc files to be used.
;    samples   :  Samples of the slc files.
;    lines     :  Lines of the slc files.
; Keyword Input Parameters:
;    float     :
;    sc        :
;    fc        :
;    int       :
;    long      :
;    swap_endian: Keyword set for TLI_SUBSETDATA
;    outfile   :  PSs point list file.
;    thr_da    :  Threshold for amplitude dispersion.
;    thr_amp:  :  Threshold for amplitude.
; Outputs:
;    outfile   :  Complex N*1 Array.
; Commendations:
;    thr_da    :  (0,1)
;    thr_amp   :  [0,2]
; Example:
;    sarlist='D:\myfiles\Software\TSX_PS_Tianjin\sarlist.txt'
;    samples= 3500
;    lines= 3500
;    sc=1
;    swap_endian=1
;    outfile= 'D:\myfiles\Software\TSX_PS_Tianjin\plist.dat'
;    thr_da= 0.45
;    result= TLI_PSSELECT(sarlist, samples, lines, $
;                 float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian,$
;                 outfile=outfile, thr_da=thr_da, thr_amp=thr_amp)
; Modification History:
;    11/04/2012: Written by T.Li @ InSAR Team in SWJTU & CUHK.
;-  

FUNCTION DETECTPS, $        ; Use DA to detect PSs.
         SLCS, $            ; Datas of slcs.
         thr_da=thr_da,$    ; threshold of DA
         thr_amp=thr_amp    ; Threshold of amplitude. [0,2]
    COMPILE_OPT idl2
    IF ~KEYWORD_SET(thr_da) THEN thr_da=0.25
        ; PS detection begin. For speed, input params are not verified.
      sz=SIZE(SLCS,/DIMENSIONS)
      mean_pwr= FLTARR(sz[0], sz[1])
      var_pwr= mean_pwr
;      SLCS= DOUBLE(SLCS)
      FOR k=0, sz[2]-1 DO BEGIN; Get mean value of all points
        mean_pwr= mean_pwr+ (SLCS[*,*,k])/sz[2]
      ENDFOR
      FOR k=0, sz[2]-1 DO BEGIN; Get std value of all points
        var_pwr= var_pwr+ ((SLCS[*,*,k])-mean_pwr)^2/(sz[2]-1)
      ENDFOR
      result= SQRT(var_pwr)/mean_pwr
      
;      WINDOW, XSIZE=500, YSIZE=500 & TVSCL, result
;      WINDOW,/FREE, XSIZE=500, YSIZE=500 & TVSCL, mean_pwr
      
      resulta= WHERE(result LT thr_da);-------------------------D/M------------------------
      IF KEYWORD_SET(thr_amp) THEN BEGIN
        resultb= WHERE(mean_pwr GE MEAN(mean_pwr,/NAN)*thr_amp)
      ENDIF ELSE BEGIN
        resultb= WHERE(mean_pwr GE 100);----------------------Amplitude------------------
      ENDELSE
      result= FW_ARRAY_UID(resulta, resultb, /intersection);---------------Intersection-----------------------
      ; change result to true coor.
      IF result[0] NE -1 THEN BEGIN
        x= result MOD sz[0]
        y= result/sz[0]
        result= COMPLEX(x,y)
        RETURN, result
      ENDIF ELSE BEGIN
        RETURN, -1
      ENDELSE
END

FUNCTION TLI_PSSELECT, sarlist, samples, lines,$
                  float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian, $
                  outfile=outfile, thr_da=thr_da, thr_amp=thr_amp

  COMPILE_OPT idl2
;  ON_ERROR, 2
  
  IF N_PARAMS() NE 3 THEN Message,'Usage, result=TLI_PSSELECT(sarlist, samples, lines)'
  infile= sarlist
  IF ~KEYWORD_SET(outfile) THEN $
    outfile= FILE_DIRNAME(sarlist)+PATH_SEP()+'plist.dat'

  n_lines= FILE_LINES(infile)
  infiles= STRARR(n_lines)
  OPENR, lun, infile,/GET_LUN
  READF, lun, infiles
  FREE_LUN, lun
  r=500L
  ss=samples
  ls=lines
  tile_s= FLOOR(ss/r)
  tile_l= FLOOR(ls/r)
  IF ~(ss MOD r) THEN tile_s= tile_s-1
  IF ~(ls MOD r) THEN tile_l= tile_l-1
;  a= FLTARR(r,r,n_lines); Create temporary array to include slcs.
  plist=COMPLEX(0,0)
  FOR i=0D,tile_s DO BEGIN
    FOR j=0D, tile_l DO BEGIN
    PRINT,STRCOMPRESS(FIX(j)),STRCOMPRESS(FIX(i)),'/',STRCOMPRESS(tile_l),STRCOMPRESS(tile_s)
      s_start= i*r
      l_start= j*r
;      PRINT, s_start,l_start
      s_end= r*(i+1)<ss
      l_end= r*(j+1)<ls
      a= FLTARR(s_end-s_start,l_end-l_start,n_lines)
      FOR k=0, n_lines-1 DO BEGIN
;        PRINT,STRCOMPRESS(k), STRCOMPRESS(FIX(j)),STRCOMPRESS(FIX(i)),'/',STRCOMPRESS(n_lines-1),STRCOMPRESS(tile_l),STRCOMPRESS(tile_s)
        b= TLI_SUBSETDATA(infiles[k],ss, ls, s_start, s_end-s_start, l_start, l_end-l_start,$
                          float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian)
;        b= SUBSETSLC(infiles[k], s_start,  s_end-s_start, l_start, l_end-l_start, fileNs=ss, fileNl=ls)
; TVSCL, ALOG(ABS(b))
        sz= SIZE(b,/DIMENSIONS)
        a[0:sz[0]-1,0:sz[1]-1,k]=ABS(b)
      ENDFOR
      IF i EQ tile_s AND j EQ tile_l THEN BEGIN
        Print, i, j
      ENDIF
      
      index= WHERE(a EQ COMPLEX(0.0))
      IF index[0] NE -1 THEN BEGIN
        a[WHERE(a EQ COMPLEX(0.0))] = !VALUES.F_NAN ; Change 0 to nan.
      ENDIF
      
      
      result= DETECTPS(a, thr_da=thr_da, thr_amp=thr_amp)
      IF result[0] NE -1 THEN BEGIN
        x= REAL_PART(result)+s_start
        y= IMAGINARY(result)+l_start
        plist=[plist, COMPLEX(x,y)]
      ENDIF
    ENDFOR
  ENDFOR
  IF N_ELEMENTS(plist) EQ 1 THEN Message, 'No PSs were found! Please amplify the threshold.'
  Print, MAX(REAL_PART(plist)), MAX(IMAGINARY(plist))
  plist=plist[1:*]
  PRINT, 'PSs total number:',size(plist,/N_ELEMENTS)

;  IF FILE_TEST(outfile) THEN FILE_DELETE,outfile
  OPENW, lun, outfile,/GET_LUN
  WRITEU, lun, plist
  FREE_LUN, lun

END


