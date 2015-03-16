;
; Read base perp file
; 
FUNCTION TLI_READ_BASE_PERP, baseperpfile
  
  COMPILE_OPT idl2
  
  nlines=N_ELEMENTS(baseperp)
  
  header_lines=12
  end_lines=5
  baseperp=TLI_READTXT(baseperpfile, header_lines=header_lines, end_lines=end_lines,/txt)
  
  baseperp=DOUBLE(TLI_STRSPLIT(baseperp))
  
  baseperp=CREATE_STRUCT('line', baseperp[0, *], $
                         'range', baseperp[1, *], $
                         'b_t', baseperp[2, *], $
                         'b_c', baseperp[3, *], $
                         'b_n', baseperp[4, *], $
                         'look_angle', baseperp[5,*], $
                         'bpara', baseperp[6,*], $
                         'bperp', baseperp[7, *], $
                         'blen', baseperp[8,*])
  RETURN, baseperp

END