;+
;:Description:
;    解析ENVI的HDR头文件模块
;    很早之前程序里面用到的一个模块，功能不太完善哈，
;    没有添加错误判断，需要的自己添加下 ^_^
;
; Author: DYQ 整理于 2009-3-17;
;
; E-Mail: dongyq@esrichina-bj.cn
; MSN：dongyq@esrichina-bj.cn
;-
;
;读取HDR文件
;
PRO  Read_envi_hdr,hdrfile, samples = samples, $
    lines = lines, min_lon = min_lon,max_lon = max_lon, $
    min_lat = min_lat,max_lat = max_lat
    
    
  Hdr_Label='';
  data='';
  samples=0L
  lines=0L
  bands=0L
  headeroffset=0L;
  datatype=0L;
  interleave=''
  
  OPENR,hdrf,hdrfile,/GET_LUN;
  READF,hdrf,Hdr_Label ;
  Hdr_Label= STRLOWCASE(Hdr_Label);
  Hdr_Label=STRTRIM(Hdr_Label);
  IF( Hdr_Label NE 'envi') THEN BEGIN
    temp = DIALOG_MESSAGE('文件格式错误！',/Warning)
  END
  chara=''
  
  WHILE ~EOF(hdrf) DO BEGIN
    READF,hdrf,data
    
    chara=STRMID(data,0,STRPOS(data,'='))
    chara=STRTRIM(chara);
    chara=STRLOWCASE(chara)
    
    CASE chara OF
      'description': BREAK
      
      'samples':  temp_samples=STRMID(data,STRPOS(data,'=')+1)
      
      'lines':  temp_lines=STRMID(data,STRPOS(data,'=')+1)
      
      'bands': bands=STRMID(data,STRPOS(data,'=')+1)
      
      'headeroffset': headroffset=STRMID(data,STRPOS(data,'=')+1)
      
      'filetype': filetype=STRMID(data,STRPOS(data,'=')+1)
      
      'data type': datatype=STRMID(data,STRPOS(data,'=')+1)
      
      'interleave': interleave=STRMID(data,STRPOS(data,'=')+1)
      
      'map info': BEGIN ;提取经纬度信息
        InfoString = STRMID(data,STRPOS(data,'=')+1)
        Info = Strsplit(data,',',/extract)
        Min_lon = FLOAT(Info[3])
        Max_lon = Min_lon+ temp_samples*FLOAT(info[5])
        
        Max_lat = FLOAT(Info[4])
        Min_lat =  Max_lat- temp_lines*FLOAT(info[6])
      END
      ELSE:
    ENDCASE
  ENDWHILE
  
  FREE_LUN,hdrf
  
  
END