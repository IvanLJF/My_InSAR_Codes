PRO TLI_CC_VS_DA

  workpath='/mnt/software/myfiles/Software/experiment/Qingli/test1Crop3'
  ptfile= workpath+'/pt'
  ptccfile= workpath+'/ptcc'
  msrfile= workpath+'/msr'
  itabfile= workpath+'/itab'
  ptmsrfile= workpath+'/ptmsr'
  ccfile= workpath+'/cc.dat'
  
  npt=TLI_PNUMBER(ptfile)
  
  ptccs= TLI_READDATA(ptccfile, samples= npt, format='FLOAT',/SWAP_ENDIAN)
  
  ptmsr= TLI_READDATA(ptmsrfile, samples=1, format='FLOAT',/SWAP_ENDIAN)
  
  cc= TLI_READDATA(ccfile, samples=3, format='DOUBLE') ; [Bperp Temp ccs]
  bp= cc[0, *]
  Print, '[max, min] of ABS(bp):', MAX(ABS(bp)), MIN(ABS(bp))
  bt= cc[1, *]
  Print, '[max, min] of ABS(bt):', MAX(ABS(bt)), MIN(ABS(bt))
  
  ; Analyze points with msr > 4
  ind= WHERE(ptmsr GT 4 AND ptmsr LT 5)
  IF ind[0] EQ -1 THEN Message, 'No such points.'
  ptind= ind[3]
  Print, 'Point index:', STRCOMPRESS(ptind), '   Point msr', STRCOMPRESS(ptmsr[ptind])
  ptcc= ptccs[ptind, *]
  Print, '[max, min] of coherence of this point:', MAX(ptcc), MIN(ptcc)
  
  outputfile=workpath+'/ptcc.d'+STRCOMPRESS(ptmsr[ptind])
  Print, outputfile
  OPENW, lun, outputfile,/GET_LUN
  PRINTF, lun, [ABS(bp), ABS(bt), (ptcc)]
  FREE_LUN, lun
  
  Print, 'Correlation between ptcc and bp', CORRELATE(TRANSPOSE(ptcc), TRANSPOSE(bp))
  Print, 'Correlation between ptcc and bt', CORRELATE(TRANSPOSE(ptcc), TRANSPOSE(bt))
  
  
  
END