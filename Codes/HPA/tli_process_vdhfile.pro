PRO TLI_PROCESS_VDHFILE, vdhfile,sarlistfile,outputfile=outputfile,minus=minus, los_to_v=los_to_v, v=v, dh=dh, vdhinfo=vdhinfo
  
  IF KEYWORD_SET(v) + KEYWORD_SET(dh) EQ 0 THEN v=1
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=vdhfile+'_processed'
  
  finfo=TLI_LOAD_SLC_PAR_SARLIST(sarlistfile)
  
  vdh=TLI_READMYFILES(vdhfile, type='vdh')
  v=vdh[3,*]
  dh=vdh[4,*]
  
  minv=MIN(v, max=maxv)
  mindh=MIN(dh, max=maxdh)
  
  vdhinfo= CREATE_STRUCT('origv','minv:'+STRCOMPRESS(minv)+' maxv:'+STRCOMPRESS(maxv),  $
                         'origdh', 'mindh:'+STRCOMPRESS(mindh)+' maxdh:'+STRCOMPRESS(maxdh))
                         
  
  IF KEYWORD_SET(v) THEN BEGIN
    IF KEYWORD_SET(los_to_v) THEN BEGIN ; change the deformation rate from LOS to vert. With a precondition that there are no horizonal vert.
      v=v/COS(DEGREE2RADIUS(finfo.incidence_angle))
      minv=MIN(v, max=maxv)  
      vdhinfo=CREATE_STRUCT(vdhinfo, 'los_to_v','minv:'+STRCOMPRESS(minv)+' maxv:'+STRCOMPRESS(maxv))
    ENDIF ELSE BEGIN
      vdhinfo=CREATE_STRUCT(vdhinfo, 'los_to_v','Step is ignored.')
    ENDELSE
    IF KEYWORD_SET(minus) THEN BEGIN
      v=v-maxv
      minv=MIN(v, max=maxv)
      vdhinfo=CREATE_STRUCT(vdhinfo, 'minusv', 'minv:'+STRCOMPRESS(minv)+' maxv:'+STRCOMPRESS(maxv))
    ENDIF ELSE BEGIN
      vdhinfo=CREATE_STRUCT(vdhinfo, 'minusv','Step is ignored.')
    ENDELSE
  ENDIF
  
  IF KEYWORD_SET(dh) THEN BEGIN
    IF KEYWORD_SET(minus) THEN BEGIN
      dh=dh-maxdh
      mindh=MIN(dh, max=maxdh)
      vdhinfo=CREATE_STRUCT(vdhinfo, 'minusdh', 'mindh:'+STRCOMPRESS(mindh)+' maxdh:'+STRCOMPRESS(maxdh))
    ENDIF ELSE BEGIN
      vdhinfo=CREATE_STRUCT(vdhinfo, 'minusdh', 'Step is ignored.')
    ENDELSE
  ENDIF
  
  vdh[3, *]=v
  vdh[4, *]=dh
  
  TLI_WRITE, outputfile, vdh
END