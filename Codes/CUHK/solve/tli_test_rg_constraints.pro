



PRO TLI_TEST_RG_CONSTRAINTS
  workpath= '/mnt/software/myfiles/Software/experiment/TSX_PS_HK'
  sarlistfilegamma= workpath+'/SLC_tab'
  sarlistfile= workpath+'/testforCUHK/sarlist_Linux'
  pdifffile= workpath+'/pdiff0'
  plistfilegamma= workpath+'/pt';'/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/plist'
  plistfile= workpath+'/testforCUHK/plist'
  itabfile= workpath+'/itab';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/itab'
  arcsfile=workpath+'/testforCUHK/arcs';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/arcs'
  pbasefile=workpath+'/pbase';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/pbase'
  dvddhfile=workpath+'/testforCUHK/dvddh';/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/testforCUHK/dvddh'
  vdhfile= workpath+'/testforCUHK/vdh'
  ptattrfile= workpath+'/testforCUHK/ptattr'
  
  refind=62186; Reference point's index for TSX_PS_Tianjin
  ref_v=0
  ref_dh=0
  weight=0  ; 0: coh
  ; 1: sigma
  ; 2: both
  mask_arc= 0.5
  mask_pt_coh= 0.5
  v_acc= 10 ; Accuracy threshold of deformation velocity: mm/yr
  dh_acc= 10 ; Accuracy threshold of hight error: m
  
  ; Arbitrarily choose one point
  pt_ind=0
  path_coor= TLI_INTEGRATED_PATH(ptattrfile, plistfile, pt_ind, refind)
  
  ; Extract path info.
  dvddh= TLI_READDATA(dvddhfile, samples=6, format='DOUBLE')
  sz= SIZE(path_coor,/DIMENSIONS)
  path_info=DBLARR(6)
  FOR i=0, sz[1]-2 DO BEGIN
    startpt_ind= path_coor[0,i]>path_coor[0,i+1] ; Large index.
    endpt_ind= path_coor[0,i]<path_coor[0,i+1]   ; Small index.
    ; Find this arc
    arc_ind= WHERE(dvddh[0, *] EQ startpt_ind AND dvddh[1, *] EQ endpt_ind)
    path_info=[[path_info], [dvddh[*, arc_ind]]]
  ENDFOR
  path_info=path_info[*, 1:*]
  
  ; Integrating
  npt= sz[1]
  narc= npt-1
  startpt_ind=refind
  pt_info=CREATE_STRUCT('pt_ind', 0L, 'pt_x', 0.0, 'pt_y', 0.0, 'v', 0D, 'dh', 0D, 'weight', 0D, 'v_acc', 0D, 'h_acc', 0D )
  pt_attr= REPLICATE(pt_info, npt)
  pt_attr.pt_ind= REVERSE(TRANSPOSE(LONG(path_coor[0, *])))
  pt_attr.pt_x= REVERSE(TRANSPOSE(path_coor[1, *]))
  pt_attr.pt_y= REVERSE(TRANSPOSE(path_coor[2, *]))
  pt_attr[0].weight=1
  order= DBLARR(npt-1)+1
  
  ;[pt_ind, pt_x, pt_y, dv, ddh, weight, v_acc, h_acc]
  FOR i=1, npt-1 DO BEGIN ; i=0, info is set to default value.
    startpt_arc_info= path_info[*,i-1]
    IF startpt_arc_info[0] EQ startpt_ind THEN BEGIN ; start point of the arc is equal to startpt
      endpt= i
      startpt=i-1
      steps= i-1 ; Steps of the start point
      CASE weight OF
        0 : BEGIN ; Coh
          IF startpt_arc_info[4] GT mask_arc THEN BEGIN ; Here is the problem: this point's information mostly depends on the former information, not itself exactly
            pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[4]/(steps+1)
            this_arc_weight=startpt_arc_info[4]
          ENDIF ELSE BEGIN
            pt_weight=0
          ENDELSE
        END
        
        1: BEGIN ; Sigma
          IF startpt_arc_info[5] LT mask_arc THEN BEGIN
            pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[5]/(maxsigma*(steps+1))
            this_arc_weight=startpt_arc_info[5]/maxsigma
          ENDIF ELSE BEGIN
            pt_weight=0
          ENDELSE
        END
        
        2: BEGIN
          mixedweight=startpt_arc_info[4]+startpt_arc_info[5]/maxsigma
          IF  mixedweight GT mask_arc THEN BEGIN
            pt_weight= pt_attr[startpt].weight/(steps+1)*steps+ mixedweight/(steps+1)
            this_arc_weight=mixedweight
          ENDIF ELSE BEGIN
            pt_weight=0
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
        
      pt_attr[endpt].weight=pt_weight
      
    ;      Print, 'Start point info:', pt_attr[startpt]
    ;      Print, 'Arc info:', startpt_arc_info
    ;      Print, 'End point info:', pt_attr[endpt]
      
    ENDIF ELSE BEGIN ; start point of the arc is not equal to startpt (start point index is larger than the reference point)
      order[i-1]=-1
      endpt= i
      startpt= i-1
      steps= i-1
      CASE weight OF
      
        0 : BEGIN ; Coh
          IF startpt_arc_info[4] GT mask_arc THEN BEGIN ; Here is the problem: this point's information mostly depends on the former information, not itself exactly
            pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[4]/(steps+1)
            this_arc_weight= startpt_arc_info[4]
            IF this_arc_weight GT 10.0 THEN STOP
          ENDIF ELSE BEGIN
            pt_weight=0
          ENDELSE
        END
        
        1: BEGIN ; Sigma
          IF startpt_arc_info[5] LT mask_arc THEN BEGIN
            pt_weight= pt_attr[startpt].weight / (steps+1)*steps+startpt_arc_info[5]/(maxsigma*(steps+1))
            this_arc_weight=startpt_arc_info[5]/maxsigma
          ENDIF ELSE BEGIN
            pt_weight=0
          ENDELSE
        END
        
        2: BEGIN
          mixedweight=startpt_arc_info[4]+startpt_arc_info[5]/maxsigma
          IF  mixedweight GT mask_arc THEN BEGIN
            pt_weight= pt_attr[startpt].weight/(steps+1)*steps+ mixedweight/(steps+1)
            this_arc_weight= mixedweight
          ENDIF ELSE BEGIN
            pt_weight=0
          ENDELSE
        END
        
      ENDCASE
      
      
      ; Deformation velocity and height error are updated first.
      ; Other information is not updated here.
      ;          pt_attr[endpt].v= pt_attr[startpt].v*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
      ;            - startpt_arc_info[2]*(pt_weight/(pt_weight*(steps+1)))  ; Update end node's attr. dv= small_ind-large_ind
      ;          pt_attr[endpt].dh= pt_attr[startpt].dh*((pt_attr[startpt].weight*steps)/(pt_weight*(steps+1))) $
      ;            - startpt_arc_info[3]*(pt_weight/(pt_weight*(steps+1)))
      pt_attr[endpt].v= pt_attr[startpt].v*((pt_attr[startpt].weight)/(pt_weight)) $
        + (1-pt_attr[startpt].weight/(pt_weight))*ref_v $
        - startpt_arc_info[2]* (this_arc_weight) $
        * (pt_attr[startpt].weight/(pt_weight))  ; Update end node's attr. dv= small_ind-large_ind
      pt_attr[endpt].dh= pt_attr[startpt].dh*((pt_attr[startpt].weight)/(pt_weight)) $
        + (1-pt_attr[startpt].weight/(pt_weight))*ref_dh $
        - startpt_arc_info[3]* (this_arc_weight) $
        * (pt_attr[startpt].weight/(pt_weight))  ; Update end node's attr. dv= small_ind-large_ind
      pt_attr[endpt].weight=pt_weight
      
      
      
    ;      Print, 'Start point info:', pt_attr[startpt]
    ;      Print, 'Arc info:', startpt_arc_info
    ;      Print, 'End point info:', pt_attr[endpt]
    ENDELSE
  ENDFOR
  Print, 'Order:  Start point info(v):   Arc info(v):   End point info(v):     '
  Print, [TRANSPOSE(order),TRANSPOSE(pt_attr[INDGEN(npt-1)].v),(path_info[2, *]),TRANSPOSE(pt_attr[INDGEN(npt-1)+1].v)]
  Print, 'Start point info(dh):    ', 'Arc info(dh):    ', 'End point info(dh):     '
  Print, [TRANSPOSE(order),TRANSPOSE(pt_attr[INDGEN(npt-1)].dh),(path_info[3, *]),TRANSPOSE(pt_attr[INDGEN(npt-1)+1].dh)]
  Print, '[MIN, MAX] of v', MIN(pt_attr.v), MAX(pt_attr.v)
  Print, '[MIN, MAX] of dh', MIN(pt_attr.dh), MAX(pt_attr.dh)
  
  ;  intpathfile=workpath+'/testforCUHK/int_path'
  ;  OPENW, lun, intpathfile,/GET_LUN
  ;  PRINTF, lun, path_coor
  ;  FREE_LUN, lun
  Print, 'Main pro finished!!'
END