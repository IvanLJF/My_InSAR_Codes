PRO TLI_PUBLIC_INSAR
  inputfile='D:\myfiles\卫星中心\公益性行业专项-实施\Project_members.txt'
  ; Read data
  input=TLI_READTXT(inputfile,/txt)
  np=52
  
  ind=STRARR(1, np)
  bday=strarr(1, np)  ; Birthday
  mcon=strarr(1, np)  ; Months contribution percent.
  ; Get IDs
  FOR i=3,53 DO BEGIN
  Print, input[i]
    str=STRSPLIT(input[i],/extract)
    nstr=N_ELEMENTS(str)
    
    mcon_i=str[nstr-2]
    bday_i=str[nstr-3]
    
    mcon[i-3]=STRMID(STRCOMPRESS(ROUND(mcon_i/2D/12D*100),/REMOVE_ALL),0,2)
    bday[i-3]=STRMID(bday_i,6, 4)+'.'+STRMID(bday_i, 10, 2)
    
    ind[i-3]=str[0]
    
    
  ENDFOR 
  result=[ind,bday, mcon]
  
  OPENW, lun, inputfile+'_slim.txt',/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun
  
  STOP
  

END