;
; Filter the images using SHP.
;
; Parameters:
;   inputfile  : File to filter
;   dspath     : Ds path to find related files.
; Keywords:
;   outputfile : Filtered image
;   logfile    : log file.
;   discard_nonds: Set this keyword to 1 to set the non ds points to 0.
; Written by:
;   T.LI @ SWJTU
;
FUNCTION TLI_READSHPS, dslookupfile, start_pos, end_pos
  ; read the SHPs from lookup file.
  ; Start_pos   : Position to start reading.
  ; End_pos     : Position to end reading.
  pointer=start_pos*8D
  result=COMPLEXARR(end_pos-start_pos+1)
  OPENR, lun, dslookupfile,/GET_LUN
  POINT_LUN, lun, pointer
  READU, lun, result
  FREE_LUN, lun
  
  RETURN, result
END

PRO TLI_DS_FILTER, inputfile, dspath, outputfile=outputfile, logfile=logfile, discard_nonds=discard_nonds, $
    samples=samples, lines=lines, format=format, swap_endian=swap_endian
    
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=dspath+FILE_BASENAME(inputfile)+'.ds_filter'
  
  dsmaskfile=dspath+'dsc.mask'
  start_sectionfile=dspath+'start_section'
  end_sectionfile=dspath+'end_section'
  logfile=dspath+'log.txt'
  dslookupfile=dspath+'dsc.lookup'
  
  discard_nonds=0
  
;  finfo=TLI_LOAD_SLC_PAR(inputfile+'.par')
  
  ;  ; Test lookupfile
  ;  temp=COMPLEXARR(10)
  ;  OPENR, lun, dslookupfile,/GET_LUN
  ;  READU, lun, temp
  ;  FREE_LUN, lun
  
  ; Read the input file
  array=TLI_READDATA(inputfile, samples=samples, format=format,swap_endian=swap_endian)
  
  ; Get the ds coordinates
  dsmask=TLI_READDATA(dsmaskfile, samples=samples, format='byte')
  coors=WHERE(dsmask EQ 1, nds)
  coors=ARRAY_INDICES(dsmask, coors)
  
  ; Read the section files.
  start_section=TLI_READDATA(start_sectionfile, samples=samples, format='double')
  end_section=TLI_READDATA(end_sectionfile, samples=samples, format='double')
  
  ; Prepare result array.
  IF KEYWORD_SET(discard_nonds) THEN BEGIN
    Case STRLOWCASE(SIZE(array[0],/tname)) OF
      'float': BEGIN
        result=FLTARR(samples, lines)
      END
      'fcomplex': BEGIN
        result=COMPLEXARR(samples, lines)
      END
      'scomplex': BEGIN
        result=COMPLEXARR(samples, lines)
      END
      ELSE: BEGIN
        Message, 'Format not supported:'+size(array[0],/tname)
      END
      
    ENDCASE
    
  ENDIF ELSE BEGIN
  
    result=array
  ENDELSE
  
  ; For loops
  FOR i=0D, nds-1D DO BEGIN
    IF ~(i MOD 10000) THEN Print, i, '/', nds-1D
    ; DS info
    coors_i=coors[0, i]
    coors_j=coors[1, i]
    
    ; Get the SHP coordinates.
    start_i=start_section[coors_i, coors_j]
    end_i=end_section[coors_i, coors_j]
    coors_shp=TLI_READSHPS(dslookupfile, start_i, end_i)
    
    ; Values of the SHP
    coors_shp_r=REAL_PART(coors_shp)
    coors_shp_i=IMAGINARY(coors_shp)
    values_shp=array[coors_shp_r, coors_shp_i]
    
    ; Filter
    result[coors_i, coors_j]= MEAN(values_shp)
    
  ENDFOR
  ; Write the data
  Case STRLOWCASE(format) OF
    'scomplex': BEGIN
      temp=INTARR(finfo.range_samples*2, finfo.azimuth_lines)
      temp[0:*:2, *]=REAL_PART(result)
      temp[1:*:2, *]=IMAGINARY(result)
      TLI_WRITE, outputfile, temp,/swap_endian
    END
    ELSE: BEGIN
      TLI_WRITE, outputfile, result,/swap_endian
    END
    
  ENDCASE
  
END