;-
;- Extract some integral paths to plot figures
;- Using geocoded results.

@tli_test_rg_constraints.pro
PRO TLI_INTEGRAL_PATHS

  COMPILE_OPT idl2
  
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin'
  
  workpath=workpath+PATH_SEP()
  geocodepath=workpath+'geocode'+PATH_SEP()
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
  pmapllfile=geocodepath+'pt.pmapll' ; Use the pmapll file to extract integral path.
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
  refind=127700
  
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
  pts= COMPLEX([xmin, xmax, xmax],[ymin, ymax,  ymin])
  pts= [pts, COMPLEX(0, finfo.azimuth_lines/2D)]
  
  npts=N_ELEMENTS(pts)
  plist_update=TLI_READDATA(plistfile_update, samples=1, format='FCOMPLEX')
;  pmapll=TLI_READDATA(pmapllfile, samples=1, format='FCOMPLEX',/swap_endian);///////////////////////////////////
  pmapll=TLI_READDATA(pmapllfile, samples=1, format='FCOMPLEX')    ;///////////////////////////////////
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
  
  PrintF, lun, 'psimage ../geocode/noborder/ave.utm.rmli.ras -Gtblack -W5i/5i -O -K -V >>$outputfile'
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
END