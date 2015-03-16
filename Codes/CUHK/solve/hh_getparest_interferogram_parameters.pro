; Get params from Doc. Zhao's para-file.
Function HH_GetParEst_Interferogram_Parameters, filename
  Compile_Opt IDL2
  openr, lun, fileName, /get_lun
  line = ''
  ReArr = Strarr(19, 1)
  Guide = 0
  While(~Eof(lun)) do begin
    Readf, lun, line
    if Guide eq 1 then begin
      if Strtrim(line, 2) eq '' then Break
      strs = StrSplit(line, String(9B), /extract)
      ReArr = [[ReArr], [strs]]
      Continue
    endif
    pos = StrPos(line, 'Interferogram Parameters')
    if pos ne -1 then begin
      Guide = 1
      Readf, lun, line ;ÌøÒ»ÐÐ
      Continue
    endif   
  EndWhile
  free_lun, lun
  nEle = N_Elements(ReArr[0,*])
  Return,  ReArr[*, 1:nEle-1]
End