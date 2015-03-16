PRO TLI_LS_DVDDH_ML, mfile,dvddhfile, plistfile, vdhfile, weighted=weighted
  ; Write the m file which will be used to do LS estimation for v & dh.
  IF NOT KEYWORD_SET(weighted) THEN weighted = 0
  OPENW, lun, mfile,/GET_LUN
  PrintF, lun, "%function tli_ls_dvddh"
  PrintF, lun, "% Solve v and dh using a least square estimation."
  PrintF, lun, "clear;"
  PrintF, lun, "clc;"
  PrintF, lun, ""
  PrintF, lun, "if 1"
  PrintF, lun, "    dvddhfile='"+dvddhfile+"';"
  PrintF, lun, "    plistfile='"+plistfile+"';"
  PrintF, lun, "    vdhfile='"+vdhfile+"';"
  PrintF, lun, "    weighted="+STRCOMPRESS(weighted,/REMOVE_ALL)+";"
  PrintF, lun, "end"
  PrintF, lun, ""
  PrintF, lun, "if 0"
  PrintF, lun, "    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023/HPA/';"
  PrintF, lun, "    dvddhfile=[workpath,'dvddh'];"
  PrintF, lun, "    plistfile=[workpath,'plist'];"
  PrintF, lun, "    vdhfile=[workpath, 'vdh_matlab'];"
  PrintF, lun, "    weighted=1;"
  PrintF, lun, "end"
  PrintF, lun, ""
  PrintF, lun, "if 0"
  PrintF, lun, "    workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin/HPA/';"
  PrintF, lun, "    dvddhfile=[workpath,'dvddh_update_sort'];"
  PrintF, lun, "    plistfile=[workpath,'dvddh_update.plist'];"
  PrintF, lun, "    vdhfile=[workpath, 'vdh_matlab_weighted'];"
  PrintF, lun, "    weighted=1;"
  PrintF, lun, "end"
  PrintF, lun, ""
  PrintF, lun, "% read dvddh file"
  PrintF, lun, "samples=6;"
  PrintF, lun, "finfo=dir(dvddhfile);"
  PrintF, lun, "fsize=finfo.bytes;"
  PrintF, lun, "lines=fsize/samples/8;"
  PrintF, lun, "fid=fopen(dvddhfile, 'r');"
  PrintF, lun, "dvddh=fread(fid, [samples, lines], 'double'); % IDL -> Matlab. Data transpose."
  PrintF, lun, "fclose(fid);"
  PrintF, lun, ""
  PrintF, lun, "% read plist file"
  PrintF, lun, "samples=2;"
  PrintF, lun, "finfo=dir(plistfile);"
  PrintF, lun, "fsize=finfo.bytes;"
  PrintF, lun, "lines=fsize/samples/4;"
  PrintF, lun, "fid=fopen(plistfile, 'r');"
  PrintF, lun, "plist=fread(fid, [samples, lines], 'float'); "
  PrintF, lun, "fclose(fid);"
  PrintF, lun, ""
  PrintF, lun, "% Prepare for LS estimation."
  PrintF, lun, "[~, narcs]=size(dvddh);"
  PrintF, lun, "finfo=dir(plistfile);"
  PrintF, lun, "fsize=finfo.bytes;"
  PrintF, lun, "npt=fsize/8;"
  PrintF, lun, "% Define the line header info of dvddh."
  PrintF, lun, "start_ind=dvddh(1, :)+1;  % All the indices from IDL start at 0, not 1."
  PrintF, lun, "start_val=zeros(1,narcs)-1;"
  PrintF, lun, "end_ind=dvddh(2, :)+1;% All the indices from IDL start at 0, not 1."
  PrintF, lun, "end_val=zeros(1,narcs)+1;"
  PrintF, lun, "dv=transpose(dvddh(3, :));"
  PrintF, lun, "ddh=transpose(dvddh(4, :));"
  PrintF, lun, "coh=dvddh(5, :)';"
  PrintF, lun, "sigma=dvddh(6, :)';"
  PrintF, lun, ""
  PrintF, lun, "% Create the sparse matrix."
  PrintF, lun, "lines=1:1:narcs;"
  PrintF, lun, "i=[lines, lines];"
  PrintF, lun, "j=[start_ind, end_ind];"
  PrintF, lun, "s=[start_val, end_val];"
  PrintF, lun, "coefs=sparse(i,j,s,narcs, npt);"
  PrintF, lun, ""
  PrintF, lun, "if weighted == 0"
  PrintF, lun, "    v=coefs\dv;"
  PrintF, lun, "    dh=coefs\ddh;"
  PrintF, lun, "else"
  PrintF, lun, "    "
  PrintF, lun, "    % weighted LS estimation"
  PrintF, lun, "    p=sparse(1:narcs, 1:narcs, coh);"
  PrintF, lun, "    temp=(transpose(coefs)*p*coefs)\(transpose(coefs)*p);"
  PrintF, lun, "    v=temp*dv;"
  PrintF, lun, "    dh=temp*ddh;"
  PrintF, lun, "    "
  PrintF, lun, "    %     temp=(transpose(coefs)*p*coefs)\(transpose(coefs)*p);"
  PrintF, lun, "    %     v=temp*dv;"
  PrintF, lun, "    %     dh=temp*ddh;"
  PrintF, lun, ""
  PrintF, lun, "end"
  PrintF, lun, "% Write vdh file."
  PrintF, lun, "result=[0:1:npt-1; plist(1,:); plist(2,:); transpose(v);transpose(dh)];"
  PrintF, lun, "result=double(result);"
  PrintF, lun, ""
  PrintF, lun, "fid=fopen(vdhfile, 'w');"
  PrintF, lun, "fwrite(fid, result, 'double');"
  PrintF, lun, "fclose(fid);"
  PrintF, lun, ""
  PrintF, lun, "%tli_write(vdhfile, result,'double');"
  PrintF, lun, ""
  PrintF, lun, "disp('Main pro finished.')"
  FREE_LUN, lun
