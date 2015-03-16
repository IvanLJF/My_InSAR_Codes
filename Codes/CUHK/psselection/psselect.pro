PRO PSSELECT

  infile= '/mnt/software/ForExperiment/TSX_SH_IPTA_Piece/plist';Plist contains .rslc files with size of 2700*2000
  n_lines= FILE_LINES(infile)
  infiles= STRARR(n_lines)
  OPENR, lun, infile,/GET_LUN
  READF, lun, infiles
  FREE_LUN, lun
  tempmaster= infiles(0)
  r=500L
  ss=READ_PARAMS(tempmaster+'.par','samples')
  ls=READ_PARAMS(tempmaster+'.par', 'lines')
  tile_s= FLOOR(ss/r)
  tile_l= FLOOR(ls/r)
  IF ~(ss MOD r) THEN tile_s= tile_s-1
  IF ~(ls MOD r) THEN tile_l= tile_l-1
  a= FLTARR(r,r,n_lines)
  plist=COMPLEX(0,0)
  FOR i=0D,tile_s DO BEGIN
  PRINT, STRING(i)+'/'+STRING(tile_s)
    FOR j=0D, tile_l DO BEGIN
      s_start= i*r & l_start= j*r 
      PRINT, s_start,l_start
      temp=r    
      FOR k=0, n_lines-1 DO BEGIN
        b= SUBSETSLC(infiles(k),s_start, temp, l_start, temp)   
        sz= SIZE(b,/DIMENSIONS)
        a[0:sz(0)-1,0:sz(1)-1,k]=b 
      ENDFOR      
      result= DETECTPS(a, thr=0.35)
      x= REAL_PART(result)+s_start
      y= IMAGINARY(result)+l_start
      plist=[plist, COMPLEX(x,y)]      
    ENDFOR
  ENDFOR
  plist=plist[1:*]
  PRINT, size(plist,/N_ELEMENTS)
  outfile= '/mnt/software/ForExperiment/TSX_SH_IPTA_Piece/plist.dat'
  OPENW, lun, outfile,/GET_LUN
  WRITEU, lun, plist
  FREE_LUN, lun


  ;display
  outfile= '/mnt/software/ForExperiment/TSX_SH_IPTA_Piece/plist.dat'
  plist= COMPLEXARR(PNUMBER(outfile))
  OPENR, lun, outfile,/GET_LUN
  READU, lun, plist
  FREE_LUN, lun
  pwr= ABS(OPENSLC(tempmaster))
  scale= 0.35
  sz=SIZE(pwr,/DIMENSIONS)
  pwr= CONGRID(pwr,sz(0)*scale, sz(1)*scale)
;  pwr= ROTATE(pwr, 5)
  ps_index_s= REAL_PART(plist)*scale
  ps_index_l= IMAGINARY(plist)*scale
  WINDOW, xpos=0, ypos=0, xsize=sz(0)*scale, ysize=sz(1)*scale,0 & TVSCL, linear2(pwr)
  PLOTS, ps_index_s, ps_index_l, psym=1, symsize=1, COLOR=200,/DEVICE

END

FUNCTION DETECTPS, SLCS, thr=thr
    
    IF ~KEYWORD_SET(thr) THEN thr=0.25
        ; PS detection begin. For speed, input params are not verified.
      sz=SIZE(SLCS,/DIMENSIONS)
      mean_pwr= FLTARR(sz(0), sz(1))
      var_pwr= mean_pwr
      SLCS= DOUBLE(SLCS)
      FOR k=0, sz(2)-1 DO BEGIN; Get mean value of all points
        mean_pwr= mean_pwr+ ABS(SLCS[*,*,k])/sz[2]
      ENDFOR
      FOR k=0, sz(2)-1 DO BEGIN; Get std value of all points
        var_pwr= var_pwr+ (ABS(SLCS[*,*,k])-mean_pwr)^2/(sz[2]-1)
      ENDFOR
      result= SQRT(var_pwr)/mean_pwr
      resulta= WHERE(result LT thr);-------------------------D/M------------------------
      resultb= WHERE(mean_pwr GE MEAN(mean_pwr));----------------------Amplitude------------------
      result= FW_ARRAY_UID(resulta, resultb, /intersection);---------------Intersection-----------------------
      ; change result to true coor.
      x= result MOD sz(1)
      y= result/sz(0)
      result= COMPLEX(x,y)
      RETURN, result      
      
END
