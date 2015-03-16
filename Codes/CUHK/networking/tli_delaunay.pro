;+
; Name:
;    TLI_DELAUNAY
; Purpose:
;    Generate arcs of the points using Delaunay
; Calling Sequence:
;    result= TLI_DELAUNAY(plist,outname=outname,range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
; Inputs:
;    plist         :  Input point list file.
;    range_pixel_spacing: Range pixel spacing of input file.
;    azimuth_pixel_spacing: Azimuth pixel spacing of input file.
; Keyword Input Parameters:
;    outname       :  Output file name for arcs
;    dist_thresh   :  Threshold of the distance of one arc to be removed.
; Outputs:
;    Arcs file.
; Commendations:
;    None.
; Example:
;    plist= '/mnt/backup/Qingzang_envisat/PSI/plist'
;    outfile='/mnt/backup/Qingzang_envisat/PSI/arcs'
;    range_pixel_spacing= 7.8
;    azimuth_pixel_spacing= 4.0
;    dist_thresh=1000
;    result= TLI_DELAUNAY(plist,outname= outfile, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh)
; Modification History:
;    30/3/2012     :  Written by T.Li @ InSAR Team in SWJTU & CUHK
;    24/7/2012    : Add keyword 'dist_thresh'.
;-

FUNCTION TLI_DELAUNAY, plist,outname=outname, range_pixel_spacing, azimuth_pixel_spacing, dist_thresh= dist_thresh,$
    logfile=logfile
    
  COMPILE_OPT idl2
  
  IF N_PARAMS() NE 3 THEN Message, 'Please specify the point list file.'
  IF ~KEYWORD_SET(outname)  THEN outname= FILE_DIRNAME(plist)+PATH_SEP()+'arcs.dat'
  IF ~KEYWORD_SET(dist_thresh) THEN dist_thresh= 10000000000D
  outfile= outname
  
  ;----------------Triangulate---------------------
  psno= TLI_PNUMBER(plist)
  
  pscoor= COMPLEXARR(1,psno)
  OPENR, lun, plist,/GET_LUN
  READU, lun, pscoor
  FREE_LUN, lun
  
  x=REAL_PART(pscoor)
  y=IMAGINARY(pscoor)
  TRIANGULATE,x, y, triangles, CONNECTIVITY= list, REPEATS= repeats,tolerance=0.0
  
  ;  ; Check list
  ;  list_coor= list[0:psno-1]
  ;  list_chk=LINDGEN(psno)
  ;  list_coorind= SORT(list_coor)
  ;  list_result= list_chk-list_coorind
  ;  ind= WHERE(list_result NE 0)
  ;  Print, N_ELEMENTS(ind)
  ;  Print, "Check done."
  
  
  ;-------------Compute all arcs------------------
  ; With reference to list
  arcs= COMPLEXARR(3) ; Arcs=[start_coor end_coor (start_ind, end_ind)]
  OPENW, lun, outfile,/GET_LUN
  For i=0, psno-2 DO BEGIN ; The last point needs no consideration.
  
    IF (psno-2) GT 10000 THEN BEGIN
      IF i GT 0 AND ~(i MOD 10000) THEN BEGIN
        Print,'Processed arcs:', STRCOMPRESS(i), ' / ', STRCOMPRESS(psno-2)
        WriteU, lun, arcs[*,1:*]
        arcs= COMPLEXARR(3)
      ENDIF
      end_ind= list[list[i]:list[i+1]-1]
      ind= WHERE(end_ind GT i)
      IF ind[0] EQ -1 THEN CONTINUE
      
      end_ind= end_ind[ind] ; Find end point
      start_coor= TRANSPOSE(COMPLEXARR(N_ELEMENTS(ind)) + pscoor[i])
      end_coor= pscoor[*,end_ind]
      start_ind= TRANSPOSE(i+FLTARR(N_ELEMENTS(ind)))
      arcs_tmp= [end_coor, start_coor, TRANSPOSE(COMPLEX(end_ind, start_ind))] ; Let large index comes first.
      arcs= [[arcs], [arcs_tmp]]
      
      IF i EQ psno-2 THEN BEGIN
        WriteU, lun, arcs[*, 1:*]
      ENDIF
      
    ENDIF ELSE BEGIN
    
      IF list[i+1]-1 LE list[i] THEN CONTINUE
      end_ind= list[list[i]:list[i+1]-1]
      ind= WHERE(end_ind GT i)
      IF ind[0] EQ -1 THEN CONTINUE
      end_ind= end_ind[ind] ; Find end point
      start_coor= TRANSPOSE(COMPLEXARR(N_ELEMENTS(ind)) + pscoor[i])
      end_coor= pscoor[*,end_ind]
      start_ind= TRANSPOSE(i+FLTARR(N_ELEMENTS(ind)))
      arcs_tmp= [end_coor, start_coor, TRANSPOSE(COMPLEX(end_ind, start_ind))] ; Let large index comes first.
      arcs= [[arcs], [arcs_tmp]]
      
    ENDELSE
    
  ENDFOR
  IF (psno-2) MOD 10000 THEN BEGIN
    WriteU, lun, arcs[*, 1:*]
  ENDIF
  FREE_LUN, lun
  ; Refine arcs
  arcs_coor= TLI_READDATA(outfile,samples=3, format='FCOMPLEX')
  arcs_num_before= N_ELEMENTS(arcs_coor)/3
  arcs_dist= (arcs_coor[1, *]- arcs_coor[0, *])
  arcs_dist= SQRT((REAL_PART(arcs_dist)*range_pixel_spacing)^2+(IMAGINARY(arcs_dist)*azimuth_pixel_spacing)^2)
  ind= WHERE(arcs_dist LE dist_thresh, COMPLEMENT=ind_large)
  
  IF KEYWORD_SET(logfile) THEN BEGIN
    ; Check the useful point number.
    all_ind=arcs_coor[2, *]
    all_ind=[REAL_PART(all_ind),IMAGINARY(all_ind)]
    all_ind=all_ind[UNIQ(all_ind[SORT(all_ind)])]
    npt_after=N_ELEMENTS(all_ind)
    npt_before=TLI_PNUMBER(plist)
    temp=LONG(npt_before-npt_after)
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Delaynay Triangulation:',/PRT
    TLI_LOG, logfile, 'Some points are discarded due to colinear problems: '+STRCOMPRESS(temp),/PRT
  ENDIF
  
  
  IF ind[0] EQ -1 THEN BEGIN
    Message, 'Error! Please enlarge the dist_thresh!'
  ENDIF ELSE BEGIN
    arcs_coor= arcs_coor[*, ind]
  ENDELSE
  arcs_num_after= N_ELEMENTS(ind)
  Print, 'Arcs number before refinement: ', STRCOMPRESS(arcs_num_before)
  Print, 'Arcs number after refinement:', STRCOMPRESS(arcs_num_after)
  
  OPENW, lun, outfile,/GET_LUN
  WriteU, lun, arcs_coor
  FREE_LUN, lun
  
  OPENW, lun, outfile+'.txt',/GET_LUN
  PRINTF, lun, arcs_coor[2, *]
  FREE_LUN, lun
  
  RETURN, 1
END


;
;  ;---------------Compute all arcs---------------------
;  pscoor= COMPLEX(x,y)
;  arcs_coor_1= pscoor[triangles[0,*]]
;  arcs_coor_2= pscoor[triangles[1,*]]
;  arcs_coor_3= pscoor[triangles[2,*]]
;  arcs_coor=[[arcs_coor_1,arcs_coor_2], $
;             [arcs_coor_1,arcs_coor_3], $
;             [arcs_coor_2,arcs_coor_3]]
;;  result= [[COMPLEX(triangles[0,*],triangles[1, *])], $
;;           [COMPLEX(triangles[0,*],triangles[2, *])], $
;;           [COMPLEX(triangles[1,*],triangles[2, *])]]
;;           PRINT, SIZE(result,/DIMENSIONS)
;
;  ;--------------Refine Delaunay-------------
;  ;Uniq
;
;  ;1. Let the larger index of the two points in one arc comes first.
;  ind_all= [[triangles[0, *], triangles[1, *]],$
;              [triangles[0, *], triangles[2, *]],$
;              [triangles[1, *], triangles[2, *]]]
;  ind_tochange= WHERE(ind_all[0, *] LT ind_all[1, *])
;  tmp= ind_all[0, ind_tochange]
;  ind_all[0, ind_tochange]= ind_all[1, ind_tochange]
;  ind_all[1, ind_tochange]= tmp
;
;;  ;2. Sort the indices according to the start point.
;;  ; Horrible! This is wrong.
;;  ind_sort= SORT(ind_all[0, *])
;;  ind_all= ind_all[*, ind_sort]
;;
;  ;3. Then sort the indices according to the distances.
;  dis_x= Real_part(arcs_coor[1, *]-arcs_coor[0, *])*range_pixel_spacing
;  dis_y= IMAGINARY(arcs_coor[1, *]-arcs_coor[0, *])*azimuth_pixel_spacing
;  dis= SQRT(dis_x^2+dis_y^2); All arcs' distances.
;;
;;  dis= dis[ind_sort]
;  ind_dis= SORT(dis)
;  dis= dis[ind_dis]
;  ind_all= ind_all[*,ind_dis]
;
;  ;4. Select uniq arcs
;  ind_all_complex= COMPLEX(ind_all[0, *], ind_all[1, *])
;  ind_uniq= UNIQ(SORT(ind_all_complex))
;
;  dis= dis[ind_uniq]
;  ind_all= ind_all[*, ind_uniq]
;  refine_before= N_ELEMENTS(ind_all)/2
;
;  ;5. Set distance threshold.
;  ind_dis_mask= WHERE(dis LE dist_thresh)
;  ind_all= ind_all[*, ind_dis_mask]
;  refine_after= N_ELEMENTS(ind_all)/2
;  Print, 'Arcs Before Refinement:', refine_before
;  Print, 'Arcs After Refinement:', refine_after
;  ind= COMPLEX(ind_all[0,*], ind_all[1, *])
;  arcs_coor= [pscoor[ind_all[0, *]], pscoor[ind_all[1, *]], ind]