END

FUNCTION TLI_SPARSE_DVDDH, dvddhfile_sort, max_ind=max_ind
  ; Create the sparse matrix for input file.
  ; Make sure that the diagnal elements are not 0.
  dvddh=TLI_READMYFILES(dvddhfile_sort, type='dvddh')
  sz=SIZE(dvddh,/DIMENSIONS)
  narcs=sz[1]
  
  IF NOT KEYWORD_SET(max_ind) THEN max_ind=MAX(dvddh[0:1, *])
  ; First create the matrix according to dvddhfile
  refind=dvddh[0, *]
  adjind=dvddh[1, *]
  dv=dvddh[2, *]
  ddh=dvddh[3, *]
  coh=dvddh[4, *]
  sigma_phi=dvddh[5, *]
  row=[DINDGEN(narcs), DINDGEN(narcs)]  ; Should be sorted first????////////////////////////////
  col=[TRANSPOSE(refind), TRANSPOSE(adjind)]
  val=[DINDGEN(narcs)-1, DINDGEN(narcs)+1]
  ; Second add the diagnol elements.
  n_comp=narcs-(max_ind+1)
  row=[row, DINDGEN(n_comp)+max_ind+1]
  col=[col, DINDGEN(n_comp)+max_ind+1]
  ;  val=[val, DBLARR(n_comp)+1];//////////////////////////////////////
  val=[val, DBLARR(n_comp)]
  dv=[TRANSPOSE(dv)]
  ddh=[TRANSPOSE(ddh)]
  ; Return the result
  dvddh_str=CREATE_STRUCT('row',row, 'col',col, 'val', val, 'dv', dv, 'ddh', ddh, 'coh', coh, 'sigma_phi', sigma_phi)
  RETURN, dvddh_str
END

FUNCTION TLI_IND_COMPLEMENT, inputind, max_ind=max_ind
  ; Find the missed index for inputind. The whole index sequence should be LINDGEN(max_ind).
  IF NOT KEYWORD_SET(max_ind) THEN max_ind=MAX(inputind)
  ; Check if the inputind is sorted or not.
  nind=N_ELEMENTS(inputind)
  sort_ind=SORT(inputind)
  IF TOTAL(ABS(sort_ind-DINDGEN(nind))) NE 0 THEN Message, 'Error: inputind should be sorted first.'
  ; Shift the inputind
  sz=SIZE(inputind,/DIMENSIONS)
  samples=sz[0]
  IF N_ELEMENTS(sz) EQ 1 THEN lines=1 $
  ELSE lines=sz[1]
  IF lines EQ 1 THEN inputind_c=TRANSPOSE(inputind) $
  ELSE inputind_c=inputind   ; Make sure that the first element is 0 and the last is max_ind
  inputind_shift=SHIFT(inputind_c,0, 1)
  inputind_shift_diff=(inputind_c-inputind_shift)[1:*]
  non_one_ind=WHERE(inputind_shift_diff NE 1)
  IF non_one_ind[0] EQ -1 THEN RETURN, -1
  n_non_one=N_ELEMENTS(non_one_ind)
  result=0
  FOR i=0, n_non_one-1 DO BEGIN
    non_one_i=non_one_ind[i]
    result=[result, inputind[non_one_i]+DINDGEN(inputind_shift_diff[non_one_i]-1)+1]
  ENDFOR
  result=result[1:*]
  IF inputind[0] NE 0 THEN result=[DINDGEN(MIN(inputind)), result]
  IF inputind[nind-1] NE max_ind THEN result=[result, inputind[nind-1]+DINDGEN(max_ind-inputind[nind-1])+1]
  
  IF lines EQ 1 THEN RETURN, result $
  ELSE RETURN, TRANSPOSE(result)
