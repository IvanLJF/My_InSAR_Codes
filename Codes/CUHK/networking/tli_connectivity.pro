;- Purpose:
;-     Rebuild connectivity of the input arcs array.
;- npt  : Number of points.
;- arcs : Arcs array. [startind endind ...]
Function TLI_CONNECTIVITY, npt, arcs
  ;- Create connectivity among plist.
  npt= DOUBLE(npt)
  arcs_start= arcs[0, *]
  arcs_end= arcs[1,*]
  arcs_repeat_start=[[arcs_start], [arcs_end]]
  arcs_repeat_end= [[arcs_end], [arcs_start]]
  arcs_repeat_sort_ind= SORT(arcs_repeat_start)
  arcs_repeat_start= arcs_repeat_start[*, arcs_repeat_sort_ind]
  arcs_repeat_end= arcs_repeat_end[*, arcs_repeat_sort_ind]
  arcs_repeat_uniq_ind= UNIQ(arcs_repeat_start); Create connectivities according to the start points' indices.
  arcs_repeat_uniq_ind= [0, arcs_repeat_uniq_ind+1] ; What a mess!!! I want uniq to start from 0.Attention, modified uniq is one element more than the original uniq.
  plist_single_num= npt-N_ELEMENTS(arcs_repeat_uniq_ind); single points number.
  
  connect= DBLARR(npt+1+N_ELEMENTS(arcs_repeat_start)+plist_single_num+1) ; Always remember to plus or minus 1 in IDL
  
  j=0D ; index for arcs_repeat_uniq_ind
  connect_before=npt+1
  connect_after=npt+1
  connect[0]=connect_before
  FOR i=0D, npt-1D DO BEGIN
  
    IF arcs_repeat_uniq_ind[j] NE N_ELEMENTS(arcs_repeat_end) THEN BEGIN ; Not the last element.
    
      IF arcs_repeat_start[arcs_repeat_uniq_ind[j]] GT i THEN BEGIN ; The first uniq nod's index is not equal to the first point's index.
        connect_after= connect_before+1
        connect[i+1]= connect_after
        connect[connect_before]=-1
        connect_before= connect_after
      ENDIF ELSE BEGIN
        p_nconnect= arcs_repeat_uniq_ind[j+1]-arcs_repeat_uniq_ind[j] ; There are p_nconnect points connected to the i-th point.
        connect_after= connect_before+p_nconnect
        connect[i+1]= connect_after
        connect[connect_before: (connect_after-1)]=arcs_repeat_end[arcs_repeat_uniq_ind[j]:(arcs_repeat_uniq_ind[j+1]-1)] ; Connectivities of the i-th point.
        ;        print,'i & should-be i:', i, arcs_repeat_start[arcs_repeat_uniq_ind[j]]
        j=j+1 ; j++
        connect_before= connect_after
      ENDELSE
      
    ENDIF ELSE BEGIN ; The last element.
    
      connect_after= connect_before+1
      connect[i+1]= connect_after
      connect[connect_before]=-1
      connect_before= connect_after
    ENDELSE
    
  ENDFOR
  
  RETURN, LONG(connect)
  
END