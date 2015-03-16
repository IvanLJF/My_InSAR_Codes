;- 
;- Purpose:
;-    Open SLC and return the complex data
;- Calling Sequence:
;-    result= OPENSLC(infile)
;- Inputs:
;-    infile
;- Optional Input Parameters:
;-    None
;- Keyword Input Parameters:
;-    None
;- Outputs:
;-    Complex array of input file
;- Commendations:
;-    None
;- Example:
;-    infile= 'D:\ForExperiment\TSX_TJ_1500\20090327.rslc'
;-    result= OPENSLC(infile)
;- Modification History:
;-    Long time before: Done written by T. Li @ InSAR Team in SWJTU
;-    09/02/2010: Add judgement for datatype: Single Complex or Float Complex.
FUNCTION OPENSLC,INFILE,columns=columns,lines=lines,data_type=data_type,swap_endian=swap_endian
  
  COMPILE_OPT idl2
  
    ;-开始读取slc文件
    infilepar=infile+'.par'
    IF ~KEYWORD_SET(columns) THEN $
      columns=READ_PARAMS(infilepar,'range_samples:')
    IF ~KEYWORD_SET(lines) THEN $
      lines=READ_PARAMS(infilepar,'azimuth_lines:')
    IF ~KEYWORD_SET(data_type) THEN $
      data_type= READ_PARAMS(infilepar, 'image_format')
    
    ;- Scomplex
    IF data_type EQ 'SCOMPLEX' THEN arr_temp=intarr(columns*2,lines)
    ;- Fcomplex
    IF data_type EQ 'FCOMPLEX' THEN arr_temp= FLTARR(columns*2, lines)

    slc=complexarr(columns,lines)
    ;------------------read slcamplitude data-------------------------
    IF KEYWORD_SET(swap_endian) THEN BEGIN
      openr,lun,infile[0],/get_lun,/swap_endian
    ENDIF ELSE BEGIN
      openr,lun,infile[0],/get_lun
    ENDELSE
    readu,lun,arr_temp
;    readf,lun,arr_temp
    free_lun,lun
    ;loadct,12   ;load color bar
;    temp=long(tempz(0:columns*2-1,0:lines-1))
    arr_temp=DOUBLE(arr_temp)
    rl_part=arr_temp[0:columns*2-1:2,0:lines-1]
    img_part=arr_temp[1:columns*2-1:2,0:lines-1]
    slc=complex(rl_part,img_part)
    return,slc
;  endif


END