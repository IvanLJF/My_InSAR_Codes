;+
; Calculate deformation parameters for each PS point by using region growing.
; Add some rational constraints to accept a point.
; 
; Parameters:
; 
; Keywords:
;
; Written by:
;     T.LI @ InSAR Group of SWJTU & CUHK
;     04/11/2012, CUHK
;+
PRO TLI_RG_DVDDH_CONSTRAINTS,plistfile, dvddhfile, vdhfile, ptattrfile,$
                             mask_arc, mask_pt_coh, refind,v_acc, dh_acc
  
  
  COMPILE_OPT idl2
  
  time_start= SYSTIME(/SECONDS)
  
  ;*************Input params****************
  ;  refind= 30000
  ref_v=0
  ref_dh=0
  weight=0  ; 0: coh
  ; 1: sigma
  ; 2: both
  ;  mask_arc= 0.8
  ;  mask_pt_coh= 0.9
  ;  mask_pt_sigma= 0.01 ; rad
  ;  v_acc= 10 ; Accuracy of deformation velocity: mm/yr
  ;  dh_acc= 10 ; Accuracy of hight error: m
  
  ; ***************Input files info.****************
  npt= TLI_PNUMBER(plistfile)
  dvddh= TLI_READDATA(dvddhfile, samples=6, format='DOUBLE')
  maxsigma= MAX(dvddh[5, *])+0.1
  
  arcs= dvddh[0:1, *]
  OPENW, lun, plistfile+'.arcs.txt',/GET_LUN
  PRINTF, lun, arcs[0:1, *]
  FREE_LUN, lun
  ; Points to be calculated
  npt_arcs= arcs[SORT(arcs)]
  npt_arcs= npt_arcs[UNIQ(npt_arcs)]
  npt_arcs= N_ELEMENTS(npt_arcs) ; points in the arcs
  
  
  ;- Rebuild connectivities among points.
  connect= TLI_CONNECTIVITY(npt, arcs)
  
  ;- Region Growing
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
  pt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
  pt_attr= REPLICATE(pt_attr, npt); point attribute
  pt_attr[refind].v= ref_v
  pt_attr[refind].dh= ref_dh
  pt_attr[refind].calculated= 1; reference point
  pt_attr[refind].accepted=1
  pt_attr[refind].weight=1
  
  npt_calculated=0
  
  warning_time=0
  WHILE ~(EOPT) DO BEGIN ; Not end of point.
    startpts= endpts     ; Start points.
    
    i=0
    endpts=0; prepared for next while-loop
    FOR i=0, N_ELEMENTS(startpts)-1 DO BEGIN ; Parent node
      startpt= startpts[i] ; start point i.
      
      startpt_weight=0 ; Point quality of the startpt.*******This is very important for this pro.*****
      
      startpt_con= connect[connect[startpt]: (connect[startpt+1]-1)]  ; points connected to this point.
      
      IF (startpt_con[0] EQ -1  AND N_ELEMENTS(startpt_con) EQ 1)Then Begin
        Print, 'Error! The ', STRCOMPRESS(startpts), 'th point is an isolated point. Please specify another reference point.'
        RETURN
      ENDIF
      
      
      ; Remove parent node. And the refrence node.
      ; ***************And also remove the points that have already been accepted.**************************
      temp= WHERE(startpt_con NE pt_attr[startpt].parent AND startpt_con NE refind AND pt_attr[startpt_con].accepted EQ 0)
      IF temp[0] EQ -1 THEN BEGIN ; Only a single arc is connected to this point
        CONTINUE
      ENDIF
      
      startpt_con= startpt_con[temp]
      
      ; not a single point
      
      ; Find [dv ddh] on the arcs
      startpt_arcs= [TRANSPOSE(DBLARR(N_ELEMENTS(startpt_con)))+startpt, TRANSPOSE(startpt_con)]
      startpt_arcs_start= startpt_arcs[0, *]>startpt_arcs[1, *]
      startpt_arcs_end= startpt_arcs[0, *]<startpt_arcs[1, *]
      startpt_arcs=[startpt_arcs_start, startpt_arcs_end] ; Change arc's indices
      
      j=0
      nextpoints=0 ; points to be calculated after this i loop
      FOR j=0, N_ELEMENTS(startpt_con)-1 DO BEGIN ; Child node
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
                this_arc_weight=startpt_arc_info[4]
              ENDIF ELSE BEGIN
                pt_weight=0
                this_arc_weight=0
              ENDELSE
            END
            
            1: BEGIN ; Sigma
              IF startpt_arc_info[5] LT mask_arc THEN BEGIN
                pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[5]/(maxsigma*(steps+1))
                this_arc_weight=startpt_arc_info[5]/maxsigma
              ENDIF ELSE BEGIN
                pt_weight=0
                this_arc_weight=0
              ENDELSE
            END
            
            2: BEGIN
              mixedweight=startpt_arc_info[4]+startpt_arc_info[5]/maxsigma
              IF  mixedweight GT mask_arc THEN BEGIN
                pt_weight= pt_attr[startpt].weight/(steps+1)*steps+ mixedweight/(steps+1)
                this_arc_weight=pt_weight
              ENDIF ELSE BEGIN
                pt_weight=0
                this_arc_weight=0
              ENDELSE
            END
            
          ENDCASE
          ; Deformation velocity and height error are updated first.
          ; Other information is not updated here.
          
          ; If the constraints are fulfilled. Update point attr.
          pt_attr[endpt].v= pt_attr[startpt].v*((pt_attr[startpt].weight)/(pt_weight)) $
            + (1-pt_attr[startpt].weight/(pt_weight))*ref_v $
            + startpt_arc_info[2]* (this_arc_weight) $
            * (pt_attr[startpt].weight/(pt_weight))  ; Update end node's attr. dv= small_ind-large_ind
          pt_attr[endpt].dh= pt_attr[startpt].dh*((pt_attr[startpt].weight)/(pt_weight)) $
            + (1-pt_attr[startpt].weight/(pt_weight))*ref_dh $
            + startpt_arc_info[3]* (this_arc_weight) $
            * (pt_attr[startpt].weight/(pt_weight))  ; Update end node's attr. dv= small_ind-large_ind
            
          ;- Here I change the constraints of accepting a point.
          ;- 1) Weight
          ;- 2) Cosistency.
          ; Judge if this node shoulde be accepted or not.
          ; 1) Weight > mask_pt_coh
          IF (pt_weight LT mask_pt_coh) THEN CONTINUE ; Go to next point.
          ; 2) cosistency == MEAN(sigma) < mask_pt_sigma
          ; Find grandchild nodes
          grandnode= connect[connect[endpt]:(connect[endpt+1]-1)]
          ; Pick out the accepted ones. Those include itself's parent node.
          grandnode = grandnode[WHERE (pt_attr[grandnode].accepted EQ 1)]
          ;      IF grannode[0] EQ -1 THEN BEGIN ; it can never be equal to -1. If this happens, then there must be something wrong in this pro.
          ;        CONTINUE
          ;      ENDIF
          ; Find those arcs and calculate cosistency.
          ; Referece to line 83
          grandnode_arcs= [TRANSPOSE(DBLARR(N_ELEMENTS(grandnode)))+endpt, TRANSPOSE(grandnode)]
          grandnode_arcs_start= grandnode_arcs[0, *]>grandnode_arcs[1, *]
          grandnode_arcs_end= grandnode_arcs[0, *]<grandnode_arcs[1, *]
          grandnode_arcs=[grandnode_arcs_start, grandnode_arcs_end] ; Change arc's indices
          grandnode_dv_calculated=pt_attr[grandnode].v - pt_attr[endpt].v ; grandnode- childnode********************************************
          grandnode_ddh_calculated= pt_attr[grandnode].dh - pt_attr[endpt].dh ;childnode - grandnode
          grandnode_dvddh=DBLARR(2)
          FOR k=0, N_ELEMENTS(grandnode)-1 DO BEGIN
            grandnode_arc= grandnode_arcs[*,k] ; Calculate v & dh one by one.
            grandnode_arc_ind= WHERE(arcs[0, *] EQ grandnode_arc[0] AND arcs[1, *] EQ grandnode_arc[1]) ; Locate this arc.
            grandnode_arc_info= dvddh[*, grandnode_arc_ind] ; Extract arc info. [s_ind e_ind dv ddh coh sigma]
            
            IF grandnode_arc[0] NE endpt THEN BEGIN ; endpt is larger than this grandchild node's index.
              temp= -grandnode_arc_info[2:3]
            ENDIF ELSE BEGIN
              temp= grandnode_arc_info[2:3]
            ENDELSE
            
            grandnode_dvddh=[[grandnode_dvddh], [temp]]
          ENDFOR
          grandnode_dvddh=grandnode_dvddh[*, 1:*]
          v_acc_dev= MEAN((grandnode_dvddh[0, *]- grandnode_dv_calculated)^2)
          v_acc_std= SQRT(v_acc_dev)
          dh_acc_dev= MEAN((grandnode_dvddh[1,*] - grandnode_ddh_calculated)^2)
          dh_acc_std= SQRT(dh_acc_dev)
          IF v_acc_std GT v_acc THEN CONTINUE   ; Accuracy of v.
          IF dh_acc_std GT dh_acc THEN CONTINUE  ; Accuracy of dh.
          
          
          pt_attr[endpt].parent= startpt
          pt_attr[endpt].steps= steps+1
          pt_attr[endpt].weight=pt_weight
          pt_attr[endpt].calculated=1 ; This is dunplicate, maybe.
          pt_attr[endpt].accepted=1
          
          nextpoints= [nextpoints, endpt] ; Start points merged at the end of this j loop.
          
          
        ENDIF ELSE BEGIN ; start point of the arc is not equal to startpt (start point index is larger than the reference point)
        
          endpt= startpt_arc[0]
          steps= pt_attr[startpt].steps
          CASE weight OF
          
            0 : BEGIN ; Coh
              IF startpt_arc_info[4] GT mask_arc THEN BEGIN ; Here is the problem: this point's information mostly depends on the former information, not itself exactly
                pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[4]/(steps+1)
                this_arc_weight=startpt_arc_info[4]
              ENDIF ELSE BEGIN
                pt_weight=0
                this_arc_weight=0
              ENDELSE
            END
            
            1: BEGIN ; Sigma
              IF startpt_arc_info[5] LT mask_arc THEN BEGIN
                pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[5]/(maxsigma*(steps+1))
                this_arc_weight=startpt_arc_info[5]/maxsigma
              ENDIF ELSE BEGIN
                pt_weight=0
                this_arc_weight=0
              ENDELSE
            END
            
            2: BEGIN
              mixedweight=startpt_arc_info[4]+startpt_arc_info[5]/maxsigma
              IF  mixedweight GT mask_arc THEN BEGIN
                pt_weight= pt_attr[startpt].weight/(steps+1)*steps+ mixedweight/(steps+1)
                this_arc_weight=mixedweight
              ENDIF ELSE BEGIN
                pt_weight=0
                this_arc_weight=0
              ENDELSE
            END
            
          ENDCASE
          
          
          ; Deformation velocity and height error are updated first.
          ; Other information is not updated here.
          ;          pt_attr[endpt].v= pt_attr[startpt].v*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
          ;            - startpt_arc_info[2]*(pt_weight/(pt_weight*(steps+1)))  ; Update end node's attr. dv= small_ind-large_ind
          ;          pt_attr[endpt].dh= pt_attr[startpt].dh*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
          ;            - startpt_arc_info[3]*(pt_weight/(pt_weight*(steps+1)))
