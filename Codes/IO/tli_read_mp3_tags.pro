PRO TLI_READ_MP3_TAGS
  
  mp3file='E:\Music\00000.mp3'
  
  finfo=FILE_INFO(mp3file)
  fsize=finfo.size
  
  ftagsize=128*8
  ftag_start=fsize-ftagsize+1
  
  taginfo=CREATE_STRUCT('version'  , '   '                            ,  $ ; 3字节，存放TAG字符，表示ID3 v1.0标准，紧接其后的是歌曲信息
                        'name'     , '                              ' ,  $ ; 30字节，歌名
                        'singers'  , '                              ' ,  $ ; 30字节，作者
                        'album'    , '                              ' ,  $ ; 30字节，专辑名
                        'year'     , '    '                           ,  $ ; 4字节，年份 
                        'remark'   , '                              ' ,  $ ; 30字节，附注
                        'type'     , ' '                                 ) ; MP3音乐类别，共147种。
  
  OPENR, lun, mp3file,/GET_LUN
  POINT_LUN, lun, ftag_start
  
  READU, lun, taginfo
  FREE_LUN, lun
  
  STOP

END