FUNCTION SOURCEROOT 
COMPILE_OPT StrictArr 
HELP, Calls = Calls 
UpperRoutine = (StrTok(Calls[1], ' ', /Extract))[0] 
Skip = 0 
CATCH, ErrorNumber 
IF (ErrorNumber NE 0) THEN BEGIN 
CATCH, /Cancel 
ThisRoutine = ROUTINE_INFO(UpperRoutine, /Functions, /Source) 
Skip = 1 
ENDIF 
IF (Skip EQ 0) THEN BEGIN 
ThisRoutine = ROUTINE_INFO(UpperRoutine, /Source) 
IF (thisRoutine.Path EQ '') THEN BEGIN 
MESSAGE,'',/traceback 
ENDIF 
ENDIF 
CATCH,/cancel 
IF (STRPOS(thisroutine.path,PATH_SEP()) EQ -1 ) THEN BEGIN 
CD, current=current 
sourcePath = FILEPATH(thisrouitine.path, root=current) 
ENDIF ELSE BEGIN 
sourcePath = thisroutine.path 
ENDELSE 
Root = STRMID(sourcePath, 0, STRPOS(sourcePath, PATH_SEP(), /Reverse_Search) + 1) 
RETURN, Root 
END