END


PRO TLI_SORT_DVDDH, dvddhfile_update, outputfile=outputfile
  ;- Prepare the dvddh file for LS esitmation.
  ;- Before using this, please update the dvddh file using tli_update_dvddh.pro
  ;- Make sure that the diagonal is not zero
  ;
  dvddhfile=dvddhfile_update
  IF NOT KEYWORD_SET(outputfile) THEN outputfile=dvddhfile+'_sort'
  dvddh=TLI_READMYFILES(dvddhfile, type='dvddh')
  ref_ind=dvddh[0,*]
  adj_ind=dvddh[1,*]
  sz=SIZE(dvddh,/DIMENSIONS)
  result=DBLARR(sz)
  narcs=sz[1]
  
  ; Select the uniq adj_ind. Because the dvddh file is sorted according to adj_ind
  arc_msk=BYTARR(1, narcs)
  uniq_adj_ind=UNIQ(adj_ind)
  useful_adj_ind=adj_ind[*, uniq_adj_ind]
  arc_msk[uniq_adj_ind]=1
  
  result[*,useful_adj_ind]=dvddh[*, uniq_adj_ind];//////////////////////////
  
  ; Locate the missed adj_ind
  max_ind=MAX(dvddh[0:1, *])
  useful_adj_ind_miss=TLI_IND_COMPLEMENT( useful_adj_ind, max_ind=max_ind)
  
  ; Try to find the missed data from ref_ind
  n_miss=N_ELEMENTS(useful_adj_ind_miss)
  n_repeat_arc=0
  FOR i=0D, n_miss-1D DO BEGIN
    adj_ind_miss_i=useful_adj_ind_miss[i]
    miss_i= WHERE(ref_ind EQ adj_ind_miss_i AND arc_msk NE 1)
    
    IF miss_i[0] EQ -1 THEN BEGIN ; This point is only connected to one other point.
      miss_i=WHERE(ref_ind EQ adj_ind_miss_i)
      IF miss_i[0] EQ -1 THEN Message, 'This should never happen!!!!!'
      n_repeat_arc=n_repeat_arc+1
    ENDIF
    
    result[*, adj_ind_miss_i]=dvddh[*, miss_i[0]]
    arc_msk[miss_i[0]]=1
  ENDFOR
  
  ; Add the complemented data to result
  comp_ind=WHERE(arc_msk EQ 0)
  result[*, (max_ind+1-n_repeat_arc):*]=dvddh[*, comp_ind]
  
  ; Write the result
  TLI_WRITE, outputfile, result
  TLI_WRITE, outputfile+'.txt', result,/txt
END

PRO TLI_LS_DVDDH, plistfile, arcsfile, dvddhfile, weighted=weighted, $
                  plistfile_update=plistfile_update,vdhfile=vdhfile, logfile=logfile,coh=coh, sigma=sigma
    ; Least-squared estimation of the deformation rate map.
    ; 
    ; Parameters:
    ;   
    ; Keywords:
    ;   coh    : Coherence to mask the arcs
    ;   sigma  : Phase residues to mask the arcs
    ; 
    ; Written by:
    ;   T.LI @ ISEIS, CUHK.
    ;    
  COMPILE_OPT idl2
  workpath=FILE_DIRNAME(dvddhfile)+PATH_SEP()
  IF NOT KEYWORD_SET(logfile) THEN logfile=workpath+'log.txt'
  IF N_ELEMENTS(coh) EQ 0 THEN coh=0.8
  IF NOT KEYWORD_SET(sigma) THEN sigma=1000D
