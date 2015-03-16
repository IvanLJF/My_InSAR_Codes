;- Count the lines of my *.pro
;- 20130522: 52773 in my laptop

PRO TLI_STAT_MYCODES
  workpath='/mnt/software/myfiles/My_InSAR_Tools/Codes'
  workpath=workpath+PATH_SEP()
  
  allpath=FILE_SEARCH(workpath+'*',/TEST_DIRECTORY,count=npath )
  allpath=TRANSPOSE(allpath)+PATH_SEP()
  ind=LINDGEN(npath)
;  ind=[0,1,4,5,6,7,8,9,10,13,14,15,16,17]
  Print, 'The paths to analyze:'
  Print, [TRANSPOSE(STRCOMPRESS(ind)),allpath[*, ind]]
  
  npaths=N_ELEMENTS(ind)
  allfiles=0
  alllines=0
  FOR i=0, npaths-1 DO BEGIN
    files=FILE_SEARCH(allpath[i]+'*.pro',count=nfiles)
    IF nfiles EQ 0 THEN CONTINUE
    allfiles=allfiles+nfiles
    lines=FILE_LINES(files)
    alllines=alllines+TOTAL(lines)
    files=FILE_SEARCH(allpath[i]+'*'+PATH_SEP()+'*.pro',count=nfiles)
    IF nfiles EQ 0 THEN CONTINUE
    allfiles=allfiles+nfiles
    lines=FILE_LINES(files)
    alllines=alllines+TOTAL(lines)
  ENDFOR
  Print, 'The number of *.pro files:', STRING(allfiles)
  Print, 'The number of lines:', STRING(alllines)
END