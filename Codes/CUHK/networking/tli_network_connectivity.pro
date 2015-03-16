PRO TLI_NETWORK_CONNECTIVITY

  Case 1 OF  ; Experimental data.
    1: BEGIN  ; Use the true data.
      workpath='/mnt/data_tli/Connectivity/'
      arcsfile=workpath+'arcs'
      plistfile=workpath+'plist'
      npt=TLI_PNUMBER(plistfile)
      arcs=TLI_READMYFILES(arcsfile, type='arcs')
      arcs=[REAL_PART(arcs[2,*]), IMAGINARY(arcs[2,*])]   ;[start_indices, end_indices]
    END
    ;
    0: BEGIN  ; Two networks in the arcs.
      arcs=Transpose([[1,2,3,9,10,11],[0,0,0,8,8,8]]);[start_indices, end_indices]
      Print, 'Arcs:', arcs
      npt=12
    END
    
    0: BEGIN  ; Three networkds in the arcs.
      arcs=Transpose([[1,2,3,5,9,10,11],[0,0,0,4,8,8,8]]);[start_indices, end_indices]
      npt=12
    END
    
    0: BEGIN ; One networks in the arcs
      arcs=Transpose([[1,2,3,8,9,10,11],[0,0,0,3,8,8,8]]);[start_indices, end_indices]
      npt=12
    END
  ENDCASE
  
  
  
  
  ; Give the original connectivities, using the structure the same as triangulate.pro.
  connect_orig=TLI_CONNECTIVITY(npt, arcs)
  
  ; Update the connectivities.
  pt_mask=DBLARR(npt)
  over=0
  ncluster=1  ; number of point clusters.
  start_ind=0
  npt_checked=1
  single_point=0
  
  pt_mask[start_ind]=ncluster
  pt_checked_mask=BYTARR(npt)
  pt_checked_mask[start_ind]=1
  WHILE NOT over DO BEGIN
  
    ; Number of start index
    npt_start=N_ELEMENTS(start_ind)
    all_child_nodes=0
    FOR i=0, npt_start-1 DO BEGIN
      ; Start index
      start_ind_i=start_ind[i]
      ; End index
      
      pt_end=connect_orig[connect_orig[start_ind_i]:connect_orig[start_ind_i+1]-1]  ; The child nodes.
      
      IF pt_end[0] EQ -1 THEN BEGIN ; An isolated point.
        ; Do nothing
        single_point=1
        BREAK
      ENDIF
      
      pt_mask[pt_end]=ncluster
      npt_checked=N_ELEMENTS(where(pt_checked_mask EQ 1))
      
      
      IF npt_checked EQ npt THEN BEGIN
        over=1
        BREAK
      ENDIF
      
      all_child_nodes=[all_child_nodes, pt_end]
      
    ENDFOR
    
    IF NOT over THEN BEGIN
      IF single_point THEN BEGIN
        pt_not_checked=WHERE(pt_checked_mask EQ 0)
        IF pt_not_checked[0] EQ -1 THEN BEGIN
          over=1
          Print, 'Connectivities update: Finished!'
          Break
        ENDIF ELSE BEGIN
          start_ind=pt_not_checked[0]
          pt_checked_mask[start_ind]=1  ; Update the mask
          single_point=0
          CONTINUE
        ENDELSE
      ENDIF
      all_child_nodes=all_child_nodes[1:*]
      all_child_nodes=all_child_nodes[SORT(all_child_nodes)]
      all_child_nodes=all_child_nodes[UNIQ(all_child_nodes)] ; Eliminate the duplicate points.
      child_ind=WHERE(pt_checked_mask[all_child_nodes] EQ 0)
      
      IF child_ind[0] EQ -1 THEN BEGIN ; A new point cluster is found.
        ncluster=ncluster+1
        pt_not_checked=WHERE(pt_checked_mask EQ 0)
        start_ind=pt_not_checked[0]
        pt_checked_mask[start_ind]=1  ; Update the mask
      ENDIF ELSE BEGIN
      
        all_child_nodes=all_child_nodes[child_ind]  ; Eliminate the checked points.
        
        start_ind=all_child_nodes
        pt_checked_mask[start_ind]=1  ; Update the mask
      ENDELSE
    ENDIF
    
    npt_checked=N_ELEMENTS(where(pt_checked_mask EQ 1))
    Print, 'No. of checked points:',npt_checked
  ENDWHILE
  
  Print, 'No. of networks in the arcs file:', MAX(pt_mask)
  FOR i=0, MAX(pt_mask) DO BEGIN
    temp=WHERE(pt_mask EQ i)     ; Point indices for the i-th network.
    Case i OF
      0: BEGIN
        IF temp[0] EQ -1 THEN BEGIn
          Print, 'No. of isolated points:', 0
        ENDIF ELSE BEGIN
          Print, 'No. of isolated points:', STRCOMPRESS(N_ELEMENTS(temp))
        ENDELSE
      END
      else: Print, 'Points No. in network',STRCOMPRESS(i), '   :', STRCOMPRESS(N_ELEMENTS(temp))+'/'+STRCOMPRESS(LONG(npt))
    ENDCASE
  ENDFOR
  
  
  
END