;- 
;- Purpose:
;-     Change a binary file to ascii file. dat2txt
;- Keywords:
;-     trans: If this is set to 1, then do transpose
;-
PRO TLI_DAT2ASCII, inputfile, outputfile=outputfile, trans=trans, $
                   samples=samples, lines=lines, format=format, swap_endian=swap_endian

  IF ~KEYWORD_SET(outputfile) THEN BEGIN
    outputfile= inputfile+'.txt'
  ENDIF
  
  ; Read data
  data= TLI_READDATA(inputfile, samples=samples, lines=lines, format=format, swap_endian=swap_endian)
  Print, 'Size of input data:', STRCOMPRESS(SIZE(data,/DIMENSIONS))
  
  ; Transpose
  IF KEYWORD_SET(trans) THEN BEGIN
    Print, 'Input file will be transposed.'
    data= TRANSPOSE(data)
  ENDIF
  ; Write data
  TLI_WRITE, outputfile, data,/txt
  Print, 'Output file: '+outputfile
END