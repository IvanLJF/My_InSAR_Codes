@tli_plot_hpa
@tli_readdata
PRO TLI_HPA_PLOT_ALLFIGURES
  
  IF 0 THEN BEGIN
    ; Plot Figure 6. This is the result of level 10.
    workpath='/mnt/ihiusa/Software/ForExperiment/TSX_PS_Tianjin/HPA/'
    vdhfile=workpath+'lel10vdh_merge'
    rasfile=workpath+'ave.ras'
    sarlistfile=workpath+'sarlist'
    outputfile=workpath+'lel10_vdh_merge.tif'
    ptsize=0.005
    noframe=1
    maxv=0
    minv=-71.25
    fliph_pt=1
    fliph_image=1
    los_to_v=1
    minus=1
    cpt='rainbow'
    colorbar_interv=7
    dpi=800
    no_clean=1
    show=1
    
    tli_plot_linear_def, vdhfile, rasfile, sarlistfile, $
      outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
      tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
      fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
      no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
      dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
      
  ENDIF
  
  IF 0 THEN BEGIN
    ;Plot Figure 5. Hierarchical results.
    workpath='/mnt/data_tli/ForExperiment/TSX_PS_Tianjin/HPA/'
    
    hpapath=workpath
    level=10
    ptsize=0.005
    noframe=0
    maxv=0
    minv=-71.25
    fliph_pt=1
    fliph_image=1 
    los_to_v=1
    no_colorbar=1
    minus=1
    cpt='tli_def'
    
    TLI_PLOT_HPA, hpapath, level=level, $
      xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
      tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
      fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
      no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
      dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
  ENDIF
  
  IF 0 THEN BEGIN
    ; Plot figure 4. The integral paths.
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_RefCR05/'
    resultpath=workpath+'integral_paths'+PATH_SEP()
    IF ~FILE_TEST(resultpath,/DIRECTORY) THEN FILE_MKDIR, resultpath
    hpapath=workpath+'HPA'+PATH_SEP()
    logfile=resultpath+'log.txt'
    pathsfile=resultpath+'path'
    shfile=resultpath+'plot_paths.sh'
    loglun=TLI_OPENLOG(logfile)
    PRINTF, loglun, '*************************************************'
    PrintF, loglun, 'Extract integral paths for several points. Use a geocoded coordinate.'
    PrintF, loglun, 'Time start:'+(TLI_TIME(/str))
    PrintF, loglun, ''
    
    ptattrfile=hpapath+'ptattr'
    plistfile_orig=hpapath+'plist' ;- Use original plist to calculate the paths. While updated plist to locate the points.
    plistfile_update=hpapath+'plistupdate'
    itabfile=workpath+'itab'
    sarlistfile=workpath+'SLC_tab'
    pmapllfile=plistfile_orig  ;////////////////////////////////////////
    finfo=TLI_LOAD_MPAR(sarlistfile, itabfile)
    
    plist=TLI_READDATA(plistfile_orig,samples=1, format='FCOMPLEX')
    ; Locate the reference point.
    x_center=DOUBLE(finfo.range_samples)/2D
    y_center=DOUBLE(finfo.azimuth_lines)/2D
    cnter=COMPLEX(x_center, y_center)
    dis=ABS(plist-cnter)
    mindis=MIN(dis, refind)
    
    ; Specify the fixed refind
    refind=77907
    
    PrintF, loglun, 'Refind: '+STRING(refind)
    PrintF, loglun, 'Ref. coor: '+STRING(plist[refind])
    PrintF, loglun, 'Plistfile:'+plistfile_orig
    Print, 'Ref. Ind.:',refind
    Print, 'Ref. coor.:',plist[refind]
    ; Locate four points that are nearest to the four coners of the image.
    xmin=0
    xmax=finfo.range_samples-1
    ymin=0
    ymax=finfo.azimuth_lines-1
    ; Points to be analyzed
    ;  pts= COMPLEX([xmin, xmax, xmin,xmax],[ymin, ymax, ymax, ymin])
    ;    pts= COMPLEX([xmin, xmax, xmax, xmin],[ymin, ymax,  ymin, ymax])
    ;    pts= [pts, COMPLEX(0, finfo.azimuth_lines/2D)]
    pts= COMPLEX([16,xmin,xmax, xmax],[1864, ymax, ymin, ymax])
    npts=N_ELEMENTS(pts)
    plist_update=TLI_READDATA(plistfile_update, samples=1, format='FCOMPLEX')
    ;  pmapll=TLI_READDATA(pmapllfile, samples=1, format='FCOMPLEX',/swap_endian);///////////////////////////////////
    pmapll=TLI_READDATA(pmapllfile, samples= 1 , format='FCOMPLEX')    ;///////////////////////////////////
    pmapll=COMPLEX(finfo.range_samples, finfo.azimuth_lines)-pmapll    ;////////////////////////////////
    
    FOR i=0, npts-1 DO BEGIN
      ; Find the points in the updated plist
      dis=ABS(plist_update-pts[i])
      mindis=MIN(dis, pt_ind)
      ; Find the index in the original plist.
      ptcoor=plist_update[pt_ind]
      pt_ind=WHERE(plist EQ ptcoor)
      
      PrintF, loglun, ''
      PrintF, loglun, 'Point:'+STRING(i)
      PrintF, loglun, 'Point index:'+STRING(pt_ind)
      PrintF, loglun, 'Coor:'+STRING(plist[pt_ind])
      result=TLI_INTEGRATED_PATH(ptattrfile, plistfile_orig, pt_ind, refind)
      ind=result[0,*]
      pmap=pmapll[ind]
      lon=REAL_PART(pmap)
      lat=IMAGINARY(pmap)
      OPENW, lun, pathsfile+STRCOMPRESS(i,/REMOVE_ALL),/GET_LUN
      PrintF, lun, [lon, lat], format='(D18, D18)'
      FREE_LUN, lun
      OPENW, lun, pathsfile+STRCOMPRESS(i,/REMOVE_ALL)+'_mod',/GET_LUN
      nlons=N_ELEMENTS(lon)
      PRINTF, lun,[lon[*,0:nlons-2], lat[*,0:nlons-2]], format='(D18,D18)'
      FREE_LUN, lun
    ENDFOR
    
    ; Write the .sh file.
    OPENW, lun, shfile,/GET_LUN
    PrintF, lun, '#! /bin/sh'
    PrintF, lun, 'gmtset ANNOT_FONT_SIZE_PRIMARY 10p ANNOT_OFFSET_PRIMARY 0.07i FRAME_WIDTH 0.04i MAP_SCALE_HEIGHT 0.04i \'
    PrintF, lun, '       LABEL_FONT_SIZE 10p LABEL_OFFSET 0.05i TICK_LENGTH 0.05i GRID_PEN_PRIMARY 0.5p'
    PrintF, lun, ''
    PrintF, lun, 'outputfile=integral_paths.ps'
    PrintF, lun, 'psbasemap -R116.95583/117.11165/39.045850/39.179167 -JX5i/5i -Ba0.02f0.01g0.03::WeSn -P -K -V  >$outputfile'
    PrintF, lun, ''
    
    PrintF, lun, 'psimage ave.ras_repair.ras -Gtblack -W5i/5i -O -K -V >>$outputfile'
    FOR i=0,npts-1 DO BEGIN
      temp=FILE_BASENAME(pathsfile+STRCOMPRESS(i,/REMOVE_ALL))
      PrintF, lun, ''
      Case i OF
        0: BEGIN
          PrintF, lun, 'psxy '+temp+' -J -K -R -W0.03i/0/255/255 -O -V >> $outputfile'
          PrintF, lun, 'psxy '+temp+'_mod'+' -Gred -J -K -R -Sc0.05i -O -V -W0.001i >> $outputfile'
        END
        1: BEGIN
          PrintF, lun, 'psxy '+temp+' -J -K -R -W0.03i/255/255/0 -O -V >> $outputfile'
          PrintF, lun, 'psxy '+temp+'_mod'+' -Gred -J -K -R -Sc0.05i -O -V -W0.001i>> $outputfile'
        END
        2: BEGIN
          PrintF, lun, 'psxy '+temp+' -J -K -R -W0.03i/255/0/255 -O -V >> $outputfile'
          PrintF, lun, 'psxy '+temp+'_mod'+' -Gred -J -K -R -Sc0.05i -O -V -W0.001i>> $outputfile'
        END
        npts-1: BEGIN
          PrintF, lun, 'psxy '+temp+' -J -K -R -W0.03i/0/255/0 -O -V >> $outputfile'
          PrintF, lun, 'psxy '+temp+'_mod'+' -Gred -J -K -R -Sc0.05i -O -V -W0.001i>> $outputfile'
        END
        ELSE: BEGIN
          PrintF, lun, 'psxy '+temp+' -J -K -R -W0.03i/0/255/0 -O -V >> $outputfile'
          PrintF, lun, 'psxy '+temp+'_mod'+' -Gred -J -K -R -Sc0.05i -O -V -W0.001i>> $outputfile'
        END
      ENDCASE
    ENDFOR
    PrintF, lun, '# Add the reference point.'
    PrintF, lun, 'psxy -Gred -J -R -St0.1i -O -V -W0.01i << END >> $outputfile'
    PrintF, lun, [lon[nlons-1],lat[nlons-1]],format='(D18,D18)'
    PrintF, lun, 'END'
    
    
    PrintF, lun, 'ps2raster $outputfile'
    FREE_LUN, lun
    
    FREE_LUN, loglun
    Print, 'Main pro is finished.'
    
  ENDIF
  
  
  IF 0 THEN BEGIN
    ; Plot figure 3 ; The linear deformation rates map of the PTs. S1 is the subsidence funnel.
    workpath='/mnt/ihiusa/Software/ForExperiment/TSX_PS_Tianjin/HPA/'
    vdhfile=workpath+'vdh'
    lel10vdhfile=workpath+'lel10vdh_merge'
    rasfile=workpath+'ave.ras'
    sarlistfile=workpath+'sarlist'
    outputfile='Fig.3.tif'
    
    ;  temp=TLI_READMYFILES(lel10vdhfile,type='vdh')
    ;  v=temp[3,*]/cos(degree2radius(41.08))
    ;  print, min(v, max=maxv), maxv
    
    maxv=0
    minv=-71.25
    los_to_v=1
    show=1
    no_clean=1
    minus=1
    cpt='tli_def'
    fliph_pt=1
    fliph_image=1
    noframe=1
    ptsize=0.005
    TLI_PLOT_LINEAR_DEF, vdhfile, rasfile, sarlistfile, $
      outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
      tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
      fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
      no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
      dpi=dpi, minus=minus,colorbar_interv=7
  ENDIF
  
  IF 0 THEN BEGIN
    ; Provide Leveling points for Fig.2
    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/figures/'
    origfile=workpath+'ALL_JHG'
    
    outputfile=origfile+'_anno'
    nlines=FILE_LINES(origfile)
    anno=STRARR(1, nlines)
    OPENR, lun, origfile,/GET_LUN
    READF, lun, anno
    FREE_LUN, lun
    
    anno=TLI_STRSPLIT(anno)
    names=anno[0,*]
    x=FLOAT(5000-anno[1,*])-130
    y=FLOAT(6150-anno[2,*])+70
    result=STRCOMPRESS(x,/REMOVE_ALL)+' '+STRCOMPRESS(y,/REMOVE_ALL)+' 9 0 5 RT '+names
    
    OPENW, lun, outputfile,/GET_LUN
    PRINTF, lun, result
    FREE_LUN, lun
  ENDIF
  Print, 'Main pro finished!: Tli_hpa_plot_allfigures.pro'
END