;+ 
; Name:
;    TLI_SELECTMASTER
; Purpose:
;    Select a master image according to Doc. Zhao's param file.
; Calling Sequence:
;    result= TLI_SELECTMASTER(paramfile, sarlist, method=method, weights=weights)
; Inputs:
;    paramfile    :  Param file.
;    sarlist      :  An ASCII file containing all the slcs' full path.
; Keyword Input Parameters:
;    method       :  Method to choose master.
;                    0: Temporal baseline minimized.
;                    1: Spatial baseline minimized.
;                    2: Doppler centroid baseline minimized.
;                    3: Perpendicular spatial baseline minimized.
;                    3: A weighting algrithom combining above all.
;    weights      :  If mothod EQ 4, then this is needed.
; Outputs:
;    Number of master image. same order as sarlist
; Commendations:
;    None
; Example:
;    paramfile='/mnt/software/ISEIS/Data/Img/Result_ASAR_Full.txt'
;    sarlist='/mnt/software/ISEIS/Data/Img/sarlist.txt'
;    method=0
;    weights=[1,1,1]
;    result=TLI_SELECTMASTER(paramfile, sarlist, method=method, weights=weights)
; Modification History:
;    23/05/2012        :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;- 


FUNCTION TLI_MOSTBASELINE, data
; Get master image according to max or min baseline.
  nfiles= 0
  sz= N_ELEMENTS(data)
  WHILE ((nfiles^2+nfiles)/2) NE sz DO BEGIN
    nfiles= nfiles+1
    IF nfiles GT 1000 THEN Message, 'TLI_SELECTMASTER/TLI_MOSTBASELINE: You must be joking!'
  ENDWHILE
  nfiles=nfiles+1
  
  baselines= DBLARR(nfiles, nfiles)
  s=0;start of data
  e=0;end of data
  length=0; length of data
  FOR i=0, nfiles-2 DO BEGIN
    s= s+length
    e= e+(nfiles-2-i)
    baselines[i,i+1:*]=data[s:e]
    length= nfiles-i-2
  ENDFOR
  baselines= baselines+ TRANSPOSE(baselines)
  result= TOTAL(ABS(baselines),1); sum in samples.
  final= MIN(result,p)
  RETURN, p
END

FUNCTION TLI_SELECTMASTER,paramfile, sarlist, method=method, weights=weights
;    paramfile='/mnt/software/ISEIS/Data/Img/Result_ASAR_Full.txt'
;    sarlist='/mnt/software/ISEIS/Data/Img/sarlist.txt'
    params= TLI_EXTRBASELINE(paramfile)
    t_baseline= params[0,*]
    s_baseline= params[1,*]
    perp_s_baseline= params[2,*]
    f_baseline= params[3,*]
    
    nfiles= 0
    sz= N_ELEMENTS(t_baseline)
    WHILE ((nfiles^2+nfiles)/2) NE sz DO BEGIN
      nfiles= nfiles+1
      IF nfiles GT 10000 THEN Message, 'TLI_SELECTMASTER/TLI_MOSTBASELINE: You must be joking!'
    ENDWHILE
    nfiles=nfiles+1
    nlines= FILE_LINES(sarlist)
    IF nfiles NE nlines THEN Message, 'TLI_SELECTMASTER: sarlist is inconsistent with paramfile'
    
    IF ~KEYWORD_SET(method) THEN method = 2
    IF method EQ 4 THEN BEGIN
      IF N_ELEMENTS(weights) NE 3 THEN BEGIN
        Message, 'TLI_SELECTMASTER: Please give weights when specify mothod of 3!'
      ENDIF
    ENDIF
    
    
    Case method OF
      0: BEGIN; Temporal baseline
        index= TLI_MOSTBASELINE(t_baseline)
      END
      1: BEGIN; Spatial baseline
        index= TLI_MOSTBASELINE(s_baseline)
      END
      2 : BEGIN; Perpendicular spatial baseline
        index= TLI_MOSTBASELINE(perp_s_baseline)
      END
      3: BEGIN; Doppler Centroid difference
        index= TLI_MOSTBASELINE(f_baseline)
      END
      4: BEGIN
        sum_baseline= t_baseline*weights[0]+s_baseline*weights[1]+f_baseline*weights
        index= TLI_MOSTBASELINE(sum_baseline)
      END
      ELSE: BEGIN
        Message, 'Method is not supported!'
      END
    ENDCASE
    Return, index
END