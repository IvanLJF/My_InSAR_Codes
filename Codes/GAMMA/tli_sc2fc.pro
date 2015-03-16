;
; Change the single complex file to float complex file.
; Parameters:
;   inputfile    : The input signel complex file.
; Keywords:
;   outputfile   : The output file name.
;   reverse      : Change the FCOMPLEX file to SCOMPLEX file
; Written by:
;   T.LI @ ISEIS, 20140109
;
PRO TLI_SC2FC, inputfile, outputfile=outputfile,reverse=reverse
  
  parfile=inputfile+'.par'
  IF NOT FILE_TEST(inputfile) THEN Message, 'File not found:'+inputfile
  IF NOT FILE_TEST(parfile) THEN Message, 'File header not found:'+parfile
  
  suffix='_sc2fc'
  IF KEYWORD_SET(reverse) THEN suffix='_fc2sc'
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=inputfile+suffix
  
  data=TLI_READSLC(inputfile,/original)
  
  finfo=TLI_LOAD_SLC_PAR(parfile)
  format=STRLOWCASE(finfo.image_format)
  
  Case format OF
     'scomplex': BEGIN
       IF KEYWORD_SET(reverse) THEN Message, 'Warning, not reversable.'
       TLI_WRITE, outputfile, data,/swap_endian
     END
     'fcomplex': BEGIN
       IF NOT KEYWORD_SET(reverse) THEN Message, 'Please add the keyword: /reverse.'
       data=FIX(data)
       TLI_WRITE, outputfile, data,/swap_endian
     END
  ENDCASE 
  
  Print, 'Format conversion finished, please check the outputfile:'+outputfile

END