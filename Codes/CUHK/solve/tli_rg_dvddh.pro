;-
;- Purpose
;-   Solve v & dh using region growing algorithm

PRO TLI_RG_DVDDH, plistfile, dvddhfile, vdhfile,mask_arc,refind

  COMPILE_OPT idl2
  
  time_start= SYSTIME(/SECONDS)
  
;  sarlistfile= 'D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\sarlist_Win'
;  pdifffile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\pdiff0'
;  plistfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\plist'
;  itabfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\itab'
;  arcsfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\arcs'
;  pbasefile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\pbase'
;  dvddhfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\dvddh'
;  pdiffrasfile='D:\myfiles\Software\experiment\TSX_PS_Tianjin\pdiff0.01.ras'
;  v_file='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\v'
;  dh_file='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\dh'
;  vdh_file='D:\myfiles\Software\experiment\TSX_PS_Tianjin\testforCUHK\vdh'
;  
;  IF (!D.NAME) EQ 'X' THEN BEGIN
;    sarlistfile= TLI_DIRW2L(sarlistfile)
;    pdifffile= TLI_DIRW2L(pdifffile)
;    plistfile= TLI_DIRW2L(plistfile)
;    itabfile= TLI_DIRW2L(itabfile)
;    arcsfile=TLI_DIRW2L(arcsfile)
;    pbasefile=TLI_DIRW2L(pbasefile)
;    dvddhfile=TLI_DIRW2L(dvddhfile)
;    pdiffrasfile=TLI_DIRW2L(pdiffrasfile)
;    vdh_file=TLI_DIRW2L(vdh_file)
;  ENDIF
  ;*************Input params****************
;  refind= 30000
  ref_v=0
  ref_dh=0
  weight=0  ; 0: coh
  ; 1: sigma
  ; 2: both
