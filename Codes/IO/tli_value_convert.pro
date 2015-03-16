;
; Convert the value in the inputfile to a specified value.;
;
; Parameters
;   inputfile    : Input file.
;
; Keywords:
;   samples      :
;   lines        :
;   format       :
;   swap_endian  : Keywords for tli_readdata
;   outputfile   : Output file. Default value is inputfile+'v_conv'
;   value_in     : value to change.
;   value_out    : value to change to .
;   refine       : Refine input data values before print minv and maxv.
;   minv         : Min value
;   maxv         : Max value
;
; Example:
;   workpath='/mnt/data_tli/ForExperiment/GMT/tli_shanghai'
;   workpath=workpath+PATH_SEP()
;
;   inputfile=workpath+'19960325-19960326.hgt.utm'
;   samples=3050
;   format='float'
;   swap_endian=swap_endian
;   outputfile=inputfile
;   TLI_VALUE_CONVERT, inputfile, samples=samples, format=format,swap_endian=swap_endian
;
; Written by:
;   T.LI @ Sasmac, 20141211
;
PRO TLI_VALUE_CONVERT, inputfile, samples=samples, lines=lines, format=format, swap_endian=swap_endian, outputfile=outputfile, value_in=value_in, value_out=value_out, $
    refine=refine, minv=minv, maxv=maxv, meanv=meanv, stdv=stdv

  IF NOT KEYWORD_SET(outputfile) THEN outputfile=inputfile+'.v_conv'
  IF NOT KEYWORD_SET(value_in) THEN value_in=0.0
  IF NOT KEYWORD_SET(value_out) THEN value_out=!Values.F_NAN
  
  input=TLI_READDATA(inputfile, samples=samples, lines=lines, format=format, swap_endian=swap_endian)
  ind=WHERE(input EQ value_in, complement=ind_valid)
  IF ind[0] NE -1 THEN BEGIN
    input[ind]=value_out
  ENDIF ELSE BEGIN
    meanv=MEAN(input,/nan)
    stdv=STDDEV(input,/nan)
    minv=MIN(input, max=maxv,/nan)
    FILE_COPY, inputfile, outputfile,/allow_same,/overwrite
    RETURN
  ENDELSE
  
  ; Refine data
  input_valid=input[ind_valid]
  meanv=MEAN(input_valid,/nan)
  stdv=STDDEV(input_valid,/nan)
  minv=MIN(input_valid, max=maxv,/nan)
  IF KEYWORD_SET(refine) THEN BEGIN
    ind=WHERE(input_valid GE meanv-3*stdv AND input_valid LE meanv+3*stdv)
    input_valid=input_valid[ind]
    meanv=MEAN(input_valid,/nan)
    stdv=STDDEV(input_valid, /nan)
    minv=MIN(input_valid, max=maxv,/nan)
  ENDIF
  
  TLI_WRITE, outputfile,input,swap_endian=swap_endian
END