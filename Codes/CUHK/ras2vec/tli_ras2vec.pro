;+
; Name:
;    TLI_RAS2VEC
; Purpose:
;    Convert raster file to vector file according to the given point list.
; Calling Sequence:
;    Result= TLI_RAS2VEC(rasinfile,pinfile,data_type, samples, lines, swap_endian=swap_endian)
; Inputs:
;    rasinfile    :  Raster file to be converted.
;    pinfile      :  Point list file.
;    data_type    :  The type of the raster file.
;                    Four types supported:
;                    FLOAT     :  Float
;                    LONG      :  Long
;                    SCOMPLEX  :  Single Complex, EQ COMPLEX(INT, INT)
;                    FCOMPLEX  :  Float Complex, EQ COMPLEX(FLOAT, FLOAT)
;    samples      :  Samples of the raster file.
;    lines        :  Lines of the raster file.
;    swap_endian  :  Swap endian if possible.
; Keyword Input Parameters:
;    None.
; Outputs:
;    Return data on the point list. The detail information about return value via data_type:
;    FLOAT        :
;    LONG         :  3 lines: x-coordinates, y-coordinates, data
;    SCOMPLEX     :
;    FCOMPLEX     :  4 lines: x-coordinates, y-coordinates, real part, imaginary part
; Commendations:
;    data_type    :  Case sensitive. Please use capital letters.
; Example:
;    rasinfile= 'D:\myfiles\Software\TSX_PS_TJ_Piece\piece\20090327.rslc'
;    samples= 3500
;    lines= 3500
;    swap_endian=1
;    pinfile= 'D:\myfiles\Software\TSX_PS_TJ_Piece\plist'
;    data_type= 'SCOMPLEX'
;    result= TLI_RAS2VEC(rasinfile,pinfile, samples, lines,data_type,swap_endian=swap_endian)
; Modification History:
;    03/04/2012   :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;-

