;
; Convert my arcsfile to GMT triangulate file.
; 
; Parameters:
;   arcsfile   : My arcs file careated using ti_delaunay.
; Keywords:
;   outputfile : Outputfile for GMT plot command.
; 
; Written by
;   T.LI @ SWJTU, 20140319
;
PRO TLI_GMT_NETWORK, arcsfile, outputfile=outputfile, lines=lines
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=arcsfile+'_tri.list'
  
  arcs=TLI_READMYFILES(arcsfile, type='arcs')
  startcoor=arcs[0, *]
  endcoor=arcs[1, *]
  indice=arcs[2, *]
  indice_start=REAL_PART(indice)
  indice_end=IMAGINARY(indice)
  
  IF NOT KEYWORD_SET(lines) THEN BEGIN
    all_y=[IMAGINARY(startcoor), IMAGINARY(endcoor)]
    lines=MAX(all_y)
  ENDIF
  
  sz=SIZE(arcs,/DIMENSIONS)
  narcs=sz[1]
  
  ; Results
  result=STRARR(1, narcs*3)
  
  arcs_header='> Edge '+STRCOMPRESS(LONG(indice_start),/REMOVE_ALL)+'-'+STRCOMPRESS(LONG(indice_end),/REMOVE_ALL)
  arcs_startcoor=STRCOMPRESS(REAL_PART(startcoor),/REMOVE_ALL)+' '+STRCOMPRESS(lines-IMAGINARY(startcoor),/REMOVE_ALL)
  arcs_endcoor=STRCOMPRESS(REAL_PART(endcoor),/REMOVE_ALL)+' '+STRCOMPRESS(lines-IMAGINARY(endcoor),/REMOVE_ALL)
  
  arcs_indices=LINDGEN(narcs)*3
  result[*, arcs_indices]=arcs_header
  result[*, arcs_indices+1]=arcs_startcoor
  result[*, arcs_indices+2]=arcs_endcoor
  
  OPENW, lun, outputfile,/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun
  
  Print, 'Arcs format has been converted from T.LI to GAMMA.'
  Print, 'Please check the file:',outputfile
  Print, 'To plot the arcs, call GMT command: psxy -M ...'
END