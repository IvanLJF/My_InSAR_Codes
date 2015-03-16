PRO TLI_READ_LOOKUP

  infile= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK_Kowloon/lookup'
  path= FILE_DIRNAME(infile)
  dem_segpar= path+path_sep()+'dem_seg.par'
  
  
  
  ;  ;lookup table is a float complex arr.
  samples= READ_PARAMS(dem_segpar, 'width')
    fileinfo= FILE_INFO(infile)
    lines= fileinfo.size/samples/8
  ;  result= COMPLEXARR(samples,lines)
  ;  OPENR, lun, infile, /GET_LUN,/SWAP_ENDIAN
  ;  READU, lun, result
  ;  FREE_LUN, lun
  
  result= TLI_READDATA(infile,samples=samples, format='FCOMPLEX',/SWAP_ENDIAN)
  
  first_l= result[*, 1] ; 1st line
  last_l= result[*, lines-1]
  first_s= result[0, *]
  last_s= result[samples-3, *]
  
  fl= WHERE(last_s NE COMPLEX(0, 0))
  Print,N_ELEMENTS(fl)
  Print, fl[2908]
  Print, last_s[fl[2908]]
  
  
;  PRINT, "Min X:",MIN(REAL_PART(result))
;  PRINT, "Max X:",MAX(REAL_PART(result))
;  PRINT, "Min Y:",MIN(IMAGINARY(result))
;  PRINT, "Max Y:",MAX(IMAGINARY(result))
;  Print, "UL, UR, DL, DR:", result[[0, samples-1,0,  samples-1], [0,0,lines-1, lines-1 ]]
;  
;  scale=1
;  sz= SIZE(result,/DIMENSIONS)*scale
;  pwr= CONGRID(ABS(result),sz[0],sz[1])
;  WINDOW, 0,XSIZE=sz[0], YSIZE=sz[1], TITLE=infile
;  LOADCT,0
;  TV, pwr,/ORDER
  
  
END