;  mask_arc= 0.5
  
  ; ***************Input files info.****************
  npt= TLI_PNUMBER(plistfile)
  dvddh= TLI_READDATA(dvddhfile, samples=6, format='DOUBLE')
  maxsigma= MAX(dvddh[5, *])+0.1
  
  arcs= dvddh[0:1, *]
  
  ;- Rebuild connectivities among points.
  connect= TLI_CONNECTIVITY(npt, arcs)
  
  ;- Regional growth
  IF refind GT npt THEN BEGIN
    Print, 'Error! Reference point index is larger than points number.'
    RETURN
  ENDIF
  
  plist= TLI_READDATA(plistfile, samples=1, format='FCOMPLEX')
  refcoor= plist[refind]
  Print, 'Coordinate of the reference point is:', STRCOMPRESS(refcoor)
  
  ;  cal_mask= BYTARR(npt)
  EOPT=0
  endpts= refind
  pt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B)
  pt_attr= REPLICATE(pt_attr, npt); point attribute
  pt_attr[refind].v= ref_v
  pt_attr[refind].dh= ref_dh
  pt_attr[refind].calculated= 1; reference point
  
  
  npt_calculated=0
  
  warning_time=0
  WHILE ~(EOPT) DO BEGIN ; Not end of point.
    startpts= endpts     ; Start points.
    
    i=0
    endpts=0; prepared for next while-loop
    FOR i=0, N_ELEMENTS(startpts)-1 DO BEGIN ; Calculations begin at each start point.
      startpt= startpts[i] ; start point i.
      startpt_con= connect[connect[startpt]: (connect[startpt+1]-1)]  ; points connected to this point.
      
      IF (startpt_con[0] EQ -1  AND N_ELEMENTS(startpt_con) EQ 1)Then Begin
        Print, 'Error! The ', STRCOMPRESS(startpts), 'th point is a single point. Please specify another reference point.'
        RETURN
      ENDIF
      
      ; Remove parent node. And the refrence node.
      temp= WHERE(startpt_con NE pt_attr[startpt].parent AND startpt_con NE refind)
      IF temp[0] EQ -1 THEN BEGIN ; Only a single arc is connected to this point
        CONTINUE
      ENDIF
      
      startpt_con= startpt_con[temp]
      
      ; not a single point
      
      ; Find [dv ddh] on the arcs
      startpt_arcs= [TRANSPOSE(DBLARR(N_ELEMENTS(startpt_con)))+startpt, TRANSPOSE(startpt_con)]
      startpt_arcs_start= startpt_arcs[0, *]>startpt_arcs[1, *]
      startpt_arcs_end= startpt_arcs[0, *]<startpt_arcs[1, *]
      startpt_arcs=[startpt_arcs_start, startpt_arcs_end] ; Change start points' indices
      
      j=0
      nextpoints=0 ; points to be calculated after this loop
      FOR j=0, N_ELEMENTS(startpt_con)-1 DO BEGIN
        startpt_arc= startpt_arcs[*,j] ; Calculate v & dh one by one.
        startpt_arc_ind= WHERE(arcs[0, *] EQ startpt_arc[0] AND arcs[1, *] EQ startpt_arc[1]) ; Locate this arc.
        startpt_arc_info= dvddh[*, startpt_arc_ind] ; Extract arc info. [s_ind e_ind dv ddh coh sigma]
        ;          Print, startpt_arc_info
        
        IF startpt_arc[0] EQ startpt THEN BEGIN ; start point of the arc is equal to startpt
          endpt= startpt_arc[1]
          steps= pt_attr[startpt].steps
          CASE weight OF
          
            0 : BEGIN ; Coh
              IF startpt_arc_info[4] GT mask_arc THEN BEGIN ; Here is the problem: this point's information mostly depends on the former information, not itself exactly
                pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[4]/(steps+1)
              ENDIF ELSE BEGIN
                pt_weight=0
              ENDELSE
            END
            
            1: BEGIN ; Sigma
              IF startpt_arc_info[5] LT mask_arc THEN BEGIN
                pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[5]/(maxsigma*(steps+1))
              ENDIF ELSE BEGIN
                pt_weight=0
              ENDELSE
            END
            
            2: BEGIN
              mixedweight=startpt_arc_info[4]+startpt_arc_info[5]/maxsigma
              IF  mixedweight GT mask_arc THEN BEGIN
                pt_weight= pt_attr[startpt].weight/(steps+1)*steps+ mixedweight/(steps+1)
              ENDIF ELSE BEGIN
                pt_weight=0
              ENDELSE
            END
            
          ENDCASE
          
          IF pt_weight GT pt_attr[endpt].weight THEN BEGIN ; Calculated weight is larger than the original weight. Update point attr.
            pt_attr[endpt].v= pt_attr[startpt].v*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
              + startpt_arc_info[2]*(pt_weight/(pt_weight*(steps+1)))  ; Update end node's attr. dv= small_ind-large_ind
            pt_attr[endpt].dh= pt_attr[startpt].dh*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
              + startpt_arc_info[3]*(pt_weight/(pt_weight*(steps+1)))
              
            pt_attr[endpt].parent= startpt
            pt_attr[endpt].steps= steps+1
            pt_attr[endpt].weight=pt_weight
            pt_attr[endpt].calculated=1
            
            nextpoints= [nextpoints, endpt] ; Start points merged at the end of this j loop.
            
          ENDIF ELSE BEGIN
            CONTINUE  ; continue with next child point.
          ENDELSE
          
          
        ENDIF ELSE BEGIN ; start point of the arc is not equal to startpt (start point index is larger than the reference point)
        
          endpt= startpt_arc[0]
          steps= pt_attr[startpt].steps
          CASE weight OF
          
            0 : BEGIN ; Coh
              IF startpt_arc_info[4] GT mask_arc THEN BEGIN ; Here is the problem: this point's information mostly depends on the former information, not itself exactly
                pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[4]/(steps+1)
              ENDIF ELSE BEGIN
                pt_weight=0
              ENDELSE
            END
            
            1: BEGIN ; Sigma
              IF startpt_arc_info[5] LT mask_arc THEN BEGIN
                pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[5]/(maxsigma*(steps+1))
              ENDIF ELSE BEGIN
                pt_weight=0
              ENDELSE
            END
            
            2: BEGIN
              mixedweight=startpt_arc_info[4]+startpt_arc_info[5]/maxsigma
              IF  mixedweight GT mask_arc THEN BEGIN
                pt_weight= pt_attr[startpt].weight/(steps+1)*steps+ mixedweight/(steps+1)
              ENDIF ELSE BEGIN
                pt_weight=0
              ENDELSE
            END
            
          ENDCASE
          
          IF pt_weight GT pt_attr[endpt].weight THEN BEGIN ; Calculated weight is larger than the original weight. Update point attr.
            pt_attr[endpt].v= pt_attr[startpt].v*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
              - startpt_arc_info[2]*(pt_weight/(pt_weight*(steps+1)))  ; Update end node's attr. dv= small_ind-large_ind
            pt_attr[endpt].dh= pt_attr[startpt].dh*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
              - startpt_arc_info[3]*(pt_weight/(pt_weight*(steps+1)))
            pt_attr[endpt].parent= startpt
            pt_attr[endpt].steps= steps+1
            pt_attr[endpt].weight=pt_weight
            pt_attr[endpt].calculated=1
            
            nextpoints= [nextpoints, endpt] ; Start points merged at the end of this j loop.
            
          ENDIF ELSE BEGIN
            CONTINUE  ; continue with next child point.
          ENDELSE
          
          
          
        ENDELSE
      ;          print, 'Ref. info.',startpt_arc_info, 'This info.', pt_attr[endpt]
        
      ENDFOR; Finished at each child node.
      
      ; check nextpoints
      IF N_ELEMENTS(WHERE(nextpoints NE -1)) EQ 1 THEN BEGIN
      ;          Print, 'No child node found at the point ', STRCOMPRESS(startpt)
      ENDIF ELSE BEGIN
        ;endpts
        nextpoints= nextpoints[1:*]
        endpts= [endpts, nextpoints] ; Merge nextpoints.
      ENDELSE
      
    ENDFOR
    ; check endpts
    IF N_ELEMENTS(endpts) EQ 1 THEN BEGIN; No child nodes
      EOPT=1 ; End of the while loop
      ; Check if we are done.
      npt_calculated= TOTAL(pt_attr.calculated)  ; points calculated.
      npt_arcs= arcs[SORT(arcs)]
      npt_arcs= npt_arcs[UNIQ(npt_arcs)]
      npt_arcs= N_ELEMENTS(npt_arcs) ; points in the arcs
      Print, 'Points to be calculated   : ', STRCOMPRESS(npt_arcs)
      Print, 'Points already calculated : ', STRCOMPRESS(npt_calculated)
      
      IF npt_calculated GT npt_arcs*0.9 THEN BEGIN
        Print, 'Most of the points are successfully updated!'
      ENDIF ELSE BEGIN
        Print, 'Error: Please select another reference point or adjust the mask_weight!'
        RETURN
      ENDELSE
      
    ENDIF ELSE BEGIN ; Remove duplicated child nodes
    
      endpts= endpts[1:*]
      endpts= endpts[SORT(endpts)]
      endpts= endpts[UNIQ(endpts)]
      
      
      ;      s_ind= WHERE(pt_attr.calculated NE 0)
      ;
      ;      e_ind= pt_attr[s_ind].parent
      ;      Print, 'nodes that are calculated', COMPLEX(s_ind, e_ind)
      
      old_npt_calculated= npt_calculated
      npt_calculated= TOTAL(pt_attr.calculated)
     
      IF old_npt_calculated GE npt_calculated THEN BEGIN
        warning_time=warning_time+1
        Print, 'Refining result: ', STRCOMPRESS(warning_time)
      ENDIF ELSE BEGIN
        Print,'Number of updated points:', npt_calculated
      ENDELSE
      IF warning_time EQ 5000 THEN BEGIN ; No more points are calculated for 5 times.
        ; Check if we are done.
