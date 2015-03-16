 ; This pro is used to read the specified data.
 ; inputfile   : The full path of the file.
 ; samples     : Samples of the file.
 ; lines       : Lines of the file. Either samples or lines have to be specified.
 ; format      : Data format supported by this pro.
 ;               BYTE, INT, LONG, FLOAT, DOUBLE, SCOMPLEX, FCOMPLEX, DCOMPLEX
 ; swap_endian : Swap endian or not.
 ; force_sc    : Force the result to be single complex [int_realpart int_imaginary]
 ;
 ;
 ; e.g
 ; inputfile= 'D:\test.bin'
 ; samples=100
 ; format='FLOAT'
 ; swap_endian=0
 ; result= TLI_READDATA(inputfile, samples=samples, lines=lines, format=format, swap_endian=swap_endian)
 ;
 ; Written by T. Li @ ISEIS
 ; Modified: 20131008 : Add keyword: force_sc
 
 FUNCTION TLI_READDATA, inputfile, samples=samples,lines=lines,format= format, swap_endian=swap_endian,$
     force_sc=force_sc, force_dc=force_dc
     
   COMPILE_OPT idl2
   ON_ERROR, 2
   
   IF ~FILE_TEST(inputfile) THEN Message, 'Input file does not exist:'$
     +STRING(13b)+inputfile
   IF ~KEYWORD_SET(format) THEN Message, '*** Format is not specified. ***'
   
   finfo= FILE_INFO(inputfile)
   
   IF KEYWORD_SET(samples) THEN BEGIN
     format_c=STRUPCASE(format)
     Case format_c OF
       'BYTE': BEGIN
         lines= finfo.size/samples/1
         result= BYTARR(samples, lines)
       END
       'INT': BEGIN
         lines= finfo.size/samples/2
         result= INTARR(samples, lines)
       END
       'LONG':  BEGIN
         lines= finfo.size/samples/4
         result= LONARR(samples, lines)
       END
       'FLOAT': BEGIN
         lines= finfo.size/samples/4
         result= FLTARR(samples, lines)
       END
       'DOUBLE': BEGIN
         lines= finfo.size/samples/8
         result= DBLARR(samples, lines)
       END
       'SCOMPLEX': BEGIN
         lines= finfo.size/samples/4
         result= INTARR(samples*2, lines)
       END
       'FCOMPLEX': BEGIN
         lines= finfo.size/samples/8
         result= COMPLEXARR(samples, lines)
       END
       'DCOMPLEX': BEGIN
         lines=finfo.size/samples/16
         result=DBLARR(samples*2, lines)
       END
       
       ELSE: BEGIN
         Message, 'TLI_READDATA: Format Error! This keyword is case sensitive.'
       END
     ENDCASE
     Print, 'Size of the input file:'+STRING(13b)+inputfile+STRING(13b)+' ['+STRCOMPRESS(samples,/REMOVE_ALL)+' ,'+STRCOMPRESS(lines,/REMOVE_ALL)+'].'+STRING(13b)
     OPENR, lun, inputfile,/GET_LUN, swap_endian=swap_endian
     READU, lun, result
     FREE_LUN, lun
     IF format_c EQ 'SCOMPLEX' THEN BEGIN
       result=COMPLEX(result[0:*:2, *], result[1:*:2, *])
     ENDIF
     RETURN, result
     
   ENDIF ELSE BEGIN
   
     IF KEYWORD_SET(lines) THEN BEGIN
       format_c=STRUPCASE(format)
       Case format_c OF
         'BYTE': BEGIN
           samples= finfo.size/lines
           result= BYTARR(samples, lines)
         END
         'INT': BEGIN
           samples= finfo.size/lines/2
           result= INTARR(samples, lines)
         END
         'LONG':  BEGIN
           samples= finfo.size/lines/4
           result= LONARR(samples, lines)
         END
         'FLOAT': BEGIN
           samples= finfo.size/lines/4
           result= FLTARR(samples, lines)
         END
         'DOUBLE': BEGIN
           samples= finfo.size/lines/8
           result= DBLARR(samples, lines)
         END
         'SCOMPLEX': BEGIN
           samples= finfo.size/lines/4
           result= INTARR(samples*2, lines)
         END
         'FCOMPLEX': BEGIN
           samples= finfo.size/lines/8
           result= COMPLEXARR(samples, lines)
         END
         'DCOMPLEX': BEGIN
           samples=finfo.size/lines/16
           result= DBLARR(samples*2, lines)
         END
         
         ELSE: BEGIN
           Message, 'TLI_READDATA: Format Error! This keyword is case sensitive.'
         END
       ENDCASE
       
       Print, 'Size of the input file:'+STRING(13b)+inputfile+STRING(13b)+' ['+STRCOMPRESS(samples,/REMOVE_ALL)+' ,'+STRCOMPRESS(lines,/REMOVE_ALL)+'].'+STRING(13b)
       OPENR, lun, inputfile,/GET_LUN, swap_endian=swap_endian
       READU, lun, result
       FREE_LUN, lun
       IF format_c EQ 'SCOMPLEX' OR format_c EQ 'DCOMPLEX' THEN BEGIN
         IF NOT KEYWORD_SET(force_sc) AND NOT KEYWORD_SET(force_dc) THEN BEGIN
           result=COMPLEX(result[0:*:2, *], result[1:*:2, *])
         ENDIF
       ENDIF
       
       RETURN, result
     ENDIF ELSE BEGIN
       Message, 'Please specify either samples or lines.'
     ENDELSE
     
   ENDELSE
   
 END