;          pt_attr[endpt].v= pt_attr[startpt].v*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
;            - (pt_attr[startpt].v + startpt_arc_info[2]) *(pt_attr[startpt].weight/(pt_weight*(steps+1)))  ; Update end node's attr. dv= small_ind-large_ind
;          pt_attr[endpt].dh= pt_attr[startpt].dh*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
;            - (pt_attr[startpt].dh+ startpt_arc_info[3]) *(pt_attr[startpt].weight/(pt_weight*(steps+1)))
            
            pt_attr[endpt].v= pt_attr[startpt].v*((pt_attr[startpt].weight)/(pt_weight)) $
            + (1-pt_attr[startpt].weight/(pt_weight))*ref_v $
            - startpt_arc_info[2]* (this_arc_weight) $
            * (pt_attr[startpt].weight/(pt_weight))  ; Update end node's attr. dv= small_ind-large_ind
          pt_attr[endpt].dh= pt_attr[startpt].dh*((pt_attr[startpt].weight)/(pt_weight)) $
            + (1-pt_attr[startpt].weight/(pt_weight))*ref_dh $
            - startpt_arc_info[3]* (this_arc_weight) $
            * (pt_attr[startpt].weight/(pt_weight))  ; Update end node's attr. dv= small_ind-large_ind
            
          ; If the constraints are fulfilled. Update point attr.
            
          ;- Here I change the constraints of accepting a point.
          ;- 1) Weight
          ;- 2) Cosistency.
          ; Judge if this node shoulde be accepted or not.
          ; 1) Weight > mask_pt_coh
          IF (pt_weight LT mask_pt_coh) THEN CONTINUE ; Go to next point.
          ; 2) cosistency == MEAN(sigma) < mask_pt_sigma
          ; Find grandchild nodes
          grandnode= connect[connect[endpt]:(connect[endpt+1]-1)]
          ; Pick out the accepted ones. Those include itself's parent node.
          grandnode = grandnode[WHERE (pt_attr[grandnode].accepted EQ 1)]
          ;      IF grannode[0] EQ -1 THEN BEGIN ; it can never be equal to -1. If this happens, then there must be something wrong in this pro.
          ;        CONTINUE
          ;      ENDIF
          ; Find those arcs and calculate cosistency.
          ; Referece to line 83
          grandnode_arcs= [TRANSPOSE(DBLARR(N_ELEMENTS(grandnode)))+endpt, TRANSPOSE(grandnode)]
          grandnode_arcs_start= grandnode_arcs[0, *]>grandnode_arcs[1, *]
          grandnode_arcs_end= grandnode_arcs[0, *]<grandnode_arcs[1, *]
          grandnode_arcs=[grandnode_arcs_start, grandnode_arcs_end] ; Change arc's indices
          grandnode_dv_calculated=pt_attr[grandnode].v - pt_attr[endpt].v ; grandnode- childnode********************************************
          grandnode_ddh_calculated= pt_attr[grandnode].dh - pt_attr[endpt].dh ;childnode - grandnode
          grandnode_dvddh=DBLARR(2)
          FOR k=0, N_ELEMENTS(grandnode)-1 DO BEGIN
            grandnode_arc= grandnode_arcs[*,k] ; Calculate v & dh one by one.
            grandnode_arc_ind= WHERE(arcs[0, *] EQ grandnode_arc[0] AND arcs[1, *] EQ grandnode_arc[1]) ; Locate this arc.
            grandnode_arc_info= dvddh[*, grandnode_arc_ind] ; Extract arc info. [s_ind e_ind dv ddh coh sigma]
            
            IF grandnode_arc[0] NE endpt THEN BEGIN ; endpt is larger than this grandchild node's index.
              temp= -grandnode_arc_info[2:3]
            ENDIF ELSE BEGIN
              temp= grandnode_arc_info[2:3]
            ENDELSE
            
            grandnode_dvddh=[[grandnode_dvddh], [temp]]
          ENDFOR
          grandnode_dvddh=grandnode_dvddh[*, 1:*]
          v_acc_dev= MEAN((grandnode_dvddh[0, *]- grandnode_dv_calculated)^2)
          v_acc_std= SQRT(v_acc_dev)
          dh_acc_dev= MEAN((grandnode_dvddh[1,*] - grandnode_ddh_calculated)^2)
          dh_acc_std= SQRT(dh_acc_dev)
          IF v_acc_std GT v_acc THEN CONTINUE   ; Accuracy of v.
          IF dh_acc_std GT dh_acc THEN CONTINUE  ; Accuracy of dh.
          
          
          
          pt_attr[endpt].parent= startpt
          pt_attr[endpt].steps= steps+1
          pt_attr[endpt].weight=pt_weight
          pt_attr[endpt].calculated=1 ; This is duplicate, maybe.
          pt_attr[endpt].accepted=1
          
          nextpoints= [nextpoints, endpt] ; Start points merged at the end of this j loop.
          
          
          
          
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
        Print, 'Error: Less than 90% points are calculated successfully.'
        Print, 'Error: Please select another reference point or adjust the mask_weight!'
        Print, 'But we still output the results for you...'
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
        Print,'Number of updated points:', LONG(npt_calculated), '/', STRCOMPRESS(npt_arcs)
        IF npt_calculated EQ 36 THEN BEGIN
          Print, 'Ready to test'
        ENDIF
      ENDELSE
      IF warning_time EQ 5000 THEN BEGIN ; No more points are calculated for 5 times.
        ; Check if we are done.
        ;        npt_calculated= TOTAL(pt_attr.calculated)  ; points calculated.
      
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
    
    
    
  ENDWHILE
  
  pt_calculated= WHERE(pt_attr.calculated NE 0)
  pt_coors= plist[pt_calculated]
  v= pt_attr[pt_calculated].v
  dh= pt_attr[pt_calculated].dh
  result= [[pt_calculated],[REAL_PART(pt_coors)], [IMAGINARY(pt_coors)], [v], [dh]]
  result= TRANSPOSE(result)
  OPENW, lun, vdhfile,/GET_LUN ; Index , x, y, v, dh
  WRITEU, lun, result
  FREE_LUN, lun
  
  OPENW, lun, vdhfile+'.txt',/GET_LUN
  PRINTF, lun, result
  FREE_LUN, lun
  
;  pt_attr= pt_attr[pt_calculated];*****************************************
  OPENW,lun, ptattrfile,/GET_LUN
  WRITEU, lun, pt_attr
  FREE_LUN, lun
  
  time_end= SYSTIME(/SECONDS)
  time_consumed= (time_end-time_start)/3600D
  Print, 'Time consumed(h): ',STRCOMPRESS(time_consumed)
  
END