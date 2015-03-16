;
; Read the GAMMA slc file. 
; 
; Parameters:
;   inputfile  : The input file.
; Written by:
;   T.LI @ ISEIS, 20140109
;
FUNCTION TLI_READSLC, inputfile, original=original
  
  parfile=inputfile+'.par'
  IF NOT FILE_TEST(inputfile) THEN Message, 'File not found:'+inputfile
  IF NOT FILE_TEST(parfile) THEN Message, 'File not found:'+parfile
  
  finfo=TLI_LOAD_SLC_PAR(parfile)
  samples=finfo.range_samples
  format=STRLOWCASE(finfo.image_format)
  
  result=TLI_READDATA(inputfile, samples=samples, format=format,/swap_endian)
  RETURN, result
END