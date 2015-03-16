PRO TLI_TEST_SASMAC_DATA


  ;--------------------------------------------------------------------------------
  ; Test the deflattening algorithm which is composed of FFT.
  workpath='/mnt/software/ForExperiment/Deflattening'+PATH_SEP()
  intfile=workpath+'int'
  ; Create a flattening file.
  flt=FINDGEN(500)/10
  flt=TLI_WRAP_PHASE(flt)
  flt=REBIN(flt, [500, 500])
  result=COMPLEX(COS(flt), SIN(flt))
  TLI_WRITE, intfile, result
  
  samples=500
  format='fcomplex'
  TLI_FLATTENNING, intfile, samples, format=format, fltfile=fltfile, outputfile=outputfile,swap_endian=swap_endian
  
  STOP
  ;---------------------------------------------------------------------------------
  IF 0 THEN BEGIN
    ; Deflatenning the interferograms.
    origpath='/mnt/software/ForExperiment/Sasmac_Data/201406270001-001'
    origpath=origpath+PATH_SEP()
    
    workpath=origpath+'result'+PATH_SEP()
    
    inputfile1=workpath+'data1.slc'
    inputfile2=workpath+'data3.slc'
    
    intfile=workpath+'int'
    
    samples=8192
    lines=16384
    
    int=TLI_READDATA(intfile, samples=samples, format='fcomplex')
  ENDIF
  
  
  
;-------------------------------------------------------------------------
; ; Generate a pwr file.
;  master=TLI_READDATA(inputfile1, samples=8192, format='fcomplex',/swap_endian)
;  master=ABS(master)
;
;  TLI_WRITE, inputfile1+'.pwr', master,/swap_endian
;
;  void=DIALOG_MESSAGE('Task finished at time:'+TLI_TIME(/str),/information)
;----------------------------------------------------------
;
;  inputfile1=origpath+'data1.dat'
;  inputfile2=origpath+'data3.dat'
;  outputfile1=workpath+'data1.slc'
;  outputfile2=workpath+'data3.slc'
;
;  samples = 8192
;  lines_all= 16384
;  input_format='dcomplex'
;  output_format='fcomplex'
;
;  start_line=0
;  end_line=lines_all-1
;  swap_endian=1
;
;  inputfile=inputfile2
;  outputfile=outputfile2
;
;  TLI_CONVERT_FORMAT, inputfile, outputfile=outputfile, samples=samples, lines=lines, input_format=input_format, output_format=output_format, stretch_data=stretch_data, $
;    start_line=start_line, end_line=end_line,swap_endian=swap_endian
;
;  void=DIALOG_MESSAGE('Task ended at time:'+TLI_TIME(/str),/information)
;----------------------------------------------------------
  
;----------------------------------------------------------
;  origpath='/mnt/software/ForExperiment/Sasmac_Data'
;  origpath=origpath+PATH_SEP()
;
;  workpath=origpath+'results'
;
;  inputfile=origpath+'data_C1_1_57.dat'
;
;  samples=8192
;  lines=32768
;
;  data=DBLARR(samples*2, 1000)
;  OPENR, lun, inputfile,/GET_LUN
;  READU, lun, data
;  FREE_LUN, lun
;
;  r_part=data[0:*:2, *]
;  i_part=data[1:*:2, *]
;  data=COMPLEX(r_part, i_part)
;
;  amp=ABS(data)
;
;  phase=ATAN(data,/PHASE)
;
;  ; Show the results
;  amp=CONGRID(amp, samples/10, 100)
;
;  WINDOW, xsize=samples/10, ysize=100
;  TV, amp
;
;  STOP
;----------------------------------------------------------
  
END