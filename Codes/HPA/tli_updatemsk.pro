;  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA'
;  workpath=workpath+PATH_SEP()
;  mskfile= workpath+'msk'
;  vdhfile= workpath+'vdh'
;  lel=lel
;  samples=5000
;  lines=6150
; TLI_UPDATEMSK, mskfile, vdhfile, samples, lines

PRO TLI_UPDATEMSK, mskfile, vdhfile, samples, lines, lel=lel,type=type

  IF NOT KEYWORD_SET(type) THEN type='vdh'

  IF ~FILE_TEST(mskfile)THEN BEGIN
    Print, 'Mask file is not found. We created a new one for you.'
  ENDIF
  IF N_PARAMS() NE 4 THEN BEGIN
    Message, 'Wrong input params.'
  ENDIF
  
;  IF lel GT 255 THEN BEGIN
;    Message, 'Iterations larger than 255 is not allowed here.'
;  ENDIF
  
  ; Get the coordinates of the points to be masked as 1
  ; Read file.
  type=STRLOWCASE(type)
  CASE type OF
    'vdh': BEGIN
      vdh= TLI_READDATA(vdhfile,samples=5, format='DOUBLE')
      ptcoor= vdh[1:2, *]
    END
    
    'plist': BEGIN
      result=TLI_READDATA(vdhfile,samples=1, format='fcomplex')
      ptcoor=[REAL_PART(result), IMAGINARY(result)]
    END
    
  ELSE : BEGIN
    Message, 'Wrong file type!'
  END
  
ENDCASE

max_x= MAX(ptcoor[0, *])
max_y= MAX(ptcoor[1, *])
IF max_x GT samples OR max_y GT lines THEN BEGIN
  Message, 'Error: Pls check the vdh file and samples&lines.'
ENDIF

; Create mask file
IF ~FILE_TEST(mskfile) THEN BEGIN
  msk= BYTARR(samples, lines)
;  msk[ptcoor[0, *], ptcoor[1, *]]=lel
  msk[ptcoor[0, *], ptcoor[1, *]]=msk[ptcoor[0, *], ptcoor[1, *]]+1
ENDIF ELSE BEGIN
  msk= TLI_READDATA(mskfile, samples=samples, format='BYTE')
;  msk[ptcoor[0, *], ptcoor[1, *]]=lel
  msk[ptcoor[0, *], ptcoor[1, *]]=msk[ptcoor[0, *], ptcoor[1, *]]+1
ENDELSE
IF MAX(msk) GT 1 THEN Message, 'ERROR, mask values can not be greater than 1. Please refresh the mask file.'
; Write mask file
OPENW, lun, mskfile,/GET_LUN
WRITEU, lun, msk
FREE_LUN, lun

END