FUNCTION TLI_RAS2VEC, rasinfile,pinfile,data_type, samples, lines, swap_endian=swap_endian, changed_coor=changed_coor

  COMPILE_OPT idl2
  ;  ON_ERROR, 2
  IF N_PARAMS() NE 5 THEN Message, 'Usage:result= TLI_RAS2VEC(rasinfile,pinfile, samples, lines,data_type, swap_endian=swap_endian)'
  
  sar= rasinfile
  ss= DOUBLE(samples)
  ls= DOUBLE(lines)
  plist= pinfile
  data_type= data_type
  tiling=0
  tile_size=1000
  ;  IF KEYWORD_SET(swap_endian) THEN BEGIN;swap_endian is GAMMA's format.
  ;    pno= TLI_PNUMBER(plist)
  ;    coor= LONARR(2,pno)
  ;    OPENR, lun, plist,/GET_LUN
  ;    READU, lun,coor
  ;    FREE_LUN, lun
  ;    coor_x= coor[0,*]
  ;    coor_y= coor[1,*]
  ;  ENDIF ELSE BEGIN
  pno= TLI_PNUMBER(plist)
  coor= COMPLEXARR(pno)
  OPENR, lun, plist,/GET_LUN
  READU, lun,coor
  FREE_LUN, lun
  coor_x= REAL_PART(coor)
  coor_y= IMAGINARY(coor)
  ;  ENDELSE
  IF MAX(coor_x) GE samples THEN Message, 'Wrong point coordinates!'
  IF MAX(coor_y) GE lines THEN Message, 'Wrong point coordinates!'
  
  ;-------------------Pick out data according to plist-------------
  
  ByteSize= (FILE_INFO(sar)).size
  IF ~tiling THEN BEGIN
    CASE STRCOMPRESS(data_type,/REMOVE_ALL) OF
      'FLOAT': BEGIN
        IF ByteSize NE ss*ls*4D THEN $
          Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
        temparr= FLTARR(ss,ls)
        OPENR, lun, sar,/GET_LUN, swap_endian=swap_endian
        READU, lun, temparr
        FREE_LUN, lun
        result= [[coor_x], [coor_y],[temparr[coor_x, coor_y]]]
        RETURN, result
      END
      'DOUBLE': BEGIN
        IF ByteSize NE ss*ls*8D THEN $
          Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
        temparr= DBLARR(ss,ls)
        OPENR, lun, sar,/GET_LUN, swap_endian=swap_endian
        READU, lun, temparr
        FREE_LUN, lun
        result= [[coor_x], [coor_y],[temparr[coor_x, coor_y]]]
        RETURN, result
        
      END
      'LONG': BEGIN
        IF ByteSize NE ss*ls*4D THEN $
          Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
        temparr= LONARR(ss,ls)
        OPENR, lun, sar,/GET_LUN, swap_endian=swap_endian
        READU, lun, temparr
        FREE_LUN, lun
        result= [[coor_x], [coor_y],[temparr[coor_x, coor_y]]]
        RETURN, result
      END
      'SCOMPLEX': BEGIN
        IF ByteSize NE ss*ls*4D THEN $
          Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
        temparr= INTARR(ss*2,ls)
        OPENR, lun, sar,/GET_LUN, swap_endian=swap_endian
        READU, lun, temparr
        FREE_LUN, lun
        result= [[coor_x], [coor_y], [(temparr[0:*:2,*])[coor_x, coor_y]], [(temparr[1:*:2, *])[coor_x, coor_y]]]
        RETURN, result
      END
      'FCOMPLEX': BEGIN
        IF ByteSize NE ss*ls*8D THEN $
          Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
        temparr= COMPLEXARR(ss,ls)
        OPENR, lun, sar,/GET_LUN, swap_endian=swap_endian
        READU, lun, temparr
        FREE_LUN, lun
        result= [[coor_x], [coor_y],[REAL_PART(temparr[coor_x, coor_y])], [IMAGINARY(temparr[coor_x, coor_y])]]
        RETURN, result
      END
      ELSE: BEGIN
        Message, 'Data type not supported!'
      END
    ENDCASE
  ENDIF ELSE BEGIN
    ; ·Ö¿éËã·¨
    IF ls MOD tile_size THEN BEGIN
      tile_l= FLOOR(ls/tile_size)
    ENDIF ELSE BEGIN
      tile_l= FLOOR(ls/tile_size)-1
    ENDELSE
    
    CASE data_type OF
      'FLOAT'     : result= [0,0,0];TRANSPOSE([0,0,0])
      'LONG'      : result= [0,0,0];TRANSPOSE([0,0,0])
      'SCOMPLEX'  : result= [0,0,0,0];TRANSPOSE([0,0,0,0])
      'FCOMPLEX'  : result= [0,0,0,0];TRANSPOSE([0,0,0,0])
    ENDCASE
    
    FOR i= 0, tile_l DO BEGIN
      end_y= ((tile_size*(i+1)) GT ls)? ls: tile_size*(i+1)
      start_y= tile_size*i
      CASE data_type OF
        'FLOAT': BEGIN
          IF ByteSize NE ss*ls*4D THEN $
            Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
          temparr= TLI_SUBSETDATA(sar, ss, ls, 0, ss, start_y,end_y-start_y, $
            /float,swap_endian=swap_endian)
        END
        'LONG': BEGIN
          IF ByteSize NE ss*ls*4D THEN $
            Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
          temparr= TLI_SUBSETDATA(sar, ss, ls, 0, ss, start_y,end_y-start_y, $
            /long,swap_endian=swap_endian)
        END
        'SCOMPLEX': BEGIN
          IF ByteSize NE ss*ls*4D THEN $
            Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
          temparr= TLI_SUBSETDATA(sar, ss, ls, 0, ss, start_y,end_y-start_y, $
            /sc,swap_endian=swap_endian)
        END
        'FCOMPLEX': BEGIN
          IF ByteSize NE ss*ls*8D THEN $
            Message, 'File size is wrong: '+'['+STRCOMPRESS(ss)+' , '+STRCOMPRESS(ls)+']'
          temparr= TLI_SUBSETDATA(sar, ss, ls, 0, ss, start_y,end_y-start_y, $
            /fc,swap_endian=swap_endian)
        END
        ELSE: BEGIN
          Message, 'Data type not supported!'
        END
      ENDCASE
      index= WHERE(coor_y GE start_y AND coor_y LT end_y)
      x=coor_x[index]
      y=coor_y[index]
      result= [[result], [x,y,REAL_PART(temparr[x,y]), IMAGINARY(temparr[x,y])]]
    ENDFOR
    result= result[*,1: *]
    changed_coor= result[0:1, *]
    RETURN, result
  ENDELSE
END