;        npt_calculated= TOTAL(pt_attr.calculated)  ; points calculated.
        npt_arcs= arcs[SORT(arcs)]
        npt_arcs= npt_arcs[UNIQ(npt_arcs)]
        npt_arcs= N_ELEMENTS(npt_arcs) ; points in the arcs
        Print, 'Points to be calculated   : ', STRCOMPRESS(npt_arcs)
        Print, 'Points already calculated : ', STRCOMPRESS(npt_calculated)
        
        IF npt_calculated GT npt_arcs*0.9 THEN BEGIN
          Print, 'Most of the points are successfully updated!'
          EOPT=1
        ENDIF ELSE BEGIN
          Print, 'Warning: We believe there are isolated arcs during networking'
          RETURN
        ENDELSE
      ENDIF
      
    ENDELSE
    
    
    
  ;
  ;          ; Find points next to the calculated ones.
  ;          temp=connect[connect[endpt]:connect[endpt+1]-1]
  ;          nextpoints= [nextpoints, temp]
  ;        ENDFOR ; end of j-loop
  ;
  ;        ; check nextpoints
  ;        IF N_ELEMENTS(WHERE(nextpoints NE -1)) EQ 1 THEN BEGIN
  ;          Print, 'No grandchild node found at the point ', STRCOMPRESS(startpt)
  ;        ENDIF ELSE BEGIN
  ;          ;endpts
  ;          nextpoints= nextpoints[1:*]
  ;          nextpoints= nextpoints[SORT(nextpoints)]
  ;          nextpoints= nextpoints[UNIQ(nextpoints)] ; Remove duplicated points
  ;          Print, 'Number of start points of the next loop:', STRCOMPRESS(N_ELEMENTS(nextpoints))
  ;        ENDELSE
  ;
  ;        endpts= [endpts, nextpoints]
  ;
  ;      ENDELSE
  ;    ENDFOR ; end i-loop for all the start points.
  ;
  ;    ; Check endpts
  ;    IF N_ELEMENTS(endpts) EQ 1 THEN BEGIN
  ;      EOPT=1 ; End of the while loop
  ;      ; Check if we are done.
  ;      npt_calculated= TOTAL(pt_attr.calculated)  ; points calculated.
  ;      npt_arcs= N_ELEMENTS(UNIQ(SORT(arcs))) ; points in the arcs
  ;      Print, 'Points to be calculated   : ', STRCOMPRESS(npt_arcs)
  ;      Print, 'Points already calculated : ', STRCOMPRESS(npt_calculated)
  ;
  ;      IF npt_calculated GT npt_arcs*0.9 THEN BEGIN
  ;        Print, 'Most of the points are successfully updated!'
  ;      ENDIF ELSE BEGIN
  ;        Print, 'Error: Please select another reference point or adjust the mask_weight!'
  ;        RETURN
  ;      ENDELSE
  ;
  ;    ENDIF ELSE BEGIN
  ;
  ;;      endpts= endpts[1:*]
  ;;      endpts= endpts(WHERE(endpts NE -1))
  ;;      endpts= endpts(WHERE(endpts NE startpt))
  ;
  ;
  ;    ENDELSE
    
    
  ENDWHILE
  
  pt_calculated= WHERE(pt_attr.calculated NE 0)
  pt_coors= plist[pt_calculated]
  v= pt_attr[pt_calculated].v
  dh= pt_attr[pt_calculated].dh
  result= [[REAL_PART(pt_coors)], [IMAGINARY(pt_coors)], [v], [dh]]
  result= TRANSPOSE(result)
  OPENW, lun, vdhfile,/GET_LUN
  WRITEU, lun, result
  FREE_LUN, lun
  
  OPENW, lun, vdhfile+'.txt',/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun
  
  time_end= SYSTIME(/SECONDS)
  time_consumed= (time_end-time_start)/3600D
  Print, 'Time consumed(h): ',STRCOMPRESS(time_consumed)

END