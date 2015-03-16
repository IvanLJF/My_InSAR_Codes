;
; Script that:
;   Read ROI file created using ENVI.
;
; Parameters
;   inputfile   : Input file to read. Must be an ASCII file.
;
; Written by:
;   T.LI @ SWJTU, 20140603
;
FUNCTION TLI_READ_ENVI_ROIS, inputfile

  IF NOT FILE_TEST(inputfile) THEN Message, 'File not exist: '+inputfile
  
  ; Get file header
  nlines=FILE_LINES(inputfile)
  txt=STRARR(1, nlines)
  OPENR, lun, inputfile,/GET_LUN
  READF, lun, txt
  FREE_LUN, lun
  temp=txt[1]
  nrois=LONG((STRSPLIT(temp, ':',/extract))[1])
  roi_stru=CREATE_STRUCT('nrois',nrois)
  
  ; Get ROI info.
  npts_all=0
  FOR i=0L, nrois-1L DO BEGIN
    temp=txt[0, 6+4*i]
    npts=LONG((STRSPLIT(temp, ':',/extract))[1])
    roi_stru=CREATE_STRUCT(roi_stru, 'npts'+STRCOMPRESS(i,/REMOVE_ALL), npts)
    npts_all=[npts_all, npts]
  ENDFOR
  npts_all=npts_all[1:*]
  
  ; Read data
  line_start=3+4*nrois+1
  FOR i=0L, nrois-1L DO BEGIN
    line_end=line_start+npts_all[i]
    roiinfo=txt[*, line_start:line_end-1]
    roiinfo=TLI_STRSPLIT(roiinfo)
    roiinfo=FLOAT(roiinfo)
    roi_stru_temp=CREATE_STRUCT('ID', roiinfo[0, *], $
      'X' , roiinfo[1, *], $
      'Y' , roiinfo[2, *], $
      'B1', roiinfo[3, *], $
      'B2', roiinfo[4, *], $
      'B3', roiinfo[5, *])
      
    roi_stru=CREATE_STRUCT(roi_stru, 'roi'+STRCOMPRESS(i,/REMOVE_ALL), roi_stru_temp)
    line_start=line_end+1
  ENDFOR
  RETURN, roi_stru
  
END