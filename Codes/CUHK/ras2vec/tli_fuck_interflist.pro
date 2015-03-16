PRO TLI_FUCK_INTERFLIST

  interflistfile='D:\myfiles\Software\experiment\TerraSARTestArea\Basic_InSAR\Interferogram_Selection\Interf.list'
  itabfile='D:\myfiles\Software\experiment\TerraSARTestArea\PSI\itab'
  sarlistfile='D:\myfiles\Software\experiment\TerraSARTestArea\PSI\tempsarlist'
  temp=' '
  
  OPENR, lun, interflistfile,/GET_LUN
  READF, lun, temp
  temp= STRSPLIT(temp, '=',/EXTRACT)
  nslc= temp[1]
  date=0L
  FOR i=0, nslc-1 DO BEGIN
    temp=' '
    READF, lun, temp
    temp= STRSPLIT(temp, '-', /EXTRACT)
    
    sz= N_ELEMENTS(temp)
    
    temp= temp[sz-1]
    
    temp= LONG(STRMID(temp, 0, 8))
    
    date= [[date], [temp]]
    
  ENDFOR
  date= date[*, 1:*]
  ind= SORT(date)
  
  temp=' '
  READF, lun, temp ; Blank line
  temp=' '
  READF, lun, temp
  temp= STRSPLIT(temp, '=',/EXTRACT)
  nintf= temp[1]
  itab=LONARR(2)
  fitab= LONARR(4); Fucked itab
  FOR i=0, nintf-1 DO BEGIN
    READF,lun, fitab
    master_ind= fitab[1]-1
    slave_ind= fitab[2]-1
    true_master_ind= WHERE(ind EQ master_ind)+1
    true_slave_ind= WHERE(ind EQ slave_ind)+1
    temp= [true_master_ind, true_slave_ind]
    itab=[[itab], [temp]]
  ENDFOR
  FREE_LUN, lun
  itab= itab[*,1:*]
  slave_ind= itab[1, *]
  ind= SORT(TRANSPOSE(slave_ind))
  itab= itab[*, ind]
  itab= [itab, INDGEN(1,nintf)+1, BYTARR(1,nintf)+1]
  
  
  OPENW, lun, itabfile,/GET_LUN
  PRINTF, lun, STRCOMPRESS(itab)
  FREE_LUN, lun
  
  OPENW, lun, sarlistfile,/GET_LUN
  PRINTF, lun, date[*, ind]
  FREE_LUN, lun
  
END