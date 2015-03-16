function filter_filename, infile
;- 获取要进行滤波的图像文件
       filter='.img'

        if infile eq '' then return,-1
        
        filename=getfilename(infile)

        is=strpos(filename,'.',/reverse_search)
        if is eq -1 then filename=filename+filter
        if is eq strlen(filename)-1 then  filename=strmid(filename,0,is)+filter
        infile=getpathname(infile)+sep()+filename
;        if file_test(infile) then begin
;        yn=dialog_message('文件已存在，是否覆盖？',/question,/default_no,title='卷积滤波')
;        if yn eq 'no' then return, -1
;        endif 
        return, infile

    
end


function sep
  ;
    CASE !VERSION.OS_FAMILY OF
        'MacOS': BEGIN
            sep = ':'
          END
        'unix': BEGIN
            sep = '/'
          END
        'vms': BEGIN
            sep = ']'
          END
        'Windows': BEGIN
            sep = '\'
          END
    ENDCASE
  ;
  RETURN, sep
end
;///


FUNCTION getfilename, filename

    CASE !VERSION.OS_FAMILY OF
        'MacOS': BEGIN
            sep = ':'
          END
        'unix': BEGIN
            sep = '/'
          END
        'vms': BEGIN
            sep = ']'
          END
        'Windows': BEGIN
            sep = '\'
          END
    ENDCASE

    ;pos = STRPOS(filename, sep, /REVERSE_SEARCH)
    ;IF ((pos GE 0) AND (pos LT (STRLEN(filename)))) THEN $
    ;    RETURN, STRMID(filename, pos+1) $
    ;ELSE $
    ;    RETURN, filename
    pos = STRPOS(filename, sep, /REVERSE_SEARCH)
    ;stop
    isvalid=where(pos ne -1)
    if n_elements(isvalid) eq 1 then $
      if isvalid eq -1 then return,filename
    tmp=filename
    for i=0,n_elements(isvalid)-1 do begin
      tmp(isvalid(i))=strmid(filename(isvalid(i)),pos(isvalid(i))+1)
    endfor
    return,tmp
END



FUNCTION getpathname, filename

    CASE !VERSION.OS_FAMILY OF
        'MacOS': BEGIN
            sep = ':'
          END
        'unix': BEGIN
            sep = '/'
          END
        'vms': BEGIN
            sep = ']'
          END
        'Windows': BEGIN
            sep = '\'
          END
    ENDCASE

    pos = STRPOS(filename, sep, /REVERSE_SEARCH)
    ;stop
    isvalid=where(pos ne -1)
    if n_elements(isvalid) eq 1 then $
      if isvalid eq -1 then return,''
    tmp=filename
    for i=0,n_elements(isvalid)-1 do begin
      tmp(isvalid(i))=strmid(filename(isvalid(i)),0,pos(isvalid(i)))
    endfor
    return,tmp
    ;
    ;
END
