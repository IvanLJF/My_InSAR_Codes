;-
;- Merge two files
;- Type can be any one of the followings:
;- v, dh, vdh, arcs, dvddh, ptattr, ptstruct
;-

PRO TLI_MERGE_RESULTS,inputfile1, inputfile2, outputfile=outputfile, type=type

  IF ~KEYWORD_SET(outputfile) THEN BEGIN
    outputfile= inputfile2+'_merge'
  ENDIF
  IF ~KEYWORD_SET(type)  THEN BEGIN
    type='vdh'
  ENDIF
  
  type=STRLOWCASE(type)
  CASE type OF
    'vdh': BEGIN
      OPENW, lun, outputfile+'.txt',/GET_LUN
      
      OPENW, outlun, outputfile,/GET_LUN
      temp=TLI_READMYFILES(inputfile1, type=type)
      sz=SIZE(temp,/DIMENSIONS)
      npt_first=sz[1]
      temp[0, *]=DINDGEN(npt_first)
      WRITEU, outlun, temp
      PrintF, lun, temp
      
      temp=TLI_READMYFILES(inputfile2, type=type)
      sz=SIZE(temp,/DIMENSIONS)
      npt_second=sz[1]
      temp[0,*]=npt_first+DINDGEN(npt_second)
      WRITEU, outlun, temp
      FREE_LUN, outlun
      PrintF, lun, temp
      
      FREE_LUN, lun
    END
    'ptattr': BEGIN
      FILE_COPY, inputfile1, outputfile,/OVERWRITE
      temp=TLI_READMYFILES(inputfile2, type='ptattr')
      TLI_WRITE, outputfile, temp,/APPEND
      temp=0
    END
    
    'plist' : BEGIN
      FILE_COPY, inputfile1, outputfile,/OVERWRITE
      temp=TLI_READMYFILES(inputfile2, type='plist')
      TLI_WRITE, outputfile, temp,/APPEND
      temp=0
    END
    
    ELSE: BEGIN
      Message, 'Type is not supported.'
    END
    
  ENDCASE
  
  
END