;  IF NOT KEYWORD_SET(sigma) THEN sigma=2*!PI
  TLI_LOG, logfile, ''
  TLI_LOG, logfile, 'Using LS estimation instead of region growing to solve the integrated v & dh.'
  TLI_LOG, logfile, 'Start at time:'+TLI_TIME(/str)
  
  IF NOT KEYWORD_SET(weighted) THEN weighted=0
  IF KEYWORD_SET(weighted) THEN TLI_LOG, logfile, 'Warning: Large quantities of memory will be occupied.'
  IF NOT KEYWORD_SET(plistfile_update) THEN plistfile_update=plistfile+'update'
  IF NOT KEYWORD_SET(vdhfile) THEN vdhfile=workpath+'vdh'
  
  dvddhfile_update=dvddhfile+'_update'
  dvddhfile_sort=dvddhfile_update+'_sort'
  mfile=workpath+'tli_ls_dvddh.m'
  
  TLI_LOG, logfile, '************************************************************'
  TLI_LOG, logfile, 'Calculate the v & dh for each point using LS estimation.'
  TLI_LOG, logfile, 'Start at time:'+TLI_TIME(/str)
  
  IF 1 THEN BEGIN
    npt= TLI_PNUMBER(plistfile)
    ; First update dvddh file. Discriminate the useless points.
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'Step 1: Update the dvddh file. Eliminate the useless points.'
    TLI_LOG, logfile, 'Time:'+TLI_TIME(/str)
    
    TLI_LOG, logfile, ''
    TLI_LOG, logfile, 'The parameters to reject arcs with low quality: '
    TLI_LOG, logfile, 'Coherence:'+STRING(coh)
    TLI_LOG, logfile, 'Sigma:'+STRING(sigma)
    TLI_UPDATE_DVDDH, plistfile, dvddhfile, coh=coh, sigma=sigma, keep_zero=keep_zero, $
      plistfile_update=plistfile_update, dvddhfile_update=dvddhfile_update
    TLI_LOG, logfile, 'Point number before optimization:'+STRCOMPRESS(TLI_PNUMBER(plistfile)),/prt
    TLI_LOG, logfile, 'Point number after optimization:'+STRCOMPRESS(TLI_PNUMBER(plistfile_update)),/prt
    TLI_LOG, logfile, 'From now on, the plist file to be use will be '+plistfile_update
  ENDIF
  ;  ; Second, sort the dvddhfile to make sure rank(coefs)=n.
  ;  TLI_LOG, logfile, ''
  ;  TLI_LOG, logfile, 'Step2: Sort the dvddhfile to make sure that rank(coefs)=n.'
  ;  TLI_SORT_DVDDH,  dvddhfile_update, outputfile=dvddhfile_sort
  
  
  TLI_LOG, logfile, ''
  TLI_LOG, logfile, 'Call matlab to do LS estimation.'
  TLI_LOG, logfile, 'The m file is located at : "'+mfile+'"'
  TLI_LS_DVDDH_ML,mfile,dvddhfile_update, plistfile_update, vdhfile, weighted=0
  
  mfile_path=FILE_DIRNAME(mfile)
  CD, current=currpath
  CD, mfile_path
  matlab_cmd='matlab -nodesktop -nosplash -nojvm <"'+mfile+'"'
  Print, matlab_cmd
  SPAWN, matlab_cmd
  CD, currpath
  IF 0 THEN BEGIN  ; Draw the result.
    rasfile=workpath+'ave.ras'
    sarlistfile=workpath+'sarlist_Linux'
    minus=1
    show=1
    fliph_image=1
    fliph_pt=1
    
    ;      npt=TLI_PNUMBER(plistfile)
    ;      v=TLI_READDATA(v_file,lines=3, format='DOUBLE')
    ;      dh=TLI_READDATA(dh_file, lines=3, format='DOUBLE')
    ;      npt_useful=FILE_LINES(v_file+'.txt')
    ;      vdh=[DINDGEN(1,npt_useful), TRANSPOSE(v), (TRANSPOSE(dh))[2, *]]
    ;      TLI_WRITE, vdhfile, vdh
    
    TLI_PLOT_LINEAR_DEF, vdhfile, rasfile, sarlistfile, $
      outputfile=outputfile,xsize=xsize, ysize=ysize, ptsize=ptsize,noframe=noframe, $
      tick_major=tick_major,tick_minor=tick_minor,refine=refine,delta=delta,show=show, maxv=maxv, minv=minv, $
      fliph_pt=fliph_pt, fliph_image=fliph_image, flipv_image=flipv_image, no_clean=no_clean, los_to_v=los_to_v,$
      no_colorbar=no_colorbar,unit=unit,compress=compress, percent=percent,overwrite=overwrite,cpt=cpt, intercept=intercept,$
      dpi=dpi, minus=minus,colorbar_interv=colorbar_interv
  ENDIF
  
  ;  FILE_DELETE, dvddhfile_update, mfile
  Print, 'Main Pro finished!'
  
END