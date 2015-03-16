;+ 
; Name:
;    tli_getwholedata
; Purpose:
;    Get all data from the given file.
; Calling Sequence:
;    result= Tli_GetWholeData(infile, samples, lines, data_type, /swap_endian)
; Inputs:
;    infile: Input file path
;    samples: samples of the input file.
;    lines: lines of the input file.
;    data_type: 'FOMPLEX', 'SCOMPLEX' or 'FLOAT'. Case sensitive.
; Optional Input Parameters:
;    swap_endian: Set this keyword if possible. For detail pls see the IDL Help Documents.
; Keyword Input Parameters:
;    None.
; Outputs:
;    All the data you need.
; Commendations:
;    None.
; Example:
;  infile= '/mnt/software/ForExperiment/TSX_PS_Tianjin/piece/20091113.rslc'
;  samples= READ_PARAMS(infile+'.par', 'samples')
;  lines= READ_PARAMS(infile+'.par', 'lines')
;  data_type= 'SCOMPLEX'
;  result= Tli_GetWholeData(infile, samples, lines, data_type, /swap_endian)
; Modification History:
;  22/03/2012: Written by T.Li @ InSAR Team in SWJTU & CUHK
;-
FUNCTION TLI_GETWHOLEDATA, infile, samples, lines, data_type, swap_endian=swap_endian

  COMPILE_OPT idl2
  IF N_PARAMS() NE 4 THEN MESSAGE, 'Usage: result= TLI_GETWHOLEDATA(infile, samples, lines, data_type)'
  
  samples= LONG64(samples)
  lines= LONG64(lines)
  fileinfo= FILE_INFO(infile)
  filesz= fileinfo.size
  CASE data_type OF
  
    'SCOMPLEX': BEGIN
      IF filesz NE samples*lines*4 THEN MESSAGE, 'Given file size is not consistent with true file size.'
      temp= INTARR(samples*2, lines)
      OPENR, lun, infile,/GET_LUN, SWAP_ENDIAN=swap_endian
      READU, lun, temp
      FREE_LUN, lun
      result= COMPLEX(temp[0:*:2, *],temp[1:*:2, *])
      RETURN, result
    END
      
    'FCOMPLEX': BEGIN
      IF filesz NE samples*lines*8 THEN MESSAGE, 'Given file size is not consistent with true file size.'
      temp= FLTARR(samples*2, lines)
      OPENR, lun, infile,/GET_LUN, SWAP_ENDIAN=swap_endian
      READU, lun, temp
      FREE_LUN, lun
      result= COMPLEX(temp[0:*:2, *],temp[1:*:2, *])
      RETURN, result
    END
    'FLOAT': BEGIN
      IF filesz NE samples*lines*4 THEN MESSAGE, 'Given file size is not consistent with true file size.'
      temp= FLTARR(samples, lines)
      OPENR, lun, infile,/GET_LUN, SWAP_ENDIAN=swap_endian
      READU, lun, temp
      FREE_LUN, lun
      RETURN, temp
    END
    
    ELSE:BEGIN
      MESSAGE, 'File type not supported!'
    END
  
  ENDCASE
  
END