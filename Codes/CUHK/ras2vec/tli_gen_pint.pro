PRO TLI_GEN_PINT
  ; File names
  IF !D.NAME NE 'WIN' THEN BEGIN
    path='/mnt/backup/TSX-HK/subRslc/'
    sarlistfile='/mnt/backup/TSX-HK/PSI_CUHK/sarlist.txt'
    paramfile= '/mnt/backup/TSX-HK/subRslcPasEst.txt'
    itabfile= '/mnt/backup/TSX-HK/PSI_CUHK/itab.txt'
    plistfile= '/mnt/backup/TSX-HK/PSI_CUHK/plist'
    pintfile='/mnt/backup/TSX-HK/PSI_CUHK/pint'
    arcsfile='/mnt/backup/TSX-HK/PSI_CUHK/arcs'
    pslcfile='/mnt/backup/TSX-HK/PSI_CUHK/pslc' 
  
  ENDIF ELSE BEGIN
    path='F:\TSX-HK\subRslc\'
    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
    paramfile= 'F:\TSX-HK\subRslc\PasEst.txt'
    itabfile= 'F:\TSX-HK\PSI_CUHK\itab.txt'
    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
    pintfile='F:\TSX-HK\PSI_CUHK\pint'
    arcsfile='F:\TSX-HK\PSI_CUHK\arcs'
    pslcfile='F:\TSX-HK\PSI_CUHK\pslc' 
  ENDELSE

  ;-----------------Tli_sarlist----------------------
;    path='F:\TSX-HK\subRslc\'
    suffix= '.rslc'
;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
    result= TLI_SARLIST(path, suffix, outfile=sarlistfile)
;;  ----------------------Tli_itab---------------
;    paramfile= 'F:\TSX-HK\subRslc\PasEst.txt'
;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
;    itabfile= 'F:\TSX-HK\PSI_CUHK\itab.txt'
    master=20
    method=2; 主影像选取方法：
            ; 0: 单一主影像
            ; 1: 自由组合
            ; 2: 多主影像
    result= TLI_ITAB(paramfile, sarlistfile, method= method, master= master, output_file= itabfile)
;;---------------------------Tli_psselect------------------
;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
    samples= 2679
    lines= 1471
    fc= 1
    swap_endian= 0
;    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
    thr_da= 0.25
    thr_amp= 1
    result= TLI_PSSELECT(sarlistfile, samples, lines,$
                  float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian, $
                  outfile=plistfile, thr_da=thr_da, thr_amp=thr_amp)
;;---------------------------TLI_DELAUNAY------------------
;    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
;    arcsfile='F:\TSX-HK\PSI_CUHK\arcs'
    range_pixel_spacing= 0.9
    azimuth_pixel_spacing= 2.04
    dist_thresh=1000
    result= TLI_DELAUNAY(plistfile,outname= arcsfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
;;;-------------------------Tli_pslc------------------
;    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
;    pslcfile='F:\TSX-HK\PSI_CUHK\pslc'
;    samples= 2679
;    lines= 1471
    data_type='FCOMPLEX'
    swap_endian=0
    result=TLI_PSLC(sarlistfile,plistfile, samples, lines,data_type,$
                     swap_endian=swap_endian, outfile=pslcfile)
;   
;  ----------------------Tli_pint---------------
;    pslcfile='F:\TSX-HK\PSI_CUHK\pslc'
;    plistfile= 'F:\TSX-HK\PSI_CUHK\plist'
;    itabfile= 'F:\TSX-HK\PSI_CUHK\itab.txt'
;    sarlistfile='F:\TSX-HK\PSI_CUHK\sarlist.txt'
;    pintfile='F:\TSX-HK\PSI_CUHK\pint'
    TLI_PINT, pslcfile, plistfile, itabfile, sarlistfile, pint_file=pintfile
    Print, '****************************'
    Print, '*         Finished!        *'
    Print, '****************************'

;----------------To Read Pint File----------------
    nlines= TLI_PNUMBER(plistfile)
    nsamples= FILE_LINES(itabfile) ;
    pint= COMPLEXARR(nsamples, nlines)
    OPENR, lun, pintfile,/GET_LUN
    READU, lun, pint
    FREE_LUN, lun
    STOP

END