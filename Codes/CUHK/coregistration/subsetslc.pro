FUNCTION SUBSETSLC, infile, roff, nr, loff, nl, $
                      fileNs=fileNs, fileNl=fileNl
;- Script that:
;-     Read tile data from large SLC file
;- Usage:
;-     data= SUBSETSLC(infile, roff, nr, loff, nl, length)
;-     infile: Full path of input file
;-     samples: Samples of input file
;-     lines: Lines of input file
;-     roff: Rows offset
;-     nr: No. of rows to read
;-     loff: Lines offset
;-     nl: No. of lines to read
;-     length: Length of each element in input file. 2 for Scomplex.
;- Commondations:
;-     nr=1000
;-     nl=1000
;- Example:
;-    infile= 'D:\ForExperiment\PARLSAR_BJ\20070117.rslc'
;-    result= SUBSETSLC(infile, 10,10,100,100)
;- History:
;-    By: T. Li @ InSAR Team in SWJTU
;-    09/02/2012: Add: Auto detect length. T. Li @ InSAR Team in CUHK

;  infile= 'D:\myfiles\My_InSAR_Tools\InSAR\Images\20090327.rslc'
;  samples=500D    ;- Samples of input file
;  lines=500D      ;- Lines of input file
;  roff=0D       ;- Rows off
;  nr=500D         ;- No. of rows to read
;  loff=0D
;  nl=500D
;  length=2       ;- Length of each element in input file
  COMPILE_OPT idl2
  ON_ERROR, 2
  ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Check input params ！！！！！！！！！！！！！！！！！！！！！！！！！！！！
  IF N_PARAMS() NE 5 THEN $
  result= DIALOG_MESSAGE('Usage:'+ STRING(13B)+ 'data= SUBSETSLC(infile, samples, lines, roff, nr, loff, nl, length=length)')

  ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Initialization ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
;  infile_par= infile+'.par'
;  result= FILE_TEST(infile_par)
;
;  IF result EQ -1 THEN BEGIN
;    result= DIALOG_MESSAGE(TITLE='Par not found!', 'Please Put The .par File In The Same Directory!',/Information)
;  ENDIF

  samples= Double(fileNs) ; READ_PARAMS(infile_par, 'range_samples')
;  samples= Double(READ_PARAMS(infile_par, 'range_pixels'))
;  samples= DOUBLE(samples)
  lines= Double(fileNl) ; READ_PARAMS(infile_par, 'azimuth_lines')
;  lines= READ_PARAMS(infile_par, 'azimuth_pixels')
;  lines= DOUBLE(lines)
;  samples= DOUBLE(samples)    ;- Samples of input file
;  lines= DOUBLE(lines)      ;- Lines of input file
  roff= DOUBLE(roff)       ;- Rows off
  nr= DOUBLE(nr)        ;- No. of rows to read
  loff= DOUBLE(loff)
  nl= DOUBLE(nl)

  IF roff GE samples THEN BEGIN
    RETURN,-1
  ENDIF
  IF loff GE lines THEN BEGIN
    RETURN, -1
  ENDIF
  IF (roff+nr) GT samples THEN nr= samples-roff
  IF (loff+nl) GT lines THEN nl= lines-loff
  IF roff LT 0 THEN BEGIN
    nr= nr+roff
    roff=0
  ENDIF
  IF loff LT 0 THEN BEGIN
    nl= nl+loff
    loff=0
  ENDIF
  ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Open data file ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
  length=2
  data=FLTARR(nr*2, nl)
  temparr=FLTARR(nr*2)
  type= 'FCOMPLEX' ; READ_PARAMS(infile_par, 'image_format')
  IF type EQ 'FCOMPLEX' THEN BEGIN
    length=4
    data= FLTARR(nr*2, nl)
    temparr=FLTARR(nr*2)
  ENDIF
  pointer=Long64((samples*2D*loff+roff*2D)*length);--------------------------------maybe wrong
  a=0
  OPENR, lun, infile, /GET_LUN;, /SWAP_ENDIAN
;  OPENR, lun, infile, /GET_LUN
  ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Read data file ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
  FOR i= 0, nl-1 DO BEGIN  ;assoc
    POINT_LUN, lun, pointer
    READU, lun, temparr
    data[*,i]=temparr
    pointer=Long64(pointer+samples*2*length)
  ENDFOR
  ;！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！Free lun ！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
  FREE_LUN, lun
  data= COMPLEX(data[0:*:2, *], data[1:*:2, *])

  RETURN, data
END