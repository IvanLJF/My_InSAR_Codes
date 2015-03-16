;-
;- Change annotation for the coordinate file.
;- e.g.: change GYX to GaoYaXian

PRO TLI_QL_CHANGEANN

  workpath='/mnt/backup/experiment/Qingli_all/test1'
  workpath=workpath+PATH_SEP()
  
  coorfile=workpath+'coors'
  coors_annfile= workpath+'coors_ann'
  
  results= STRARR(4, FILE_LINES(coorfile))
  results[0,*]= INDGEN(FILE_LINES(coorfile))+1
  
  OPENR, lun, coorfile,/GET_LUN
  
  FOR i=0, FILE_LINES(coorfile)-1 DO BEGIN
    temp=' '
    
    READF, lun, temp
    
    temp=STRSPLIT(temp,' ',/EXTRACT)
    results[1:2, i]=temp[0:1]
    Case temp[2] OF
      'GYX': results[3,i]='High_voltage_wire'
      'GL' : results[3,i]='High_building'
      'H'  : results[3,i]='River'
      'NT' : results[3,i]='Cropland'
      'Q'  : results[3,i]='Wall'
      'LD' : results[3,i]='Roof'
      'WD' : results[3,i]='Housetop'
    ENDCASE
    
  ENDFOR
  FREE_LUN, lun
  
  OPENW, lun, coors_annfile,/GET_LUN
  PrintF, lun, results
  FREE_LUN, lun
  
  OPENW, lun, coorfile+'.dat',/GET_LUN
  WRITEU, lun, COMPLEX(results[1, *], results[2, *])
  FREE_LUN, lun
  
END