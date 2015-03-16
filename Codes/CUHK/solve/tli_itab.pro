;+ 
; Name:
;    TLI_ITAB
; Purpose:
;    Generate itab file.
; Calling Sequence:
;    Result= TLI_ITAB(paramfile, sarlist, method=method, master=master, output_file=output_file)
; Inputs:
;    paramfile     : Dr. Zhao's param file.
;    sarlist       : Sar list file. 
; Keyword Input Parameters:
;    method        : Method to choose master file.
;                    0: Single master
;                    1: Free combination
;                    2: Multi master.
;                    3: MST using temporal baselines.
;    master        : Indices of master images. IF method is equal to 2 then this is needed.
;    output_file   : Full path of itab file.
; Outputs:
;    output_file    :
; Commendations:
;    None.
; Example:
;    paramfile= '/mnt/software/ISEIS/Data/Img/Result_ASAR_Full.txt'
;    sarlist='/mnt/software/ISEIS/Data/Img/sarlist.txt'
;    method=0
;    output_file= FILE_DIRNAME(sarlist)+PATH_SEP()+'itab.txt'
;    result= TLI_ITAB(paramfile, sarlist, method= method, master= master, output_file= output_file)
; Modification History:
;    28/5/2012        :  Written by T.Li @ InSAR Team in SWJTU & CUHK
; -
Function TLI_ITAB , paramfile, sarlist, method=method, master=master, output_file=output_file
  
  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 2 THEN Message, 'TLI_ITAB: Usage error!'
  IF ~Keyword_set(method) THEN method = 0

  ; itab file,all indices start from 1
  ; ---master index---slave index---inter index---mask value---
  indices=1
  itab= INTARR(4)
  mask=1; Mask value, always equal to 0
  nlines= FILE_LINES(sarlist)
  Case method OF
    0: BEGIN;Single master
      master=TLI_SELECTMASTER(paramfile, sarlist)
      Print, 'Use single master. Master index is:', STRCOMPRESS(master)
      nlines= FILE_LINES(sarlist)
      temp= STRARR(nlines)
      OPENR, lun, sarlist,/GET_LUN
      READF, lun, temp
      FREE_LUN, lun
      Print, 'Master file is:  ', temp[master]
      FOR slave=1, nlines DO BEGIN
        IF slave NE master THEN BEGIN
          result= [master, slave,indices,  mask]
          itab= [[itab], [result]]
          indices= indices+1
        ENDIF
      ENDFOR
      itab= itab[*,1:*]
    END
    1: BEGIN
      Print, 'Use free combination.'
      FOR master=1, nlines-1 DO BEGIN
        FOR slave= master+1, nlines DO BEGIN
          result= [master, slave, indices, mask]
          indices= indices+1
          itab= [[itab], [result]]
        ENDFOR
      ENDFOR
      itab= itab[*,1:*]
    END
    2: BEGIN
      IF N_ELEMENTS(master) EQ 0 THEN Message, 'TLI_ITAB: Please specify the master image.'
      Print, 'Use multi master. '
      Print, 'The master indices are(start from 1):  ', master
      IF MAX(master) GT nlines THEN Message, 'TLI_ITAB: Master indices wrong.'
      sz= N_ELEMENTS(master)
      FOR  i=0, sz-1 DO BEGIN
        FOR slave=1, nlines DO BEGIN
          IF slave NE master[i] THEN BEGIN
            result= [master[i], slave, indices, mask]
            indices= indices+1
            itab= [[itab], [result]]
          ENDIF
        ENDFOR
      ENDFOR
      itab= itab[*,1:*]
    END
    3: BEGIN ; Referred to Qingli LUO @ ISEIS, CUHK, Using a minimum spanning tree (only consider the temporal baselines).
      ; Read sarlist file
      nlines=file_lines(sarlist)
      slcs=STRARR(1,nlines)
      OPENR, lun,sarlist,/GET_LUN
      READF, lun, slcs
      FREE_LUN, lun
      ; Judge the columns 
      temp=slcs[0]
      temp=STRSPLIT(temp,' ',/EXTRACT)
      IF N_ELEMENTS(temp) EQ 1 THEN BEGIN
        names=slcs
      ENDIF ELSE BEGIN
        slcs=STRSPLIT(slcs,' ',/EXTRACT)
        names=slcs[1,*]
        temp=temp[1]
      ENDELSE
      ; Get the basenames
      suffix=STRSPLIT(temp, '.',/EXTRACT)
      IF N_ELEMENTS(suffix) EQ 1 THEN BEGIN
        names=FILE_BASENAME(names)
      ENDIF ELSE BEGIN
        suffix=suffix[1]
        names=FILE_BASENAME(names,'.'+suffix)
      ENDELSE
      ; Get the date
      dates=STRMID(names,8,/REVERSE_OFFSET)
      dates=LONG(dates)
      
      ; Creat MST itab
      itab=LONARR(4, nlines-1)
      count=0
      FOR i=0, nlines-1 DO BEGIN
        date=dates[i]
        intf_ind=WHERE((dates-date) GT 0)
        IF intf_ind[0] EQ -1 THEN CONTINUE
        mintbase=MIN((dates[intf_ind]-date),intf_ind_ind)
        intf_ind=intf_ind[intf_ind_ind]
        intf_date=dates[intf_ind]
        itab[*, count]=[i+1, intf_ind+1, count+1, 1]
        count=count+1
      ENDFOR
    END
    ELSE: BEGIN
      Message, 'TLI_ITAB: Method to construct itab file is not supported!'
    END
  ENDCASE
  IF ~Keyword_set(output_file) THEN BEGIN
    output_file= FILE_DIRNAME(sarlist)+PATH_SEP()+'itab.txt'
  ENDIF
  OPENW, lun, output_file,/GET_LUN
  PRINTF, lun, STRCOMPRESS(itab), FORMAT='(I3, I4, I5, I3)'
  FREE_LUN, lun
  Print, 'File written successfully!'
  Return, itab
END